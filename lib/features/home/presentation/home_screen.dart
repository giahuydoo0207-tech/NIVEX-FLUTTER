import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/features/jobs/data/remote_application_controller.dart';
import 'package:nivex_flutter/features/jobs/presentation/application_thread_screen.dart';
import 'package:nivex_flutter/features/shell/domain/app_tab_controller.dart';
import 'package:nivex_flutter/features/wallet/data/wallet_summary_controller.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/home/presentation/widgets/nivex_education_section.dart';
import 'package:nivex_flutter/features/profile/data/demo_freelancer_profile_controller.dart';
import 'package:nivex_flutter/features/replyn_pairing/presentation/replyn_scan_button.dart';
import 'package:nivex_flutter/shared/widgets/nivex_logo.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';
import 'package:nivex_flutter/shared/widgets/solana_mark.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.onJobs,
    required this.onProfile,
    required this.onCreatePost,
    this.homeApi,
    this.replynScannerBuilder,
    super.key,
  });

  final VoidCallback onJobs;
  final VoidCallback onProfile;
  final VoidCallback onCreatePost;
  final NovaApiClient? homeApi;

  /// Replaces the Replyn scanner route; tests use it to avoid the camera.
  final WidgetBuilder? replynScannerBuilder;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _balanceVisible = false;
  NovaHomeSnapshot? _snapshot;

  WalletSummaryController? _wallet;

  @override
  void initState() {
    super.initState();
    _bindWallet();
    _loadHome();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.homeApi != widget.homeApi) {
      _bindWallet();
      _loadHome();
    }
  }

  @override
  void dispose() {
    _wallet?.removeListener(_onWalletChanged);
    super.dispose();
  }

  void _bindWallet() {
    _wallet?.removeListener(_onWalletChanged);
    final api = widget.homeApi;
    if (api == null) {
      _wallet = null;
      return;
    }
    _wallet = WalletSummaryController.of(api)..addListener(_onWalletChanged);
  }

  void _onWalletChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadHome() async {
    final api = widget.homeApi;
    if (api == null) return;
    unawaited(_wallet?.refresh());
    try {
      final snapshot = await api.home();
      if (mounted) setState(() => _snapshot = snapshot);
    } on NovaApiException {
      // Keep the demo fixture visible while an offline session reconnects.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: RefreshIndicator(
        onRefresh: _loadHome,
        child: SingleChildScrollView(
          key: const PageStorageKey('home-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHero(
                onNotifications: () => _showNotifications(context),
                replynScannerBuilder: widget.replynScannerBuilder,
                onProfile: widget.onProfile,
                balanceVisible: _balanceVisible,
                onToggleBalance: () {
                  setState(() => _balanceVisible = !_balanceVisible);
                },
                profileName:
                    _snapshot?.profile.displayName ??
                    DemoFreelancerProfileController.instance.displayName,
                unreadNotifications:
                    _snapshot?.unreadNotificationCount ??
                    (widget.homeApi == null ? 1 : 0),
                incomeLast7DaysMinor: _snapshot?.finalizedIncomeLast7DaysMinor,
                isLive: widget.homeApi != null,
                wallet: _wallet?.summary,
                walletFailed: _wallet?.failed ?? false,
              ),
              _HomeDashboard(
                onOpenCommunity: widget.onCreatePost,
                snapshot: _snapshot,
                isLive: widget.homeApi != null,
              ),
              const SizedBox(height: 8),
              const NivexEducationSection(),
              SizedBox(
                height: 80.0 + MediaQuery.paddingOf(context).bottom + 24.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showNotifications(BuildContext context) async {
    final api = widget.homeApi;
    if (api == null) {
      await showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        builder: (context) => _NotificationsSheet(onJobs: widget.onJobs),
      );
      return;
    }
    final opened = await showModalBottomSheet<NovaNotification>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _LiveNotificationsSheet(api: api),
    );
    unawaited(_loadHome());
    if (opened == null || !mounted) return;
    await _openNotificationTarget(api, opened);
  }

  Future<void> _openNotificationTarget(
    NovaApiClient api,
    NovaNotification notification,
  ) async {
    final applicationId = notification.applicationId;
    if (applicationId != null) {
      final controller = RemoteApplicationController.of(api);
      await controller.refresh();
      if (!mounted) return;
      if (controller.byId(applicationId) != null) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => ApplicationThreadScreen(
              applicationId: applicationId,
              controller: controller,
            ),
          ),
        );
        return;
      }
      widget.onJobs();
      return;
    }
    if (notification.threadId != null) {
      AppTabController.index.value = 3;
    }
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({
    required this.onOpenCommunity,
    required this.snapshot,
    required this.isLive,
  });

  final VoidCallback onOpenCommunity;
  final NovaHomeSnapshot? snapshot;

  /// With a backend, placeholders are neutral instead of demo numbers.
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nhịp Nova',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          NivexCard(
            padding: EdgeInsets.zero,
            child: InkWell(
              onTap: onOpenCommunity,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _initials(
                          snapshot?.communityHighlight?.authorName ??
                              (isLive ? 'Nova' : 'Trần Bảo Long'),
                        ),
                        style: TextStyle(
                          color: theme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Điểm nổi bật cộng đồng',
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _highlightContent(snapshot),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.textPrimary,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            _highlightMeta(snapshot),
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
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
          Row(
            children: [
              Expanded(
                child: _DashboardMetric(
                  icon: Icons.workspace_premium_outlined,
                  iconColor: theme.secondary,
                  title: 'Hồ sơ đang xử lý',
                  value: snapshot == null
                      ? (isLive ? '—' : '2')
                      : '${snapshot!.activeApplicationCount}',
                  detail: 'Cơ hội đang được theo dõi',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DashboardMetric(
                  icon: Icons.local_fire_department_outlined,
                  iconColor: theme.warning,
                  title: 'Dự án đã đạt',
                  value: snapshot == null
                      ? (isLive ? '—' : '3')
                      : '${snapshot!.completedProjectCount}',
                  detail: 'Cơ hội đã hoàn thành',
                ),
              ),
            ],
          ),
          // The response streak is not tracked by the backend yet.
          if (!isLive) ...[
            const SizedBox(height: 10),
            const _ResponseStreakCard(),
          ],
        ],
      ),
    );
  }

  String _highlightContent(NovaHomeSnapshot? snapshot) {
    final highlight = snapshot?.communityHighlight;
    if (highlight != null) return '“${highlight.content}”';
    if (snapshot != null) return 'Cộng đồng đang chờ bài chia sẻ đầu tiên của bạn.';
    if (isLive) return 'Đang tải điểm nổi bật cộng đồng…';
    return '“Clarity beats cleverness. Spec rõ ràng giúp cả team tiết kiệm hàng tuần làm lại.”';
  }

  String _highlightMeta(NovaHomeSnapshot? snapshot) {
    final highlight = snapshot?.communityHighlight;
    if (highlight == null) {
      if (snapshot != null) return 'Hãy bắt đầu một cuộc trao đổi';
      return isLive ? '' : 'Trần Bảo Long, 41 lượt tương tác';
    }
    return '${highlight.authorName}, ${highlight.reactionCount} lượt tương tác';
  }

  String _initials(String name) {
    return name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();
  }
}

class _DashboardMetric extends StatelessWidget {
  const _DashboardMetric({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexCard(
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        height: 116,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 25),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponseStreakCard extends StatefulWidget {
  const _ResponseStreakCard();

  @override
  State<_ResponseStreakCard> createState() => _ResponseStreakCardState();
}

class _ResponseStreakCardState extends State<_ResponseStreakCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _celebrate() {
    HapticFeedback.lightImpact();
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: _celebrate,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 82,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 13, 74, 13),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.warningSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: theme.warning,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chuỗi phản hồi đúng hạn',
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '12 ngày liên tiếp',
                              style: TextStyle(
                                color: theme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 15,
                top: 12,
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final bounce = Curves.elasticOut.transform(
                        _controller.value.clamp(0, 0.72) / 0.72,
                      );
                      return SizedBox(
                        width: 50,
                        height: 56,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _BurstFire(
                              progress: bounce,
                              offset: const Offset(-16, -11),
                              size: 17,
                              color: theme.warning.withValues(alpha: 0.82),
                            ),
                            _BurstFire(
                              progress: bounce,
                              offset: const Offset(18, -5),
                              size: 15,
                              color: theme.warning.withValues(alpha: 0.74),
                            ),
                            Center(
                              child: Transform.scale(
                                scale: 1 + (0.16 * bounce),
                                child: Icon(
                                  Icons.local_fire_department_rounded,
                                  color: theme.warning,
                                  size: 38,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BurstFire extends StatelessWidget {
  const _BurstFire({
    required this.progress,
    required this.offset,
    required this.size,
    required this.color,
  });

  final double progress;
  final Offset offset;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16 - (offset.dx * progress),
      top: 18 - (offset.dy * progress),
      child: Opacity(
        opacity: progress == 0 ? 0 : (1 - (progress * 0.42)).clamp(0, 1),
        child: Transform.scale(
          scale: 0.45 + (progress * 0.75),
          child: Icon(Icons.local_fire_department_rounded, color: color, size: size),
        ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.onNotifications,
    required this.onProfile,
    required this.balanceVisible,
    required this.onToggleBalance,
    required this.profileName,
    required this.unreadNotifications,
    required this.incomeLast7DaysMinor,
    required this.isLive,
    required this.wallet,
    required this.walletFailed,
    this.replynScannerBuilder,
  });

  final VoidCallback onNotifications;
  final WidgetBuilder? replynScannerBuilder;
  final VoidCallback onProfile;
  final bool balanceVisible;
  final VoidCallback onToggleBalance;
  final String profileName;
  final int unreadNotifications;
  final BigInt? incomeLast7DaysMinor;
  final bool isLive;
  final NovaWalletSummary? wallet;
  final bool walletFailed;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = (screenHeight * 0.43).clamp(348.0, 410.0);
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
                  // Top Header: Logo + Replyn scan + Bell with indicator dot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const NivexLogo(isLight: true, height: 26),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ReplynScanButton(scannerBuilder: replynScannerBuilder),
                          const SizedBox(width: 4),
                          _NotificationBell(
                            onTap: onNotifications,
                            unreadCount: unreadNotifications,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // User Profile Row: Avatar + Name (Tappable with min 48dp target)
                  Semantics(
                    button: true,
                    label: 'Hồ sơ người dùng $profileName',
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
                              children: [
                                const Icon(
                                  Icons.account_circle_outlined,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  profileName,
                                  style: const TextStyle(
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
                  Row(
                    children: [
                      Text(
                        isLive ? 'Đã nhận vào ví cá nhân' : 'Số dư khả dụng',
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
                  Text(
                    !balanceVisible
                        ? '••••••••'
                        : !isLive
                        ? '500.00 USDC'
                        : wallet == null
                        ? '—'
                        : !wallet!.hasPayoutWallet
                        ? 'Chưa cấu hình ví nhận tiền'
                        : '${formatUsdc2(wallet!.paidToPersonalWalletMinor)} USDC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          isLive && wallet != null && !wallet!.hasPayoutWallet
                          ? 22
                          : 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    !balanceVisible
                        ? '••••••••'
                        : !isLive
                        ? '≈ 12.500.000 VND'
                        : wallet == null
                        ? ''
                        : wallet!.paidViaDemoWalletMinor > BigInt.zero
                        ? 'Giao dịch demo cũ (ví máy chủ): ${formatUsdc2(wallet!.paidViaDemoWalletMinor)} USDC'
                        : 'Đang chờ thanh toán: ${formatUsdc2(wallet!.pendingBalanceMinor)} USDC',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    !isLive
                        ? 'Chưa đồng bộ được Devnet.'
                        : wallet == null
                        ? (walletFailed ? 'Chưa tải được ví.' : 'Đang tải ví…')
                        : !wallet!.hasPayoutWallet
                        ? 'Thêm ví nhận tiền trong mục Ví để được thanh toán.'
                        : 'Ví cá nhân · Solana ${wallet!.network}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _SolanaDevnetBadge(),
                  const Spacer(),
                  _HeroIncomeSnapshot(
                    isBalanceVisible: balanceVisible,
                    trendColor: theme.secondary,
                    // Home and Wallet read the same summary.
                    incomeMinor: isLive
                        ? wallet?.earnedLast7DaysMinor
                        : incomeLast7DaysMinor,
                    isLive: isLive,
                    backgroundColor: theme.isDark
                        ? theme.surface.withValues(alpha: 0.88)
                        : const Color(0xC0121C2E),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroIncomeSnapshot extends StatelessWidget {
  const _HeroIncomeSnapshot({
    required this.isBalanceVisible,
    required this.trendColor,
    required this.backgroundColor,
    required this.incomeMinor,
    required this.isLive,
  });

  final bool isBalanceVisible;
  final Color trendColor;
  final Color backgroundColor;
  final BigInt? incomeMinor;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x38FFFFFF)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Thu nhập 7 ngày qua',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.trending_up_rounded, color: trendColor, size: 20),
          const SizedBox(width: 5),
          Text(
            isBalanceVisible
                ? incomeMinor == null
                    ? (isLive ? '—' : '+15%')
                    : '+${formatUsdc(incomeMinor!)} USDC'
                : '•••',
            style: TextStyle(
              color: trendColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.onTap, required this.unreadCount});

  final VoidCallback onTap;
  final int unreadCount;

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
            if (unreadCount > 0)
              Positioned(
                top: 6,
                right: 7,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
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

/// Notifications from the backend. Tapping one marks it read and pops the
/// sheet with it so the caller can open its target.
class _LiveNotificationsSheet extends StatefulWidget {
  const _LiveNotificationsSheet({required this.api});

  final NovaApiClient api;

  @override
  State<_LiveNotificationsSheet> createState() =>
      _LiveNotificationsSheetState();
}

class _LiveNotificationsSheetState extends State<_LiveNotificationsSheet> {
  List<NovaNotification>? _items;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final items = await widget.api.notifications();
      if (mounted) setState(() => _items = items);
    } on NovaApiException {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _open(NovaNotification notification) async {
    if (notification.isUnread) {
      try {
        await widget.api.markNotificationRead(notification.id);
      } on NovaApiException {
        // Opening still works; the item stays unread until the next try.
      }
    }
    if (mounted) Navigator.of(context).pop(notification);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final items = _items;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông báo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (_failed)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Không tải được thông báo.',
                      style: TextStyle(color: theme.textSecondary),
                    ),
                  ),
                  TextButton(onPressed: _load, child: const Text('Thử lại')),
                ],
              )
            else if (items == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Bạn chưa có thông báo nào.',
                  style: TextStyle(color: theme.textSecondary),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  key: const Key('notification-list'),
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final status = item.data['status'];
                    final icon = switch (item.type) {
                      'APPLICATION_STATUS' when status == 'accepted' =>
                        Icons.check_circle_outline_rounded,
                      'APPLICATION_STATUS' when status == 'rejected' =>
                        Icons.cancel_outlined,
                      'APPLICATION_STATUS' => Icons.work_outline_rounded,
                      _ => Icons.chat_bubble_outline_rounded,
                    };
                    final color = status == 'accepted'
                        ? theme.success
                        : status == 'rejected'
                        ? theme.danger
                        : theme.primary;
                    return Material(
                      color: item.isUnread
                          ? theme.primary.withValues(alpha: 0.08)
                          : theme.surfaceSubtle,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: item.isUnread
                              ? theme.primary.withValues(alpha: 0.45)
                              : theme.border,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _open(item),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(icon, color: color, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: item.isUnread
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: theme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.body,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (item.isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 5),
                                  decoration: BoxDecoration(
                                    color: theme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
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
                            'Nova Labs vừa đăng cơ hội Flutter và Product Design.',
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
