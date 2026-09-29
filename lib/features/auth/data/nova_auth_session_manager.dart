import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nivex_flutter/features/auth/data/nova_auth_api.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

enum NovaSessionRestoreResult { authenticated, signedOut, unavailable }

class NovaStoredSession {
  const NovaStoredSession({
    required this.accessToken,
    required this.refreshToken,
  });

  final String? accessToken;
  final String? refreshToken;
}

abstract interface class NovaAuthSessionStore {
  Future<NovaStoredSession> read();
  Future<void> save(NovaAuthSession session);
  Future<void> clear();
}

class SecureNovaAuthSessionStore implements NovaAuthSessionStore {
  SecureNovaAuthSessionStore({
    required this.origin,
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  final String origin;
  final FlutterSecureStorage _storage;

  String get _accessKey => 'nova.mobile.session.$origin';
  String get _refreshKey => 'nova.mobile.refresh.$origin';

  @override
  Future<NovaStoredSession> read() async => NovaStoredSession(
    accessToken: await _storage.read(key: _accessKey),
    refreshToken: await _storage.read(key: _refreshKey),
  );

  @override
  Future<void> save(NovaAuthSession session) async {
    await _storage.write(key: _accessKey, value: session.accessToken);
    await _storage.write(key: _refreshKey, value: session.refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

class NovaAuthSessionManager {
  NovaAuthSessionManager({
    required this.config,
    required this.store,
    NovaAuthApi Function(NovaApiConfig config)? createApi,
  }) : _createApi = createApi ?? ((config) => NovaAuthApi(config: config));

  final NovaApiConfig config;
  final NovaAuthSessionStore store;
  final NovaAuthApi Function(NovaApiConfig config) _createApi;

  Future<NovaSessionRestoreResult> restore() async {
    final stored = await store.read();
    if (stored.accessToken == null && stored.refreshToken == null) {
      return NovaSessionRestoreResult.signedOut;
    }

    final api = _createApi(config);
    try {
      if (stored.accessToken != null) {
        try {
          await api.validateAccessToken(accessToken: stored.accessToken!);
          return NovaSessionRestoreResult.authenticated;
        } on NovaApiException catch (error) {
          if (!_isUnauthorized(error)) {
            return NovaSessionRestoreResult.unavailable;
          }
        }
      }

      if (stored.refreshToken == null) {
        await store.clear();
        return NovaSessionRestoreResult.signedOut;
      }

      try {
        final session = await api.refreshSession(
          refreshToken: stored.refreshToken!,
        );
        await store.save(session);
        return NovaSessionRestoreResult.authenticated;
      } on NovaApiException catch (error) {
        if (_isUnauthorized(error)) {
          await store.clear();
          return NovaSessionRestoreResult.signedOut;
        }
        return NovaSessionRestoreResult.unavailable;
      }
    } finally {
      api.close();
    }
  }

  Future<String?>? _refreshInFlight;

  /// Exchanges the stored refresh token for a new access token.
  ///
  /// Concurrent callers share one request: the backend rotates refresh tokens,
  /// so a second parallel refresh would present an already revoked token and
  /// sign the user out. Returns null and clears the session only when the
  /// server rejects the refresh token; network failures keep the session.
  Future<String?> refreshAccessToken() => _refreshInFlight ??= _refresh()
      .whenComplete(() => _refreshInFlight = null);

  Future<String?> _refresh() async {
    final stored = await store.read();
    final refreshToken = stored.refreshToken;
    if (refreshToken == null) return null;
    final api = _createApi(config);
    try {
      final session = await api.refreshSession(refreshToken: refreshToken);
      await store.save(session);
      return session.accessToken;
    } on NovaApiException catch (error) {
      if (_isUnauthorized(error)) {
        await store.clear();
        onSessionExpired?.call();
      }
      return null;
    } finally {
      api.close();
    }
  }

  /// Called after the server rejects the refresh token during normal use.
  void Function()? onSessionExpired;

  Future<void> logout() async {
    final stored = await store.read();
    final api = _createApi(config);
    try {
      if (stored.accessToken != null || stored.refreshToken != null) {
        try {
          await api.logout(
            accessToken: stored.accessToken,
            refreshToken: stored.refreshToken,
          );
        } on NovaApiException {
          // Local credentials are cleared even when the server is unavailable.
        }
      }
    } finally {
      await store.clear();
      api.close();
    }
  }

  bool _isUnauthorized(NovaApiException error) =>
      error.statusCode == 401 || error.statusCode == 403;
}
