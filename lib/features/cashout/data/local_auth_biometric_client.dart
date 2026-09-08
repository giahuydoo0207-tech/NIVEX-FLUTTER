import 'package:local_auth/local_auth.dart';
import 'package:nivex_flutter/features/cashout/domain/biometric_auth_client.dart';

class LocalAuthBiometricClient implements BiometricAuthClient {
  LocalAuthBiometricClient({
    LocalAuthentication? auth,
    DateTime Function()? clock,
  }) : _auth = auth ?? LocalAuthentication(),
       _clock = clock ?? DateTime.now;

  final LocalAuthentication _auth;
  final DateTime Function() _clock;

  @override
  Future<bool> canAuthenticate() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      if (!isSupported) return false;
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<BiometricAuthExecutionResult> authenticate({
    required String localizedReason,
  }) async {
    try {
      final canAuth = await canAuthenticate();
      if (!canAuth) {
        return const BiometricAuthUnavailable(
          'Thiết bị không hỗ trợ hoặc chưa đăng ký sinh trắc học',
        );
      }

      final didAuth = await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (didAuth) {
        return BiometricAuthSuccess(authenticatedAt: _clock());
      } else {
        return const BiometricAuthFailed(
          reason:
              'Hệ thống chưa nhận diện được. Vui lòng thử lại hoặc dùng PIN.',
        );
      }
    } on LocalAuthException catch (e) {
      switch (e.code) {
        case LocalAuthExceptionCode.noBiometricsEnrolled:
        case LocalAuthExceptionCode.noBiometricHardware:
        case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
        case LocalAuthExceptionCode.noCredentialsSet:
          return BiometricAuthUnavailable(
            e.description ?? 'Sinh trắc học không khả dụng',
          );
        case LocalAuthExceptionCode.temporaryLockout:
        case LocalAuthExceptionCode.biometricLockout:
          return const BiometricAuthErrorResult(
            'Sinh trắc học bị tạm khóa do thử sai nhiều lần',
          );
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.userRequestedFallback:
          return const BiometricAuthUserCancelled();
        default:
          return BiometricAuthErrorResult(
            e.description ?? 'Lỗi xác thực sinh trắc học',
          );
      }
    } catch (e) {
      return BiometricAuthErrorResult(e.toString());
    }
  }
}
