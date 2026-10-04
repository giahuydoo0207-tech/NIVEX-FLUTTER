import 'package:flutter/widgets.dart';
import 'package:nivex_flutter/features/profile/data/demo_freelancer_profile_controller.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_pairing_service.dart';

/// The Nova account shown on the Replyn confirmation step.
abstract interface class ReplynAccountSource implements Listenable {
  /// Null while a connected account is still loading or failed to load.
  NovaTalentIdentity? get identity;
  ImageProvider? get avatar;
  bool get failed;
}

/// Reads the signed-in Talent from the shared profile state, which loads
/// `/profile/me` and `/auth/me` for a live session.
class ProfileAccountSource implements ReplynAccountSource {
  ProfileAccountSource([DemoFreelancerProfileController? profile])
    : _profile = profile ?? DemoFreelancerProfileController.instance;

  final DemoFreelancerProfileController _profile;

  @override
  NovaTalentIdentity? get identity {
    final name = _profile.displayName.trim();
    if (name.isEmpty) return null;
    return NovaTalentIdentity(
      displayName: name,
      initials: _profile.initials,
      // The controller calls this `novaId`, but it is the legacy profile ID
      // from `/profile/me` (`remoteProfile.id`), not a public Nova ID.
      profileId: _profile.novaId,
      email: _profile.email,
    );
  }

  @override
  ImageProvider? get avatar => _profile.avatarImage;

  @override
  bool get failed => _profile.remoteFailed;

  @override
  void addListener(VoidCallback listener) => _profile.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _profile.removeListener(listener);
}
