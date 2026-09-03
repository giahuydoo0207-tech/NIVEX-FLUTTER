import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/profile/widgets/demo_notice.dart';
import 'package:nivex_flutter/features/profile/widgets/status_badge.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexPage(
      title: 'Trạng thái xác minh',
      subtitle: 'Định danh điện tử (KYC Demo)',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Current Status Banner
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
                          color: theme.successSoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_user_rounded,
                          color: theme.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  'Định danh Cấp 2',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: theme.textPrimary,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const StatusBadge(label: 'Đã duyệt'),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Hạn mức giao dịch: 50.000 USDC / ngày',
                              style: TextStyle(
                                fontSize: 12.5,
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
                const SizedBox(height: 20),

                // 2. Verification Steps Checklist
                Container(
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.border),
                  ),
                  child: Column(
                    children: [
                      const _KycStepItem(
                        title: 'Xác thực số điện thoại & Email',
                        subtitle: 'Hoàn thành khi tạo tài khoản demo',
                        isCompleted: true,
                      ),
                      Divider(height: 1, thickness: 1, color: theme.divider),
                      const _KycStepItem(
                        title: 'Giấy tờ tùy thân (CCCD / Hộ chiếu)',
                        subtitle: 'Dữ liệu mô phỏng đã được phê duyệt',
                        isCompleted: true,
                      ),
                      Divider(height: 1, thickness: 1, color: theme.divider),
                      const _KycStepItem(
                        title: 'Nhận diện khuôn mặt sinh trắc học',
                        subtitle: 'Mô phỏng xác thực tự động thành công',
                        isCompleted: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Demo Notice
                const DemoNotice(
                  text: 'Toàn bộ quy trình xác minh danh tính đều là dữ liệu mô phỏng phục vụ đánh giá MVP. Ứng dụng không thu thập hình ảnh CCCD thật hoặc sinh trắc học cá nhân.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KycStepItem extends StatelessWidget {
  const _KycStepItem({
    required this.title,
    required this.subtitle,
    this.isCompleted = true,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isCompleted ? theme.success : theme.textSecondary,
            size: 20,
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
                  subtitle,
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
    );
  }
}
