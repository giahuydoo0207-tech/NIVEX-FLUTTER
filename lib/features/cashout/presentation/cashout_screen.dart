import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/cashout/data/demo_cashout_fixtures.dart';
import 'package:nivex_flutter/features/cashout/data/local_auth_biometric_client.dart';
import 'package:nivex_flutter/features/cashout/data/mock_quote_repository.dart';
import 'package:nivex_flutter/features/cashout/domain/biometric_auth_client.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_auth_service.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_money.dart';
import 'package:nivex_flutter/features/cashout/domain/usdc_parser.dart';
import 'package:nivex_flutter/features/cashout/presentation/quote_screen.dart';
import 'package:nivex_flutter/shared/constants/app_environment.dart';
import 'package:nivex_flutter/shared/widgets/demo_notice.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class CashoutScreen extends StatefulWidget {
  const CashoutScreen({
    this.initialAmount = '100',
    this.clock = DateTime.now,
    this.biometricClient,
    this.authService,
    this.quoteRepository,
    super.key,
  });

  final String initialAmount;
  final Clock clock;
  final BiometricAuthClient? biometricClient;
  final CashoutAuthService? authService;
  final MockQuoteRepository? quoteRepository;

  @override
  State<CashoutScreen> createState() => _CashoutScreenState();
}

class _CashoutScreenState extends State<CashoutScreen> {
  late final TextEditingController _amountController;
  late final MockQuoteRepository _quoteRepo;
  late final CashoutAuthService _authService;
  late DemoBankItem _selectedBank;
  bool _isLoading = false;

  final UsdcAmount _available = DemoCashoutFixtures.availableBalance;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.initialAmount);
    _quoteRepo =
        widget.quoteRepository ?? MockQuoteRepository(clock: widget.clock);
    final bioClient =
        widget.biometricClient ?? LocalAuthBiometricClient(clock: widget.clock);
    _authService =
        widget.authService ??
        CashoutAuthService(biometricClient: bioClient, clock: widget.clock);
    _selectedBank = DemoCashoutFixtures.linkedBanks.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  UsdcParseResult get _parseResult => UsdcParser.parse(_amountController.text);

  String? get _validationError {
    switch (_parseResult) {
      case UsdcParseEmpty():
        return 'Vui lòng nhập số tiền muốn đổi';
      case UsdcParseInvalid(:final message):
        return message;
      case UsdcParseSuccess(:final amount):
        if (amount <= UsdcAmount.zero) {
          return 'Số tiền phải lớn hơn 0 USDC';
        }
        if (amount > _available) {
          return 'Vượt quá số dư';
        }
        if (amount <= DemoCashoutFixtures.canonicalTotalFee) {
          return 'Số tiền phải lớn hơn tổng phí 1,51 USDC';
        }
        return null;
    }
  }

  bool get _isValid => _validationError == null;

  void _applyPercentage(int percent) {
    final targetMicroUnits =
        (_available.minorUnits * BigInt.from(percent)) ~/ BigInt.from(100);
    final amount = UsdcAmount.fromMinorUnits(targetMicroUnits);
    _amountController.text = amount.toFormattedString(
      fractionDigits: 0,
      includeSymbol: false,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final parseResult = _parseResult;
    final validationError = _validationError;

    // Calculate dynamic preview if valid
    String estimateVndStr = '0 VND';
    if (parseResult is UsdcParseSuccess && validationError == null) {
      final quote = _quoteRepo.getQuote(
        amount: parseResult.amount,
        bank: _selectedBank,
      );
      estimateVndStr = quote.netVnd.toFormattedString();
    }

    return NivexPage(
      title: 'Rút VND',
      subtitle: AppEnvironmentScope.isProduction(context)
          ? 'Quy đổi USDC sang VND'
          : 'Mô phỏng quy đổi USDC sang VND',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              // 1. Amount Input Field
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Số USDC muốn đổi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _applyPercentage(100),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.primary,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    child: const Text('Dùng tối đa'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isValid
                        ? theme.primary
                        : (validationError != null
                              ? theme.danger
                              : theme.border),
                    width: _isValid ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[\,\.]?\d{0,6}'),
                          ),
                        ],
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: theme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: theme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'USDC',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Khả dụng: ${_available.toFormattedString()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
                  if (validationError != null)
                    Flexible(
                      child: Text(
                        validationError,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.danger,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Percentage Quick Select Chips
              Row(
                children: [
                  _buildPercentChip('25%', () => _applyPercentage(25), theme),
                  const SizedBox(width: 8),
                  _buildPercentChip('50%', () => _applyPercentage(50), theme),
                  const SizedBox(width: 8),
                  _buildPercentChip('75%', () => _applyPercentage(75), theme),
                  const SizedBox(width: 8),
                  _buildPercentChip(
                    'Tối đa',
                    () => _applyPercentage(100),
                    theme,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 3. Conversion Estimate Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Tỷ giá ước tính',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            DemoCashoutFixtures.canonicalRate
                                .toFormattedString(),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Số tiền VND dự kiến nhận',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            estimateVndStr,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: theme.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 4. Bank Account Selection
              Text(
                'TÀI KHOẢN NHẬN TIỀN',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.border),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: DemoCashoutFixtures.linkedBanks.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, thickness: 1, color: theme.divider),
                  itemBuilder: (context, index) {
                    final b = DemoCashoutFixtures.linkedBanks[index];
                    final isSel = b.name == _selectedBank.name;
                    return InkWell(
                      onTap: () => setState(() => _selectedBank = b),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSel
                                    ? theme.primary
                                    : theme.surfaceSubtle,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSel ? theme.primary : theme.border,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                b.code,
                                style: TextStyle(
                                  color: isSel
                                      ? colorScheme.onPrimary
                                      : theme.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${b.accountHolder} • ${b.accountNumber}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSel
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSel
                                  ? theme.primary
                                  : theme.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const DemoNotice(),
              const SizedBox(height: 20),

              // 5. Submit Button
              FilledButton(
                onPressed: (_isValid && !_isLoading) ? _openQuote : null,
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
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Text('Xem báo giá quy đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openQuote() async {
    if (!_isValid || _isLoading) return;
    setState(() => _isLoading = true);

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    try {
      final parseSuccess = _parseResult as UsdcParseSuccess;
      final quote = _quoteRepo.getQuote(
        amount: parseSuccess.amount,
        bank: _selectedBank,
      );
      setState(() => _isLoading = false);
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => QuoteScreen(
            quote: quote,
            clock: widget.clock,
            authService: _authService,
            quoteRepository: _quoteRepo,
          ),
        ),
      );
    } on ArgumentError catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message?.toString() ?? 'Không thể tạo báo giá'),
        ),
      );
    }
  }

  Widget _buildPercentChip(
    String label,
    VoidCallback onTap,
    NivexThemeExtension theme,
  ) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: theme.surfaceSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
