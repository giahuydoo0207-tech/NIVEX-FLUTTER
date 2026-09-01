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
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    color: NivexColors.blue,
                    backgroundColor: NivexColors.blueSoft,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Đang gửi yêu cầu rút VND',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                const Text(
                  'NIVEX đang mô phỏng kiểm tra báo giá và thông tin ngân hàng.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: NivexColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                const NivexCard(
                  child: Column(
                    children: [
                      _ProcessingStep(
                        label: 'Khóa báo giá',
                        icon: Icons.check_circle_rounded,
                        done: true,
                      ),
                      SizedBox(height: 14),
                      _ProcessingStep(
                        label: 'Kiểm tra yêu cầu',
                        icon: Icons.sync_rounded,
                        done: false,
                      ),
                      SizedBox(height: 14),
                      _ProcessingStep(
                        label: 'Tạo biên nhận',
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
          size: 22,
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
