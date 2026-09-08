import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/cashout/data/demo_cashout_fixtures.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_auth_service.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_quote.dart';
import 'package:nivex_flutter/features/cashout/presentation/cashout_screen.dart';
import 'package:nivex_flutter/features/shell/domain/app_tab_controller.dart';
import 'package:nivex_flutter/shared/constants/app_environment.dart';
import 'package:nivex_flutter/shared/widgets/demo_notice.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({
    this.quote,
    this.clock = DateTime.now,
    this.receiptId = DemoCashoutFixtures.defaultReceiptId,
    super.key,
  });

  final CashoutQuote? quote;
  final Clock clock;
  final String receiptId;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final simulated = AppEnvironmentScope.isSimulated(context);

    final effectiveQuote =
        quote ?? DemoCashoutFixtures.createCanonicalQuote(now: clock());

    final formattedTime = _formatTimestamp(effectiveQuote.createdAt);

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
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: theme.successSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: theme.success,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      simulated
                          ? 'Payout VND mô phỏng hoàn tất'
                          : 'Payout VND hoàn tất',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      simulated
                          ? 'Dữ liệu mô phỏng • Không có tiền thật được chuyển'
                          : 'Giao dịch đã được ghi nhận',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(height: 1, thickness: 1, color: theme.divider),
                    const SizedBox(height: 16),

                    // Amount received
                    _ReceiptRow(
                      label: 'Số tiền VND thực nhận',
                      value: effectiveQuote.netVnd.toFormattedString(),
                      isHighlight: true,
                    ),
                    const SizedBox(height: 12),

                    // Total USDC debited
                    _ReceiptRow(
                      label: 'Tổng USDC đã trừ',
                      value:
                          '-${effectiveQuote.sellAmount.toFormattedString()}',
                    ),
                    const SizedBox(height: 10),

                    // Fees itemized
                    _ReceiptRow(
                      label: 'Phí mạng lưới',
                      value: effectiveQuote.fee.networkFee.toFormattedString(),
                    ),
                    const SizedBox(height: 10),
                    _ReceiptRow(
                      label: 'Phí dịch vụ',
                      value: effectiveQuote.fee.serviceFee.toFormattedString(),
                    ),
                    const SizedBox(height: 10),
                    _ReceiptRow(
                      label: 'Tổng phí giao dịch',
                      value:
                          '-${effectiveQuote.fee.totalFee.toFormattedString()}',
                    ),
                    const SizedBox(height: 10),

                    // Amount converted
                    _ReceiptRow(
                      label: 'USDC quy đổi',
                      value: effectiveQuote.netUsdc.toFormattedString(),
                    ),
                    const SizedBox(height: 10),

                    // Rate
                    _ReceiptRow(
                      label: 'Tỷ giá quy đổi',
                      value: effectiveQuote.exchangeRate.toFormattedString(),
                    ),
                    const SizedBox(height: 10),

                    // Bank
                    _ReceiptRow(
                      label: simulated
                          ? 'Ngân hàng nhận demo'
                          : 'Ngân hàng nhận',
                      value: effectiveQuote.destinationBankName,
                    ),
                    const SizedBox(height: 10),
                    _ReceiptRow(
                      label: 'Số tài khoản',
                      value: effectiveQuote.destinationAccountNumber,
                    ),
                    const SizedBox(height: 10),

                    // Network & Time
                    _ReceiptRow(
                      label: 'Mạng lưới',
                      value: effectiveQuote.network,
                    ),
                    const SizedBox(height: 10),
                    _ReceiptRow(label: 'Thời gian', value: formattedTime),
                    const SizedBox(height: 10),

                    // Transaction ID with Copy button
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Text(
                          'Mã giao dịch',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textSecondary,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                receiptId,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: receiptId),
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Đã sao chép mã giao dịch',
                                      ),
                                      backgroundColor: theme.primary,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.copy_rounded,
                                    size: 16,
                                    color: theme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const DemoNotice(),
              const SizedBox(height: 20),

              // 2. Action Buttons
              FilledButton(
                onPressed: () {
                  AppTabController.index.value = 0;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: theme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Về Trang chủ'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  final navigator = Navigator.of(context);
                  AppTabController.index.value = 0;
                  navigator.popUntil((route) => route.isFirst);
                  navigator.push<void>(
                    MaterialPageRoute(builder: (_) => const CashoutScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: theme.textPrimary,
                  side: BorderSide(color: theme.border),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Thực hiện giao dịch khác'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');
    final year = time.year.toString();
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  final String label;
  final String value;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: theme.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 13,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              color: isHighlight ? theme.success : theme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
