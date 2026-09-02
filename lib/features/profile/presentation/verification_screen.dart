import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/features/profile/widgets/demo_notice.dart';
import 'package:nivex_flutter/features/profile/widgets/status_badge.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NivexPage(
      title: 'Trạng thái xác minh',
      subtitle: 'Thông tin định danh tài khoản',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Status Banner Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: NivexColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: NivexColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: NivexColors.greenSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: NivexColors.green,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Đã xác minh',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: NivexColors.navy,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tài khoản được xác minh trong môi trường demo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: NivexColors.textSecondary,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Identity Info List
                Container(
                  decoration: BoxDecoration(
                    color: NivexColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: NivexColors.border),
                  ),
                  child: Column(
                    children: const [
                      _VerifRow(label: 'Họ và tên', value: 'Minh Anh'),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: NivexColors.border,
                      ),
                      _VerifRow(label: 'Quốc gia', value: 'Việt Nam'),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: NivexColors.border,
                      ),
                      _VerifRow(
                        label: 'Trạng thái',
                        value: 'Demo verified',
                        trailingWidget: StatusBadge(label: 'Demo verified'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. KYC Warning Notice
                const DemoNotice(text: 'NIVEX MVP không thực hiện KYC thật.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerifRow extends StatelessWidget {
  const _VerifRow({
    required this.label,
    required this.value,
    this.trailingWidget,
  });

  final String label;
  final String value;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: NivexColors.textSecondary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
    );
  }
}
