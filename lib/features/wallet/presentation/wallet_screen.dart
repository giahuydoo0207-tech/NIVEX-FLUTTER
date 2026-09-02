import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/features/receive/presentation/receive_usdc_screen.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';
import 'package:nivex_flutter/shared/widgets/solana_mark.dart';

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
      subtitle: 'Demo Mode • Solana Devnet',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            key: const PageStorageKey('wallet-scroll'),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              // 1. Compact Balance Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: NivexColors.navy,
                  borderRadius: BorderRadius.circular(16),
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
                        color: NivexColors.white,
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
                              backgroundColor: NivexColors.white,
                              foregroundColor: NivexColors.navy,
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
                              foregroundColor: NivexColors.white,
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
              const SizedBox(height: 22),

              // 2. Assets Section: Flat List
              const Text(
                'Tài sản',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: NivexColors.navy,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: NivexColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: NivexColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: NivexColors.blueSoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        r'$',
                        style: TextStyle(
                          color: NivexColors.blue,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'USD Coin',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: NivexColors.navy,
                              letterSpacing: 0,
                            ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              SolanaMark(width: 13),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Solana Devnet',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: NivexColors.textSecondary,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '880,00',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: NivexColors.navy,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '22.480.000 đ',
                          style: TextStyle(
                            fontSize: 12,
                            color: NivexColors.textSecondary,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 3. Wallet Information: Clean List Group
              const Text(
                'Thông tin ví',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: NivexColors.navy,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              Material(
                color: NivexColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: NivexColors.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      minTileHeight: 56,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: NivexColors.blueSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.key_outlined,
                          color: NivexColors.blue,
                          size: 19,
                        ),
                      ),
                      title: const Text(
                        'Địa chỉ ví',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: NivexColors.navy,
                          letterSpacing: 0,
                        ),
                      ),
                      subtitle: const Text(
                        '7xKXtg...sgAsU',
                        style: TextStyle(
                          fontSize: 12,
                          color: NivexColors.textSecondary,
                          letterSpacing: 0,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.copy_rounded,
                          color: NivexColors.blue,
                          size: 19,
                        ),
                        tooltip: 'Sao chép địa chỉ',
                        onPressed: () => _copyAddress(context),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: NivexColors.border,
                      indent: 68,
                    ),
                    ListTile(
                      minTileHeight: 56,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: NivexColors.blueSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.account_balance_outlined,
                          color: NivexColors.blue,
                          size: 19,
                        ),
                      ),
                      title: const Text(
                        'Tài khoản nhận VND',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: NivexColors.navy,
                          letterSpacing: 0,
                        ),
                      ),
                      subtitle: const Text(
                        'Vietcombank •••• 2868',
                        style: TextStyle(
                          fontSize: 12,
                          color: NivexColors.textSecondary,
                          letterSpacing: 0,
                        ),
                      ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép địa chỉ ví.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
