import 'package:flutter/foundation.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_pairing_request.dart';

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
  missingSessionId,
  invalidSessionId,
  unexpectedParameter,
  duplicateParameter,
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

  /// `REPLYN_ALLOWED_HOSTS` (comma separated) overrides the production host.
  /// Local hosts need `REPLYN_ALLOW_DEV_HOSTS=true` and are never accepted in
  /// a release build.
  factory ReplynQrConfig.fromEnvironment() {
    const hosts = String.fromEnvironment(
      'REPLYN_ALLOWED_HOSTS',
      defaultValue: defaultProductionHost,
    );
    const allowDev = bool.fromEnvironment('REPLYN_ALLOW_DEV_HOSTS');
    return ReplynQrConfig(
      allowedHosts: hosts
          .split(',')
          .map((host) => host.trim().toLowerCase())
          .where((host) => host.isNotEmpty)
          .toSet(),
      allowDevHosts: allowDev && !kReleaseMode,
    );
  }

  static const defaultProductionHost = 'replyn-web.vercel.app';
  static const devHosts = {'localhost', '127.0.0.1', '10.0.2.2'};

  /// Exact hostnames; subdomains and look-alikes do not match.
  final Set<String> allowedHosts;
  final bool allowDevHosts;
}

/// Validates Replyn login QR codes. The supported format is the one Replyn's
/// `/auth/nova` page shows today:
///
/// ```text
/// https://<allowed-host>/auth/nova?demo-qr=<12 hex>[&exp=<unix seconds>][&action=login]
/// ```
///
/// Anything else, including extra query parameters, is refused.
class ReplynQrParser {
  ReplynQrParser(this.config, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final ReplynQrConfig config;
  final DateTime Function() _now;

  static const maxLength = 512;
  static const loginPath = '/auth/nova';
  static const _sessionParam = 'demo-qr';
  static const _expiryParam = 'exp';
  static const _actionParam = 'action';
  static const _allowedParams = {_sessionParam, _expiryParam, _actionParam};
  static final _sessionId = RegExp(r'^[0-9a-f]{12}$');
  static final _digits = RegExp(r'^[0-9]{1,12}$');
  // Whitespace, control characters and backslashes have no place in the URL
  // and are a common way to make parsers disagree about the host.
  static final _forbiddenChars = RegExp(r'[\s\x00-\x1f\x7f\\]');

  /// Codes may be shown up to this long before they expire...
  static const maxLifetime = Duration(minutes: 10);

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

    final action = params[_actionParam]?.single;
    if (action != null && action != 'login') {
      return const ReplynQrRejected(ReplynQrRejection.unsupportedAction);
    }

    final sessionId = params[_sessionParam]?.single;
    if (sessionId == null || sessionId.isEmpty) {
      return const ReplynQrRejected(ReplynQrRejection.missingSessionId);
    }
    if (!_sessionId.hasMatch(sessionId)) {
      return const ReplynQrRejected(ReplynQrRejection.invalidSessionId);
    }

    DateTime? expiresAt;
    final exp = params[_expiryParam]?.single;
    if (exp != null) {
      if (!_digits.hasMatch(exp)) {
        return const ReplynQrRejected(ReplynQrRejection.invalidExpiry);
      }
      expiresAt = DateTime.fromMillisecondsSinceEpoch(
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
    }

    return ReplynQrAccepted(
      ReplynPairingRequest(
        action: ReplynPairingAction.login,
        pairingSessionId: sessionId,
        displayOrigin: uri.hasPort && isDevHost ? '$host:${uri.port}' : host,
        isPrototype: true,
        expiresAt: expiresAt,
      ),
    );
  }
}
