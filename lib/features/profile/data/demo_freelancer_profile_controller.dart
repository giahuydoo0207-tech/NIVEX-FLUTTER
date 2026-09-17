import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nivex_flutter/features/profile/domain/freelancer_profile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DemoFreelancerProfileController extends ChangeNotifier {
  DemoFreelancerProfileController._() {
    _restoreMedia();
  }

  static final instance = DemoFreelancerProfileController._();

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

  Future<void> update(FreelancerProfile nextProfile) async {
    var stableProfile = nextProfile;
    if (nextProfile.avatarPath != profile.avatarPath) {
      final stableAvatarPath = await _persistAvatar(nextProfile.avatarPath);
      stableProfile = stableProfile.copyWith(
        avatarPath: stableAvatarPath,
        clearAvatar: stableAvatarPath == null,
      );
    }
    if (nextProfile.coverPath != profile.coverPath) {
      final stableCoverPath = await _persistCover(nextProfile.coverPath);
      stableProfile = stableProfile.copyWith(
        coverPath: stableCoverPath,
        clearCover: stableCoverPath == null,
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
      if (validAvatar != null || validCover != null) {
        profile = profile.copyWith(
          avatarPath: validAvatar,
          coverPath: validCover,
        );
        notifyListeners();
      }
    } catch (_) {
      // Persistence is best-effort until the profile API is connected.
    }
  }

  Future<String?> _persistAvatar(String? sourcePath) async {
    final preferences = SharedPreferencesAsync();
    if (sourcePath == null) {
      final previousPath = await preferences.getString(_avatarPreferenceKey);
      if (previousPath != null) {
        final previousFile = File(previousPath);
        if (await previousFile.exists()) await previousFile.delete();
      }
      await preferences.remove(_avatarPreferenceKey);
      return null;
    }

    final source = File(sourcePath);
    if (!await source.exists()) return null;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dotIndex = sourcePath.lastIndexOf('.');
    final extension = dotIndex >= 0 ? sourcePath.substring(dotIndex) : '.jpg';
    final destination = File(
      '${documentsDirectory.path}${Platform.pathSeparator}nivex_profile_avatar$extension',
    );
    final copiedAvatar = source.path == destination.path
        ? source
        : await source.copy(destination.path);
    await preferences.setString(_avatarPreferenceKey, copiedAvatar.path);
    return copiedAvatar.path;
  }

  Future<String?> _persistCover(String? sourcePath) async {
    final preferences = SharedPreferencesAsync();
    if (sourcePath == null) {
      final previousPath = await preferences.getString(_coverPreferenceKey);
      if (previousPath != null) {
        final previousFile = File(previousPath);
        if (await previousFile.exists()) await previousFile.delete();
      }
      await preferences.remove(_coverPreferenceKey);
      return null;
    }

    final source = File(sourcePath);
    if (!await source.exists()) return null;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dotIndex = sourcePath.lastIndexOf('.');
    final extension = dotIndex >= 0 ? sourcePath.substring(dotIndex) : '.jpg';
    final destination = File(
      '${documentsDirectory.path}${Platform.pathSeparator}nivex_profile_cover$extension',
    );
    final copiedCover = source.path == destination.path
        ? source
        : await source.copy(destination.path);
    await preferences.setString(_coverPreferenceKey, copiedCover.path);
    return copiedCover.path;
  }
}
