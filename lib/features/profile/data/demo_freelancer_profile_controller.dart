import 'package:flutter/foundation.dart';
import 'package:nivex_flutter/features/profile/domain/freelancer_profile.dart';

class DemoFreelancerProfileController extends ChangeNotifier {
  DemoFreelancerProfileController._();

  static final instance = DemoFreelancerProfileController._();

  FreelancerProfile profile = const FreelancerProfile(
    displayName: 'Minh Anh',
    username: 'minhanh.nivex',
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
        title: 'NIVEX Mobile Prototype',
        role: 'Flutter Developer',
        summary: 'Ứng dụng hỗ trợ freelancer tìm việc, trao đổi và theo dõi thanh toán quốc tế.',
        technologies: ['Flutter', 'Dart', 'Solana Devnet'],
        status: 'Prototype',
        link: 'https://github.com/giahuydoo0207-tech/NIVEX-FLUTTER',
      ),
      FreelancerProject(
        title: 'NIVEX Business',
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

  void update(FreelancerProfile nextProfile) {
    profile = nextProfile;
    notifyListeners();
  }
}
