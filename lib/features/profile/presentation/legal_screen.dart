import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/features/profile/widgets/demo_notice.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NivexPage(
      title: 'Điều khoản & quyền riêng tư',
      subtitle: 'Thông tin pháp lý và bản quyền',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: NivexColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: NivexColors.border),
                  ),
                  child: Column(
                    children: const [
                      _LegalSectionItem(
                        title: 'Điều khoản sử dụng',
                        icon: Icons.description_outlined,
                        content: 'NIVEX là sản phẩm phần mềm thử nghiệm (prototype) được xây dựng phục vụ mục đích trình diễn giải pháp thanh toán và chuyển đổi token Solana Devnet tại hackathon.',
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: NivexColors.border,
                      ),
                      _LegalSectionItem(
                        title: 'Chính sách quyền riêng tư',
                        icon: Icons.shield_outlined,
                        content: 'Hệ thống không thu thập thông tin danh tính thực, số điện thoại hay tài khoản ngân hàng thực tế. Tất cả dữ liệu hồ sơ hiển thị đều là dữ liệu giả lập mẫu.',
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: NivexColors.border,
                      ),
                      _LegalSectionItem(
                        title: 'NIVEX là prototype hackathon',
                        icon: Icons.code_rounded,
                        content: 'Dự án được phát triển dưới dạng bản thử nghiệm công nghệ. Mọi tính năng bao gồm tỷ giá quy đổi USDC/VND và tạo quote đều hoạt động dựa trên cơ chế mô phỏng.',
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: NivexColors.border,
                      ),
                      _LegalSectionItem(
                        title: 'Không có tiền thật được chuyển',
                        icon: Icons.money_off_rounded,
                        content: 'Không có bất kỳ giao dịch tiền thật (fiat VND) hay chuyển khoản ngân hàng thực tế nào diễn ra. Tuyệt đối không gửi tài sản có giá trị thực vào địa chỉ thử nghiệm.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const DemoNotice(
                  text: 'Nội dung chưa phải điều khoản pháp lý production. Khi phát hành phiên bản thương mại chính thức, NIVEX sẽ công bố các văn bản pháp lý đầy đủ và tuân thủ các quy định hiện hành.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalSectionItem extends StatelessWidget {
  const _LegalSectionItem({
    required this.title,
    required this.icon,
    required this.content,
  });

  final String title;
  final IconData icon;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: NivexColors.blueSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: NivexColors.blue, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: NivexColors.navy,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: NivexColors.textSecondary,
              height: 1.45,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
