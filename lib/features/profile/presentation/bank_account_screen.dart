import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/features/profile/widgets/demo_notice.dart';
import 'package:nivex_flutter/features/profile/widgets/status_badge.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class BankAccountScreen extends StatelessWidget {
  const BankAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                Container(
                  decoration: BoxDecoration(
                    color: NivexColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: NivexColors.border),
                  ),
                  child: Column(
                    children: const [
                      _BankDetailRow(
                        label: 'Ngân hàng thụ hưởng',
                        value: 'Vietcombank',
                        icon: Icons.account_balance_rounded,
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: NivexColors.border,
                      ),
                      _BankDetailRow(
                        label: 'Số tài khoản',
                        value: '•••• 2868',
                        icon: Icons.credit_card_rounded,
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: NivexColors.border,
                      ),
                      _BankDetailRow(
                        label: 'Chủ tài khoản',
                        value: 'Minh A.',
                        icon: Icons.person_outline_rounded,
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: NivexColors.border,
                      ),
                      _BankDetailRow(
                        label: 'Trạng thái',
                        value: 'Sẵn sàng nhận payout mô phỏng',
                        icon: Icons.check_circle_outline_rounded,
                        trailingWidget: StatusBadge(
                          label: 'Sẵn sàng nhận payout mô phỏng',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const DemoNotice(
                  text: 'Dữ liệu tài khoản trong bản demo chỉ là mô phỏng. Khi thực hiện thao tác Rút VND, hệ thống chỉ chạy quy trình giả lập, không có lệnh chuyển khoản thực tế qua ngân hàng.',
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
  const _BankDetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.trailingWidget,
  });

  final String label;
  final String value;
  final IconData icon;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: NivexColors.blueSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: NivexColors.blue, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: NivexColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 2),
                if (trailingWidget != null)
                  trailingWidget!
                else
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: NivexColors.navy,
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
