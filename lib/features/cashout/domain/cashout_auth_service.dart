import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:nivex_flutter/features/cashout/data/cashout_auth_state_store.dart';
import 'package:nivex_flutter/features/cashout/domain/biometric_auth_client.dart';

typedef Clock = DateTime Function();

enum AuthMethod { biometric, pin }

@immutable
sealed class TransactionAuthResult {
  const TransactionAuthResult();
}

@immutable
class TransactionAuthSuccess extends TransactionAuthResult {
  const TransactionAuthSuccess({
    required this.method,
    required this.authenticatedAt,
  });

  final AuthMethod method;
  final DateTime authenticatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAuthSuccess &&
          method == other.method &&
          authenticatedAt == other.authenticatedAt;

  @override
  int get hashCode => Object.hash(method, authenticatedAt);
}

@immutable
class TransactionAuthCancelled extends TransactionAuthResult {
  const TransactionAuthCancelled();

  @override
  bool operator ==(Object other) => other is TransactionAuthCancelled;

  @override
  int get hashCode => 0;
}

@immutable
class TransactionAuthLocked extends TransactionAuthResult {
  const TransactionAuthLocked({
    required this.lockoutUntil,
    required this.remainingSeconds,
  });

  final DateTime lockoutUntil;
  final int remainingSeconds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAuthLocked &&
          lockoutUntil == other.lockoutUntil &&
          remainingSeconds == other.remainingSeconds;

  @override
  int get hashCode => Object.hash(lockoutUntil, remainingSeconds);
}

@immutable
class TransactionAuthUnavailable extends TransactionAuthResult {
  const TransactionAuthUnavailable(this.reason);
  final String reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAuthUnavailable && reason == other.reason;

  @override
  int get hashCode => reason.hashCode;
}

@immutable
class TransactionAuthError extends TransactionAuthResult {
  const TransactionAuthError(this.message);
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAuthError && message == other.message;

  @override
  int get hashCode => message.hashCode;
}

@immutable
sealed class PinVerificationOutcome {
  const PinVerificationOutcome();
}

@immutable
class PinSuccessOutcome extends PinVerificationOutcome {
  const PinSuccessOutcome({required this.authenticatedAt});
  final DateTime authenticatedAt;
}

@immutable
class PinIncorrectOutcome extends PinVerificationOutcome {
  const PinIncorrectOutcome({
    required this.remainingAttempts,
    required this.failedAttempts,
  });
  final int remainingAttempts;
  final int failedAttempts;
}

@immutable
class PinLockedOutcome extends PinVerificationOutcome {
  const PinLockedOutcome({
    required this.lockoutUntil,
    required this.remainingSeconds,
  });
  final DateTime lockoutUntil;
  final int remainingSeconds;
}

class CashoutAuthService {
  CashoutAuthService({
    required this.biometricClient,
    this.clock = DateTime.now,
    this.demoExpectedPin = '123456',
    this.maxAttempts = 5,
    this.lockoutDuration = const Duration(seconds: 30),
    CashoutAuthStateStore? stateStore,
  }) : stateStore = stateStore ?? SecureCashoutAuthStateStore();

  final BiometricAuthClient biometricClient;
  final Clock clock;
  final String demoExpectedPin;
  final int maxAttempts;
  final Duration lockoutDuration;
  final CashoutAuthStateStore stateStore;

  int _failedAttempts = 0;
  DateTime? _lockoutUntil;
  DateTime? _lastObservedAt;
  Future<void>? _initialization;

  int get failedAttempts => _failedAttempts;
  DateTime? get lockoutUntil => _lockoutUntil;

  Future<void> initialize() {
    return _initialization ??= _loadPersistedState();
  }

  Future<void> _loadPersistedState() async {
    final state = await stateStore.read();
    _failedAttempts = state.failedAttempts.clamp(0, maxAttempts);
    _lockoutUntil = state.lockoutUntil;
    _lastObservedAt = state.lastObservedAt;
    await _expireLockoutIfNeeded(_effectiveNow(clock()));
  }

  DateTime _effectiveNow(DateTime candidate) {
    final previous = _lastObservedAt;
    if (previous != null && candidate.isBefore(previous)) {
      return previous;
    }
    _lastObservedAt = candidate;
    return candidate;
  }

  bool isLocked([DateTime? now]) {
    final current = _effectiveNow(now ?? clock());
    final until = _lockoutUntil;
    return until != null && current.isBefore(until);
  }

  int remainingAttempts([DateTime? now]) {
    if (isLocked(now)) return 0;
    return math.max(0, maxAttempts - _failedAttempts);
  }

  int lockoutSecondsRemaining([DateTime? now]) {
    final current = now ?? clock();
    final until = _lockoutUntil;
    if (until == null || !current.isBefore(until)) return 0;
    return until.difference(current).inSeconds;
  }

  Future<PinVerificationOutcome> verifyPin(
    String pin, [
    DateTime? atTime,
  ]) async {
    await initialize();
    final current = _effectiveNow(atTime ?? clock());
    await _expireLockoutIfNeeded(current);
    if (isLocked(current)) {
      return PinLockedOutcome(
        lockoutUntil: _lockoutUntil!,
        remainingSeconds: lockoutSecondsRemaining(current),
      );
    }

    if (pin == demoExpectedPin) {
      _failedAttempts = 0;
      _lockoutUntil = null;
      await _persist();
      return PinSuccessOutcome(authenticatedAt: current);
    }

    _failedAttempts++;
    if (_failedAttempts >= maxAttempts) {
      _lockoutUntil = current.add(lockoutDuration);
      await _persist();
      return PinLockedOutcome(
        lockoutUntil: _lockoutUntil!,
        remainingSeconds: lockoutDuration.inSeconds,
      );
    }

    await _persist();
    return PinIncorrectOutcome(
      remainingAttempts: maxAttempts - _failedAttempts,
      failedAttempts: _failedAttempts,
    );
  }

  Future<TransactionAuthResult> authenticateBiometric({
    String reason = 'Xác thực để hoàn tất rút tiền',
    DateTime? atTime,
  }) async {
    await initialize();
    final current = _effectiveNow(atTime ?? clock());
    await _expireLockoutIfNeeded(current);
    if (isLocked(current)) {
      return TransactionAuthLocked(
        lockoutUntil: _lockoutUntil!,
        remainingSeconds: lockoutSecondsRemaining(current),
      );
    }

    final canAuth = await biometricClient.canAuthenticate();
    if (!canAuth) {
      return const TransactionAuthUnavailable(
        'Thiết bị chưa cài đặt hoặc không hỗ trợ sinh trắc học',
      );
    }

    final res = await biometricClient.authenticate(localizedReason: reason);
    switch (res) {
      case BiometricAuthSuccess(:final authenticatedAt):
        _failedAttempts = 0;
        _lockoutUntil = null;
        _lastObservedAt = authenticatedAt;
        await _persist();
        return TransactionAuthSuccess(
          method: AuthMethod.biometric,
          authenticatedAt: authenticatedAt,
        );
      case BiometricAuthUserCancelled():
        return const TransactionAuthCancelled();
      case BiometricAuthUnavailable(:final reason):
        return TransactionAuthUnavailable(reason);
      case BiometricAuthErrorResult(:final message):
        return TransactionAuthError(message);
      case BiometricAuthFailed(:final reason):
        return TransactionAuthError(reason);
    }
  }

  Future<void> _expireLockoutIfNeeded(DateTime current) async {
    final until = _lockoutUntil;
    if (until == null || current.isBefore(until)) return;
    _failedAttempts = 0;
    _lockoutUntil = null;
    await _persist();
  }

  Future<void> _persist() {
    return stateStore.write(
      CashoutAuthState(
        failedAttempts: _failedAttempts,
        lockoutUntil: _lockoutUntil,
        lastObservedAt: _lastObservedAt,
      ),
    );
  }

  Future<void> reset() async {
    _failedAttempts = 0;
    _lockoutUntil = null;
    _lastObservedAt = null;
    await stateStore.clear();
  }
}
