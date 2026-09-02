import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/features/profile/widgets/demo_notice.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NivexPage(
      title: 'Thông tin cá nhân',
      subtitle: 'Hồ sơ người dùng demo',
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
                      _InfoRow(
                        label: 'Họ và tên',
                        value: 'Minh Anh',
                        icon: Icons.person_outline_rounded,
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: NivexColors.border,
                      ),
                      _InfoRow(
                        label: 'Email',
                        value: 'minh.anh@nivex.demo',
                        icon: Icons.email_outlined,
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: NivexColors.border,
                      ),
                      _InfoRow(
                        label: 'Quốc gia/khu vực',
                        value: 'Việt Nam',
                        icon: Icons.public_rounded,
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: NivexColors.border,
                      ),
                      _InfoRow(
                        label: 'Ngôn ngữ',
                        value: 'Tiếng Việt',
                        icon: Icons.language_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const DemoNotice(
                  text: 'Dữ liệu hồ sơ chỉ dùng trong môi trường thử nghiệm MVP. Không thể chỉnh sửa trong phiên bản demo.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
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
    );
  }
}
