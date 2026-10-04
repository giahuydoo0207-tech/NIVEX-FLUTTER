import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nivex_flutter/features/auth/data/nova_auth_api.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

void main() {
  final config = NovaApiConfig('https://api.nova.test');

  test('logs in with email and reads the issued session', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/auth/login/email');
      expect(jsonDecode(request.body), {
        'email': 'huy@nova.vn',
        'password': 'nova-demo-password',
      });
      return http.Response(
        jsonEncode({
          'accessToken': _token('a'),
          'refreshToken': _token('r'),
          'accessExpiresAt': '2030-01-01T00:00:00Z',
        }),
        200,
      );
    });
    final api = NovaAuthApi(config: config, client: client);

    final session = await api.loginEmail(
      email: 'huy@nova.vn',
      password: 'nova-demo-password',
    );

    expect(session.accessToken, _token('a'));
    expect(session.refreshToken, _token('r'));
    api.close();
  });
}

String _token(String seed) => seed.padRight(43, seed);
