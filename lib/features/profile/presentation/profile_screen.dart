import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/app/theme/theme_controller.dart';
import 'package:nivex_flutter/features/help/presentation/help_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/appearance_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/bank_account_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/legal_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/notification_settings_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/personal_info_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/verification_screen.dart';
import 'package:nivex_flutter/features/profile/widgets/demo_notice.dart';
import 'package:nivex_flutter/features/profile/widgets/profile_row.dart';
import 'package:nivex_flutter/features/profile/widgets/profile_section.dart';
import 'package:nivex_flutter/features/profile/widgets/status_badge.dart';
import 'package:nivex_flutter/features/receive/presentation/receive_usdc_screen.dart';
import 'package:nivex_flutter/shared/constants/demo_data.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({this.themeController, super.key});

  final ThemeController? themeController;
  static const String nivexId = DemoData.nivexId;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexPage(
      title: 'Cá nhân',
      subtitle: 'Hồ sơ và tuỳ chỉnh tài khoản',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Profile Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Avatar Initials: MA
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.primary,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'MA',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      'Minh Anh',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: theme.textPrimary,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    const StatusBadge(label: 'Đã xác minh'),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'minh.anh@nivex.demo',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: theme.textSecondary,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, thickness: 1, color: theme.divider),
                      const SizedBox(height: 8),
                      // NIVEX ID Row with Copy button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  'NIVEX ID: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textSecondary,
                                    letterSpacing: 0,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    nivexId,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textPrimary,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Semantics(
                            button: true,
                            label: 'Sao chép NIVEX ID',
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    const ClipboardData(text: nivexId),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã sao chép NIVEX ID'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.copy_rounded,
                                          size: 15,
                                          color: theme.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Sao chép',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: theme.primary,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Section: Tài khoản & Bảo mật
                ProfileSection(
                  title: 'TÀI KHOẢN & BẢO MẬT',
                  children: [
                    ProfileRow(
                      title: 'Thông tin cá nhân',
                      subtitle: 'Họ tên, email, số điện thoại',
                      icon: Icons.person_outline_rounded,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => const PersonalInfoScreen(),
                        ),
                      ),
                    ),
                    ProfileRow(
                      title: 'Trạng thái xác minh',
                      subtitle: 'Định danh điện tử (KYC Demo)',
                      icon: Icons.verified_user_outlined,
                      trailing: const StatusBadge(label: 'Cấp 2'),
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => const VerificationScreen(),
                        ),
                      ),
                    ),
                    ProfileRow(
                      title: 'Địa chỉ ví Solana',
                      subtitle: 'Xem mã QR và địa chỉ Devnet',
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => const ReceiveUsdcScreen(),
                        ),
                      ),
                    ),
                    ProfileRow(
                      title: 'Tài khoản nhận VND',
                      subtitle: DemoData.bankAccountFull,
                      icon: Icons.account_balance_outlined,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => const BankAccountScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Section: Cài đặt ứng dụng
                ProfileSection(
                  title: 'CÀI ĐẶT ỨNG DỤNG',
                  children: [
                    ProfileRow(
                      title: 'Thông báo',
                      subtitle: 'Công việc, giao dịch và biến động số dư',
                      icon: Icons.notifications_none_rounded,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsScreen(),
                        ),
                      ),
                    ),
                    ProfileRow(
                      title: 'Giao diện ứng dụng',
                      subtitle: theme.mode.label,
                      icon: Icons.palette_outlined,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => AppearanceScreen(
                            themeController: themeController,
                          ),
                        ),
                      ),
                    ),
                    ProfileRow(
                      title: 'Ngôn ngữ',
                      subtitle: 'Tiếng Việt (mặc định)',
                      icon: Icons.language_rounded,
                      showChevron: false,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Section: Hỗ trợ & Pháp lý
                ProfileSection(
                  title: 'HỖ TRỢ & PHÁP LÝ',
                  children: [
                    ProfileRow(
                      title: 'Trung tâm trợ giúp',
                      subtitle: 'Câu hỏi thường gặp và liên hệ',
                      icon: Icons.help_outline_rounded,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(builder: (_) => const HelpScreen()),
                      ),
                    ),
                    ProfileRow(
                      title: 'Điều khoản & quyền riêng tư',
                      subtitle: 'Quy chế demo và chính sách',
                      icon: Icons.description_outlined,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(builder: (_) => const LegalScreen()),
                      ),
                    ),
                    ProfileRow(
                      title: 'Phiên bản ứng dụng',
                      subtitle: 'v1.0.0 (MVP Build 2025)',
                      icon: Icons.info_outline_rounded,
                      showChevron: false,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 5. Section: Tài khoản
                ProfileSection(
                  title: 'TÀI KHOẢN',
                  children: [
                    ProfileRow(
                      title: 'Đăng xuất',
                      subtitle: 'Kết thúc phiên đăng nhập demo',
                      icon: Icons.logout_rounded,
                      isDanger: true,
                      showChevron: false,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 6. Demo Notice Footer
                const DemoNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = context.nivexTheme;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.border),
        ),
        title: Text(
          'Đăng xuất',
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản demo này không?',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 14,
            height: 1.4,
            letterSpacing: 0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: theme.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã đăng xuất phiên demo.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0),
            ),
          ),
        ],
      ),
    );
  }
}
