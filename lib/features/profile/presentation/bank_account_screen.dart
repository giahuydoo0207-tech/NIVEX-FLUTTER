import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/profile/widgets/demo_notice.dart';
import 'package:nivex_flutter/features/profile/widgets/status_badge.dart';
import 'package:nivex_flutter/shared/constants/demo_data.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class BankAccountScreen extends StatelessWidget {
  const BankAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexPage(
      title: 'Tài khoản nhận VND',
      subtitle: 'Tài khoản ngân hàng liên kết',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Linked Bank Card
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: theme.surfaceSubtle,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: theme.border),
                                  ),
                                  child: Icon(
                                    Icons.account_balance_rounded,
                                    color: theme.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DemoData.bankName,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: theme.textPrimary,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Ngân hàng TMCP Ngoại thương VN',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                          const SizedBox(width: 8),
                          const StatusBadge(label: 'Mặc định'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(height: 1, thickness: 1, color: theme.divider),
                      const SizedBox(height: 12),
                      _BankDetailRow(
                        label: 'Số tài khoản',
                        value: DemoData.bankAccountLast4,
                      ),
                      const SizedBox(height: 8),
                      _BankDetailRow(label: 'Chủ tài khoản', value: 'MINH ANH'),
                      const SizedBox(height: 8),
                      _BankDetailRow(
                        label: 'Trạng thái',
                        value: 'Đã liên kết (Khớp KYC)',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Demo Notice
                const DemoNotice(
                  text: 'Tài khoản ngân hàng dùng để nhận tiền khi rút VND (mô phỏng). Trong bản demo MVP, thông tin ngân hàng được cấu hình sẵn theo hồ sơ KYC và không chuyển tiền thật.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BankDetailRow extends StatelessWidget {
  const _BankDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: theme.textSecondary,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
