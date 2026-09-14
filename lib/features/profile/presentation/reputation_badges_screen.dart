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
    ];

    return NivexPage(
      title: 'Cấp bậc uy tín',
      subtitle: 'Theo dõi uy tín nghề nghiệp trong NIVEX',
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
                        'Dữ liệu cấp bậc hiện đang được minh họa và chưa được cấp cho tài khoản. '
                        'Cấp bậc chỉ phản ánh uy tín trong NIVEX và không mở khóa hạn mức tiền.',
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
                'HỆ THỐNG CẤP BẬC',
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
                description: 'Chỉ được cấp sau khi NIVEX xác minh thủ công danh tính và chuyên môn.',
              ),
              const SizedBox(height: 24),
              _SafetyRules(),
            ],
          ),
        ),
      ),
    );
  }

  static String _descriptionFor(ReputationTier tier) => switch (tier) {
    ReputationTier.unranked =>
      'Hoàn thành thêm dự án để bắt đầu xây dựng uy tín nghề nghiệp.',
    ReputationTier.bronze =>
      'Tín hiệu uy tín ban đầu từ các dự án và review đã xác thực.',
    ReputationTier.silver =>
      'Lịch sử hoàn thành ổn định và chất lượng được duy trì.',
    ReputationTier.gold =>
      'Mức uy tín cao, có thể được ưu tiên trong gợi ý ứng viên.',
    _ => '',
  };
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier, required this.description});

  final ReputationTier tier;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReputationBadge(
            tier: tier,
            size: ReputationBadgeSize.large,
            showLabel: false,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReputationBadge(tier: tier, size: ReputationBadgeSize.regular),
                const SizedBox(height: 10),
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
                  'Nguyên tắc hiển thị',
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
          const _Rule(text: 'Chỉ tính review gắn với dự án hợp lệ.'),
          const _Rule(
            text: 'Badge có thể bị hạ hoặc tạm ẩn khi có tranh chấp.',
          ),
          const _Rule(
            text: 'Badge không thay thế KYC, AML hoặc xác minh chuyên môn.',
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
