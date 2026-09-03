import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/shared/constants/demo_data.dart';
import 'package:nivex_flutter/shared/widgets/demo_notice.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';
import 'package:nivex_flutter/shared/widgets/solana_mark.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveUsdcScreen extends StatelessWidget {
  const ReceiveUsdcScreen({super.key});

  static const address = DemoData.solanaAddressFull;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexPage(
      title: 'Nhận USDC',
      subtitle: 'Mạng Solana Devnet',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              children: [
                // 1. QR Code & Address Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.border),
                  ),
                  child: Column(
                    children: [
                      // Demo Mode • Solana Devnet Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SolanaMark(width: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Demo Mode • Solana Devnet',
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Clean white card for QR scan reliability
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: theme.border),
                        ),
                        child: QrImageView(
                          data: address,
                          version: QrVersions.auto,
                          size: 180,
                          backgroundColor: Colors.white,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF0F2439),
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF0F2439),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Địa chỉ ví USDC',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 13,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.border),
                        ),
                        child: SelectableText(
                          address,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                  const ClipboardData(text: address),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Đã sao chép địa chỉ ví Solana',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              label: const Text('Sao chép'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                                foregroundColor: theme.primary,
                                side: BorderSide(color: theme.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 2. Guidelines & Disclaimers
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.surfaceSubtle,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: theme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Lưu ý quan trọng',
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
                        '• Chỉ gửi USDC qua mạng Solana.\n• Gửi token qua mạng khác có thể khiến tài sản không thể khôi phục.\n• Bản demo sử dụng dữ liệu mô phỏng hoặc Solana Devnet. Không gửi tài sản thật.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: theme.textSecondary,
                          height: 1.5,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const DemoNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
