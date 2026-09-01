import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/features/home/domain/wallet_transaction.dart';
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
      amountDetail: 'Ví 7xKm...2Qp9',
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
              const SizedBox(height: 18),
              for (final item in visible) ...[
                _TransactionTile(
                  transaction: item,
                  onTap: () => _showDetails(context, item),
                ),
                const SizedBox(height: 10),
              ],
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
            const CircleAvatar(
              radius: 28,
              backgroundColor: NivexColors.greenSoft,
              child: Icon(Icons.check_rounded, color: NivexColors.green),
            ),
            const SizedBox(height: 12),
            Text(
              transaction.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(transaction.amount),
            const SizedBox(height: 20),
            NivexCard(
              child: Column(
                children: [
                  _DetailRow(label: 'Trạng thái', value: 'Hoàn tất'),
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
    return SizedBox(
      height: 44,
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: NivexColors.blueSoft,
        side: BorderSide(
          color: selected ? NivexColors.blue : NivexColors.border,
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.onTap});

  final WalletTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final incoming = transaction.kind == TransactionKind.incoming;
    return Material(
      color: NivexColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: NivexColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        minTileHeight: 72,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: CircleAvatar(
          backgroundColor: incoming
              ? NivexColors.greenSoft
              : NivexColors.blueSoft,
          child: Icon(
            transaction.icon,
            color: incoming ? NivexColors.green : NivexColors.blue,
          ),
        ),
        title: Text(transaction.title),
        subtitle: Text(
          transaction.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              transaction.amount,
              style: TextStyle(
                color: incoming ? NivexColors.green : NivexColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              transaction.amountDetail,
              style: const TextStyle(
                color: NivexColors.textSecondary,
                fontSize: 10,
              ),
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
            style: const TextStyle(color: NivexColors.textSecondary),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
