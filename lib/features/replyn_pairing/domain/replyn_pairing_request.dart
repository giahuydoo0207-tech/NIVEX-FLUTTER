/// What a Replyn QR code may ask Nova to do. Only browser login exists today.
enum ReplynPairingAction { login }

/// A Replyn QR code that passed validation. Widgets receive this instead of
/// the raw scanned text, so nothing downstream re-reads an untrusted URL.
class ReplynPairingRequest {
  const ReplynPairingRequest({
    required this.action,
    required this.pairingSessionId,
    required this.displayOrigin,
    required this.isPrototype,
    this.expiresAt,
  });

  static const provider = 'REPLYN';

  final ReplynPairingAction action;

  /// Identifies the browser session on Replyn that showed the code.
  final String pairingSessionId;

  /// Host the code came from, shown to the user (e.g. `replyn-web.vercel.app`).
  final String displayOrigin;

  /// True for Replyn's current `demo-qr` codes, which no backend can approve.
  final bool isPrototype;

  /// Null when the code carries no expiry (Replyn's prototype expires it in
  /// the browser only).
  final DateTime? expiresAt;

  // Keeps the session ID out of logs and error reports that print objects.
  @override
  String toString() =>
      'ReplynPairingRequest($action, origin: $displayOrigin, prototype: $isPrototype)';
}
