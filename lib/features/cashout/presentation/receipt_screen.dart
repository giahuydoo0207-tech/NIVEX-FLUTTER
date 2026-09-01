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
              NivexCard(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      backgroundColor: NivexColors.greenSoft,
                      child: Icon(
                        Icons.check_rounded,
                        color: NivexColors.green,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Yêu cầu đã hoàn tất',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Dữ liệu mô phỏng • Không có tiền thật được chuyển',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: NivexColors.textSecondary),
                    ),
                    const SizedBox(height: 22),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatVnd(draft.vndAmount),
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(color: NivexColors.green),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Divider(),
                    const SizedBox(height: 16),
                    _ReceiptRow(
                      label: 'Đã đổi',
                      value: formatUsdc(draft.usdcAmount),
                    ),
                    const SizedBox(height: 14),
                    const _ReceiptRow(
                      label: 'Tỷ giá',
                      value: '1 USDC = 25.545 VND',
                    ),
                    const SizedBox(height: 14),
                    const _ReceiptRow(label: 'Phí', value: '0 VND'),
                    const SizedBox(height: 14),
                    _ReceiptRow(label: 'Ngân hàng', value: draft.bankName),
                    const SizedBox(height: 14),
                    _ReceiptRow(
                      label: 'Tài khoản',
                      value: 'Minh Anh • ${draft.accountNumber}',
                    ),
                    const SizedBox(height: 14),
                    const _ReceiptRow(label: 'Mã yêu cầu', value: receiptId),
                    const SizedBox(height: 14),
                    const _ReceiptRow(
                      label: 'Thời gian',
                      value: '01/09/2026 • 12:30',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () => _shareReceipt(context),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Chia sẻ biên nhận'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
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
            Text(
              'Chia sẻ biên nhận',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ListTile(
              minTileHeight: 56,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Sao chép nội dung'),
              subtitle: const Text('Mã yêu cầu và số tiền'),
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text: 'NIVEX $receiptId • ${formatVnd(draft.vndAmount)}',
                  ),
                );
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
            ),
            ListTile(
              minTileHeight: 56,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.image_outlined),
              title: const Text('Chia sẻ dưới dạng ảnh'),
              subtitle: const Text('Bản xem trước mô phỏng'),
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
            style: const TextStyle(color: NivexColors.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
