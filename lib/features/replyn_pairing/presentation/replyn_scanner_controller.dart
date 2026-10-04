import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nivex_flutter/features/replyn_pairing/data/camera_permission_gateway.dart';
import 'package:nivex_flutter/features/replyn_pairing/data/qr_camera.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_pairing_request.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_qr_parser.dart';

enum ReplynScanPhase {
  checkingPermission,
  requestingPermission,
  permissionDenied,
  permissionPermanentlyDenied,
  startingCamera,
  scanning,
  processing,
  rejected,
  awaitingConfirmation,
  unsupported,
  cameraFailed,
}

/// Drives the Replyn scanner: permission, camera, and what happens to each
/// scanned code. Only one code is handled at a time; the camera is paused or
/// released whenever the screen is not actively scanning.
class ReplynScannerController extends ChangeNotifier {
  ReplynScannerController({
    required this.camera,
    required this.permissions,
    required this.parser,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now {
    _codes = camera.codes.listen(handleCode);
  }

  final QrCamera camera;
  final CameraPermissionGateway permissions;
  final ReplynQrParser parser;
  final DateTime Function() _now;
  late final StreamSubscription<String?> _codes;
  final _requests = StreamController<ReplynPairingRequest>.broadcast();

  /// After resuming, the code that was just handled is ignored for this long,
  /// so a QR code still in front of the camera does not reopen the same step.
  static const repeatCooldown = Duration(seconds: 3);

  ReplynScanPhase _phase = ReplynScanPhase.checkingPermission;
  ReplynScanPhase get phase => _phase;

  ReplynQrRejection? _rejection;
  ReplynQrRejection? get rejection => _rejection;

  /// Hash of the last handled code, never the text itself.
  int? _lastCodeHash;
  DateTime? _ignoreLastUntil;
  bool _disposed = false;

  /// Each accepted code, emitted once. The screen opens the confirmation step.
  Stream<ReplynPairingRequest> get requests => _requests.stream;

  bool get showsCamera => switch (_phase) {
    ReplynScanPhase.startingCamera ||
    ReplynScanPhase.scanning ||
    ReplynScanPhase.processing ||
    ReplynScanPhase.rejected => true,
    _ => false,
  };

  Future<void> start() async {
    _set(ReplynScanPhase.checkingPermission);
    final status = await permissions.status();
    if (_disposed) return;
    switch (status) {
      case CameraPermissionState.granted:
        await _startCamera();
      case CameraPermissionState.permanentlyDenied:
        _set(ReplynScanPhase.permissionPermanentlyDenied);
      case CameraPermissionState.denied:
        await requestPermission();
    }
  }

  Future<void> requestPermission() async {
    _set(ReplynScanPhase.requestingPermission);
    final result = await permissions.request();
    if (_disposed) return;
    await _applyPermission(result);
  }

  /// After returning from Settings: check again without showing a dialog.
  Future<void> recheckPermission() async {
    if (_phase != ReplynScanPhase.permissionDenied &&
        _phase != ReplynScanPhase.permissionPermanentlyDenied) {
      return;
    }
    final status = await permissions.status();
    if (_disposed) return;
    if (status == CameraPermissionState.granted) await _startCamera();
  }

  Future<bool> openSettings() => permissions.openSettings();

  Future<void> _applyPermission(CameraPermissionState state) async {
    switch (state) {
      case CameraPermissionState.granted:
        await _startCamera();
      case CameraPermissionState.denied:
        _set(ReplynScanPhase.permissionDenied);
      case CameraPermissionState.permanentlyDenied:
        _set(ReplynScanPhase.permissionPermanentlyDenied);
    }
  }

  Future<void> _startCamera() async {
    _set(ReplynScanPhase.startingCamera);
    await camera.start();
    if (_phase == ReplynScanPhase.startingCamera) {
      _set(ReplynScanPhase.scanning);
    }
  }

  /// The preview reported that frames are flowing.
  void cameraStarted() {
    if (_phase == ReplynScanPhase.startingCamera) {
      _set(ReplynScanPhase.scanning);
    }
  }

  Future<void> cameraFailed(QrCameraFailure failure) async {
    if (_disposed) return;
    switch (failure) {
      case QrCameraFailure.permissionDenied:
        final status = await permissions.status();
        if (_disposed) return;
        _set(
          status == CameraPermissionState.permanentlyDenied
              ? ReplynScanPhase.permissionPermanentlyDenied
              : ReplynScanPhase.permissionDenied,
        );
      case QrCameraFailure.unsupported:
        _set(ReplynScanPhase.unsupported);
      case QrCameraFailure.failed:
        _set(ReplynScanPhase.cameraFailed);
    }
  }

  /// Handles one scanned code. Ignored unless the scanner is actively
  /// scanning, so a burst of detections yields a single result.
  Future<void> handleCode(String? raw) async {
    if (_phase != ReplynScanPhase.scanning) return;
    final hash = raw?.hashCode;
    final ignoreUntil = _ignoreLastUntil;
    if (hash != null &&
        hash == _lastCodeHash &&
        ignoreUntil != null &&
        _now().isBefore(ignoreUntil)) {
      return;
    }
    _lastCodeHash = hash;
    _set(ReplynScanPhase.processing);
    final result = parser.parse(raw);
    switch (result) {
      case ReplynQrRejected(:final reason):
        _rejection = reason;
        _set(ReplynScanPhase.rejected);
        await camera.pause();
      case ReplynQrAccepted(:final request):
        _rejection = null;
        _set(ReplynScanPhase.awaitingConfirmation);
        await camera.stop();
        if (!_disposed) _requests.add(request);
    }
  }

  /// Back to scanning after a rejected code, a cancelled confirmation or
  /// "scan another code".
  Future<void> resumeScanning() async {
    if (_phase != ReplynScanPhase.rejected &&
        _phase != ReplynScanPhase.awaitingConfirmation) {
      return;
    }
    _rejection = null;
    _ignoreLastUntil = _now().add(repeatCooldown);
    await _startCamera();
  }

  /// Retry after a camera error.
  Future<void> retry() => start();

  Future<void> toggleTorch() => camera.toggleTorch();

  void _set(ReplynScanPhase phase) {
    if (_disposed) return;
    _phase = phase;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_codes.cancel());
    unawaited(_requests.close());
    super.dispose();
  }
}
