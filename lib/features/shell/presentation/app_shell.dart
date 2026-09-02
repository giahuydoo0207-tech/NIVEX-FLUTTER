import 'package:flutter/material.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_draft.dart';
import 'package:nivex_flutter/features/cashout/presentation/cashout_screen.dart';
import 'package:nivex_flutter/features/cashout/presentation/quote_screen.dart';
import 'package:nivex_flutter/features/help/presentation/help_screen.dart';
import 'package:nivex_flutter/features/home/presentation/home_screen.dart';
import 'package:nivex_flutter/features/receive/presentation/receive_usdc_screen.dart';
import 'package:nivex_flutter/features/shell/domain/app_tab_controller.dart';
import 'package:nivex_flutter/features/transactions/presentation/transactions_screen.dart';
import 'package:nivex_flutter/features/wallet/presentation/wallet_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({this.initialTab = 0, super.key});

  final int initialTab;

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
        onReceive: _openReceive,
        onCashout: _openCashout,
        onHistory: () => _selectTab(2),
        onQuote: _openQuickQuote,
        onHelp: _openHelp,
      ),
      WalletScreen(onReceive: _openReceive, onCashout: _openCashout),
      const TransactionsScreen(),
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
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Ví',
            ),
            NavigationDestination(
              icon: Icon(Icons.swap_horiz_rounded),
              selectedIcon: Icon(Icons.swap_horiz_rounded),
              label: 'Giao dịch',
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(int index) {
    AppTabController.index.value = index;
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
    return Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => const CashoutScreen()));
  }

  Future<void> _openQuickQuote() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => const QuoteScreen(
          draft: CashoutDraft(
            usdcAmount: 250,
            bankName: 'Vietcombank',
            accountNumber: '•••• 2868',
          ),
        ),
      ),
    );
  }

  Future<void> _openHelp() {
    return Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => const HelpScreen()));
  }
}
