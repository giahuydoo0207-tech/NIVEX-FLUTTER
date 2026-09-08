import 'package:flutter/foundation.dart';

@immutable
sealed class BiometricAuthExecutionResult {
  const BiometricAuthExecutionResult();
}

@immutable
class BiometricAuthSuccess extends BiometricAuthExecutionResult {
  const BiometricAuthSuccess({required this.authenticatedAt});
  final DateTime authenticatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiometricAuthSuccess && authenticatedAt == other.authenticatedAt;

  @override
  int get hashCode => authenticatedAt.hashCode;
}

@immutable
class BiometricAuthFailed extends BiometricAuthExecutionResult {
  const BiometricAuthFailed({
    this.reason = 'Xác thực sinh trắc học không thành công',
  });
  final String reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiometricAuthFailed && reason == other.reason;

  @override
  int get hashCode => reason.hashCode;
}

@immutable
class BiometricAuthUserCancelled extends BiometricAuthExecutionResult {
  const BiometricAuthUserCancelled();

  @override
  bool operator ==(Object other) => other is BiometricAuthUserCancelled;

  @override
  int get hashCode => 0;
}

@immutable
class BiometricAuthUnavailable extends BiometricAuthExecutionResult {
  const BiometricAuthUnavailable(this.reason);
  final String reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiometricAuthUnavailable && reason == other.reason;

  @override
  int get hashCode => reason.hashCode;
}

@immutable
class BiometricAuthErrorResult extends BiometricAuthExecutionResult {
  const BiometricAuthErrorResult(this.message);
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiometricAuthErrorResult && message == other.message;

  @override
  int get hashCode => message.hashCode;
}

abstract interface class BiometricAuthClient {
  Future<bool> canAuthenticate();
  Future<BiometricAuthExecutionResult> authenticate({
    required String localizedReason,
  });
}
