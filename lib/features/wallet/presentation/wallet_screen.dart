import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/receive/presentation/receive_usdc_screen.dart';
import 'package:nivex_flutter/shared/constants/demo_data.dart';
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
