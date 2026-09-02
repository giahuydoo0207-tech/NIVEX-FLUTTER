import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/features/profile/widgets/demo_notice.dart';
import 'package:nivex_flutter/features/profile/widgets/status_badge.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const themes = [
      _ThemeOption(
        title: 'Mặc định',
        subtitle: 'Giao diện ngân hàng tinh giản hiện đại',
        isActive: true,
      ),
      _ThemeOption(
        title: 'Minimal Light',
        subtitle: 'Tối giản thuần trắng và độ tương phản cao',
        isComingSoon: true,
      ),
      _ThemeOption(
        title: 'Cyber Night',
        subtitle: 'Chế độ nền tối huyền ảo',
        isComingSoon: true,
      ),
      _ThemeOption(
        title: 'Blockchain Flow',
        subtitle: 'Sắc thái gradient Web3 động',
        isComingSoon: true,
      ),
      _ThemeOption(
        title: 'Vietnam Future',
        subtitle: 'Cảm hứng đô thị năng động Việt Nam',
        isComingSoon: true,
      ),
      _ThemeOption(
        title: 'Abstract Finance',
        subtitle: 'Nghệ thuật đồ họa tài chính trừu tượng',
        isComingSoon: true,
      ),
    ];

    return NivexPage(
      title: 'Giao diện ứng dụng',
      subtitle: 'Tùy chỉnh chủ đề hiển thị',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: NivexColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: NivexColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: themes.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: NivexColors.border,
                    ),
                    itemBuilder: (_, index) {
                      final theme = themes[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              theme.isActive
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: theme.isActive
                                  ? NivexColors.blue
                                  : NivexColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    theme.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: theme.isActive
                                          ? NivexColors.navy
                                          : NivexColors.navySoft,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    theme.subtitle,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: NivexColors.textSecondary,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (theme.isActive)
                              const StatusBadge(label: 'Đang dùng')
                            else if (theme.isComingSoon)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: NivexColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Sắp ra mắt',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: NivexColors.textSecondary,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const DemoNotice(
                  text: 'Các chủ đề giao diện bổ sung đang được phát triển và sẽ ra mắt trong các phiên bản cập nhật tiếp theo.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeOption {
  const _ThemeOption({
    required this.title,
    required this.subtitle,
    this.isActive = false,
    this.isComingSoon = false,
  });

  final String title;
  final String subtitle;
  final bool isActive;
  final bool isComingSoon;
}
