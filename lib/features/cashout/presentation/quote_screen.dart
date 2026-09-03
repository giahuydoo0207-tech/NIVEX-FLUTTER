import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_draft.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_format.dart';
import 'package:nivex_flutter/features/cashout/presentation/processing_screen.dart';
import 'package:nivex_flutter/shared/widgets/demo_notice.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({required this.draft, super.key});

  final CashoutDraft draft;

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  Timer? _timer;
  int _remainingSeconds = 30;

  bool get _expired => _remainingSeconds == 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final totalVnd = CashoutFormat.estimateVnd(widget.draft.usdcAmount);

    return NivexPage(
      title: 'Báo giá quy đổi',
      subtitle: 'Kiểm tra thông tin trước khi xác nhận',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              // 1. Timer / Expiry Indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _expired ? theme.dangerSoft : theme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _expired ? theme.danger : theme.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _expired
                          ? Icons.timer_off_outlined
                          : Icons.timer_outlined,
                      color: _expired ? theme.danger : theme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _expired
                            ? 'Báo giá đã hết hạn'
                            : 'Tỷ giá tham khảo còn hiệu lực: ${_remainingSeconds}s',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _expired ? theme.danger : theme.textPrimary,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    if (_expired)
                      TextButton(
                        onPressed: _refreshQuote,
                        style: TextButton.styleFrom(
                          foregroundColor: theme.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Làm mới'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 2. Main Conversion Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: [
                    Text(
                      'Số tiền VND dự kiến nhận',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textSecondary,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CashoutFormat.vnd(totalVnd),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: theme.success,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(height: 1, thickness: 1, color: theme.divider),
                    const SizedBox(height: 16),
                    _DetailRow(
                      label: 'Đổi từ',
                      value:
                          '${CashoutFormat.usdc(widget.draft.usdcAmount)} USDC',
                    ),
                    const SizedBox(height: 10),
                    const _DetailRow(
                      label: 'Tỷ giá tham khảo trong bản demo',
                      value: '1 USDC = 25.545 VND',
                    ),
                    const SizedBox(height: 10),
                    const _DetailRow(
                      label: 'Phí trong bản demo',
                      value: '0 VND',
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      label: 'Ngân hàng nhận',
                      value:
                          '${widget.draft.bankName} • ${widget.draft.accountNumber}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const DemoNotice(),
              const SizedBox(height: 20),
              // 3. Confirm Button
              FilledButton(
                onPressed: _expired
                    ? null
                    : () {
                        Navigator.of(context).pushReplacement<void, void>(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProcessingScreen(draft: widget.draft),
                          ),
                        );
                      },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: theme.primary,
                  foregroundColor: theme.isDark
                      ? const Color(0xFF0F172A)
                      : Colors.white,
                  disabledBackgroundColor: theme.disabled,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Xác nhận payout mô phỏng'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  void _refreshQuote() {
    _startTimer();
    setState(() {});
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: theme.textSecondary,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
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
