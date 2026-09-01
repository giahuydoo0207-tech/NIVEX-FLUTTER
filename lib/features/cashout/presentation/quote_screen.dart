import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_draft.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_format.dart';
import 'package:nivex_flutter/features/cashout/presentation/processing_screen.dart';
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _expired
                      ? const Color(0xFFFFF1F1)
                      : NivexColors.blueSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      _expired
                          ? Icons.timer_off_outlined
                          : Icons.timer_outlined,
                      color: _expired ? NivexColors.danger : NivexColors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _expired
                            ? 'Báo giá đã hết hạn'
                            : 'Báo giá còn hiệu lực trong',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (!_expired)
                      Text(
                        '00:${_remainingSeconds.toString().padLeft(2, '0')}',
                        key: const Key('quote-countdown'),
                        style: const TextStyle(
                          color: NivexColors.blue,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              NivexCard(
                child: Column(
                  children: [
                    _QuoteAmount(
                      label: 'Bạn đổi',
                      value: formatUsdc(widget.draft.usdcAmount),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),
                    _QuoteAmount(
                      label: 'Bạn nhận',
                      value: formatVnd(widget.draft.vndAmount),
                      highlighted: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              NivexCard(
                child: Column(
                  children: [
                    const _QuoteRow(
                      label: 'Tỷ giá',
                      value: '1 USDC = 25.545 VND',
                    ),
                    const SizedBox(height: 14),
                    const _QuoteRow(label: 'Phí giao dịch', value: '0 VND'),
                    const SizedBox(height: 14),
                    _QuoteRow(
                      label: 'Ngân hàng nhận',
                      value: widget.draft.bankName,
                    ),
                    const SizedBox(height: 14),
                    _QuoteRow(
                      label: 'Tài khoản',
                      value: 'Minh Anh • ${widget.draft.accountNumber}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Dữ liệu và trạng thái trong prototype này được mô phỏng, '
                'không tạo giao dịch blockchain hoặc chuyển khoản thật.',
                style: TextStyle(
                  color: NivexColors.textSecondary,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const Key('confirm-quote'),
                onPressed: _expired ? null : _confirm,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Xác nhận yêu cầu'),
              ),
              if (_expired) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _refreshQuote,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Lấy báo giá mới'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _refreshQuote() {
    setState(() => _remainingSeconds = 30);
    _startTimer();
  }

  void _confirm() {
    _timer?.cancel();
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute(builder: (_) => ProcessingScreen(draft: widget.draft)),
      (route) => route.isFirst,
    );
  }
}

class _QuoteAmount extends StatelessWidget {
  const _QuoteAmount({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: NivexColors.textSecondary)),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: highlighted ? NivexColors.green : NivexColors.navy,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuoteRow extends StatelessWidget {
  const _QuoteRow({required this.label, required this.value});

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
