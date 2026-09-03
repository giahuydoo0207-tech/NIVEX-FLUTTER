import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_draft.dart';
import 'package:nivex_flutter/features/cashout/presentation/receipt_screen.dart';
import 'package:nivex_flutter/shared/widgets/demo_notice.dart';
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
    final theme = context.nivexTheme;
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
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: theme.primary,
                    backgroundColor: theme.surfaceSubtle,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Đang xử lý payout mô phỏng',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: theme.textPrimary,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'NIVEX đang cập nhật các trạng thái demo. Không có kết nối ngân hàng hoặc tiền thật được chuyển.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textSecondary,
                    height: 1.4,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 24),
                const DemoNotice(),
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
