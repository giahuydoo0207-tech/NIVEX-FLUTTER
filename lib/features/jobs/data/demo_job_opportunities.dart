import 'package:nivex_flutter/features/jobs/domain/job_opportunity.dart';

abstract final class DemoJobOpportunities {
  static const items = [
    JobOpportunity(
      id: 'job-flutter-payments',
      organizationName: 'NIVEX Labs',
      organizationVerified: true,
      title: 'Flutter Developer - Payment Experience',
      category: 'Mobile Development',
      summary: 'Xây dựng luồng nhận việc, thông báo và theo dõi thanh toán cho ứng dụng Flutter.',
      skills: ['Flutter', 'Dart', 'Firebase'],
      locationScope: 'Việt Nam',
      engagement: JobEngagement.project,
      paymentType: JobPaymentType.milestone,
      budgetMinUsdc: 1200,
      budgetMaxUsdc: 1800,
      duration: '6-8 tuần',
      applicationDeadline: '24/09/2026',
      publishedLabel: '2 phút trước',
      matchScore: 94,
      isNew: true,
    ),
    JobOpportunity(
      id: 'job-product-designer',
      organizationName: 'NIVEX Labs',
      organizationVerified: true,
      title: 'Product Designer - Remote Workflows',
      category: 'Product Design',
      summary: 'Thiết kế trải nghiệm ứng tuyển và hồ sơ công việc cho đội ngũ làm việc từ xa.',
      skills: ['Figma', 'Design System', 'UX Research'],
      locationScope: 'Đông Nam Á',
      engagement: JobEngagement.contract,
      paymentType: JobPaymentType.fixed,
      budgetMinUsdc: 800,
      budgetMaxUsdc: 1200,
      duration: '4 tuần',
      applicationDeadline: '20/09/2026',
      publishedLabel: 'Hôm qua',
      matchScore: 82,
      isNew: true,
    ),
  ];
}
