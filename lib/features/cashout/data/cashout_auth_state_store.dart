import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CashoutAuthState {
  const CashoutAuthState({
    this.failedAttempts = 0,
    this.lockoutUntil,
    this.lastObservedAt,
  });

  final int failedAttempts;
  final DateTime? lockoutUntil;
  final DateTime? lastObservedAt;
}

abstract interface class CashoutAuthStateStore {
  Future<CashoutAuthState> read();
  Future<void> write(CashoutAuthState state);
  Future<void> clear();
}

class SecureCashoutAuthStateStore implements CashoutAuthStateStore {
  SecureCashoutAuthStateStore({
    FlutterSecureStorage? storage,
    this.namespace = 'cashout',
  }) : _storage = storage ?? const FlutterSecureStorage();

  final String namespace;

  final FlutterSecureStorage _storage;

  String get _attemptsKey => '${namespace}_auth_failed_attempts';
  String get _lockoutKey => '${namespace}_auth_locked_until';
  String get _lastObservedKey => '${namespace}_auth_last_observed_at';

  @override
  Future<CashoutAuthState> read() async {
    final values = await _storage.readAll();
    return CashoutAuthState(
      failedAttempts: int.tryParse(values[_attemptsKey] ?? '') ?? 0,
      lockoutUntil: DateTime.tryParse(values[_lockoutKey] ?? ''),
      lastObservedAt: DateTime.tryParse(values[_lastObservedKey] ?? ''),
    );
  }

  @override
  Future<void> write(CashoutAuthState state) async {
    await Future.wait([
      _storage.write(key: _attemptsKey, value: state.failedAttempts.toString()),
      _writeOptionalDate(_lockoutKey, state.lockoutUntil),
      _writeOptionalDate(_lastObservedKey, state.lastObservedAt),
    ]);
  }

  Future<void> _writeOptionalDate(String key, DateTime? value) {
    if (value == null) {
      return _storage.delete(key: key);
    }
    return _storage.write(key: key, value: value.toUtc().toIso8601String());
  }

  @override
  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _attemptsKey),
      _storage.delete(key: _lockoutKey),
      _storage.delete(key: _lastObservedKey),
    ]);
  }
}

class InMemoryCashoutAuthStateStore implements CashoutAuthStateStore {
  CashoutAuthState _state = const CashoutAuthState();

  @override
  Future<CashoutAuthState> read() async => _state;

  @override
  Future<void> write(CashoutAuthState state) async {
    _state = state;
  }

  @override
  Future<void> clear() async {
    _state = const CashoutAuthState();
  }
}
