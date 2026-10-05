import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_pairing_request.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_qr_parser.dart';
import 'package:nivex_flutter/shared/constants/app_environment.dart';

// Made-up pairing ID; the secret is random per run, never a real code.
const _id = '6f1c2a9e-4b7d-4c3e-9a5f-0d8b7e6c5a41';
const _host = 'replyn-web.vercel.app';
final _secret = base64Url
    .encode(List.generate(32, (_) => Random.secure().nextInt(256)))
    .replaceAll('=', '');

final _now = DateTime.utc(2026, 10, 4, 10);
int _unix(DateTime time) => time.millisecondsSinceEpoch ~/ 1000;
final _exp = _unix(_now.add(const Duration(seconds: 60)));

String _code({
  String host = 'https://$_host',
  String path = '/auth/nova',
  String? pairing = _id,
  String? secret,
  String? exp,
  String? action = 'login',
  String extra = '',
}) {
  final params = [
    if (pairing != null) 'pairing=$pairing',
    'secret=${secret ?? _secret}',
    'exp=${exp ?? _exp}',
    if (action != null) 'action=$action',
  ];
  return '$host$path?${params.join('&')}$extra';
}

String get _valid => _code();

ReplynQrParser _parser({bool dev = false}) => ReplynQrParser(
  ReplynQrConfig(allowedHosts: const {_host}, allowDevHosts: dev),
  now: () => _now,
);

ReplynQrRejection? _reason(String? raw, {bool dev = false}) =>
    switch (_parser(dev: dev).parse(raw)) {
      ReplynQrRejected(:final reason) => reason,
      ReplynQrAccepted() => null,
    };

ReplynPairingRequest _accepted(String raw, {bool dev = false}) =>
    (_parser(dev: dev).parse(raw) as ReplynQrAccepted).request;

String _without(String param) => _valid
    .replaceFirst(RegExp('[?&]$param=[^&]*'), '')
    .replaceFirst('/auth/nova&', '/auth/nova?');

void main() {
  test('accepts the login code Replyn creates', () {
    final request = _accepted(_valid);
    expect(request.action, ReplynPairingAction.login);
    expect(request.pairingId, _id);
    expect(request.qrSecret, _secret);
    expect(request.displayOrigin, _host);
    expect(request.expiresAt, _now.add(const Duration(seconds: 60)));
    expect(ReplynPairingRequest.provider, 'REPLYN');
    // Surrounding whitespace from the scanner is fine.
    expect(_reason(' $_valid\n'), isNull);
    // Hostnames are case-insensitive.
    expect(_reason(_code(host: 'https://Replyn-Web.Vercel.App')), isNull);
    // Parameter order does not matter.
    expect(
      _reason(
        'https://$_host/auth/nova?action=login&exp=$_exp&secret=$_secret&pairing=$_id',
      ),
      isNull,
    );
  });

  test('the parsed request never prints its pairing ID or secret', () {
    final printed = _accepted(_valid).toString();
    expect(printed, isNot(contains(_id)));
    expect(printed, isNot(contains(_secret)));
  });

  test('every parameter is required', () {
    expect(_reason(_without('pairing')), ReplynQrRejection.missingPairing);
    expect(_reason(_without('secret')), ReplynQrRejection.missingSecret);
    expect(_reason(_without('exp')), ReplynQrRejection.missingExpiry);
    expect(_reason(_without('action')), ReplynQrRejection.unsupportedAction);
    expect(_reason(_code(pairing: '')), ReplynQrRejection.missingPairing);
    expect(_reason(_code(secret: '')), ReplynQrRejection.missingSecret);
    expect(
      _reason('https://$_host/auth/nova'),
      ReplynQrRejection.unsupportedAction,
    );
  });

  test('the pairing must be a canonical UUID', () {
    for (final id in [
      _id.toUpperCase(),
      _id.replaceAll('-', ''),
      '${_id}0',
      _id.substring(1),
      '6f1c2a9e-4b7d-0c3e-9a5f-0d8b7e6c5a41', // version 0
      '6f1c2a9e-4b7d-4c3e-1a5f-0d8b7e6c5a41', // wrong variant
      'zf1c2a9e-4b7d-4c3e-9a5f-0d8b7e6c5a41',
      '{$_id}',
      '0a1b2c3d4e5f', // old prototype session ID
    ]) {
      expect(
        _reason(_code(pairing: id)),
        ReplynQrRejection.invalidPairing,
        reason: id,
      );
    }
  });

  test('the secret must be exactly 43 base64url characters', () {
    for (final secret in [
      _secret.substring(1),
      '${_secret}A',
      '${_secret.substring(0, 42)}=',
      '${_secret.substring(0, 42)}+',
      '${_secret.substring(0, 42)}/',
      // A 43rd character that carries more than 4 bits is not canonical.
      '${_secret.substring(0, 42)}B',
      '${_secret.substring(0, 41)}.A',
    ]) {
      expect(
        _reason(_code(secret: Uri.encodeQueryComponent(secret))),
        ReplynQrRejection.invalidSecret,
        reason: secret,
      );
    }
  });

  test('the old demo-qr format is refused', () {
    expect(
      _reason('https://$_host/auth/nova?demo-qr=0a1b2c3d4e5f'),
      ReplynQrRejection.unexpectedParameter,
    );
  });

  test('rejects a different hostname', () {
    expect(
      _reason(_code(host: 'https://example.com')),
      ReplynQrRejection.hostNotAllowed,
    );
    expect(
      _reason(_code(host: 'https://nivex-business.vercel.app')),
      ReplynQrRejection.hostNotAllowed,
    );
  });

  test('rejects hosts that only look like Replyn', () {
    for (final host in [
      '$_host.attacker.com',
      'evil-$_host',
      'replyn-web.vercel.app.',
      'sub.$_host',
      'replyn-web.vercel.app%2eattacker.com',
      'xn--replyn-web-vercel-app.com',
    ]) {
      expect(
        _reason(_code(host: 'https://$host')),
        ReplynQrRejection.hostNotAllowed,
        reason: host,
      );
    }
  });

  test('rejects plain http in production', () {
    expect(
      _reason(_code(host: 'http://$_host')),
      ReplynQrRejection.insecureScheme,
    );
  });

  test('rejects dangerous and custom schemes', () {
    for (final raw in [
      'javascript:alert(1)',
      'file:///data/data/app/secret',
      'data:text/html;base64,PHNjcmlwdD4=',
      'intent://scan/#Intent;scheme=zxing;end',
      _code(host: 'replyn://auth'),
      _code(host: 'ftp://$_host'),
    ]) {
      expect(_reason(raw), ReplynQrRejection.unsupportedScheme, reason: raw);
    }
  });

  test('rejects text that is not a URL, including bare tokens', () {
    expect(_reason('nvk_${'A' * 43}'), ReplynQrRejection.malformed);
    expect(_reason(_secret), ReplynQrRejection.malformed);
    expect(_reason(_code(host: 'https://')), ReplynQrRejection.malformed);
    expect(_reason(''), ReplynQrRejection.empty);
    expect(_reason('   '), ReplynQrRejection.empty);
    expect(_reason(null), ReplynQrRejection.empty);
  });

  test('rejects payloads over the length limit', () {
    final padded = '$_valid${' ' * ReplynQrParser.maxLength}';
    expect(_reason(padded), ReplynQrRejection.tooLong);
    expect(_reason('https://$_host/${'a' * 600}'), ReplynQrRejection.tooLong);
  });

  test('honours the expiry', () {
    final past = _unix(_now.subtract(const Duration(minutes: 2)));
    expect(_reason(_code(exp: '$past')), ReplynQrRejection.expired);
    // Small clock drift between phone and server is tolerated.
    final justNow = _unix(_now.subtract(const Duration(seconds: 10)));
    expect(_reason(_code(exp: '$justNow')), isNull);
  });

  test('rejects an expiry that is not a sensible timestamp', () {
    for (final exp in ['soon', '-5', '1.5', '9999999999999']) {
      expect(
        _reason(_code(exp: exp)),
        ReplynQrRejection.invalidExpiry,
        reason: exp,
      );
    }
    // Replyn codes live 60 seconds; ten minutes is not one of them.
    final farFuture = _unix(_now.add(const Duration(minutes: 10)));
    expect(_reason(_code(exp: '$farFuture')), ReplynQrRejection.invalidExpiry);
  });

  test('rejects actions and paths Nova does not support', () {
    expect(_reason(_code(action: 'pay')), ReplynQrRejection.unsupportedAction);
    expect(
      _reason(_code(action: 'LOGIN')),
      ReplynQrRejection.unsupportedAction,
    );
    for (final path in ['/auth/other', '/auth/nova/', '/']) {
      expect(
        _reason(_code(path: path)),
        ReplynQrRejection.unsupportedAction,
        reason: path,
      );
    }
  });

  test('extra or repeated query parameters are not ignored', () {
    for (final extra in [
      'returnTo=https://evil.com',
      'redirect=/x',
      'next=//evil.com',
      'url=https://evil.com',
      'handoff=abc',
      'token=abc',
      'novaKey=abc',
    ]) {
      expect(
        _reason('$_valid&$extra'),
        ReplynQrRejection.unexpectedParameter,
        reason: extra,
      );
    }
    for (final repeated in [
      'pairing=$_id',
      'secret=$_secret',
      'exp=$_exp',
      'action=login',
    ]) {
      expect(
        _reason('$_valid&$repeated'),
        ReplynQrRejection.duplicateParameter,
        reason: repeated,
      );
    }
    // An extra parameter does not hide another error either.
    expect(
      _reason(_code(pairing: 'bad', extra: '&returnTo=/x')),
      ReplynQrRejection.unexpectedParameter,
    );
  });

  test('rejects user-info, ports, fragments and backslash tricks', () {
    expect(
      _reason(_code(host: 'https://user@$_host')),
      ReplynQrRejection.userInfo,
    );
    expect(
      _reason(_code(host: 'https://$_host@evil.com')),
      ReplynQrRejection.userInfo,
    );
    expect(
      _reason(_code(host: 'https://$_host:8443')),
      ReplynQrRejection.unexpectedPort,
    );
    expect(_reason('$_valid#evil'), ReplynQrRejection.fragment);
    expect(
      _reason(_code(host: 'https://evil.com\\@$_host')),
      ReplynQrRejection.malformed,
    );
    expect(_reason('$_valid\u0000'), ReplynQrRejection.malformed);
    expect(_reason('$_valid x'), ReplynQrRejection.malformed);
  });

  test('local hosts are only accepted with the dev configuration', () {
    final local = _code(host: 'http://localhost:3000');
    expect(_reason(local), ReplynQrRejection.hostNotAllowed);
    expect(
      _reason(_code(host: 'http://10.0.2.2:3000')),
      ReplynQrRejection.hostNotAllowed,
    );
    expect(_accepted(local, dev: true).displayOrigin, 'localhost:3000');
    // Dev mode does not open up other hosts or plain http elsewhere.
    expect(
      _reason(_code(host: 'http://$_host'), dev: true),
      ReplynQrRejection.insecureScheme,
    );
    expect(
      _reason(_code(host: 'https://192.168.1.8'), dev: true),
      ReplynQrRejection.hostNotAllowed,
    );
  });

  group('allowed hosts', () {
    test('the default build allows only the production Replyn host', () {
      final config = ReplynQrConfig.fromEnvironment();
      expect(config.allowedHosts, {ReplynQrConfig.defaultProductionHost});
      expect(config.allowDevHosts, isFalse);
    });

    test('staging may add exactly one preview host', () {
      const preview = 'replyn-web-git-feat-qr-team.vercel.app';
      final config = ReplynQrConfig.forBuild(
        extraHost: ' Replyn-Web-Git-Feat-QR-Team.vercel.app ',
        environment: AppEnvironment.staging,
      );
      expect(config.allowedHosts, {
        ReplynQrConfig.defaultProductionHost,
        preview,
      });
    });

    test('production ignores the preview host', () {
      final config = ReplynQrConfig.forBuild(
        extraHost: 'replyn-web-git-preview.vercel.app',
        environment: AppEnvironment.production,
      );
      expect(config.allowedHosts, {ReplynQrConfig.defaultProductionHost});
    });

    test('lists, wildcards and malformed hosts fail closed', () {
      for (final extra in [
        'a.vercel.app,b.vercel.app',
        '*.vercel.app',
        '.vercel.app',
        'replyn.vercel.app:443',
        'replyn.vercel.app/path',
        'https://replyn.vercel.app',
        'localhost',
        '',
      ]) {
        final config = ReplynQrConfig.forBuild(
          extraHost: extra,
          environment: AppEnvironment.staging,
        );
        expect(config.allowedHosts, {
          ReplynQrConfig.defaultProductionHost,
        }, reason: extra);
      }
    });
  });
}
