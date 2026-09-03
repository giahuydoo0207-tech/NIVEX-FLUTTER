import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/home/domain/wallet_transaction.dart';
import 'package:nivex_flutter/shared/constants/demo_data.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  static const _items = [
    WalletTransaction(
      title: 'Nhận USDC',
      subtitle: '01/09/2026, 09:42 • Hoàn tất',
      amount: '+250,00 USDC',
      amountDetail: '+6.386.250 đ',
      icon: Icons.south_west_rounded,
      kind: TransactionKind.incoming,
    ),
    WalletTransaction(
      title: 'Quy đổi sang VND',
      subtitle: '31/08/2026, 16:20 • Hoàn tất',
      amount: '-80,00 USDC',
      amountDetail: '+2.044.400 đ',
      icon: Icons.currency_exchange_rounded,
      kind: TransactionKind.exchange,
    ),
    WalletTransaction(
      title: 'Chuyển USDC',
      subtitle: '29/08/2026, 11:08 • Hoàn tất',
      amount: '-25,00 USDC',
      amountDetail: 'Ví ${DemoData.solanaAddressShort}',
      icon: Icons.north_east_rounded,
      kind: TransactionKind.outgoing,
    ),
    WalletTransaction(
      title: 'Nhận USDC',
      subtitle: '26/08/2026, 14:35 • Hoàn tất',
      amount: '+120,00 USDC',
      amountDetail: '+3.065.400 đ',
      icon: Icons.south_west_rounded,
      kind: TransactionKind.incoming,
    ),
    WalletTransaction(
      title: 'Rút về Vietcombank',
      subtitle: '24/08/2026, 10:12 • Hoàn tất',
      amount: '-150,00 USDC',
      amountDetail: '+3.831.750 đ',
      icon: Icons.account_balance_outlined,
      kind: TransactionKind.exchange,
    ),
  ];

  TransactionKind? _filter;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final visible = _filter == null
        ? _items
        : _items.where((item) => item.kind == _filter).toList();

    return NivexPage(
      title: 'Giao dịch',
      subtitle: 'Lịch sử hoạt động của ví',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            key: const PageStorageKey('transactions-scroll'),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              // 1. Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Tất cả',
                      selected: _filter == null,
                      onTap: () => setState(() => _filter = null),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Tiền vào',
                      selected: _filter == TransactionKind.incoming,
                      onTap: () =>
                          setState(() => _filter = TransactionKind.incoming),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Tiền ra',
                      selected: _filter == TransactionKind.outgoing,
                      onTap: () =>
                          setState(() => _filter = TransactionKind.outgoing),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Quy đổi',
                      selected: _filter == TransactionKind.exchange,
                      onTap: () =>
                          setState(() => _filter = TransactionKind.exchange),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 2. Transaction List Card
              Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.border),
                ),
                child: visible.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'Không có giao dịch nào',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 14,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          thickness: 1,
                          color: theme.divider,
                        ),
                        itemBuilder: (context, index) {
                          final item = visible[index];
                          final isPositive =
                              item.kind == TransactionKind.incoming;
                          final amountColor = isPositive
                              ? theme.success
                              : (item.kind == TransactionKind.outgoing
                                    ? theme.danger
                                    : theme.textPrimary);

                          final iconBg = isPositive
                              ? theme.successSoft
                              : (item.kind == TransactionKind.outgoing
                                    ? theme.dangerSoft
                                    : theme.surfaceSubtle);

                          final iconColor = isPositive
                              ? theme.success
                              : (item.kind == TransactionKind.outgoing
                                    ? theme.danger
                                    : theme.primary);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: iconBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: iconColor,
                                    size: 19,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: theme.textPrimary,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.textSecondary,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        item.amount,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: amountColor,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.amountDetail,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? theme.primary : theme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? theme.primary : theme.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected
                ? (theme.isDark ? const Color(0xFF0F172A) : Colors.white)
                : theme.textSecondary,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
