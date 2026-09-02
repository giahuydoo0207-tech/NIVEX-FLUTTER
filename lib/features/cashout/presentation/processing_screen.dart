import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_draft.dart';
import 'package:nivex_flutter/features/cashout/presentation/receipt_screen.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({required this.draft, super.key});

  final CashoutDraft draft;

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  Timer? _completionTimer;

  @override
  void initState() {
    super.initState();
    _completionTimer = Timer(const Duration(milliseconds: 1400), _complete);
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NivexPage(
      title: 'Đang xử lý',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: NivexColors.blue,
                    backgroundColor: NivexColors.blueSoft,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Đang gửi yêu cầu rút VND',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: NivexColors.navy,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'NIVEX đang mô phỏng kiểm tra báo giá và thông tin tài khoản nhận.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: NivexColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: NivexColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: NivexColors.border),
                  ),
                  child: const Column(
                    children: [
                      _ProcessingStep(
                        label: 'Khóa tỷ giá quy đổi',
                        icon: Icons.check_circle_rounded,
                        done: true,
                      ),
                      SizedBox(height: 14),
                      _ProcessingStep(
                        label: 'Kiểm tra thông tin giao dịch',
                        icon: Icons.sync_rounded,
                        done: false,
                      ),
                      SizedBox(height: 14),
                      _ProcessingStep(
                        label: 'Tạo biên nhận chuyển tiền',
                        icon: Icons.radio_button_unchecked_rounded,
                        done: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _complete() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute(builder: (_) => ReceiptScreen(draft: widget.draft)),
    );
  }
}

class _ProcessingStep extends StatelessWidget {
  const _ProcessingStep({
    required this.label,
    required this.icon,
    required this.done,
  });

  final String label;
  final IconData icon;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: done ? NivexColors.green : NivexColors.blue,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
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
