import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/features/profile/widgets/demo_notice.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _transactionsEnabled = true;
  bool _productUpdatesEnabled = true;
  bool _quoteReminderEnabled = true;

  @override
  Widget build(BuildContext context) {
    return NivexPage(
      title: 'Thông báo',
      subtitle: 'Cài đặt thông báo ứng dụng',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: NivexColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: NivexColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _transactionsEnabled,
                        onChanged: (val) =>
                            setState(() => _transactionsEnabled = val),
                        activeTrackColor: NivexColors.blue,
                        title: const Text(
                          'Thông báo giao dịch',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: NivexColors.navy,
                            letterSpacing: 0,
                          ),
                        ),
                        subtitle: const Text(
                          'Nhận thông báo khi lệnh nạp hoặc rút tiền hoàn tất',
                          style: TextStyle(
                            fontSize: 12,
                            color: NivexColors.textSecondary,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: NivexColors.border,
                      ),
                      SwitchListTile(
                        value: _productUpdatesEnabled,
                        onChanged: (val) =>
                            setState(() => _productUpdatesEnabled = val),
                        activeTrackColor: NivexColors.blue,
                        title: const Text(
                          'Cập nhật sản phẩm',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: NivexColors.navy,
                            letterSpacing: 0,
                          ),
                        ),
                        subtitle: const Text(
                          'Thông tin tính năng mới và chương trình thử nghiệm',
                          style: TextStyle(
                            fontSize: 12,
                            color: NivexColors.textSecondary,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: NivexColors.border,
                      ),
                      SwitchListTile(
                        value: _quoteReminderEnabled,
                        onChanged: (val) =>
                            setState(() => _quoteReminderEnabled = val),
                        activeTrackColor: NivexColors.blue,
                        title: const Text(
                          'Nhắc báo giá sắp hết hạn',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: NivexColors.navy,
                            letterSpacing: 0,
                          ),
                        ),
                        subtitle: const Text(
                          'Cảnh báo khi quote 30 giây sắp hết hiệu lực',
                          style: TextStyle(
                            fontSize: 12,
                            color: NivexColors.textSecondary,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const DemoNotice(
                  text: 'Các tuỳ chỉnh thông báo được lưu trữ tạm thời trong phiên làm việc hiện tại của bản demo.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
