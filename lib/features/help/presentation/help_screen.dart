import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

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
              const NivexCard(
                color: NivexColors.blueSoft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, color: NivexColors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'NIVEX hiện dùng dữ liệu mô phỏng trên Solana Devnet. '
                        'Không gửi USDC hoặc tiền thật vào prototype.',
                        style: TextStyle(height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Câu hỏi thường gặp',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              NivexCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: const [
                    ExpansionTile(
                      minTileHeight: 56,
                      title: Text('Nhận USDC như thế nào?'),
                      childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        Text(
                          'Mở Nhận USDC, sao chép địa chỉ hoặc chia sẻ mã QR. '
                          'Chỉ sử dụng mạng Solana Devnet trong prototype.',
                        ),
                      ],
                    ),
                    Divider(),
                    ExpansionTile(
                      minTileHeight: 56,
                      title: Text('Bao lâu thì nhận được VND?'),
                      childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        Text(
                          'Luồng mô phỏng hoàn tất sau vài giây. Sản phẩm thật '
                          'sẽ hiển thị thời gian dự kiến trước khi xác nhận.',
                        ),
                      ],
                    ),
                    Divider(),
                    ExpansionTile(
                      minTileHeight: 56,
                      title: Text('Báo giá hết hạn thì sao?'),
                      childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        Text(
                          'Chọn Lấy báo giá mới để nhận tỷ giá và thời hạn 30 '
                          'giây mới trước khi xác nhận yêu cầu.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text('Liên hệ', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              NivexCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      minTileHeight: 60,
                      leading: const Icon(Icons.mail_outline_rounded),
                      title: const Text('Email hỗ trợ'),
                      subtitle: const Text('hotro@nivex.vn'),
                      trailing: const Icon(Icons.copy_rounded),
                      onTap: () => _copyEmail(context),
                    ),
                    const Divider(indent: 56),
                    ListTile(
                      minTileHeight: 60,
                      leading: const Icon(Icons.schedule_rounded),
                      title: const Text('Thời gian phản hồi'),
                      subtitle: const Text('08:00–22:00, tất cả các ngày'),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã sao chép email hỗ trợ.')));
  }

  void _showHours(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thời gian hỗ trợ'),
        content: const Text(
          'Đội ngũ hỗ trợ phản hồi từ 08:00 đến 22:00 mỗi ngày, '
          'kể cả cuối tuần.',
        ),
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
