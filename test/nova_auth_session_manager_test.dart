import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nivex_flutter/features/auth/data/nova_auth_api.dart';
import 'package:nivex_flutter/features/auth/data/nova_auth_session_manager.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

void main() {
  final config = NovaApiConfig('https://api.nova.test');

  NovaAuthSessionManager manager(
    _MemorySessionStore store,
    http.Client client,
  ) => NovaAuthSessionManager(
    config: config,
    store: store,
    createApi: (config) => NovaAuthApi(config: config, client: client),
  );

  test('returns signed out when no stored tokens exist', () async {
    final store = _MemorySessionStore();

    final result = await manager(
      store,
      MockClient((_) async => http.Response('', 500)),
    ).restore();

    expect(result, NovaSessionRestoreResult.signedOut);
    expect(store.cleared, isFalse);
  });

  test('restores a still-valid access token', () async {
    final store = _MemorySessionStore(
      access: _token('a'),
      refresh: _token('r'),
    );
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/auth/me');
      expect(request.headers['authorization'], 'Bearer ${_token('a')}');
      return http.Response(jsonEncode({'id': 'user-1'}), 200);
    });

    final result = await manager(store, client).restore();

    expect(result, NovaSessionRestoreResult.authenticated);
    expect(store.saved, isNull);
    expect(store.cleared, isFalse);
  });

  test('rotates refresh token after expired access token', () async {
    final store = _MemorySessionStore(
      access: _token('a'),
      refresh: _token('r'),
    );
    final next = NovaAuthSession.fromJson({
      'accessToken': _token('n'),
      'refreshToken': _token('s'),
      'accessExpiresAt': '2030-01-01T00:00:00Z',
    });
    final client = MockClient((request) async {
      if (request.url.path == '/api/v1/auth/me') {
        return http.Response('', 401);
      }
      expect(request.url.path, '/api/v1/auth/refresh');
      return http.Response(
        jsonEncode({
          'accessToken': next.accessToken,
          'refreshToken': next.refreshToken,
          'accessExpiresAt': next.accessExpiresAt.toIso8601String(),
        }),
        200,
      );
    });

    final result = await manager(store, client).restore();

    expect(result, NovaSessionRestoreResult.authenticated);
    expect(store.saved?.accessToken, next.accessToken);
    expect(store.saved?.refreshToken, next.refreshToken);
  });

  test('clears only the Nova session when refresh token is rejected', () async {
    final store = _MemorySessionStore(
      access: _token('a'),
      refresh: _token('r'),
    );
    final client = MockClient((_) async => http.Response('', 401));

    final result = await manager(store, client).restore();

    expect(result, NovaSessionRestoreResult.signedOut);
    expect(store.cleared, isTrue);
  });

  test('concurrent refreshes share one rotating refresh request', () async {
    final store = _MemorySessionStore(
      access: _token('a'),
      refresh: _token('r'),
    );
    var refreshCalls = 0;
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/auth/refresh');
      refreshCalls++;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return http.Response(
        jsonEncode({
          'accessToken': _token('n'),
          'refreshToken': _token('s'),
          'accessExpiresAt': '2030-01-01T00:00:00Z',
        }),
        200,
      );
    });
    final sessions = manager(store, client);

    final tokens = await Future.wait([
      sessions.refreshAccessToken(),
      sessions.refreshAccessToken(),
      sessions.refreshAccessToken(),
    ]);

    expect(refreshCalls, 1);
    expect(tokens, everyElement(_token('n')));
    expect(store.refresh, _token('s'));
  });

  test('rejected refresh clears the session and reports expiry', () async {
    final store = _MemorySessionStore(
      access: _token('a'),
      refresh: _token('r'),
    );
    var expired = false;
    final sessions = manager(
      store,
      MockClient((_) async => http.Response('', 401)),
    )..onSessionExpired = () => expired = true;

    expect(await sessions.refreshAccessToken(), isNull);
    expect(store.cleared, isTrue);
    expect(expired, isTrue);
  });

  test('network failure during refresh keeps the stored session', () async {
    final store = _MemorySessionStore(
      access: _token('a'),
      refresh: _token('r'),
    );
    final sessions = manager(
      store,
      MockClient((_) async => throw http.ClientException('offline')),
    );

    expect(await sessions.refreshAccessToken(), isNull);
    expect(store.cleared, isFalse);
    expect(store.refresh, _token('r'));
  });

  test('logout revokes access and refresh tokens then clears', () async {
    final store = _MemorySessionStore(
      access: _token('a'),
      refresh: _token('r'),
    );
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/auth/logout');
      expect(request.headers['authorization'], 'Bearer ${_token('a')}');
      expect(jsonDecode(request.body), {'refreshToken': _token('r')});
      return http.Response('', 204);
    });

    await manager(store, client).logout();

    expect(store.cleared, isTrue);
  });

  test('logout clears local credentials when the server is down', () async {
    final store = _MemorySessionStore(
      access: _token('a'),
      refresh: _token('r'),
    );

    await manager(
      store,
      MockClient((_) async => throw http.ClientException('offline')),
    ).logout();

    expect(store.cleared, isTrue);
  });
}

String _token(String seed) => seed.padRight(43, seed);

class _MemorySessionStore implements NovaAuthSessionStore {
  _MemorySessionStore({this.access, this.refresh});

  String? access;
  String? refresh;
  NovaAuthSession? saved;
  bool cleared = false;

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
    cleared = true;
  }

  @override
  Future<NovaStoredSession> read() async =>
      NovaStoredSession(accessToken: access, refreshToken: refresh);

  @override
  Future<void> save(NovaAuthSession session) async {
    saved = session;
    access = session.accessToken;
    refresh = session.refreshToken;
  }
}
