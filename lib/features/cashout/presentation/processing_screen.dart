import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/cashout/data/demo_cashout_fixtures.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_auth_service.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_quote.dart';
import 'package:nivex_flutter/features/cashout/presentation/receipt_screen.dart';
import 'package:nivex_flutter/shared/constants/app_environment.dart';
import 'package:nivex_flutter/shared/widgets/demo_notice.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

enum CashoutProcessingStatus {
  processing,
  settled,
  preSubmitFailed,
  rejected,
  offline,
  timeoutUnknown,
}

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({
    this.quote,
    this.clock = DateTime.now,
    this.initialStatus = CashoutProcessingStatus.processing,
    this.autoTransition = true,
    this.transitionDelay = const Duration(milliseconds: 1400),
    super.key,
  });

  final CashoutQuote? quote;
  final Clock clock;
  final CashoutProcessingStatus initialStatus;
  final bool autoTransition;
  final Duration transitionDelay;

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  late CashoutProcessingStatus _status;
  late final CashoutQuote _quote;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _quote =
        widget.quote ??
        DemoCashoutFixtures.createCanonicalQuote(now: widget.clock());

    if (_status == CashoutProcessingStatus.processing &&
        widget.autoTransition) {
      _timer = Timer(widget.transitionDelay, _complete);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _complete() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(quote: _quote, clock: widget.clock),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return NivexPage(
      title: 'Đang xử lý',
      showBackButton: _status != CashoutProcessingStatus.processing,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusIcon(theme),
                const SizedBox(height: 24),
                Text(
                  _getTitle(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _getMessage(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                _buildActionButtons(theme, colorScheme),
                const SizedBox(height: 20),
                const DemoNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(NivexThemeExtension theme) {
    switch (_status) {
      case CashoutProcessingStatus.processing:
        return SizedBox(
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            color: theme.primary,
            backgroundColor: theme.surfaceSubtle,
          ),
        );
      case CashoutProcessingStatus.settled:
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.successSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, color: theme.success, size: 32),
        );
      case CashoutProcessingStatus.rejected:
      case CashoutProcessingStatus.preSubmitFailed:
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.dangerSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close_rounded, color: theme.danger, size: 32),
        );
      case CashoutProcessingStatus.offline:
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.warningSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.wifi_off_rounded, color: theme.warning, size: 32),
        );
      case CashoutProcessingStatus.timeoutUnknown:
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.warningSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.help_outline_rounded,
            color: theme.warning,
            size: 32,
          ),
        );
    }
  }

  String _getTitle(BuildContext context) {
    final simulated = AppEnvironmentScope.isSimulated(context);
    switch (_status) {
      case CashoutProcessingStatus.processing:
        return simulated ? 'Đang xử lý payout mô phỏng' : 'Đang xử lý payout';
      case CashoutProcessingStatus.settled:
        return 'Giao dịch hoàn tất';
      case CashoutProcessingStatus.preSubmitFailed:
        return 'Giao dịch chưa hoàn tất';
      case CashoutProcessingStatus.rejected:
        return 'Yêu cầu bị từ chối';
      case CashoutProcessingStatus.offline:
        return 'Mất kết nối mạng';
      case CashoutProcessingStatus.timeoutUnknown:
        return 'Chưa xác định được kết quả';
    }
  }

  String _getMessage(BuildContext context) {
    final simulated = AppEnvironmentScope.isSimulated(context);
    switch (_status) {
      case CashoutProcessingStatus.processing:
        return simulated
            ? 'NIVEX đang cập nhật các trạng thái demo. Không có kết nối ngân hàng hoặc tiền thật được chuyển.'
            : 'Yêu cầu đang được xử lý. Vui lòng không thực hiện lại giao dịch.';
      case CashoutProcessingStatus.settled:
        return simulated
            ? 'Yêu cầu quy đổi đã được xử lý thành công trên hệ thống mô phỏng.'
            : 'Yêu cầu quy đổi đã được xử lý thành công.';
      case CashoutProcessingStatus.preSubmitFailed:
        return 'Quá trình xác thực không thành công hoặc phiên làm việc đã kết thúc.\nChưa có giao dịch nào được thực hiện.';
      case CashoutProcessingStatus.rejected:
        return 'Yêu cầu rút tiền của bạn đã bị từ chối bởi hệ thống đối tác.\nChưa có giao dịch nào được thực hiện.';
      case CashoutProcessingStatus.offline:
        return 'Không thể kết nối với mạng lưới. Vui lòng kiểm tra lại kết nối Internet và kiểm tra lại trạng thái.';
      case CashoutProcessingStatus.timeoutUnknown:
        return 'Chúng tôi chưa nhận được trạng thái cuối cùng.\nKhông thực hiện lại giao dịch lúc này.';
    }
  }

  Widget _buildActionButtons(
    NivexThemeExtension theme,
    ColorScheme colorScheme,
  ) {
    switch (_status) {
      case CashoutProcessingStatus.processing:
        return const SizedBox.shrink();

      case CashoutProcessingStatus.settled:
        return FilledButton(
          onPressed: _complete,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: theme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Xem biên nhận'),
        );

      case CashoutProcessingStatus.rejected:
      case CashoutProcessingStatus.preSubmitFailed:
        return Column(
          children: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: theme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Tạo báo giá mới'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: theme.textPrimary,
                side: BorderSide(color: theme.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Về Trang chủ'),
            ),
          ],
        );

      case CashoutProcessingStatus.offline:
        return Column(
          children: [
            FilledButton(
              onPressed: () {
                setState(() => _status = CashoutProcessingStatus.processing);
                _timer = Timer(widget.transitionDelay, _complete);
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: theme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Kiểm tra lại kết nối'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: theme.textPrimary,
                side: BorderSide(color: theme.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Về Trang chủ'),
            ),
          ],
        );

      case CashoutProcessingStatus.timeoutUnknown:
        // ABSOLUTELY NO RETRY BUTTON!
        return Column(
          children: [
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Hệ thống đang kiểm tra lại trạng thái giao dịch...',
                    ),
                    backgroundColor: theme.primary,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: theme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Kiểm tra lại trạng thái'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Đang mở cổng liên hệ đội ngũ hỗ trợ NIVEX...',
                    ),
                    backgroundColor: theme.surfaceSubtle,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: theme.textPrimary,
                side: BorderSide(color: theme.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Liên hệ hỗ trợ'),
            ),
          ],
        );
    }
  }
}
