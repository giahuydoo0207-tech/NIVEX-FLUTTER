import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum QrCameraFailure { permissionDenied, unsupported, failed }

/// The camera behind the Replyn scanner. Tests use a fake; the app uses
/// [MobileScannerQrCamera].
abstract class QrCamera {
  /// Raw text of each QR code seen while running.
  Stream<String?> get codes;

  /// Null until the camera reports whether it has a torch.
  ValueListenable<bool?> get torchAvailable;
  ValueListenable<bool> get torchOn;

  /// The live preview. [onFailure] reports start-up and runtime errors.
  Widget buildPreview(
    BuildContext context, {
    required ValueChanged<QrCameraFailure> onFailure,
    required VoidCallback onStarted,
  });

  Future<void> start();

  /// Freezes detection and the preview but keeps the camera open.
  Future<void> pause();

  /// Releases the camera.
  Future<void> stop();
  Future<void> toggleTorch();
  Future<void> dispose();
}

class MobileScannerQrCamera implements QrCamera {
  MobileScannerQrCamera()
    : _controller = MobileScannerController(
        // The scanner screen starts the camera itself once permission is known.
        autoStart: false,
        formats: const [BarcodeFormat.qrCode],
        detectionSpeed: DetectionSpeed.noDuplicates,
      ) {
    _controller.addListener(_onState);
    _subscription = _controller.barcodes.listen((capture) {
      for (final barcode in capture.barcodes) {
        _codes.add(barcode.rawValue);
      }
    });
  }

  final MobileScannerController _controller;
  final _codes = StreamController<String?>.broadcast();
  final _torchAvailable = ValueNotifier<bool?>(null);
  final _torchOn = ValueNotifier<bool>(false);
  StreamSubscription<BarcodeCapture>? _subscription;
  VoidCallback? _onStarted;
  ValueChanged<QrCameraFailure>? _onFailure;
  bool _wasRunning = false;

  void _onState() {
    final state = _controller.value;
    if (state.isInitialized) {
      _torchAvailable.value = state.torchState != TorchState.unavailable;
    }
    _torchOn.value = state.torchState == TorchState.on;
    if (state.isRunning && !_wasRunning) _onStarted?.call();
    _wasRunning = state.isRunning;
    final error = state.error;
    if (error != null) _onFailure?.call(_failure(error));
  }

  static QrCameraFailure _failure(MobileScannerException error) =>
      switch (error.errorCode) {
        MobileScannerErrorCode.permissionDenied =>
          QrCameraFailure.permissionDenied,
        MobileScannerErrorCode.unsupported => QrCameraFailure.unsupported,
        _ => QrCameraFailure.failed,
      };

  @override
  Stream<String?> get codes => _codes.stream;

  @override
  ValueListenable<bool?> get torchAvailable => _torchAvailable;

  @override
  ValueListenable<bool> get torchOn => _torchOn;

  @override
  Widget buildPreview(
    BuildContext context, {
    required ValueChanged<QrCameraFailure> onFailure,
    required VoidCallback onStarted,
  }) {
    _onFailure = onFailure;
    _onStarted = onStarted;
    return MobileScanner(
      controller: _controller,
      // Our own overlay and error UI replace the package defaults.
      errorBuilder: (context, error) => const ColoredBox(color: Colors.black),
      placeholderBuilder: (context) => const ColoredBox(color: Colors.black),
    );
  }

  @override
  Future<void> start() => _guard(_controller.start);

  @override
  Future<void> pause() => _guard(_controller.pause);

  @override
  Future<void> stop() => _guard(_controller.stop);

  @override
  Future<void> toggleTorch() => _guard(_controller.toggleTorch);

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on MobileScannerException catch (error) {
      // Starting a camera that is already (being) started is not a failure.
      if (error.errorCode ==
              MobileScannerErrorCode.controllerAlreadyInitialized ||
          error.errorCode == MobileScannerErrorCode.controllerInitializing) {
        return;
      }
      _onFailure?.call(_failure(error));
    }
  }

  @override
  Future<void> dispose() async {
    _onFailure = null;
    _onStarted = null;
    _controller.removeListener(_onState);
    await _subscription?.cancel();
    await _codes.close();
    _torchAvailable.dispose();
    _torchOn.dispose();
    await _controller.dispose();
  }
}
