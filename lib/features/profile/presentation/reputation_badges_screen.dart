import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/profile/domain/reputation_tier.dart';
import 'package:nivex_flutter/features/profile/widgets/reputation_badge.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class ReputationBadgesScreen extends StatelessWidget {
  const ReputationBadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    const previewTiers = [
      ReputationTier.unranked,
      ReputationTier.bronze,
      ReputationTier.silver,
      ReputationTier.gold,
      ReputationTier.platinum,
    ];

    return NivexPage(
      title: 'Cấp bậc uy tín',
      subtitle: 'Theo dõi tín hiệu nghề nghiệp trong Nova',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: theme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Cấp bậc chỉ là tín hiệu tham khảo dựa trên dự án hoàn thành, review hợp lệ và mức độ xác thực. '
                        'Thông tin này không giới hạn cơ hội hay quyền truy cập của người dùng.',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 12.5,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'TÍN HIỆU UY TÍN',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              for (var index = 0; index < previewTiers.length; index++) ...[
                _TierCard(
                  tier: previewTiers[index],
                  description: _descriptionFor(previewTiers[index]),
                ),
                if (index != previewTiers.length - 1)
                  const SizedBox(height: 10),
              ],
              const SizedBox(height: 24),
              Text(
                'TRẠNG THÁI ĐẶC BIỆT',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const _TierCard(
                tier: ReputationTier.verifiedExpert,
                description:
                    'Tín hiệu bổ trợ sau khi được xác minh chuyên môn độc lập.',
              ),
              const SizedBox(height: 24),
              const _SafetyRules(),
            ],
          ),
        ),
      ),
    );
  }

  static String _descriptionFor(ReputationTier tier) => switch (tier) {
    ReputationTier.unranked =>
      'Bắt đầu từ việc hoàn thành dự án và nhận phản hồi ban đầu.',
    ReputationTier.bronze =>
      'Tín hiệu ghi nhận bước đầu từ các dự án và review hợp lệ.',
    ReputationTier.silver =>
      'Lịch sử hoàn thành dự án đều đặn và duy trì phản hồi tích cực.',
    ReputationTier.gold =>
      'Mức độ tín nhiệm cao dựa trên nhiều dự án chất lượng.',
    ReputationTier.platinum =>
      'Hiệu suất và độ hài lòng nổi bật được duy trì lâu dài.',
    ReputationTier.verifiedExpert =>
      'Tín hiệu bổ trợ sau khi được xác minh chuyên môn độc lập.',
  };
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier, required this.description});

  final ReputationTier tier;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final accentColor = switch (tier) {
      ReputationTier.unranked => theme.textSecondary,
      ReputationTier.bronze => const Color(0xFFD49765),
      ReputationTier.silver => const Color(0xFF94A3B8),
      ReputationTier.gold => const Color(0xFFFACC15),
      ReputationTier.platinum => const Color(0xFF22D3EE),
      ReputationTier.verifiedExpert => theme.primary,
    };

    return NivexCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReputationBadge(
            tier: tier,
            size: ReputationBadgeSize.regular,
            showLabel: false,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      tier.label,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        'Tín hiệu tham khảo',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.data_usage_rounded,
                      size: 15,
                      color: theme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tier.requirement,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyRules extends StatelessWidget {
  const _SafetyRules();

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 20, color: theme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nguyên tắc minh bạch',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _Rule(
            text: 'Cấp bậc là tín hiệu tham khảo, không phân tầng hay giới hạn quyền lợi.',
          ),
          const _Rule(
            text: 'Chỉ ghi nhận đánh giá từ các dự án thực tế đã hoàn tất qua Nova.',
          ),
          const _Rule(
            text: 'Không thay thế quy trình xác thực danh tính (KYC) hoặc đánh giá chuyên môn.',
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(width: 5, height: 5, color: theme.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
