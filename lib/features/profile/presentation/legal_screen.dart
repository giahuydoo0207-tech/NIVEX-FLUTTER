import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/profile/widgets/demo_notice.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexPage(
      title: 'Điều khoản & quyền riêng tư',
      subtitle: 'Quy chế demo và chính sách',
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Mục đích thử nghiệm MVP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ứng dụng NIVEX phiên bản hiện tại là sản phẩm MVP phục vụ trình diễn giải pháp on/off-ramp crypto-fiat. Mọi giao dịch tiền tệ là mô phỏng và không phát sinh nghĩa vụ tài chính thực tế.',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textSecondary,
                          height: 1.45,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '2. Bảo mật dữ liệu người dùng',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ứng dụng tuân thủ nguyên tắc bảo mật tối thiểu: không yêu cầu hay lưu trữ private key hoặc seed phrase của người dùng. Mọi tương tác Solana được thực hiện qua địa chỉ công khai trên mạng Solana Devnet.',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textSecondary,
                          height: 1.45,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '3. Giới hạn trách nhiệm',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Người dùng không chuyển tài sản thực tế (mainnet USDC hoặc VND thật) vào các địa chỉ hoặc số tài khoản demo được cung cấp trong ứng dụng.',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textSecondary,
                          height: 1.45,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const DemoNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
