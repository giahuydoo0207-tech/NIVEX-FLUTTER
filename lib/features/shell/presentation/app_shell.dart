import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/theme_controller.dart';
import 'package:nivex_flutter/features/cashout/data/demo_cashout_fixtures.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_auth_service.dart';
import 'package:nivex_flutter/features/cashout/presentation/cashout_screen.dart';
import 'package:nivex_flutter/features/cashout/presentation/quote_screen.dart';
import 'package:nivex_flutter/features/help/presentation/help_screen.dart';
import 'package:nivex_flutter/features/home/presentation/home_screen.dart';
import 'package:nivex_flutter/features/jobs/data/remote_application_controller.dart';
import 'package:nivex_flutter/features/jobs/presentation/jobs_screen.dart';
import 'package:nivex_flutter/features/messages/presentation/messages_screen.dart';
import 'package:nivex_flutter/features/posts/presentation/posts_screen.dart';
import 'package:nivex_flutter/features/profile/data/demo_freelancer_profile_controller.dart';
import 'package:nivex_flutter/features/profile/presentation/profile_screen.dart';
import 'package:nivex_flutter/features/receive/presentation/receive_usdc_screen.dart';
import 'package:nivex_flutter/features/session/presentation/session_unlock_sheet.dart';
import 'package:nivex_flutter/features/shell/domain/app_tab_controller.dart';
import 'package:nivex_flutter/features/transactions/presentation/transactions_screen.dart';
import 'package:nivex_flutter/features/wallet/presentation/wallet_screen.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    this.initialTab = 0,
    this.themeController,
    this.cashoutAuthService,
    this.homeApi,
    this.onLogout,
    super.key,
  });

  final int initialTab;
  final ThemeController? themeController;
  final CashoutAuthService? cashoutAuthService;
  final NovaApiClient? homeApi;

  /// Revokes the server session and returns to login; null in demo builds.
  final Future<void> Function()? onLogout;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _tabs = [
    _NavTabConfig(icon: Icons.home_outlined, label: 'Trang chủ'),
    _NavTabConfig(
      icon: Icons.work_outline_rounded,
      label: 'Công việc',
      badgeCount: 2,
    ),
    _NavTabConfig(
      icon: Icons.public_rounded,
      label: 'Cộng đồng',
      isEmphasized: true,
    ),
    _NavTabConfig(icon: Icons.forum_outlined, label: 'Tin nhắn', badgeCount: 1),
    _NavTabConfig(icon: Icons.account_balance_wallet_outlined, label: 'Ví'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab != 0
        ? widget.initialTab
        : AppTabController.index.value;
    AppTabController.index.value = _selectedIndex;
    AppTabController.index.addListener(_handleExternalTabChange);
    DemoFreelancerProfileController.instance.connect(widget.homeApi);
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    DemoFreelancerProfileController.instance.connect(widget.homeApi);
  }

  @override
  void dispose() {
    AppTabController.index.removeListener(_handleExternalTabChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onJobs: () => _selectTab(1),
        onProfile: _openProfile,
        onCreatePost: () => _selectTab(2),
        homeApi: widget.homeApi,
      ),
      JobsScreen(api: widget.homeApi),
      PostsScreen(postsApi: widget.homeApi),
      MessagesScreen(api: widget.homeApi),
      WalletScreen(
        api: widget.homeApi,
        onReceive: _openReceive,
        onCashout: _openCashout,
        onQuote: _openQuickQuote,
        onHistory: _openHistory,
        onHelp: _openHelp,
      ),
    ];

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) _selectTab(0);
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: pages),
        bottomNavigationBar: switch (_liveApplications) {
          null => _navigationBar(_tabs),
          final live => ListenableBuilder(
            listenable: live,
            builder: (context, _) => _navigationBar(_liveTabs()),
          ),
        },
      ),
    );
  }

  RemoteApplicationController? get _liveApplications {
    final api = widget.homeApi;
    return api == null ? null : RemoteApplicationController.of(api);
  }

  /// Badge counts from the backend instead of the demo numbers.
  List<_NavTabConfig> _liveTabs() {
    final applications = _liveApplications!;
    final appliedJobs = {
      for (final application in applications.applications) application.jobId,
    };
    final newJobs = applications.jobs
        .where((job) => job.isNew && !appliedJobs.contains(job.id))
        .length;
    final unread = applications.unreadCount;
    return [
      for (final tab in _tabs)
        switch (tab.label) {
          'Công việc' => tab.withBadge(newJobs),
          'Tin nhắn' => tab.withBadge(unread),
          _ => tab,
        },
    ];
  }

  Widget _navigationBar(List<_NavTabConfig> tabs) => NavigationBar(
    selectedIndex: _selectedIndex,
    onDestinationSelected: _selectTab,
    destinations: [
      for (var index = 0; index < tabs.length; index++)
        NavigationDestination(
          icon: _BottomNavIcon(
            key: ValueKey('bottom-nav-${tabs[index].label}'),
            tab: tabs[index],
            selected: _selectedIndex == index,
          ),
          label: tabs[index].label,
        ),
    ],
  );

  void _selectTab(int index) {
    if (index == 4 && _selectedIndex != 4) {
      _openWalletAfterAuthentication();
      return;
    }
    AppTabController.index.value = index;
  }

  Future<void> _openWalletAfterAuthentication() async {
    final authService = widget.cashoutAuthService;
    if (authService == null) {
      AppTabController.index.value = 4;
      return;
    }

    final unlocked = await SessionUnlockSheet.show(
      context: context,
      authService: authService,
      title: 'Mở Ví Nova',
      description:
          'Nhập mã PIN Ví hoặc dùng sinh trắc học để xem tài sản và giao dịch.',
      pinLabel: 'Mã PIN Ví gồm 6 số',
      biometricReason: 'Xác thực để mở Ví Nova',
      cancelLabel: 'Quay lại',
    );
    if (!mounted) return;
    if (unlocked) AppTabController.index.value = 4;
  }

  void _handleExternalTabChange() {
    if (mounted && _selectedIndex != AppTabController.index.value) {
      setState(() => _selectedIndex = AppTabController.index.value);
    }
  }

  Future<void> _openReceive() {
    return Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const ReceiveUsdcScreen()));
  }

  Future<void> _openCashout() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CashoutScreen(authService: widget.cashoutAuthService),
      ),
    );
  }

  Future<void> _openQuickQuote() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => QuoteScreen(
          quote: DemoCashoutFixtures.createCanonicalQuote(),
          authService: widget.cashoutAuthService,
        ),
      ),
    );
  }

  Future<void> _openHelp() {
    return Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => const HelpScreen()));
  }

  Future<void> _openProfile() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          themeController: widget.themeController,
          onLogout: widget.onLogout,
        ),
      ),
    );
  }

  Future<void> _openHistory() {
    return Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const TransactionsScreen()));
  }
}

class _NavTabConfig {
  const _NavTabConfig({
    required this.icon,
    required this.label,
    this.badgeCount,
    this.isEmphasized = false,
  });

  final IconData icon;
  final String label;
  final int? badgeCount;
  final bool isEmphasized;

  _NavTabConfig withBadge(int count) => _NavTabConfig(
    icon: icon,
    label: label,
    badgeCount: count > 0 ? count : null,
    isEmphasized: isEmphasized,
  );
}

class _BottomNavIcon extends StatelessWidget {
  const _BottomNavIcon({required this.tab, required this.selected, super.key});

  final _NavTabConfig tab;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = tab.isEmphasized && selected
        ? colorScheme.onPrimary
        : selected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    final icon = Icon(
      tab.icon,
      color: iconColor,
      size: tab.isEmphasized ? 22 : 24,
    );

    final visual = tab.isEmphasized
        ? Transform.translate(
            offset: const Offset(0, -7),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? colorScheme.primary : colorScheme.outline,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: icon,
            ),
          )
        : icon;

    if (tab.badgeCount == null) return visual;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        visual,
        Positioned(
          right: -8,
          top: -6,
          child: Container(
            constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              border: Border.all(color: colorScheme.surface, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${tab.badgeCount}',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
