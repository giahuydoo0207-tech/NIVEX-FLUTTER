enum JobEngagement { project, contract, partTime }

enum JobPaymentType { fixed, milestone, hourly }

class JobOpportunity {
  const JobOpportunity({
    required this.id,
    required this.organizationName,
    required this.organizationVerified,
    required this.title,
    required this.category,
    required this.summary,
    required this.skills,
    required this.locationScope,
    required this.engagement,
    required this.paymentType,
    required this.budgetMinUsdc,
    required this.budgetMaxUsdc,
    required this.duration,
    required this.applicationDeadline,
    required this.publishedLabel,
    required this.matchScore,
    this.isNew = false,
  });

  final String id;
  final String organizationName;
  final bool organizationVerified;
  final String title;
  final String category;
  final String summary;
  final List<String> skills;
  final String locationScope;
  final JobEngagement engagement;
  final JobPaymentType paymentType;
  final int budgetMinUsdc;
  final int budgetMaxUsdc;
  final String duration;
  final String applicationDeadline;
  final String publishedLabel;
  final int matchScore;
  final bool isNew;

  String get engagementLabel => switch (engagement) {
    JobEngagement.project => 'Theo dự án',
    JobEngagement.contract => 'Hợp đồng',
    JobEngagement.partTime => 'Bán thời gian',
  };

  String get paymentLabel => switch (paymentType) {
    JobPaymentType.fixed => 'Trọn gói',
    JobPaymentType.milestone => 'Theo cột mốc',
    JobPaymentType.hourly => 'Theo giờ',
  };

  String get budgetLabel {
    final suffix = paymentType == JobPaymentType.hourly ? '/giờ' : '';
    return '$budgetMinUsdc - $budgetMaxUsdc USDC$suffix';
  }
}
