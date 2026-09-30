import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/features/invoices/presentation/mobile_invoices_screen.dart';
import 'package:nivex_flutter/shared/constants/app_environment.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/receive/presentation/receive_usdc_screen.dart';
import 'package:nivex_flutter/features/wallet/data/receive_wallet_controller.dart';
import 'package:nivex_flutter/features/wallet/data/wallet_summary_controller.dart';
import 'package:nivex_flutter/features/wallet/presentation/receive_wallet_section.dart';
import 'package:nivex_flutter/shared/constants/demo_data.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';
import 'package:nivex_flutter/shared/widgets/solana_mark.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({
    required this.onReceive,
    required this.onCashout,
    required this.onQuote,
    required this.onHistory,
    required this.onHelp,
    this.api,
    super.key,
  });

  /// Shared authenticated client; invoices use it so token refresh applies.
  final NovaApiClient? api;

  final VoidCallback onReceive;
  final VoidCallback onCashout;
  final VoidCallback onQuote;
  final VoidCallback onHistory;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final liveApi = api;
    if (liveApi != null) return _LiveWallet(api: liveApi);
    final theme = context.nivexTheme;
    return NivexPage(
      title: 'Ví của bạn',
      subtitle: 'Demo Mode • Solana Devnet',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            key: const PageStorageKey('wallet-scroll'),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              if (api != null ||
                  AppEnvironmentScope.of(context) == AppEnvironment.staging)
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('Hóa đơn Devnet'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MobileInvoicesScreen(api: api),
                    ),
                  ),
                ),
              // 1. Compact Balance Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.isDark ? theme.surface : const Color(0xFF0F2439),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số dư khả dụng',
                      style: TextStyle(
                        color: Color(0xFFCAD8E5),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '880,00 USDC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      '≈ 22.480.000 VND',
                      style: TextStyle(
                        color: Color(0xFFCAD8E5),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: onReceive,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(44),
                              backgroundColor: theme.primary,
                              foregroundColor: theme.isDark
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Nhận USDC'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onCashout,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(44),
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF8DA5B8)),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Rút VND'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _WalletActionGrid(
                onReceive: onReceive,
                onCashout: onCashout,
                onQuote: onQuote,
                onHistory: onHistory,
                onHelp: onHelp,
              ),
              const SizedBox(height: 24),
              // 2. Token Asset List
              Text(
                'TÀI SẢN',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.textSecondary,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: [
                    _TokenRow(
                      icon: SolanaMark(width: 20),
                      title: 'USD Coin',
                      symbol: 'USDC (Solana Devnet)',
                      amount: '880,00 USDC',
                      fiatAmount: '≈ 22.480.000 VND',
                      onTap: onReceive,
                    ),
                    Divider(height: 1, thickness: 1, color: theme.divider),
                    _TokenRow(
                      icon: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'đ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      title: 'Việt Nam Đồng',
                      symbol: 'VND (Mô phỏng ngân hàng)',
                      amount: '0 VND',
                      fiatAmount: 'Sẵn sàng rút',
                      onTap: onCashout,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 3. Solana Devnet Public Address Card
              Text(
                'ĐỊA CHỈ VÍ SOLANA DEVNET',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.textSecondary,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SolanaMark(width: 16),
                        const SizedBox(width: 8),
                        Text(
                          DemoData.solanaAddressShort,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Địa chỉ ví dùng để nhận test USDC trên Solana Devnet.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: theme.textSecondary,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                              const ClipboardData(
                                text: ReceiveUsdcScreen.address,
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã sao chép địa chỉ ví Solana'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Sao chép'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.primary,
                            side: BorderSide(color: theme.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton.tonalIcon(
                          onPressed: onReceive,
                          icon: const Icon(Icons.qr_code_rounded, size: 16),
                          label: const Text('Mã QR'),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.surfaceSubtle,
                            foregroundColor: theme.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wallet backed by `/mobile/wallet/*`. Businesses pay into the payout wallet
/// the user registers here; amounts come from the payment ledger only, and
/// old payments into the server demo wallet are labelled as such. Demo
/// actions (receive, VND cash-out) are hidden.
class _LiveWallet extends StatefulWidget {
  const _LiveWallet({required this.api});

  final NovaApiClient api;

  @override
  State<_LiveWallet> createState() => _LiveWalletState();
}

class _LiveWalletState extends State<_LiveWallet> {
  late final WalletSummaryController _wallet = WalletSummaryController.of(
    widget.api,
  );
  late final ReceiveWalletController _receive = ReceiveWalletController(
    widget.api,
  );
  List<NovaWalletTransaction>? _transactions;
  bool _transactionsFailed = false;

  @override
  void initState() {
    super.initState();
    _wallet.addListener(_changed);
    _refresh();
  }

  @override
  void dispose() {
    _wallet.removeListener(_changed);
    _receive.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    final summary = _wallet.refresh();
    final receive = _receive.load();
    try {
      final items = await widget.api.walletTransactions();
      if (mounted) {
        setState(() {
          _transactions = items;
          _transactionsFailed = false;
        });
      }
    } on NovaApiException {
      if (mounted) setState(() => _transactionsFailed = true);
    }
    await summary;
    await receive;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final summary = _wallet.summary;
    final transactions = _transactions;
    return NivexPage(
      title: 'Ví của bạn',
      subtitle: 'Solana ${summary?.network ?? 'Devnet'}',
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          key: const PageStorageKey('wallet-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.isDark ? theme.surface : const Color(0xFF0F2439),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.border),
              ),
              child: summary == null
                  ? SizedBox(
                      height: 96,
                      child: Center(
                        child: _wallet.failed
                            ? TextButton(
                                onPressed: _refresh,
                                child: const Text('Chưa tải được ví. Thử lại'),
                              )
                            : const CircularProgressIndicator(),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.hasPayoutWallet
                              ? 'Đã nhận vào ví cá nhân'
                              : 'Ví nhận tiền',
                          style: const TextStyle(
                            color: Color(0xFFCAD8E5),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          summary.hasPayoutWallet
                              ? '${formatUsdc2(summary.paidToPersonalWalletMinor)} USDC'
                              : 'Chưa cấu hình ví nhận tiền',
                          key: const Key('wallet-available-balance'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: summary.hasPayoutWallet ? 28 : 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (!summary.hasPayoutWallet &&
                            summary.paidToPersonalWalletMinor > BigInt.zero)
                          _SummaryLine(
                            label: 'Đã nhận vào ví cá nhân',
                            value:
                                '${formatUsdc2(summary.paidToPersonalWalletMinor)} USDC',
                          ),
                        _SummaryLine(
                          label: 'Đang chờ thanh toán',
                          value: '${formatUsdc2(summary.pendingBalanceMinor)} USDC',
                        ),
                        _SummaryLine(
                          label: 'Thu nhập 7 ngày qua',
                          value: '${formatUsdc2(summary.earnedLast7DaysMinor)} USDC',
                        ),
                        if (summary.paidViaDemoWalletMinor > BigInt.zero)
                          _SummaryLine(
                            label: 'Giao dịch demo cũ (ví máy chủ)',
                            value:
                                '${formatUsdc2(summary.paidViaDemoWalletMinor)} USDC',
                          ),
                        const SizedBox(height: 10),
                        Text(
                          summary.hasPayoutWallet
                              ? 'Số liệu lấy từ các thanh toán Nova đã hoàn tất trên '
                                    'Solana Devnet, không phải số dư đọc từ ví.'
                              : 'Thêm địa chỉ ví bên dưới để doanh nghiệp có thể '
                                    'thanh toán USDC cho bạn.',
                          style: const TextStyle(
                            color: Color(0xFFCAD8E5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            ReceiveWalletSection(
              controller: _receive,
              onChanged: () => unawaited(_wallet.refresh()),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Hóa đơn Devnet'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MobileInvoicesScreen(api: widget.api),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'GIAO DỊCH DEVNET ĐÃ XÁC NHẬN',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            if (_transactionsFailed)
              Text(
                'Chưa tải được giao dịch. Kéo xuống để thử lại.',
                style: TextStyle(color: theme.textSecondary),
              )
            else if (transactions == null)
              const Center(child: CircularProgressIndicator())
            else if (transactions.isEmpty)
              Text(
                'Chưa có giao dịch nào.',
                style: TextStyle(color: theme.textSecondary),
              )
            else
              for (final transaction in transactions)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const SolanaMark(width: 20),
                  title: Text(
                    '+${formatUsdc2(transaction.amountMinor)} ${transaction.token}'
                    '${transaction.isLegacyDemo ? ' · Giao dịch demo cũ' : ''}',
                  ),
                  subtitle: Text(
                    '${transaction.invoiceNumber ?? 'Hóa đơn'} · '
                    '${transaction.isLegacyDemo ? 'Vào ví demo máy chủ' : 'Vào ví ${_shortAddress(transaction.recipient)}'}\n'
                    'Chữ ký ${_shortAddress(transaction.signature)} · '
                    '${transaction.recordedAt.toLocal().toString().substring(0, 16)}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'Sao chép chữ ký giao dịch',
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: () => Clipboard.setData(
                      ClipboardData(text: transaction.signature),
                    ),
                  ),
                ),
            if (summary?.demoRecipientAddress != null) ...[
              const SizedBox(height: 20),
              Text(
                'VÍ DEMO CŨ CỦA MÁY CHỦ (GIAO DỊCH TRƯỚC ĐÂY)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                summary!.demoRecipientAddress!,
                style: TextStyle(color: theme.textPrimary, fontSize: 12.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _shortAddress(String value) => value.length <= 12
      ? value
      : '${value.substring(0, 6)}…${value.substring(value.length - 6)}';
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFFCAD8E5), fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletActionGrid extends StatelessWidget {
  const _WalletActionGrid({
    required this.onReceive,
    required this.onCashout,
    required this.onQuote,
    required this.onHistory,
    required this.onHelp,
  });

  final VoidCallback onReceive;
  final VoidCallback onCashout;
  final VoidCallback onQuote;
  final VoidCallback onHistory;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final actions = [
      (Icons.file_download_outlined, 'Nhận USDC', onReceive),
      (Icons.file_upload_outlined, 'Rút VND', onCashout),
      (Icons.show_chart_rounded, 'Báo giá', onQuote),
      (Icons.receipt_long_outlined, 'Giao dịch', onHistory),
      (Icons.headset_mic_outlined, 'Trợ giúp', onHelp),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THAO TÁC VÍ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: theme.textSecondary,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.38,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: action.$3,
              borderRadius: BorderRadius.circular(12),
              child: Ink(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(action.$1, color: theme.primary, size: 21),
                    const SizedBox(height: 6),
                    Text(
                      action.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TokenRow extends StatelessWidget {
  const _TokenRow({
    required this.icon,
    required this.title,
    required this.symbol,
    required this.amount,
    required this.fiatAmount,
    required this.onTap,
  });

  final Widget icon;
  final String title;
  final String symbol;
  final String amount;
  final String fiatAmount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.surfaceSubtle,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textSecondary,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fiatAmount,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondary,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
