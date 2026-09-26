import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/theme_controller.dart';
import 'package:nivex_flutter/features/cashout/data/demo_cashout_fixtures.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_auth_service.dart';
import 'package:nivex_flutter/features/cashout/presentation/cashout_screen.dart';
import 'package:nivex_flutter/features/cashout/presentation/quote_screen.dart';
import 'package:nivex_flutter/features/help/presentation/help_screen.dart';
import 'package:nivex_flutter/features/home/presentation/home_screen.dart';
import 'package:nivex_flutter/features/jobs/presentation/jobs_screen.dart';
import 'package:nivex_flutter/features/messages/presentation/messages_screen.dart';
import 'package:nivex_flutter/features/posts/presentation/posts_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/profile_screen.dart';
import 'package:nivex_flutter/features/receive/presentation/receive_usdc_screen.dart';
import 'package:nivex_flutter/features/session/presentation/session_unlock_sheet.dart';
import 'package:nivex_flutter/features/shell/domain/app_tab_controller.dart';
import 'package:nivex_flutter/features/transactions/presentation/transactions_screen.dart';
import 'package:nivex_flutter/features/wallet/presentation/wallet_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    this.initialTab = 0,
    this.themeController,
    this.cashoutAuthService,
    super.key,
  });

  final int initialTab;
  final ThemeController? themeController;
  final CashoutAuthService? cashoutAuthService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab != 0
        ? widget.initialTab
        : AppTabController.index.value;
    AppTabController.index.value = _selectedIndex;
    AppTabController.index.addListener(_handleExternalTabChange);
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
      ),
      const JobsScreen(),
      const PostsScreen(),
      const MessagesScreen(),
      WalletScreen(
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
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Trang chủ',
            ),
            NavigationDestination(
              icon: _JobsTabIcon(selected: false),
              selectedIcon: _JobsTabIcon(selected: true),
              label: 'Công việc',
            ),
            NavigationDestination(
              icon: _CommunityTabIcon(selected: false),
              selectedIcon: _CommunityTabIcon(selected: true),
              label: 'Cộng đồng',
            ),
            NavigationDestination(
              icon: _MessagesTabIcon(selected: false),
              selectedIcon: _MessagesTabIcon(selected: true),
              label: 'Tin nhắn',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Ví',
            ),
          ],
        ),
      ),
    );
  }

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
        builder: (_) => ProfileScreen(themeController: widget.themeController),
      ),
    );
  }

  Future<void> _openHistory() {
    return Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const TransactionsScreen()));
  }
}

class _CommunityTabIcon extends StatelessWidget {
  const _CommunityTabIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = selected
        ? theme.colorScheme.primary
        : theme.navigationBarTheme.iconTheme?.resolve(<WidgetState>{})?.color ??
              theme.colorScheme.onSurfaceVariant;
    return Transform.translate(
      offset: const Offset(0, -7),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(color: accent, width: selected ? 2 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(Icons.public_rounded, color: accent, size: 21),
      ),
    );
  }
}

class _MessagesTabIcon extends StatelessWidget {
  const _MessagesTabIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).navigationBarTheme.iconTheme
        ?.resolve(selected ? {WidgetState.selected} : <WidgetState>{})
        ?.color;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          selected ? Icons.forum_rounded : Icons.forum_outlined,
          color: color,
        ),
        Positioned(
          right: -7,
          top: -5,
          child: Container(
            width: 14,
            height: 14,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    Theme.of(context).navigationBarTheme.backgroundColor ??
                    Theme.of(context).colorScheme.surface,
                width: 1.5,
              ),
            ),
            child: Text(
              '1',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _JobsTabIcon extends StatelessWidget {
  const _JobsTabIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).navigationBarTheme.iconTheme
        ?.resolve(selected ? {WidgetState.selected} : <WidgetState>{})
        ?.color;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          selected ? Icons.work_rounded : Icons.work_outline_rounded,
          color: color,
        ),
        Positioned(
          right: -8,
          top: -6,
          child: Container(
            constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '2',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
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
