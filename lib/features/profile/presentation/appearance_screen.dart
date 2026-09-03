import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/app_theme_mode.dart';
import 'package:nivex_flutter/app/theme/nivex_theme.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/app/theme/theme_controller.dart';
import 'package:nivex_flutter/features/profile/widgets/demo_notice.dart';
import 'package:nivex_flutter/features/profile/widgets/status_badge.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({this.themeController, super.key});

  final ThemeController? themeController;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final currentMode = theme.mode;

    final themeOptions = [
      AppThemeMode.defaultTheme,
      AppThemeMode.cyberNight,
      AppThemeMode.blockchainFlow,
      AppThemeMode.vietnamFuture,
    ];

    return NivexPage(
      title: 'Giao diện ứng dụng',
      subtitle: 'Tuỳ chỉnh chủ đề hiển thị',
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
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: themeOptions.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, thickness: 1, color: theme.divider),
                    itemBuilder: (ctx, index) {
                      final mode = themeOptions[index];
                      final isSelected = mode == currentMode;

                      return Semantics(
                        selected: isSelected,
                        button: true,
                        label: '${mode.label}: ${mode.description}',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              if (isSelected) return;
                              final controller = themeController;
                              if (controller != null) {
                                final success = await controller.setTheme(mode);
                                if (ctx.mounted) {
                                  if (success) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Đã áp dụng giao diện mới.',
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Không thể lưu giao diện. Vui lòng thử lại.',
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 56),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.radio_button_off_rounded,
                                      color: isSelected
                                          ? theme.primary
                                          : theme.textSecondary,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 14),
                                    _ThemeColorPreview(mode: mode),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mode.label,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: theme.textPrimary,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            mode.description,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme.textSecondary,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isSelected)
                                      const StatusBadge(label: 'Đang dùng'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const DemoNotice(
                  text: 'Chủ đề giao diện được áp dụng ngay trên toàn bộ ứng dụng và tự động lưu cho các phiên làm việc tiếp theo.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeColorPreview extends StatelessWidget {
  const _ThemeColorPreview({required this.mode});

  final AppThemeMode mode;

  @override
  Widget build(BuildContext context) {
    final ext = NivexTheme.forMode(mode).extension<NivexThemeExtension>()!;
    final bg = ext.background;
    final primary = ext.primary;
    final accent = ext.secondary;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x33888888)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 14,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(3),
                ),
              ),
            ),
            Container(
              width: 7,
              height: 14,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
