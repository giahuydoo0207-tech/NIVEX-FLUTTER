import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionState {
  granted,

  /// Not granted yet, or denied once; asking again may show the system dialog.
  denied,

  /// Denied with "don't ask again" (or blocked by policy): only Settings helps.
  permanentlyDenied,
}

abstract interface class CameraPermissionGateway {
  Future<CameraPermissionState> status();
  Future<CameraPermissionState> request();

  /// Opens this app's page in system Settings. False if it could not.
  Future<bool> openSettings();
}

class PermissionHandlerCameraGateway implements CameraPermissionGateway {
  const PermissionHandlerCameraGateway();

  @override
  Future<CameraPermissionState> status() async =>
      _map(await Permission.camera.status);

  @override
  Future<CameraPermissionState> request() async =>
      _map(await Permission.camera.request());

  @override
  Future<bool> openSettings() => openAppSettings();

  static CameraPermissionState _map(PermissionStatus status) =>
      switch (status) {
        PermissionStatus.granted ||
        PermissionStatus.limited => CameraPermissionState.granted,
        PermissionStatus.permanentlyDenied ||
        PermissionStatus.restricted => CameraPermissionState.permanentlyDenied,
        _ => CameraPermissionState.denied,
      };
}
