import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final faqs = [
      (
        'NIVEX hoạt động như thế nào?',
        'NIVEX cho phép bạn nạp USDC trên mạng Solana Devnet và quy đổi rút VND về tài khoản ngân hàng liên kết một cách nhanh chóng và an toàn.',
      ),
      (
        'Bao lâu thì nhận được VND?',
        'Trong bản thử nghiệm, giao dịch payout VND được xử lý mô phỏng tức thì trong vòng 3-5 giây sau khi xác nhận quote.',
      ),
      (
        'Tỷ giá được tính thế nào?',
        'Tỷ giá USDC/VND được cập nhật theo thời gian thực từ nguồn tỷ giá thị trường và khóa trong 30 giây khi bạn tạo quote.',
      ),
      (
        'Tôi cần hỗ trợ kỹ thuật?',
        'Liên hệ đội ngũ hỗ trợ qua email support@nivex.demo hoặc kênh Telegram cộng đồng chính thức.',
      ),
    ];

    return NivexPage(
      title: 'Trung tâm trợ giúp',
      subtitle: 'Câu hỏi thường gặp và hỗ trợ',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact Support Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.support_agent_rounded,
                          color: theme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cần trợ giúp trực tiếp?',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: theme.textPrimary,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Đội ngũ hỗ trợ luôn sẵn sàng 24/7',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textSecondary,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    'CÂU HỎI THƯỜNG GẶP',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.textSecondary,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                Material(
                  color: theme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: faqs.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, thickness: 1, color: theme.divider),
                    itemBuilder: (ctx, index) {
                      final (question, answer) = faqs[index];
                      return Theme(
                        data: Theme.of(ctx)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(
                            question,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.textPrimary,
                              letterSpacing: 0,
                            ),
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            14,
                          ),
                          iconColor: theme.textSecondary,
                          collapsedIconColor: theme.textSecondary,
                          children: [
                            Text(
                              answer,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textSecondary,
                                height: 1.45,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
