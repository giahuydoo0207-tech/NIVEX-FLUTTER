import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nivex_flutter/features/auth/data/nova_auth_api.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

void main() {
  final config = NovaApiConfig('https://api.nova.test');

  test('requests and decodes a phone OTP challenge', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/auth/phone/request-otp');
      expect(jsonDecode(request.body), {'phoneE164': '+84912345678'});
      return http.Response(
        jsonEncode({
          'challengeId': 'a0ca7efa-8bb4-4a42-a6ba-b6d2b35e2636',
          'expiresInSeconds': 300,
          'debugOtp': '123456',
        }),
        202,
      );
    });
    final api = NovaAuthApi(config: config, client: client);

    final challenge = await api.requestPhoneOtp(phoneE164: '+84912345678');

    expect(challenge.id, 'a0ca7efa-8bb4-4a42-a6ba-b6d2b35e2636');
    expect(challenge.expiresInSeconds, 300);
    expect(challenge.debugOtp, '123456');
    api.close();
  });

  test('verifies an OTP and reads the issued session', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/auth/phone/verify-otp');
      expect(jsonDecode(request.body), {
        'challengeId': 'a0ca7efa-8bb4-4a42-a6ba-b6d2b35e2636',
        'code': '123456',
        'displayName': 'Gia Huy',
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

    final session = await api.verifyPhoneOtp(
      challengeId: 'a0ca7efa-8bb4-4a42-a6ba-b6d2b35e2636',
      code: '123456',
      displayName: 'Gia Huy',
    );

    expect(session.accessToken, _token('a'));
    expect(session.refreshToken, _token('r'));
    api.close();
  });
}

String _token(String seed) => seed.padRight(43, seed);
