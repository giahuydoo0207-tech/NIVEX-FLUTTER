import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
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
    final theme = context.nivexTheme;
    final totalVnd = CashoutFormat.estimateVnd(draft.usdcAmount);

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
                      'Yêu cầu đã hoàn tất',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dữ liệu mô phỏng • Không có tiền thật được chuyển',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(height: 1, thickness: 1, color: theme.divider),
                    const SizedBox(height: 16),
                    _ReceiptRow(
                      label: 'Số tiền VND',
                      value: CashoutFormat.vnd(totalVnd),
                      isHighlight: true,
                    ),
                    const SizedBox(height: 10),
                    _ReceiptRow(
                      label: 'Số USDC đã trừ',
                      value: '-${CashoutFormat.usdc(draft.usdcAmount)} USDC',
                    ),
                    const SizedBox(height: 10),
                    _ReceiptRow(
                      label: 'Ngân hàng thụ hưởng',
                      value: draft.bankName,
                    ),
                    const SizedBox(height: 10),
                    _ReceiptRow(
                      label: 'Số tài khoản',
                      value: draft.accountNumber,
                    ),
                    const SizedBox(height: 10),
                    const _ReceiptRow(label: 'Mã giao dịch', value: receiptId),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // 2. Action Buttons
              FilledButton(
                onPressed: () {
                  AppTabController.index.value = 0;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: theme.primary,
                  foregroundColor: theme.isDark
                      ? const Color(0xFF0F172A)
                      : Colors.white,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Về Trang chủ'),
              ),
            ],
          ),
        ),
      ),
    );
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
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: theme.textSecondary,
            letterSpacing: 0,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 15 : 13,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isHighlight ? theme.success : theme.textPrimary,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
