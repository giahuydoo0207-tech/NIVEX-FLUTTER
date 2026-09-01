import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/features/receive/presentation/receive_usdc_screen.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({
    required this.onReceive,
    required this.onCashout,
    super.key,
  });

  final VoidCallback onReceive;
  final VoidCallback onCashout;

  @override
  Widget build(BuildContext context) {
    return NivexPage(
      title: 'Ví của bạn',
      subtitle: 'Solana Devnet • Dữ liệu mô phỏng',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            key: const PageStorageKey('wallet-scroll'),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NivexColors.navy,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số dư khả dụng',
                      style: TextStyle(color: Color(0xFFCAD8E5)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '880,00 USDC',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(color: NivexColors.white),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '≈ 22.480.000 VND',
                      style: TextStyle(color: Color(0xFFCAD8E5)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: onReceive,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: NivexColors.white,
                              foregroundColor: NivexColors.navy,
                            ),
                            child: const Text('Nhận USDC'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onCashout,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              foregroundColor: NivexColors.white,
                              side: const BorderSide(color: Color(0xFF8DA5B8)),
                            ),
                            child: const Text('Rút VND'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Tài sản', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              const NivexCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: NivexColors.blueSoft,
                      child: Text(
                        r'$',
                        style: TextStyle(
                          color: NivexColors.blue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'USD Coin',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'USDC • Solana Devnet',
                            style: TextStyle(color: NivexColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '880,00',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '22.480.000 đ',
                          style: TextStyle(color: NivexColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Thông tin ví',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              NivexCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      minTileHeight: 58,
                      leading: const Icon(Icons.key_outlined),
                      title: const Text('Địa chỉ ví'),
                      subtitle: const Text('7xKm...aQp9'),
                      trailing: const Icon(Icons.copy_rounded),
                      onTap: () => _copyAddress(context),
                    ),
                    const Divider(indent: 56),
                    const ListTile(
                      minTileHeight: 58,
                      leading: Icon(Icons.account_balance_outlined),
                      title: Text('Tài khoản nhận VND'),
                      subtitle: Text('Vietcombank •••• 2868'),
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

  Future<void> _copyAddress(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(text: ReceiveUsdcScreen.address),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã sao chép địa chỉ ví.')));
  }
}
