import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_draft.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_format.dart';
import 'package:nivex_flutter/features/shell/domain/app_tab_controller.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({required this.draft, super.key});

  static const receiptId = 'NXV-20260901-0042';
  final CashoutDraft draft;

  @override
  Widget build(BuildContext context) {
    return NivexPage(
      title: 'Biên nhận',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              // 1. Bank Receipt Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NivexColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NivexColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: NivexColors.greenSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: NivexColors.green,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Yêu cầu đã hoàn tất',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: NivexColors.navy,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Dữ liệu mô phỏng • Không có tiền thật được chuyển',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: NivexColors.textSecondary,
                        fontSize: 12,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatVnd(draft.vndAmount),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: NivexColors.green,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: NivexColors.border,
                    ),
                    const SizedBox(height: 14),
                    _ReceiptRow(
                      label: 'Đã đổi',
                      value: formatUsdc(draft.usdcAmount),
                    ),
                    const SizedBox(height: 12),
                    const _ReceiptRow(
                      label: 'Tỷ giá',
                      value: '1 USDC = 25.545 VND',
                    ),
                    const SizedBox(height: 12),
                    const _ReceiptRow(label: 'Phí giao dịch', value: '0 VND'),
                    const SizedBox(height: 12),
                    _ReceiptRow(label: 'Ngân hàng', value: draft.bankName),
                    const SizedBox(height: 12),
                    _ReceiptRow(
                      label: 'Tài khoản',
                      value: 'Minh Anh • ${draft.accountNumber}',
                    ),
                    const SizedBox(height: 12),
                    const _ReceiptRow(label: 'Mã yêu cầu', value: receiptId),
                    const SizedBox(height: 12),
                    const _ReceiptRow(
                      label: 'Thời gian',
                      value: '01/09/2026 • 12:30',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Actions
              OutlinedButton.icon(
                onPressed: () => _shareReceipt(context),
                icon: const Icon(Icons.share_outlined, size: 19),
                label: const Text('Chia sẻ biên nhận'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: NivexColors.navy,
                  side: const BorderSide(color: NivexColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                key: const Key('receipt-home'),
                onPressed: () {
                  AppTabController.index.value = 0;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: NivexColors.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareReceipt(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chia sẻ biên nhận',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NivexColors.navy,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              minTileHeight: 52,
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: NivexColors.blueSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.copy_rounded,
                  color: NivexColors.blue,
                  size: 19,
                ),
              ),
              title: const Text(
                'Sao chép nội dung',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: NivexColors.navy,
                  fontSize: 14,
                  letterSpacing: 0,
                ),
              ),
              subtitle: const Text(
                'Mã yêu cầu và số tiền',
                style: TextStyle(
                  color: NivexColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 0,
                ),
              ),
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text: 'NIVEX $receiptId • ${formatVnd(draft.vndAmount)}',
                  ),
                );
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã sao chép nội dung biên nhận.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            const Divider(height: 1, color: NivexColors.border),
            ListTile(
              minTileHeight: 52,
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: NivexColors.blueSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: NivexColors.blue,
                  size: 19,
                ),
              ),
              title: const Text(
                'Chia sẻ dưới dạng ảnh',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: NivexColors.navy,
                  fontSize: 14,
                  letterSpacing: 0,
                ),
              ),
              subtitle: const Text(
                'Bản xem trước mô phỏng',
                style: TextStyle(
                  color: NivexColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 0,
                ),
              ),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: NivexColors.textSecondary,
              fontSize: 13.5,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: NivexColors.navy,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
