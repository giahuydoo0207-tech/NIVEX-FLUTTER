import 'package:flutter/foundation.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_pairing_request.dart';
import 'package:nivex_flutter/shared/constants/app_environment.dart';

/// Why a scanned code was refused. The UI groups these into a few messages;
/// tests assert the exact reason.
enum ReplynQrRejection {
  empty,
  tooLong,
  malformed,
  unsupportedScheme,
  insecureScheme,
  hostNotAllowed,
  userInfo,
  unexpectedPort,
  fragment,
  unsupportedAction,
  missingPairing,
  invalidPairing,
  missingSecret,
  invalidSecret,
  unexpectedParameter,
  duplicateParameter,
  missingExpiry,
  invalidExpiry,
  expired,
}

sealed class ReplynQrResult {
  const ReplynQrResult();
}

class ReplynQrAccepted extends ReplynQrResult {
  const ReplynQrAccepted(this.request);
  final ReplynPairingRequest request;
}

class ReplynQrRejected extends ReplynQrResult {
  const ReplynQrRejected(this.reason);
  final ReplynQrRejection reason;

  @override
  String toString() => 'ReplynQrRejected($reason)';
}

/// Which Replyn hosts a code may point at.
class ReplynQrConfig {
  const ReplynQrConfig({
    required this.allowedHosts,
    this.allowDevHosts = false,
  });

  /// The production host is always allowed. A non-production build may add
  /// exactly one preview host with `REPLYN_ALLOWED_HOSTS`. Local hosts need
  /// `REPLYN_ALLOW_DEV_HOSTS=true` and are never accepted in a release build.
  factory ReplynQrConfig.fromEnvironment() {
    const extraHost = String.fromEnvironment('REPLYN_ALLOWED_HOSTS');
    const allowDev = bool.fromEnvironment('REPLYN_ALLOW_DEV_HOSTS');
    return ReplynQrConfig.forBuild(
      extraHost: extraHost,
      environment: AppEnvironmentConfig.fromBuild(),
      allowDevHosts: allowDev && !kReleaseMode,
    );
  }

  /// [extraHost] is ignored in production, and also when it is not exactly
  /// one plain hostname (no list, wildcard, port or path), so a bad build
  /// setting fails closed to the production host only.
  factory ReplynQrConfig.forBuild({
    required String extraHost,
    required AppEnvironment environment,
    bool allowDevHosts = false,
  }) {
    final extra = extraHost
        .split(',')
        .map((host) => host.trim().toLowerCase())
        .where((host) => host.isNotEmpty && host != defaultProductionHost)
        .toList();
    final usable =
        !environment.isProduction &&
        extra.length == 1 &&
        _hostname.hasMatch(extra.single);
    return ReplynQrConfig(
      allowedHosts: {defaultProductionHost, if (usable) extra.single},
      allowDevHosts: allowDevHosts,
    );
  }

  static const defaultProductionHost = 'replyn-web.vercel.app';
  static const devHosts = {'localhost', '127.0.0.1', '10.0.2.2'};
  static final _hostname = RegExp(
    r'^(?=.{1,253}$)([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$',
  );

  /// Exact hostnames; subdomains and look-alikes do not match.
  final Set<String> allowedHosts;
  final bool allowDevHosts;

  /// The Replyn web host this build sends people to: the preview host of a
  /// non-production build when one is configured, otherwise production.
  String get primaryHost => allowedHosts.firstWhere(
    (host) => host != defaultProductionHost,
    orElse: () => defaultProductionHost,
  );
}

/// Validates Replyn login QR codes. The only accepted format is the one
/// Replyn's server creates:
///
/// ```text
/// https://<allowed-host>/auth/nova?pairing=<uuid>&secret=<43 base64url>&exp=<unix seconds>&action=login
/// ```
///
/// Every parameter is required exactly once; anything else is refused.
class ReplynQrParser {
  ReplynQrParser(this.config, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final ReplynQrConfig config;
  final DateTime Function() _now;

  static const maxLength = 512;
  static const loginPath = '/auth/nova';
  static const _pairingParam = 'pairing';
  static const _secretParam = 'secret';
  static const _expiryParam = 'exp';
  static const _actionParam = 'action';
  static const _allowedParams = {
    _pairingParam,
    _secretParam,
    _expiryParam,
    _actionParam,
  };
  // Lowercase canonical RFC 4122 UUID, as Nova's backend prints it.
  static final _pairingId = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );
  // 32 random bytes in base64url without padding. The last character only
  // carries 4 bits, so only 16 values are canonical.
  static final _secret = RegExp(r'^[A-Za-z0-9_-]{42}[AEIMQUYcgkosw048]$');
  static final _digits = RegExp(r'^[0-9]{1,12}$');
  // Whitespace, control characters and backslashes have no place in the URL
  // and are a common way to make parsers disagree about the host.
  static final _forbiddenChars = RegExp(r'[\s\x00-\x1f\x7f\\]');

  /// Replyn codes live 60 seconds; anything claiming to last much longer is
  /// not one of them...
  static const maxLifetime = Duration(minutes: 2);

  /// ...and this much clock drift between phone and server is tolerated.
  static const clockSkew = Duration(seconds: 30);

  ReplynQrResult parse(String? raw) {
    if (raw == null) return const ReplynQrRejected(ReplynQrRejection.empty);
    if (raw.length > maxLength) {
      return const ReplynQrRejected(ReplynQrRejection.tooLong);
    }
    final text = raw.trim();
    if (text.isEmpty) return const ReplynQrRejected(ReplynQrRejection.empty);
    if (_forbiddenChars.hasMatch(text)) {
      return const ReplynQrRejected(ReplynQrRejection.malformed);
    }

    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasScheme) {
      return const ReplynQrRejected(ReplynQrRejection.malformed);
    }
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'https' && scheme != 'http') {
      return const ReplynQrRejected(ReplynQrRejection.unsupportedScheme);
    }
    if (!uri.hasAuthority || uri.host.isEmpty) {
      return const ReplynQrRejected(ReplynQrRejection.malformed);
    }
    if (uri.userInfo.isNotEmpty) {
      return const ReplynQrRejected(ReplynQrRejection.userInfo);
    }

    final host = uri.host.toLowerCase();
    final isDevHost =
        config.allowDevHosts && ReplynQrConfig.devHosts.contains(host);
    if (!isDevHost && !config.allowedHosts.contains(host)) {
      return const ReplynQrRejected(ReplynQrRejection.hostNotAllowed);
    }
    if (scheme == 'http' && !isDevHost) {
      return const ReplynQrRejected(ReplynQrRejection.insecureScheme);
    }
    if (!isDevHost && uri.hasPort && uri.port != 443) {
      return const ReplynQrRejected(ReplynQrRejection.unexpectedPort);
    }
    if (uri.hasFragment) {
      return const ReplynQrRejected(ReplynQrRejection.fragment);
    }
    if (uri.path != loginPath) {
      return const ReplynQrRejected(ReplynQrRejection.unsupportedAction);
    }

    final Map<String, List<String>> params;
    try {
      params = uri.queryParametersAll;
    } on FormatException {
      return const ReplynQrRejected(ReplynQrRejection.malformed);
    }
    for (final entry in params.entries) {
      if (!_allowedParams.contains(entry.key)) {
        return const ReplynQrRejected(ReplynQrRejection.unexpectedParameter);
      }
      if (entry.value.length != 1) {
        return const ReplynQrRejected(ReplynQrRejection.duplicateParameter);
      }
    }

    if (params[_actionParam]?.single != 'login') {
      return const ReplynQrRejected(ReplynQrRejection.unsupportedAction);
    }

    final pairingId = params[_pairingParam]?.single;
    if (pairingId == null || pairingId.isEmpty) {
      return const ReplynQrRejected(ReplynQrRejection.missingPairing);
    }
    if (!_pairingId.hasMatch(pairingId)) {
      return const ReplynQrRejected(ReplynQrRejection.invalidPairing);
    }

    final secret = params[_secretParam]?.single;
    if (secret == null || secret.isEmpty) {
      return const ReplynQrRejected(ReplynQrRejection.missingSecret);
    }
    if (!_secret.hasMatch(secret)) {
      return const ReplynQrRejected(ReplynQrRejection.invalidSecret);
    }

    final exp = params[_expiryParam]?.single;
    if (exp == null || exp.isEmpty) {
      return const ReplynQrRejected(ReplynQrRejection.missingExpiry);
    }
    if (!_digits.hasMatch(exp)) {
      return const ReplynQrRejected(ReplynQrRejection.invalidExpiry);
    }
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      int.parse(exp) * 1000,
      isUtc: true,
    );
    final now = _now().toUtc();
    if (expiresAt.isAfter(now.add(maxLifetime + clockSkew))) {
      return const ReplynQrRejected(ReplynQrRejection.invalidExpiry);
    }
    if (now.isAfter(expiresAt.add(clockSkew))) {
      return const ReplynQrRejected(ReplynQrRejection.expired);
    }

    return ReplynQrAccepted(
      ReplynPairingRequest(
        action: ReplynPairingAction.login,
        pairingId: pairingId,
        qrSecret: secret,
        displayOrigin: uri.hasPort && isDevHost ? '$host:${uri.port}' : host,
        expiresAt: expiresAt,
      ),
    );
  }
}
