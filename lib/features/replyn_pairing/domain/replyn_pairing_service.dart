import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_pairing_request.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

/// The signed-in Talent who approves the Replyn login.
class NovaTalentIdentity {
  const NovaTalentIdentity({
    required this.displayName,
    required this.initials,
    this.profileId,
    this.email,
  });

  final String displayName;
  final String initials;

  /// The internal profile ID from `/profile/me`; null until it has loaded.
  /// Talent accounts have no public Nova ID (unlike Business `NVB-…`), so
  /// this is never shown, in the Replyn QR flow or as a public code.
  final String? profileId;
  final String? email;
}

enum ReplynPairingOutcome {
  /// Nova bound the code to this account; the browser finishes signing in.
  approved,

  /// The code expired or Nova no longer knows it.
  expired,

  /// Someone already confirmed this code.
  alreadyUsed,

  /// The phone's Nova session is missing or could not be renewed.
  unauthorized,

  /// The signed-in Nova account has no Talent profile to sign in with.
  noTalentProfile,

  /// Nova could not be reached or answered unexpectedly. Safe to retry.
  networkError,
}

/// Approves a Replyn browser login on behalf of the signed-in Talent.
abstract interface class ReplynPairingService {
  Future<ReplynPairingOutcome> confirm(ReplynPairingRequest request);
}

/// Calls Nova's `POST /api/v1/mobile/replyn/pairings/{id}/approve` through the
/// shared [NovaApiClient], which reads the stored access token and renews it
/// once on 401. Nothing about the code is stored on the phone.
class ApiReplynPairingService implements ReplynPairingService {
  const ApiReplynPairingService(this._api);

  final NovaApiClient? _api;

  @override
  Future<ReplynPairingOutcome> confirm(ReplynPairingRequest request) async {
    final api = _api;
    // A demo build without a backend has no Nova session to approve with.
    if (api == null) return ReplynPairingOutcome.unauthorized;
    try {
      await api.approveReplynPairing(request.pairingId, request.qrSecret);
      return ReplynPairingOutcome.approved;
    } on NovaApiException catch (error) {
      return switch (error.statusCode) {
        // 404 means unknown code or wrong secret; to the user it is no longer valid.
        404 || 410 => ReplynPairingOutcome.expired,
        409 => ReplynPairingOutcome.alreadyUsed,
        401 => ReplynPairingOutcome.unauthorized,
        403 => ReplynPairingOutcome.noTalentProfile,
        _ => ReplynPairingOutcome.networkError,
      };
    }
  }
}
