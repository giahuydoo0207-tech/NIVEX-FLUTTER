import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

void main() {
  NovaApiClient client(
    Future<http.Response> Function(http.Request) handler, {
    String? token = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    Duration timeout = const Duration(seconds: 1),
  }) => NovaApiClient(
    config: NovaApiConfig('https://example.test'),
    readToken: () async => token,
    transport: MockClient(handler),
    timeout: timeout,
  );

  test('requires HTTPS and rejects credentials or path in origin', () {
    for (final url in [
      'http://example.test',
      'https://u:p@example.test',
      'https://example.test/api',
    ]) {
      expect(() => NovaApiConfig(url), throwsArgumentError);
    }
    expect(
      NovaApiConfig('http://127.0.0.1:8080', allowLocalHttp: true).baseUri.port,
      8080,
    );
  });

  test(
    'sends scoped bearer and pagination and preserves u64 precision',
    () async {
      final api = client((request) async {
        expect(request.headers['Authorization'], startsWith('Bearer '));
        expect(request.headers.containsKey('X-Nova-Demo-Key'), isFalse);
        expect(request.url.path, '/api/v1/mobile/invoices');
        expect(request.url.queryParameters['offset'], '25');
        expect(request.followRedirects, isFalse);
        return http.Response(
          '[{"id":"1","invoiceNumber":"NOVA-1","description":"test","amountMinor":"18446744073709551615","status":"ISSUED"}]',
          200,
        );
      });
      addTearDown(api.close);
      expect(
        (await api.invoices(offset: 25)).single.amountMinor.toString(),
        '18446744073709551615',
      );
      expect(formatUsdc(BigInt.from(10000)), '0.01');
      expect(formatUsdc(BigInt.from(200000)), '0.2');
      expect(formatUsdc(BigInt.from(1000000)), '1');
    },
  );

  test('missing session does not call network', () async {
    final api = client(
      (_) async => throw StateError('must not send'),
      token: null,
    );
    addTearDown(api.close);
    await expectLater(
      api.invoices(),
      throwsA(
        isA<NovaApiException>().having((e) => e.requiresLogin, 'login', true),
      ),
    );
  });

  test('does not expose response content in errors', () async {
    final api = client((_) async => http.Response('secret diagnostic', 401));
    addTearDown(api.close);
    await expectLater(
      api.invoices(),
      throwsA(
        isA<NovaApiException>().having(
          (e) => e.toString().contains('secret'),
          'no leak',
          false,
        ),
      ),
    );
  });

  test('rejects malformed response and numeric token amounts', () async {
    final api = client(
      (_) async => http.Response(
        '[{"id":"1","invoiceNumber":"N","description":"d","amountMinor":0.01,"status":"ISSUED"}]',
        200,
      ),
    );
    addTearDown(api.close);
    await expectLater(
      api.invoices(),
      throwsA(
        isA<NovaApiException>().having(
          (e) => e.code,
          'code',
          'invalid_response',
        ),
      ),
    );
  });

  test('times out stalled requests', () async {
    final api = client(
      (_) => Completer<http.Response>().future,
      timeout: const Duration(milliseconds: 5),
    );
    addTearDown(api.close);
    await expectLater(
      api.invoices(),
      throwsA(isA<NovaApiException>().having((e) => e.code, 'code', 'timeout')),
    );
  });
}
