import 'package:flutter_test/flutter_test.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_pairing_request.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_qr_parser.dart';

// Made-up session IDs in Replyn's prototype format; not real codes.
const _id = '0a1b2c3d4e5f';
const _host = 'replyn-web.vercel.app';
const _valid = 'https://$_host/auth/nova?demo-qr=$_id';

final _now = DateTime.utc(2026, 10, 4, 10);
int _unix(DateTime time) => time.millisecondsSinceEpoch ~/ 1000;

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

void main() {
  test('accepts the login code Replyn shows today', () {
    final request = _accepted(_valid);
    expect(request.action, ReplynPairingAction.login);
    expect(request.pairingSessionId, _id);
    expect(request.displayOrigin, _host);
    expect(request.isPrototype, isTrue);
    expect(request.expiresAt, isNull);
    expect(ReplynPairingRequest.provider, 'REPLYN');
    // Surrounding whitespace from the scanner and an explicit action are fine.
    expect(_reason(' $_valid&action=login\n'), isNull);
    // Hostnames are case-insensitive.
    expect(
      _reason('https://Replyn-Web.Vercel.App/auth/nova?demo-qr=$_id'),
      isNull,
    );
  });

  test('the parsed request never prints its session ID', () {
    expect(_accepted(_valid).toString(), isNot(contains(_id)));
  });

  test('rejects a different hostname', () {
    expect(
      _reason('https://example.com/auth/nova?demo-qr=$_id'),
      ReplynQrRejection.hostNotAllowed,
    );
    expect(
      _reason('https://nivex-business.vercel.app/auth/nova?demo-qr=$_id'),
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
        _reason('https://$host/auth/nova?demo-qr=$_id'),
        ReplynQrRejection.hostNotAllowed,
        reason: host,
      );
    }
  });

  test('rejects plain http in production', () {
    expect(
      _reason('http://$_host/auth/nova?demo-qr=$_id'),
      ReplynQrRejection.insecureScheme,
    );
  });

  test('rejects dangerous and custom schemes', () {
    for (final raw in [
      'javascript:alert(1)',
      'file:///data/data/app/secret',
      'data:text/html;base64,PHNjcmlwdD4=',
      'intent://scan/#Intent;scheme=zxing;end',
      'replyn://auth/nova?demo-qr=$_id',
      'ftp://$_host/auth/nova?demo-qr=$_id',
    ]) {
      expect(_reason(raw), ReplynQrRejection.unsupportedScheme, reason: raw);
    }
  });

  test('rejects text that is not a URL, including bare tokens', () {
    expect(_reason('nvk_${'A' * 43}'), ReplynQrRejection.malformed);
    expect(_reason(_id), ReplynQrRejection.malformed);
    expect(
      _reason('https:///auth/nova?demo-qr=$_id'),
      ReplynQrRejection.malformed,
    );
    expect(_reason(''), ReplynQrRejection.empty);
    expect(_reason('   '), ReplynQrRejection.empty);
    expect(_reason(null), ReplynQrRejection.empty);
  });

  test('rejects a missing pairing session ID', () {
    expect(
      _reason('https://$_host/auth/nova'),
      ReplynQrRejection.missingSessionId,
    );
    expect(
      _reason('https://$_host/auth/nova?demo-qr='),
      ReplynQrRejection.missingSessionId,
    );
  });

  test('rejects a badly formed pairing session ID', () {
    for (final id in [
      '0A1B2C3D4E5F',
      '0a1b2c3d4e5',
      '0a1b2c3d4e5f0',
      'zz1b2c3d4e5f',
      '0a1b2c%2F4e5f',
    ]) {
      expect(
        _reason('https://$_host/auth/nova?demo-qr=$id'),
        ReplynQrRejection.invalidSessionId,
        reason: id,
      );
    }
  });

  test('rejects payloads over the length limit', () {
    final padded = '$_valid&action=login${' ' * ReplynQrParser.maxLength}';
    expect(_reason(padded), ReplynQrRejection.tooLong);
    expect(_reason('https://$_host/${'a' * 600}'), ReplynQrRejection.tooLong);
  });

  test('honours an expiry when the code carries one', () {
    final soon = _unix(_now.add(const Duration(seconds: 60)));
    expect(
      _accepted('$_valid&exp=$soon').expiresAt,
      _now.add(const Duration(seconds: 60)),
    );
    final past = _unix(_now.subtract(const Duration(minutes: 2)));
    expect(_reason('$_valid&exp=$past'), ReplynQrRejection.expired);
    // Small clock drift between phone and server is tolerated.
    final justNow = _unix(_now.subtract(const Duration(seconds: 10)));
    expect(_reason('$_valid&exp=$justNow'), isNull);
  });

  test('rejects an expiry that is not a sensible timestamp', () {
    for (final exp in ['soon', '-5', '1.5', '', '9999999999999']) {
      expect(
        _reason('$_valid&exp=$exp'),
        ReplynQrRejection.invalidExpiry,
        reason: exp,
      );
    }
    final farFuture = _unix(_now.add(const Duration(days: 30)));
    expect(_reason('$_valid&exp=$farFuture'), ReplynQrRejection.invalidExpiry);
  });

  test('rejects actions and paths Nova does not support', () {
    expect(_reason('$_valid&action=pay'), ReplynQrRejection.unsupportedAction);
    expect(
      _reason('https://$_host/auth/other?demo-qr=$_id'),
      ReplynQrRejection.unsupportedAction,
    );
    expect(
      _reason('https://$_host/auth/nova/?demo-qr=$_id'),
      ReplynQrRejection.unsupportedAction,
    );
    expect(
      _reason('https://$_host/?demo-qr=$_id'),
      ReplynQrRejection.unsupportedAction,
    );
  });

  test('extra or repeated query parameters are not ignored', () {
    for (final extra in [
      'returnTo=https://evil.com',
      'redirect=/x',
      'next=//evil.com',
      'url=https://evil.com',
      'handoff=abc',
      'token=abc',
    ]) {
      expect(
        _reason('$_valid&$extra'),
        ReplynQrRejection.unexpectedParameter,
        reason: extra,
      );
    }
    expect(
      _reason('$_valid&demo-qr=ffffffffffff'),
      ReplynQrRejection.duplicateParameter,
    );
    // An extra parameter does not hide another error either.
    expect(
      _reason('https://$_host/auth/nova?demo-qr=bad&returnTo=/x'),
      ReplynQrRejection.unexpectedParameter,
    );
  });

  test('rejects user-info, ports, fragments and backslash tricks', () {
    expect(
      _reason('https://user@$_host/auth/nova?demo-qr=$_id'),
      ReplynQrRejection.userInfo,
    );
    expect(
      _reason('https://$_host@evil.com/auth/nova?demo-qr=$_id'),
      ReplynQrRejection.userInfo,
    );
    expect(
      _reason('https://$_host:8443/auth/nova?demo-qr=$_id'),
      ReplynQrRejection.unexpectedPort,
    );
    expect(_reason('$_valid#evil'), ReplynQrRejection.fragment);
    expect(
      _reason('https://evil.com\\@$_host/auth/nova?demo-qr=$_id'),
      ReplynQrRejection.malformed,
    );
    expect(
      _reason('https://$_host/auth/nova?demo-qr=$_id\u0000'),
      ReplynQrRejection.malformed,
    );
    expect(
      _reason('https://$_host/auth/nova?demo-qr=$_id x'),
      ReplynQrRejection.malformed,
    );
  });

  test('local hosts are only accepted with the dev configuration', () {
    const local = 'http://localhost:3000/auth/nova?demo-qr=$_id';
    expect(_reason(local), ReplynQrRejection.hostNotAllowed);
    expect(
      _reason('http://10.0.2.2:3000/auth/nova?demo-qr=$_id'),
      ReplynQrRejection.hostNotAllowed,
    );
    expect(_accepted(local, dev: true).displayOrigin, 'localhost:3000');
    // Dev mode does not open up other hosts or plain http elsewhere.
    expect(
      _reason('http://$_host/auth/nova?demo-qr=$_id', dev: true),
      ReplynQrRejection.insecureScheme,
    );
    expect(
      _reason('https://192.168.1.8/auth/nova?demo-qr=$_id', dev: true),
      ReplynQrRejection.hostNotAllowed,
    );
  });

  test('the default configuration allows only the production Replyn host', () {
    final config = ReplynQrConfig.fromEnvironment();
    expect(config.allowedHosts, {ReplynQrConfig.defaultProductionHost});
    expect(config.allowDevHosts, isFalse);
  });
}
