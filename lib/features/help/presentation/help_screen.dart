import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';
import 'package:nivex_flutter/shared/widgets/solana_mark.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NivexPage(
      title: 'Trợ giúp',
      subtitle: 'Hỗ trợ sử dụng prototype NIVEX',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              // 1. Devnet Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NivexColors.blueSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: SolanaMark(width: 18),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'NIVEX hiện hoạt động trên môi trường thử nghiệm Solana Devnet. '
                        'Không gửi tiền thật hoặc tài sản có giá trị vào ứng dụng.',
                        style: TextStyle(
                          color: NivexColors.navy,
                          fontSize: 12.5,
                          height: 1.45,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. FAQ Section
              const Text(
                'Câu hỏi thường gặp',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: NivexColors.navy,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: NivexColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NivexColors.border),
                ),
                child: Column(
                  children: const [
                    ExpansionTile(
                      minTileHeight: 54,
                      shape: Border(),
                      collapsedShape: Border(),
                      title: Text(
                        'Nhận USDC như thế nào?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: NivexColors.navy,
                          letterSpacing: 0,
                        ),
                      ),
                      childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 14),
                      children: [
                        Text(
                          'Mở mục Nhận USDC từ trang chủ, sao chép địa chỉ ví hoặc chia sẻ mã QR. '
                          'Chỉ sử dụng mạng Solana Devnet trong bản prototype.',
                          style: TextStyle(
                            fontSize: 13,
                            color: NivexColors.textSecondary,
                            height: 1.4,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 1, thickness: 1, color: NivexColors.border),
                    ExpansionTile(
                      minTileHeight: 54,
                      shape: Border(),
                      collapsedShape: Border(),
                      title: Text(
                        'Bao lâu thì nhận được VND?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: NivexColors.navy,
                          letterSpacing: 0,
                        ),
                      ),
                      childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 14),
                      children: [
                        Text(
                          'Trong bản mô phỏng, giao dịch rút VND hoàn tất sau khoảng 1-2 giây. '
                          'Bản chính thức sẽ kết nối cổng thanh toán ngân hàng 24/7.',
                          style: TextStyle(
                            fontSize: 13,
                            color: NivexColors.textSecondary,
                            height: 1.4,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 1, thickness: 1, color: NivexColors.border),
                    ExpansionTile(
                      minTileHeight: 54,
                      shape: Border(),
                      collapsedShape: Border(),
                      title: Text(
                        'Báo giá hết hạn thì xử lý sao?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: NivexColors.navy,
                          letterSpacing: 0,
                        ),
                      ),
                      childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 14),
                      children: [
                        Text(
                          'Mỗi báo giá được giữ trong 30 giây. Khi hết hạn, nhấn "Lấy báo giá mới" '
                          'để cập nhật tỷ giá và nhận thời hạn 30 giây tiếp theo.',
                          style: TextStyle(
                            fontSize: 13,
                            color: NivexColors.textSecondary,
                            height: 1.4,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Contact Section
              const Text(
                'Kênh hỗ trợ',
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
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: NivexColors.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      minTileHeight: 58,
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
                          Icons.mail_outline_rounded,
                          color: NivexColors.blue,
                          size: 19,
                        ),
                      ),
                      title: const Text(
                        'Email hỗ trợ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: NivexColors.navy,
                          letterSpacing: 0,
                        ),
                      ),
                      subtitle: const Text(
                        'hotro@nivex.vn',
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
                        tooltip: 'Sao chép email',
                        onPressed: () => _copyEmail(context),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: NivexColors.border,
                      indent: 68,
                    ),
                    ListTile(
                      minTileHeight: 58,
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
                          Icons.schedule_rounded,
                          color: NivexColors.blue,
                          size: 19,
                        ),
                      ),
                      title: const Text(
                        'Thời gian phản hồi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: NivexColors.navy,
                          letterSpacing: 0,
                        ),
                      ),
                      subtitle: const Text(
                        '08:00 – 22:00 hàng ngày',
                        style: TextStyle(
                          fontSize: 12,
                          color: NivexColors.textSecondary,
                          letterSpacing: 0,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: NivexColors.textSecondary,
                      ),
                      onTap: () => _showHours(context),
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

  Future<void> _copyEmail(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: 'hotro@nivex.vn'));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép email hỗ trợ.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHours(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Thời gian hỗ trợ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: NivexColors.navy,
            letterSpacing: 0,
          ),
        ),
        content: const Text(
          'Đội ngũ chăm sóc khách hàng phản hồi từ 08:00 đến 22:00 tất cả các ngày trong tuần (kể cả Thứ Bảy, Chủ Nhật và ngày lễ).',
          style: TextStyle(
            fontSize: 13.5,
            color: NivexColors.navy,
            height: 1.45,
            letterSpacing: 0,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
