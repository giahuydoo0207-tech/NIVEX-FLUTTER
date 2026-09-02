import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/shared/widgets/nivex_logo.dart';
import 'package:nivex_flutter/shared/widgets/solana_mark.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.onReceive,
    required this.onCashout,
    required this.onHistory,
    required this.onQuote,
    required this.onHelp,
    super.key,
  });

  final VoidCallback onReceive;
  final VoidCallback onCashout;
  final VoidCallback onHistory;
  final VoidCallback onQuote;
  final VoidCallback onHelp;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
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
            ),
            _QuickActionsBar(
              onReceive: widget.onReceive,
              onCashout: widget.onCashout,
              onHistory: widget.onHistory,
              onQuote: widget.onQuote,
              onHelp: widget.onHelp,
            ),
            const _RecentActivitiesSection(),
            const SizedBox(height: 32),
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
      builder: (context) => const _NotificationsSheet(),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.balanceVisible,
    required this.onToggleBalance,
    required this.onNotifications,
  });

  final bool balanceVisible;
  final VoidCallback onToggleBalance;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = (screenHeight * 0.475).clamp(360.0, 460.0);

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Real Skyline Image
          Image.asset(
            'assets/images/nivex-home-skyline.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0.5, -0.15),
          ),
          // 2. Navy Gradient Overlay: deep navy on left, translucent on right
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xF2071A2E),
                  Color(0xD00A2340),
                  Color(0x2B0B2749),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // 3. Content inside Safe Area
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header: Logo + Bell with red dot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const NivexLogo(isLight: true, height: 26),
                      _NotificationBell(onTap: onNotifications),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // User Profile Row: Avatar + Name
                  Row(
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
                  const SizedBox(height: 16),
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
                  color: NivexColors.danger,
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
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
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
              label: 'Quote',
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
                  color: NivexColors.blueSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: NivexColors.blue, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: NivexColors.navy,
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

class _ActivityData {
  const _ActivityData({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.time,
    required this.isIncoming,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String time;
  final bool isIncoming;
  final IconData icon;
}

class _RecentActivitiesSection extends StatelessWidget {
  const _RecentActivitiesSection();

  static const _activities = [
    _ActivityData(
      title: 'Nhận USDC',
      subtitle: '7xKp...9mQe',
      amount: '+200.00 USDC',
      time: 'Hôm nay, 09:21',
      isIncoming: true,
      icon: Icons.arrow_downward_rounded,
    ),
    _ActivityData(
      title: 'Rút VND',
      subtitle: 'Vietcombank •••• 1234',
      amount: '-8.000.000 VND',
      time: 'Hôm qua, 16:45',
      isIncoming: false,
      icon: Icons.arrow_upward_rounded,
    ),
    _ActivityData(
      title: 'Quote đã tạo',
      subtitle: '500 USDC → VND',
      amount: '12.470.000 VND',
      time: '25/05/2025, 11:10',
      isIncoming: false,
      icon: Icons.currency_exchange_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: NivexColors.border, height: 1, thickness: 1),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Text(
            'Hoạt động gần đây',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: NivexColors.navy,
              letterSpacing: 0,
            ),
          ),
        ),
        for (var i = 0; i < _activities.length; i++) ...[
          _ActivityRow(data: _activities[i]),
          if (i < _activities.length - 1)
            const Divider(
              color: NivexColors.border,
              height: 1,
              thickness: 1,
              indent: 70,
              endIndent: 20,
            ),
        ],
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.data});

  final _ActivityData data;

  @override
  Widget build(BuildContext context) {
    final iconBg = data.isIncoming ? NivexColors.blue : NivexColors.blueSoft;
    final iconColor = data.isIncoming ? Colors.white : NivexColors.navy;
    final amountColor = data.isIncoming ? NivexColors.green : NivexColors.navy;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(data.icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: NivexColors.navy,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.amount,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.time,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: NivexColors.textSecondary,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thông báo', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: NivexColors.greenSoft,
              child: Icon(Icons.check_rounded, color: NivexColors.green),
            ),
            title: Text('Giao dịch đã hoàn tất'),
            subtitle: Text('Bạn đã nhận 200,00 USDC vào ví Devnet.'),
          ),
          const Divider(),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: NivexColors.blueSoft,
              child: Icon(Icons.shield_outlined, color: NivexColors.blue),
            ),
            title: Text('Mẹo bảo mật'),
            subtitle: Text('Không chia sẻ cụm từ khôi phục với bất kỳ ai.'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }
}
