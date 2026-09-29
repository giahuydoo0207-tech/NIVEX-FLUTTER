import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:nivex_flutter/features/profile/domain/freelancer_profile.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';
import 'package:nivex_flutter/shared/constants/demo_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared profile state. With a backend connected, identity (name, Nova ID,
/// email, headline, bio, avatar) comes from the server; the demo values below
/// are only shown when the app runs without a backend.
class DemoFreelancerProfileController extends ChangeNotifier {
  DemoFreelancerProfileController._() {
    _mediaRestored = _restoreMedia();
  }

  static final instance = DemoFreelancerProfileController._();

  /// A fresh controller, as after an app restart.
  @visibleForTesting
  factory DemoFreelancerProfileController.fresh() =>
      DemoFreelancerProfileController._();

  late final Future<void> _mediaRestored;

  /// Set once media is changed; a slower startup restore then must not
  /// overwrite the newer choice with the previously saved paths.
  bool _mediaChanged = false;

  @visibleForTesting
  Future<void> get mediaRestored => _mediaRestored;

  FreelancerProfile profile = const FreelancerProfile(
    displayName: 'Minh Anh',
    username: 'minhanh.nova',
    headline: 'Flutter Developer | Fintech Mobile Applications',
    bio:
        'Tôi xây dựng ứng dụng Flutter cho fintech và các sản phẩm thanh toán. '
        'Tôi tập trung vào giao diện responsive, code dễ bảo trì và tiến độ minh bạch theo từng giai đoạn.',
    location: 'Đà Nẵng, Việt Nam',
    timezone: 'UTC+7',
    languages: ['Tiếng Việt', 'English'],
    skills: [
      'Flutter',
      'Dart',
      'Java',
      'Spring Boot',
      'PostgreSQL',
      'REST API',
      'Solana',
      'Git',
    ],
    experiences: [
      FreelancerExperience(
        title: 'Flutter Developer',
        organization: 'Independent Freelancer',
        period: '2024 - nay',
        summary: 'Xây dựng auth flow, wallet, payment request và kiểm thử responsive trên thiết bị Android thật.',
      ),
    ],
    education: [
      FreelancerEducation(
        program: 'Kỹ thuật phần mềm',
        institution: 'Đại học FPT Đà Nẵng',
        period: 'Sinh viên · 2023 - 2027',
        note: 'Thông tin do người dùng tự khai',
      ),
    ],
    projects: [
      FreelancerProject(
        title: 'Nova Mobile Prototype',
        role: 'Flutter Developer',
        summary: 'Ứng dụng hỗ trợ freelancer tìm việc, trao đổi và theo dõi thanh toán quốc tế.',
        technologies: ['Flutter', 'Dart', 'Solana Devnet'],
        status: 'Prototype',
        link: 'https://github.com/giahuydoo0207-tech/NIVEX-FLUTTER',
      ),
      FreelancerProject(
        title: 'Nova Business',
        role: 'Product & Frontend Developer',
        summary: 'Không gian doanh nghiệp để đăng cơ hội, xét duyệt ứng viên và quản lý yêu cầu thanh toán.',
        technologies: ['Next.js', 'TypeScript', 'UI/UX'],
        status: 'Đang phát triển',
        link: 'https://nivex-business.vercel.app',
      ),
    ],
    visibility: ProfileVisibility.registeredUsers,
    isAvailable: true,
    weeklyCapacityHours: 20,
    workPreference: 'Remote · Theo dự án',
    startAvailability: 'Có thể bắt đầu trong 1 tuần',
    profileHeaderTheme: ProfileHeaderTheme.flow,
  );

  static const _avatarPreferenceKey = 'nivex_profile_avatar_path';
  static const _coverPreferenceKey = 'nivex_profile_cover_path';

  NovaApiClient? _api;

  /// Absolute, versioned avatar URL from the backend.
  String? avatarUrl;

  /// Absolute, versioned cover URL from the backend.
  String? coverUrl;

  ImageProvider? get coverImage {
    final url = coverUrl;
    if (url != null) return NetworkImage(url);
    final path = profile.coverPath;
    return path == null ? null : FileImage(File(path));
  }

  /// Removes the cover locally and, when connected, on the backend first.
  Future<void> removeCover() async {
    final api = _api;
    if (api != null) {
      final updated = await api.deleteProfileCover();
      if (identical(api, _api)) _applyRemote(api, updated);
    }
    _mediaChanged = true;
    await _replaceStoredMedia(_coverPreferenceKey, null);
    profile = profile.copyWith(clearCover: true);
    notifyListeners();
  }
  NovaPublicProfile? remoteProfile;
  NovaAccount? account;
  bool isLoadingRemote = false;
  bool remoteFailed = false;

  bool get hasBackend => _api != null;

  /// Empty while a connected account is still loading, never the demo name.
  String get displayName =>
      remoteProfile?.displayName ??
      account?.displayName ??
      (hasBackend ? '' : profile.displayName);

  String? get novaId =>
      remoteProfile?.id ?? (hasBackend ? null : DemoData.nivexId);

  String? get email => hasBackend ? account?.email : 'minh.anh@nova.demo';

  String? get phone => account?.phoneE164;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    final letters = parts.where((part) => part.isNotEmpty).map((p) => p[0]);
    final value = letters.length <= 2
        ? letters.join()
        : '${letters.first}${letters.last}';
    return value.isEmpty ? 'N' : value.toUpperCase();
  }

  ImageProvider? get avatarImage {
    final url = avatarUrl;
    if (url != null) return NetworkImage(url);
    final path = profile.avatarPath;
    return path == null ? null : FileImage(File(path));
  }

  void connect(NovaApiClient? api) {
    if (identical(api, _api)) return;
    _api = api;
    avatarUrl = null;
    coverUrl = null;
    remoteProfile = null;
    account = null;
    remoteFailed = false;
    if (api != null) unawaited(refreshRemote());
  }

  /// Loads `/profile/me` and `/auth/me`. [using] lets a screen with its own
  /// client refresh the shared state without reconnecting it.
  Future<void> refreshRemote({NovaApiClient? using}) async {
    final api = using ?? _api;
    if (api == null) return;
    isLoadingRemote = true;
    try {
      final me = await api.myProfile();
      NovaAccount? loadedAccount;
      try {
        loadedAccount = await api.myAccount();
      } on NovaApiException {
        // Name and Nova ID still come from the profile.
      }
      _applyRemote(api, me);
      account = loadedAccount ?? account;
      remoteFailed = false;
    } on NovaApiException {
      remoteFailed = remoteProfile == null;
    } finally {
      isLoadingRemote = false;
      notifyListeners();
    }
  }

  void _applyRemote(NovaApiClient api, NovaPublicProfile me) {
    remoteProfile = me;
    avatarUrl = me.avatarUrl == null ? null : api.mediaUri(me.avatarUrl!).toString();
    coverUrl = me.coverUrl == null ? null : api.mediaUri(me.coverUrl!).toString();
    profile = profile.copyWith(
      displayName: me.displayName,
      headline: me.headline,
      bio: me.bio,
    );
  }

  /// Saves name, headline and bio: to the backend when connected (throws
  /// [NovaApiException] on failure, leaving state unchanged), otherwise locally.
  Future<void> saveBasics({
    required String displayName,
    required String headline,
    required String bio,
  }) async {
    final api = _api;
    if (api != null) {
      final updated = await api.updateMyProfile(
        displayName: displayName,
        headline: headline,
        bio: bio,
      );
      if (identical(api, _api)) _applyRemote(api, updated);
    } else {
      profile = profile.copyWith(
        displayName: displayName.trim(),
        headline: headline.trim(),
        bio: bio.trim(),
      );
    }
    notifyListeners();
  }

  /// Uploads first; the local copy only changes after the backend accepted
  /// the image, so a failed upload never looks like a success.
  Future<void> uploadAvatar(Uint8List bytes, String contentType) async {
    final api = _api;
    NovaPublicProfile? updated;
    if (api != null) {
      updated = await api.uploadProfileAvatar(bytes, contentType);
    }
    final extension = switch (contentType) {
      'image/png' => '.png',
      'image/webp' => '.webp',
      _ => '.jpg',
    };
    final file = await _uniqueMediaFile('nivex_profile_avatar', extension);
    await file.writeAsBytes(bytes, flush: true);
    await _replaceStoredMedia(_avatarPreferenceKey, file.path);
    _mediaChanged = true;
    profile = profile.copyWith(avatarPath: file.path);
    if (api != null && updated != null && identical(api, _api)) {
      _applyRemote(api, updated);
    }
    notifyListeners();
  }

  /// Persists local-only fields. Media paths are copied into the app
  /// documents directory before the profile changes; throws if that fails.
  Future<void> update(FreelancerProfile nextProfile) async {
    var stableProfile = nextProfile;
    if (nextProfile.avatarPath != profile.avatarPath ||
        nextProfile.coverPath != profile.coverPath) {
      _mediaChanged = true;
    }
    if (nextProfile.avatarPath != profile.avatarPath) {
      final path = await _persistMedia(
        _avatarPreferenceKey,
        'nivex_profile_avatar',
        nextProfile.avatarPath,
      );
      stableProfile = stableProfile.copyWith(
        avatarPath: path,
        clearAvatar: path == null,
      );
    }
    if (nextProfile.coverPath != profile.coverPath) {
      final api = _api;
      final source = nextProfile.coverPath;
      if (api != null && source != null) {
        // Upload first: a failed upload must not look like a saved cover.
        final file = File(source);
        if (!await file.exists()) {
          throw FileSystemException('Selected image is no longer available', source);
        }
        final lower = source.toLowerCase();
        final updated = await api.uploadProfileCover(
          await file.readAsBytes(),
          lower.endsWith('.png')
              ? 'image/png'
              : lower.endsWith('.webp')
              ? 'image/webp'
              : 'image/jpeg',
        );
        if (identical(api, _api)) {
          _applyRemote(api, updated);
          stableProfile = stableProfile.copyWith(
            displayName: updated.displayName,
            headline: updated.headline,
            bio: updated.bio,
          );
        }
      }
      final path = await _persistMedia(
        _coverPreferenceKey,
        'nivex_profile_cover',
        nextProfile.coverPath,
      );
      stableProfile = stableProfile.copyWith(
        coverPath: path,
        clearCover: path == null,
      );
    }
    profile = stableProfile;
    notifyListeners();
  }

  Future<void> _restoreMedia() async {
    try {
      final preferences = SharedPreferencesAsync();
      final avatarPath = await preferences.getString(_avatarPreferenceKey);
      final coverPath = await preferences.getString(_coverPreferenceKey);
      final validAvatar =
          (avatarPath != null && await File(avatarPath).exists())
          ? avatarPath
          : null;
      final validCover = (coverPath != null && await File(coverPath).exists())
          ? coverPath
          : null;
      if (_mediaChanged) return;
      if (validAvatar != null || validCover != null) {
        profile = profile.copyWith(
          avatarPath: validAvatar,
          coverPath: validCover,
        );
        notifyListeners();
      }
    } catch (_) {
      // A missing or unreadable preference just means no saved media.
    }
  }

  Future<String?> _persistMedia(
    String preferenceKey,
    String baseName,
    String? sourcePath,
  ) async {
    if (sourcePath == null) {
      await _replaceStoredMedia(preferenceKey, null);
      return null;
    }
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException('Selected image is no longer available', sourcePath);
    }
    final dotIndex = sourcePath.lastIndexOf('.');
    final extension = dotIndex > sourcePath.lastIndexOf(Platform.pathSeparator)
        ? sourcePath.substring(dotIndex)
        : '.jpg';
    final destination = await _uniqueMediaFile(baseName, extension);
    await source.copy(destination.path);
    await _replaceStoredMedia(preferenceKey, destination.path);
    return destination.path;
  }

  /// A new name per save: Image.file/FileImage cache decoded images by path.
  Future<File> _uniqueMediaFile(String baseName, String extension) async {
    final directory = await getApplicationDocumentsDirectory();
    return File(
      '${directory.path}${Platform.pathSeparator}'
      '${baseName}_${DateTime.now().microsecondsSinceEpoch}$extension',
    );
  }

  Future<void> _replaceStoredMedia(String preferenceKey, String? newPath) async {
    final preferences = SharedPreferencesAsync();
    final previousPath = await preferences.getString(preferenceKey);
    if (newPath == null) {
      await preferences.remove(preferenceKey);
    } else {
      await preferences.setString(preferenceKey, newPath);
    }
    if (previousPath != null && previousPath != newPath) {
      final previous = File(previousPath);
      if (await previous.exists()) await previous.delete();
    }
  }
}
