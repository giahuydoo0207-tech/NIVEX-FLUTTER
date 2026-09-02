import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';
import 'package:nivex_flutter/shared/widgets/solana_mark.dart';

class ReceiveUsdcScreen extends StatelessWidget {
  const ReceiveUsdcScreen({super.key});

  static const address = '7xKm4hVfN8fK2WmC9Dq3PzL6sT1aQp9';

  @override
  Widget build(BuildContext context) {
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
                    color: NivexColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: NivexColors.border),
                  ),
                  child: Column(
                    children: [
                      // Solana Devnet Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: NivexColors.blueSoft,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SolanaMark(width: 18),
                            SizedBox(width: 6),
                            Text(
                              'Solana Devnet',
                              style: TextStyle(
                                color: NivexColors.navy,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _QrPreview(),
                      const SizedBox(height: 16),
                      const Text(
                        'Địa chỉ ví USDC',
                        style: TextStyle(
                          color: NivexColors.textSecondary,
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
                          color: NivexColors.ivory,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: NivexColors.border),
                        ),
                        child: const SelectableText(
                          address,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: NivexColors.navy,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _copyAddress(context),
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              label: const Text('Sao chép'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                                foregroundColor: NivexColors.navy,
                                side: const BorderSide(
                                  color: NivexColors.border,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _showShareSheet(context),
                              icon: const Icon(Icons.share_outlined, size: 18),
                              label: const Text('Chia sẻ'),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                                backgroundColor: NivexColors.blue,
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
                const SizedBox(height: 14),

                // 2. Short Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: NivexColors.blueSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: NivexColors.blue,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Chỉ gửi USDC trên mạng Solana Devnet. Đây là môi trường thử nghiệm mô phỏng, không gửi tài sản thật.',
                          style: TextStyle(
                            color: NivexColors.navy,
                            fontSize: 12.5,
                            height: 1.4,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. CTA Return to Home
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: NivexColors.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Về trang chủ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _copyAddress(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: address));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép địa chỉ ví.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void _showShareSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chia sẻ địa chỉ ví',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NivexColors.navy,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: 52,
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: NivexColors.blueSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.copy_rounded,
                  color: NivexColors.blue,
                  size: 19,
                ),
              ),
              title: const Text(
                'Sao chép địa chỉ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: NivexColors.navy,
                  fontSize: 14,
                  letterSpacing: 0,
                ),
              ),
              subtitle: const Text(
                'Lưu vào bộ nhớ tạm',
                style: TextStyle(
                  color: NivexColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 0,
                ),
              ),
              onTap: () async {
                await Clipboard.setData(const ClipboardData(text: address));
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã sao chép địa chỉ ví.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            const Divider(height: 1, color: NivexColors.border),
            ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: 52,
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: NivexColors.blueSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: NivexColors.blue,
                  size: 19,
                ),
              ),
              title: const Text(
                'Chia sẻ mã QR',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: NivexColors.navy,
                  fontSize: 14,
                  letterSpacing: 0,
                ),
              ),
              subtitle: const Text(
                'Mô phỏng chia sẻ qua ứng dụng khác',
                style: TextStyle(
                  color: NivexColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 0,
                ),
              ),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrPreview extends StatelessWidget {
  const _QrPreview();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Mã QR nhận USDC trên Solana Devnet',
      image: true,
      child: Container(
        width: 170,
        height: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: NivexColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: NivexColors.border),
        ),
        child: CustomPaint(painter: _QrPainter()),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 13;
    final paint = Paint()..color = NivexColors.navy;
    for (var row = 0; row < 13; row++) {
      for (var column = 0; column < 13; column++) {
        final finder =
            (row < 4 && column < 4) ||
            (row < 4 && column > 8) ||
            (row > 8 && column < 4);
        final data = ((row * 7 + column * 5 + row * column) % 4) < 2;
        if (finder || data) {
          canvas.drawRect(
            Rect.fromLTWH(column * cell, row * cell, cell * .82, cell * .82),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
