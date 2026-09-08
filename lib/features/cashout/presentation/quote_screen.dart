import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/cashout/data/demo_cashout_fixtures.dart';
import 'package:nivex_flutter/features/cashout/data/local_auth_biometric_client.dart';
import 'package:nivex_flutter/features/cashout/data/mock_quote_repository.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_auth_service.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_quote.dart';
import 'package:nivex_flutter/features/cashout/presentation/processing_screen.dart';
import 'package:nivex_flutter/features/cashout/presentation/widgets/transaction_auth_sheet.dart';
import 'package:nivex_flutter/shared/widgets/demo_notice.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({
    this.quote,
    this.clock = DateTime.now,
    this.authService,
    this.quoteRepository,
    super.key,
  });

  final CashoutQuote? quote;
  final Clock clock;
  final CashoutAuthService? authService;
  final MockQuoteRepository? quoteRepository;

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  late CashoutQuote _currentQuote;
  late final MockQuoteRepository _quoteRepo;
  late final CashoutAuthService _authService;
  Timer? _timer;
  int _remainingSeconds = 30;

  bool get _isExpired =>
      _remainingSeconds <= 0 || _currentQuote.isExpiredAt(widget.clock());

  String get _remainingLabel {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _quoteRepo =
        widget.quoteRepository ?? MockQuoteRepository(clock: widget.clock);
    _authService =
        widget.authService ??
        CashoutAuthService(
          biometricClient: LocalAuthBiometricClient(clock: widget.clock),
          clock: widget.clock,
        );

    if (widget.quote != null) {
      _currentQuote = widget.quote!;
    } else {
      // Fallback for draft backwards compatibility or canonical test vector
      _currentQuote = DemoCashoutFixtures.createCanonicalQuote(
        now: widget.clock(),
      );
    }

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = _currentQuote.remainingSecondsAt(widget.clock());
    if (_remainingSeconds <= 0) {
      setState(() {});
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      }
      if (_remainingSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  void _refreshQuote() {
    final newQuote = _quoteRepo.getQuote(
      amount: _currentQuote.sellAmount,
      bank: DemoBankItem(
        name: _currentQuote.destinationBankName,
        code: _currentQuote.destinationBankCode,
        accountNumber: _currentQuote.destinationAccountNumber,
        accountHolder: 'MINH ANH',
      ),
      forceNewId: true,
    );
    setState(() {
      _currentQuote = newQuote;
    });
    _startTimer();
  }

  Future<void> _handleConfirm() async {
    if (_isExpired) return;

    final result = await TransactionAuthSheet.show(
      context: context,
      quote: _currentQuote,
      authService: _authService,
      clock: widget.clock,
    );

    if (!mounted || result == null) return;

    if (result is TransactionAuthSuccess) {
      // CRUCIAL POST-AUTH EXPIRY CHECK
      if (_currentQuote.isExpiredAt(widget.clock())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Báo giá đã hết hạn trong quá trình xác thực. Vui lòng lấy báo giá mới.',
            ),
            backgroundColor: context.nivexTheme.danger,
          ),
        );
        setState(() {});
        return;
      }

      // Valid quote -> proceed to ProcessingScreen
      Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute(
          builder: (_) =>
              ProcessingScreen(quote: _currentQuote, clock: widget.clock),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final expired = _isExpired;

    return NivexPage(
      title: 'Báo giá & xác nhận',
      subtitle: 'Bước 2/4 - Chưa thực hiện giao dịch',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kiểm tra báo giá',
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tiếp theo: xác thực bằng PIN hoặc sinh trắc học',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: expired ? theme.dangerSoft : theme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: expired ? theme.danger : theme.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      expired ? Icons.timer_off_outlined : Icons.timer_outlined,
                      color: expired ? theme.danger : theme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        expired
                            ? 'Báo giá đã hết hạn'
                            : 'Báo giá còn hiệu lực $_remainingLabel',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: expired ? theme.danger : theme.textPrimary,
                        ),
                      ),
                    ),
                    if (expired)
                      TextButton(
                        onPressed: _refreshQuote,
                        style: TextButton.styleFrom(
                          foregroundColor: theme.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Lấy báo giá mới'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
                      'Bạn dự kiến nhận',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentQuote.netVnd.toFormattedString(),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: theme.success,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Divider(height: 1, thickness: 1, color: theme.divider),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _AmountSummary(
                            label: 'Từ số dư',
                            value: _currentQuote.sellAmount.toFormattedString(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: theme.primary,
                            size: 22,
                          ),
                        ),
                        Expanded(
                          child: _AmountSummary(
                            label: 'Sau phí',
                            value: _currentQuote.netUsdc.toFormattedString(),
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Chi tiết báo giá',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Tỷ giá',
                      value: _currentQuote.exchangeRate.toFormattedString(),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Tổng phí',
                      value:
                          '-${_currentQuote.fee.totalFee.toFormattedString()}',
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Phí mạng',
                      value: _currentQuote.fee.networkFee.toFormattedString(),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Phí dịch vụ',
                      value: _currentQuote.fee.serviceFee.toFormattedString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tài khoản nhận',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.surfaceSubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.account_balance_outlined,
                        color: theme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentQuote.destinationBankName,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _currentQuote.destinationAccountNumber,
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _currentQuote.network,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: theme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Chưa có giao dịch nào được thực hiện. Bạn sẽ xác thực ở bước tiếp theo.',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const DemoNotice(),
              const SizedBox(height: 20),

              FilledButton(
                onPressed: expired ? null : _handleConfirm,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: theme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  disabledBackgroundColor: theme.disabled,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Tiếp tục xác thực'),
              ),
              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
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
                child: const Text('Quay lại chỉnh sửa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountSummary extends StatelessWidget {
  const _AmountSummary({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: theme.textSecondary, fontSize: 11)),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
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
            style: TextStyle(fontSize: 13, color: theme.textSecondary),
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
            ),
          ),
        ),
      ],
    );
  }
}
