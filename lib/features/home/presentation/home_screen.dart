import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/features/home/domain/wallet_transaction.dart';
import 'package:nivex_flutter/shared/widgets/nivex_logo.dart';

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
  static const _transactions = [
    WalletTransaction(
      title: 'Nhận USDC',
      subtitle: 'Hôm nay, 09:42 • Hoàn tất',
      amount: '+250,00 USDC',
      amountDetail: '+6.386.250 đ',
      icon: Icons.south_west_rounded,
      kind: TransactionKind.incoming,
    ),
    WalletTransaction(
      title: 'Quy đổi sang VND',
      subtitle: 'Hôm qua, 16:20 • Hoàn tất',
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
  ];

  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            key: const PageStorageKey('home-scroll'),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(onNotifications: _showNotifications),
                const SizedBox(height: 20),
                const _SkylineBanner(),
                const SizedBox(height: 16),
                _BalanceCard(
                  balanceVisible: _balanceVisible,
                  onToggleBalance: () =>
                      setState(() => _balanceVisible = !_balanceVisible),
                  onReceive: widget.onReceive,
                  onCashout: widget.onCashout,
                ),
                const SizedBox(height: 22),
                _QuickActions(
                  actions: [
                    _HomeAction(
                      Icons.qr_code_2_rounded,
                      'Nhận USDC',
                      widget.onReceive,
                    ),
                    _HomeAction(
                      Icons.account_balance_outlined,
                      'Rút VND',
                      widget.onCashout,
                    ),
                    _HomeAction(
                      Icons.history_rounded,
                      'Lịch sử',
                      widget.onHistory,
                    ),
                    _HomeAction(
                      Icons.request_quote_outlined,
                      'Quote',
                      widget.onQuote,
                    ),
                    _HomeAction(
                      Icons.support_agent_rounded,
                      'Trợ giúp',
                      widget.onHelp,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _ExchangeRateCard(),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Giao dịch gần đây',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onHistory,
                      child: const Text('Xem tất cả'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _TransactionList(transactions: _transactions),
              ],
            ),
          ),
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

class _Header extends StatelessWidget {
  const _Header({required this.onNotifications});

  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: NivexColors.blueSoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            color: NivexColors.blue,
            size: 26,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Minh Anh', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              const Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: NivexColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: 7, height: 7),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Solana Devnet',
                    style: TextStyle(
                      color: NivexColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Thông báo',
          onPressed: onNotifications,
          style: IconButton.styleFrom(
            minimumSize: const Size(44, 44),
            backgroundColor: NivexColors.white,
            foregroundColor: NivexColors.navy,
            side: const BorderSide(color: NivexColors.border),
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _SkylineBanner extends StatelessWidget {
  const _SkylineBanner();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ảnh đường chân trời thành phố Việt Nam',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 142,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: NivexColors.sky),
              CustomPaint(painter: _SkylinePainter()),
              const Positioned(left: 18, top: 17, child: NivexLogo()),
              const Positioned(
                left: 18,
                top: 54,
                child: Text(
                  'Ví Solana cho người Việt',
                  style: TextStyle(
                    color: NivexColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
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

class _SkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final far = Paint()..color = const Color(0xFFB9D2E7);
    final near = Paint()..color = NivexColors.navySoft;
    final river = Path()
      ..moveTo(0, size.height * .84)
      ..quadraticBezierTo(
        size.width * .45,
        size.height * .68,
        size.width,
        size.height * .83,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(river, Paint()..color = const Color(0xFFC6DFEE));

    for (final rect in [
      Rect.fromLTWH(8, size.height * .66, size.width * .11, 42),
      Rect.fromLTWH(size.width * .16, size.height * .58, 38, 54),
      Rect.fromLTWH(size.width * .72, size.height * .61, 42, 52),
      Rect.fromLTWH(size.width * .86, size.height * .69, 48, 38),
    ]) {
      canvas.drawRect(rect, far);
    }
    final tower = Path()
      ..moveTo(size.width * .39, size.height * .88)
      ..lineTo(size.width * .45, size.height * .43)
      ..lineTo(size.width * .5, size.height * .35)
      ..lineTo(size.width * .56, size.height * .43)
      ..lineTo(size.width * .61, size.height * .88)
      ..close();
    canvas.drawPath(tower, near);
    canvas.drawRect(
      Rect.fromLTWH(size.width * .63, size.height * .52, 40, 55),
      near,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balanceVisible,
    required this.onToggleBalance,
    required this.onReceive,
    required this.onCashout,
  });

  final bool balanceVisible;
  final VoidCallback onToggleBalance;
  final VoidCallback onReceive;
  final VoidCallback onCashout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NivexColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NivexColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D102A43),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tổng tài sản',
                  style: TextStyle(color: NivexColors.textSecondary),
                ),
              ),
              IconButton(
                tooltip: balanceVisible ? 'Ẩn số dư' : 'Hiện số dư',
                onPressed: onToggleBalance,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                icon: Icon(
                  balanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: NivexColors.textSecondary,
                  size: 19,
                ),
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              balanceVisible ? '22.480.000 đ' : '••••••••',
              key: ValueKey(balanceVisible),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            balanceVisible ? '≈ 880,00 USDC' : 'Số dư đã được ẩn',
            style: const TextStyle(color: NivexColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onReceive,
                  icon: const Icon(Icons.qr_code_2_rounded, size: 19),
                  label: const Text('Nhận USDC'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onCashout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NivexColors.navy,
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: NivexColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Rút VND'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeAction {
  const _HomeAction(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.actions});

  final List<_HomeAction> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 16) / 3;
        return Wrap(
          spacing: 8,
          runSpacing: 10,
          children: actions.map((action) {
            return SizedBox(
              width: itemWidth,
              height: 78,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: action.onTap,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(action.icon, color: NivexColors.blue, size: 23),
                    const SizedBox(height: 7),
                    Text(
                      action.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: NivexColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ExchangeRateCard extends StatelessWidget {
  const _ExchangeRateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NivexColors.greenSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: NivexColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.paid_outlined, color: NivexColors.green),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tỷ giá tham khảo',
                  style: TextStyle(
                    color: NivexColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '1 USDC ≈ 25.545 VND',
                  style: TextStyle(
                    color: NivexColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+0,12%',
            style: TextStyle(
              color: NivexColors.green,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions});

  final List<WalletTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NivexColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NivexColors.border),
      ),
      child: Column(
        children: [
          for (var index = 0; index < transactions.length; index++) ...[
            _TransactionRow(transaction: transactions[index]),
            if (index != transactions.length - 1)
              const Divider(indent: 68, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final incoming = transaction.kind == TransactionKind.incoming;
    final color = incoming ? NivexColors.green : NivexColors.blue;
    final background = incoming ? NivexColors.greenSoft : NivexColors.blueSoft;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(transaction.icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
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
            subtitle: Text('Bạn đã nhận 250,00 USDC vào ví Devnet.'),
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
          const SizedBox(height: 8),
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
