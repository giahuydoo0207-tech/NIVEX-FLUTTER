import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/profile/widgets/demo_notice.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _jobAlerts = true;
  bool _txAlerts = true;
  bool _balanceAlerts = true;
  bool _newsAlerts = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexPage(
      title: 'Thông báo',
      subtitle: 'Tuỳ chỉnh kênh nhận thông báo',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: theme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        value: _jobAlerts,
                        activeTrackColor: theme.primary,
                        secondary: Icon(
                          Icons.work_outline_rounded,
                          color: theme.primary,
                        ),
                        title: Text(
                          'Công việc phù hợp',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                            letterSpacing: 0,
                          ),
                        ),
                        subtitle: Text(
                          'Báo ngay khi tổ chức đã xác minh đăng việc khớp kỹ năng',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textSecondary,
                            letterSpacing: 0,
                          ),
                        ),
                        onChanged: (val) => setState(() => _jobAlerts = val),
                      ),
                      Divider(height: 1, thickness: 1, color: theme.divider),
                      SwitchListTile.adaptive(
                        value: _txAlerts,
                        activeTrackColor: theme.primary,
                        title: Text(
                          'Giao dịch nạp/rút',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                            letterSpacing: 0,
                          ),
                        ),
                        subtitle: Text(
                          'Thông báo tức thì khi nhận USDC hoặc rút VND',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textSecondary,
                            letterSpacing: 0,
                          ),
                        ),
                        onChanged: (val) => setState(() => _txAlerts = val),
                      ),
                      Divider(height: 1, thickness: 1, color: theme.divider),
                      SwitchListTile.adaptive(
                        value: _balanceAlerts,
                        activeTrackColor: theme.primary,
                        title: Text(
                          'Biến động số dư',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                            letterSpacing: 0,
                          ),
                        ),
                        subtitle: Text(
                          'Cập nhật số dư sau mỗi lệnh thành công',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textSecondary,
                            letterSpacing: 0,
                          ),
                        ),
                        onChanged: (val) =>
                            setState(() => _balanceAlerts = val),
                      ),
                      Divider(height: 1, thickness: 1, color: theme.divider),
                      SwitchListTile.adaptive(
                        value: _newsAlerts,
                        activeTrackColor: theme.primary,
                        title: Text(
                          'Tin tức & Khuyến mãi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                            letterSpacing: 0,
                          ),
                        ),
                        subtitle: Text(
                          'Cập nhật tính năng và chương trình ưu đãi',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textSecondary,
                            letterSpacing: 0,
                          ),
                        ),
                        onChanged: (val) => setState(() => _newsAlerts = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const DemoNotice(
                  text: 'Cài đặt thông báo chỉ lưu trữ trong phiên làm việc hiện tại của bản demo.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
