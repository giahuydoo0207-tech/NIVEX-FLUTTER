import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/features/home/domain/wallet_transaction.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';
import 'package:nivex_flutter/shared/widgets/solana_mark.dart';

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
      amountDetail: 'Ví 7xKX...sgAsU',
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

              // 2. Flat Transaction List with Thin Dividers
              Container(
                decoration: BoxDecoration(
                  color: NivexColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NivexColors.border),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < visible.length; i++) ...[
                      _TransactionRow(
                        transaction: visible[i],
                        onTap: () => _showDetails(context, visible[i]),
                      ),
                      if (i < visible.length - 1)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: NivexColors.border,
                          indent: 68,
                          endIndent: 16,
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, WalletTransaction transaction) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: NivexColors.greenSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: NivexColors.green,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              transaction.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NivexColors.navy,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              transaction.amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: transaction.kind == TransactionKind.incoming
                    ? NivexColors.green
                    : NivexColors.navy,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NivexColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: NivexColors.border),
              ),
              child: Column(
                children: [
                  const _DetailRow(label: 'Trạng thái', value: 'Hoàn tất'),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Thời gian',
                    value: transaction.subtitle.split(' •').first,
                  ),
                  const SizedBox(height: 12),
                  const _DetailRow(label: 'Mạng', value: 'Solana Devnet'),
                  const SizedBox(height: 12),
                  const _DetailRow(label: 'Phí', value: '0 USDC'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Đóng'),
            ),
          ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? NivexColors.blueSoft : NivexColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? NivexColors.blue : NivexColors.border,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? NivexColors.blue : NivexColors.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction, required this.onTap});

  final WalletTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final incoming = transaction.kind == TransactionKind.incoming;
    final iconBg = incoming ? NivexColors.greenSoft : NivexColors.blueSoft;
    final iconColor = incoming ? NivexColors.green : NivexColors.blue;
    final amountColor = incoming ? NivexColors.green : NivexColors.navy;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(transaction.icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: NivexColors.navy,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                  transaction.amount,
                  style: TextStyle(
                    color: amountColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.amountDetail,
                  style: const TextStyle(
                    color: NivexColors.textSecondary,
                    fontSize: 11.5,
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: NivexColors.textSecondary,
              fontSize: 13.5,
              letterSpacing: 0,
            ),
          ),
        ),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value == 'Solana Devnet') ...[
                const SolanaMark(width: 14),
                const SizedBox(width: 5),
              ],
              Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: NivexColors.navy,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
