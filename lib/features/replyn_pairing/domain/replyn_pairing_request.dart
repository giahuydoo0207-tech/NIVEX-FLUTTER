/// What a Replyn QR code may ask Nova to do. Only browser login exists today.
enum ReplynPairingAction { login }

/// A Replyn QR code that passed validation. Widgets receive this instead of
/// the raw scanned text, so nothing downstream re-reads an untrusted URL.
class ReplynPairingRequest {
  const ReplynPairingRequest({
    required this.action,
    required this.pairingId,
    required this.qrSecret,
    required this.displayOrigin,
    required this.expiresAt,
  });

  static const provider = 'REPLYN';

  final ReplynPairingAction action;

  /// The login challenge Replyn's server created (a UUID).
  final String pairingId;

  /// One-time secret from the QR code. It is sent only in the body of the
  /// approve request to Nova and must never be logged, shown or stored.
  final String qrSecret;

  /// Host the code came from, shown to the user (e.g. `replyn-web.vercel.app`).
  final String displayOrigin;

  /// When Replyn stops accepting the code (60 seconds after it was created).
  final DateTime expiresAt;

  // Keeps the pairing ID and the QR secret out of logs and error reports that
  // print objects.
  @override
  String toString() => 'ReplynPairingRequest($action, origin: $displayOrigin)';
}
