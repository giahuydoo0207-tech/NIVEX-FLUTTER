import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/home/presentation/widgets/nivex_education_section.dart';
import 'package:nivex_flutter/shared/widgets/nivex_logo.dart';
import 'package:nivex_flutter/shared/widgets/solana_mark.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.onReceive,
    required this.onCashout,
    required this.onHistory,
    required this.onJobs,
    required this.onQuote,
    required this.onHelp,
    required this.onProfile,
    super.key,
  });

  final VoidCallback onReceive;
  final VoidCallback onCashout;
  final VoidCallback onHistory;
  final VoidCallback onJobs;
  final VoidCallback onQuote;
  final VoidCallback onHelp;
  final VoidCallback onProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: SingleChildScrollView(
        key: const PageStorageKey('home-scroll'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeHero(
              balanceVisible: _balanceVisible,
              onToggleBalance: () =>
                  setState(() => _balanceVisible = !_balanceVisible),
              onNotifications: _showNotifications,
              onProfile: widget.onProfile,
            ),
            _QuickActionsBar(
              onReceive: widget.onReceive,
              onCashout: widget.onCashout,
              onHistory: widget.onHistory,
              onQuote: widget.onQuote,
              onHelp: widget.onHelp,
            ),
            Divider(color: theme.divider, height: 1, thickness: 1),
            const NivexEducationSection(),
            SizedBox(
              height: 80.0 + MediaQuery.paddingOf(context).bottom + 24.0,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _NotificationsSheet(onJobs: widget.onJobs),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.balanceVisible,
    required this.onToggleBalance,
    required this.onNotifications,
    required this.onProfile,
  });

  final bool balanceVisible;
  final VoidCallback onToggleBalance;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = (screenHeight * 0.475).clamp(360.0, 460.0);

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Theme Skyline Image with Fallback
          Image.asset(
            theme.heroImage,
            fit: BoxFit.cover,
            alignment: const Alignment(0.5, -0.15),
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/nivex-home-skyline.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0.5, -0.15),
            ),
          ),
          // 2. Thematic Gradient Overlay: dark on left, translucent on right
          DecoratedBox(decoration: BoxDecoration(gradient: theme.heroGradient)),
          // 3. Content inside Safe Area
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header: Logo + Bell with indicator dot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const NivexLogo(isLight: true, height: 26),
                      _NotificationBell(onTap: onNotifications),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // User Profile Row: Avatar + Name (Tappable with min 48dp target)
                  Semantics(
                    button: true,
                    label: 'Hồ sơ người dùng Minh Anh',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onProfile,
                        borderRadius: BorderRadius.circular(8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.account_circle_outlined,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Minh Anh',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
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
                  const SizedBox(height: 12),
                  // Balance Label + Visibility Eye
                  Row(
                    children: [
                      const Text(
                        'Số dư khả dụng',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: onToggleBalance,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            balanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white70,
                            size: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Primary USDC Amount
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      balanceVisible ? '500.00 USDC' : '••••••••',
                      key: ValueKey(balanceVisible),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Secondary VND Amount
                  Text(
                    balanceVisible ? '≈ 12.500.000 VND' : '••••••••',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Solana Devnet Badge
                  const _SolanaDevnetBadge(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 26,
            ),
            Positioned(
              top: 8,
              right: 10,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SolanaDevnetBadge extends StatelessWidget {
  const _SolanaDevnetBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x380D2137),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x38FFFFFF), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SolanaMark(width: 19),
          SizedBox(width: 6),
          Text(
            'Solana Devnet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsBar extends StatelessWidget {
  const _QuickActionsBar({
    required this.onReceive,
    required this.onCashout,
    required this.onHistory,
    required this.onQuote,
    required this.onHelp,
  });

  final VoidCallback onReceive;
  final VoidCallback onCashout;
  final VoidCallback onHistory;
  final VoidCallback onQuote;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _QuickActionItem(
              icon: Icons.file_download_outlined,
              label: 'Nhận USDC',
              onTap: onReceive,
            ),
          ),
          Expanded(
            child: _QuickActionItem(
              icon: Icons.file_upload_outlined,
              label: 'Rút VND',
              onTap: onCashout,
            ),
          ),
          Expanded(
            child: _QuickActionItem(
              icon: Icons.receipt_long_outlined,
              label: 'Lịch sử',
              onTap: onHistory,
            ),
          ),
          Expanded(
            child: _QuickActionItem(
              icon: Icons.show_chart_rounded,
              label: 'Báo giá',
              onTap: onQuote,
            ),
          ),
          Expanded(
            child: _QuickActionItem(
              icon: Icons.headset_mic_outlined,
              label: 'Trợ giúp',
              onTap: onHelp,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.border),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: theme.primary, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: theme.textPrimary,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet({required this.onJobs});

  final VoidCallback onJobs;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thông báo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                  letterSpacing: 0,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                color: theme.textSecondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: theme.surfaceSubtle,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.primary.withValues(alpha: 0.45)),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                onJobs();
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.work_outline_rounded,
                        color: theme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2 công việc mới phù hợp',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'NIVEX Labs vừa đăng cơ hội Flutter và Product Design.',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textSecondary,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.surfaceSubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: theme.success,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã xác nhận trên Solana Devnet',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+200.00 USDC đã được ghi nhận trong dữ liệu demo của bạn.',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textSecondary,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
