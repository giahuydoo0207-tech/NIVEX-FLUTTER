import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
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
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String nivexId = 'NVX-000001';

  @override
  Widget build(BuildContext context) {
    return NivexPage(
      title: 'Cá nhân',
      subtitle: 'Hồ sơ và tuỳ chỉnh tài khoản',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Profile Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: NivexColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: NivexColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Avatar Initials: MA
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: NivexColors.navy,
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
                              children: const [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  runSpacing: 2,
                                  children: [
                                    Text(
                                      'Minh Anh',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: NivexColors.navy,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    StatusBadge(label: 'Đã xác minh'),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'minh.anh@nivex.demo',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: NivexColors.textSecondary,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: NivexColors.border,
                      ),
                      const SizedBox(height: 10),
                      // NIVEX ID & Copy Button
                      Row(
                        children: [
                          Expanded(
                            child: Text.rich(
                              const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'ID NIVEX: ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: NivexColors.textSecondary,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: nivexId,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: NivexColors.navy,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(
                                const ClipboardData(text: nivexId),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã sao chép ID NIVEX.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: 48,
                                minWidth: 48,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 6,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.copy_rounded,
                                      size: 15,
                                      color: NivexColors.blue,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Sao chép',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: NivexColors.blue,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
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

                // 2. Section: Tài khoản
                ProfileSection(
                  title: 'Tài khoản',
                  children: [
                    ProfileRow(
                      title: 'Thông tin cá nhân',
                      icon: Icons.person_outline_rounded,
                      onTap: () =>
                          _navigateTo(context, const PersonalInfoScreen()),
                    ),
                    ProfileRow(
                      title: 'Trạng thái xác minh',
                      icon: Icons.verified_user_outlined,
                      trailing: const StatusBadge(label: 'Đã xác minh'),
                      onTap: () =>
                          _navigateTo(context, const VerificationScreen()),
                    ),
                    ProfileRow(
                      title: 'Địa chỉ ví Solana',
                      icon: Icons.account_balance_wallet_outlined,
                      trailing: const Text(
                        '7xKX...sgAsU',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: NivexColors.textSecondary,
                          letterSpacing: 0,
                        ),
                      ),
                      onTap: () =>
                          _navigateTo(context, const ReceiveUsdcScreen()),
                    ),
                    ProfileRow(
                      title: 'Tài khoản nhận VND',
                      icon: Icons.account_balance_outlined,
                      trailing: const Text(
                        '•••• 2868',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: NivexColors.textSecondary,
                          letterSpacing: 0,
                        ),
                      ),
                      onTap: () =>
                          _navigateTo(context, const BankAccountScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Section: Tuỳ chỉnh
                ProfileSection(
                  title: 'Tuỳ chỉnh',
                  children: [
                    ProfileRow(
                      title: 'Thông báo',
                      icon: Icons.notifications_none_rounded,
                      trailing: const Text(
                        'Đang bật',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: NivexColors.textSecondary,
                          letterSpacing: 0,
                        ),
                      ),
                      onTap: () => _navigateTo(
                        context,
                        const NotificationSettingsScreen(),
                      ),
                    ),
                    ProfileRow(
                      title: 'Giao diện ứng dụng',
                      icon: Icons.palette_outlined,
                      trailing: const Text(
                        'Mặc định',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: NivexColors.textSecondary,
                          letterSpacing: 0,
                        ),
                      ),
                      onTap: () =>
                          _navigateTo(context, const AppearanceScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Section: Hỗ trợ và thông tin
                ProfileSection(
                  title: 'Hỗ trợ và thông tin',
                  children: [
                    ProfileRow(
                      title: 'Trung tâm trợ giúp',
                      icon: Icons.help_outline_rounded,
                      onTap: () => _navigateTo(context, const HelpScreen()),
                    ),
                    ProfileRow(
                      title: 'Điều khoản & quyền riêng tư',
                      icon: Icons.policy_outlined,
                      onTap: () => _navigateTo(context, const LegalScreen()),
                    ),
                    const ProfileRow(
                      title: 'Phiên bản ứng dụng',
                      icon: Icons.info_outline_rounded,
                      trailing: Text(
                        'v0.1.0 Demo',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: NivexColors.textSecondary,
                          letterSpacing: 0,
                        ),
                      ),
                      showChevron: false,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 5. Section: Hành động tài khoản
                ProfileSection(
                  title: 'Hành động tài khoản',
                  children: [
                    ProfileRow(
                      title: 'Đăng xuất',
                      icon: Icons.logout_rounded,
                      isDanger: true,
                      showChevron: false,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 6. Demo Notice Footer
                const DemoNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Đăng xuất khỏi NIVEX?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: NivexColors.navy,
              letterSpacing: 0,
            ),
          ),
          content: const Text(
            'Đây là thao tác mô phỏng trong phiên bản demo.',
            style: TextStyle(
              fontSize: 14,
              color: NivexColors.textSecondary,
              letterSpacing: 0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  color: NivexColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bạn đã đăng xuất khỏi NIVEX.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: NivexColors.danger,
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0),
              ),
            ),
          ],
        );
      },
    );
  }
}
