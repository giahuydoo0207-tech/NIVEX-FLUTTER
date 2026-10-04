import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_pairing_request.dart';

/// The signed-in Talent who would approve the Replyn login.
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
  /// this must not be presented as one.
  final String? profileId;
  final String? email;
}

enum ReplynPairingOutcome {
  /// The code was read and confirmed on the phone, but no backend approved
  /// it: Replyn is not signed in.
  prototypeOnly,
}

/// Approves a Replyn browser login on behalf of the signed-in Talent.
///
/// The real implementation will call Nova's
/// `POST /api/v1/mobile/replyn/pairings/approve` (planned in Replyn's
/// `docs/architecture/nova-supabase-integration.md` §4.5) with the Nova
/// session; that endpoint does not exist yet.
abstract interface class ReplynPairingService {
  Future<ReplynPairingOutcome> confirm(
    ReplynPairingRequest request,
    NovaTalentIdentity talent,
  );
}

/// Used until the pairing backend exists. It makes no network call, stores
/// nothing and never reports a successful login.
class PrototypeReplynPairingService implements ReplynPairingService {
  const PrototypeReplynPairingService();

  @override
  Future<ReplynPairingOutcome> confirm(
    ReplynPairingRequest request,
    NovaTalentIdentity talent,
  ) async => ReplynPairingOutcome.prototypeOnly;
}
