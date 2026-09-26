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
