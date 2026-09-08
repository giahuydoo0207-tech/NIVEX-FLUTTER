import 'package:nivex_flutter/features/cashout/domain/biometric_auth_client.dart';

class FakeBiometricAuthClient implements BiometricAuthClient {
  FakeBiometricAuthClient({
    this.canAuth = true,
    BiometricAuthExecutionResult? initialResult,
  }) : nextResult =
           initialResult ??
           BiometricAuthSuccess(authenticatedAt: DateTime.now());

  bool canAuth;
  BiometricAuthExecutionResult nextResult;

  @override
  Future<bool> canAuthenticate() async => canAuth;

  @override
  Future<BiometricAuthExecutionResult> authenticate({
    required String localizedReason,
  }) async {
    return nextResult;
  }
}
