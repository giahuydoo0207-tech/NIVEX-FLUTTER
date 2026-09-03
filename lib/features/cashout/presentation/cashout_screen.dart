import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_draft.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_format.dart';
import 'package:nivex_flutter/features/cashout/presentation/quote_screen.dart';
import 'package:nivex_flutter/shared/constants/demo_data.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class CashoutScreen extends StatefulWidget {
  const CashoutScreen({super.key});

  @override
  State<CashoutScreen> createState() => _CashoutScreenState();
}

class _CashoutScreenState extends State<CashoutScreen> {
  static const _available = 880.0;
  static const _banks = [
    _Bank(
      DemoData.bankName,
      'VCB',
      Color(0xFF147D64),
      DemoData.bankAccountLast4,
    ),
    _Bank('Techcombank', 'TCB', Color(0xFFC62828), '•••• 1092'),
    _Bank('ACB', 'ACB', Color(0xFF2563EB), '•••• 7741'),
    _Bank('MB Bank', 'MB', Color(0xFF123B73), '•••• 5530'),
  ];

  final _amountController = TextEditingController(text: '250');
  _Bank _selectedBank = _banks.first;

  double get _amount =>
      double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
  bool get _valid => _amount > 0 && _amount <= _available;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexPage(
      title: 'Rút VND',
      subtitle: 'Quy đổi USDC về tài khoản ngân hàng',
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
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _amountController.text = '880';
                      setState(() {});
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: theme.primary,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0,
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
                    color: _valid ? theme.primary : theme.border,
                    width: _valid ? 1.5 : 1,
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
                            RegExp(r'^\d*[\,\.]?\d{0,2}'),
                          ),
                        ],
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: theme.textPrimary,
                          letterSpacing: 0,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
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
                          letterSpacing: 0,
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
                  Text(
                    'Khả dụng: 880,00 USDC',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textSecondary,
                      letterSpacing: 0,
                    ),
                  ),
                  if (_amount > _available)
                    Text(
                      'Vượt quá số dư',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.danger,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              // 2. Conversion Estimate
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
                        Text(
                          'Tỷ giá ước tính',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textSecondary,
                            letterSpacing: 0,
                          ),
                        ),
                        Text(
                          '1 USDC = 25.545 VND',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'VND thực nhận dự kiến',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textSecondary,
                            letterSpacing: 0,
                          ),
                        ),
                        Text(
                          CashoutFormat.vnd(CashoutFormat.estimateVnd(_amount)),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: theme.success,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              // 3. Bank Account Selection
              Text(
                'TÀI KHOẢN NHẬN TIỀN',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.textSecondary,
                  letterSpacing: 0,
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
                  itemCount: _banks.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, thickness: 1, color: theme.divider),
                  itemBuilder: (context, index) {
                    final b = _banks[index];
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
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: b.color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                b.code,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  letterSpacing: 0,
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
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'MINH ANH • ${b.account}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textSecondary,
                                      letterSpacing: 0,
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
              const SizedBox(height: 28),
              // 4. Submit Button
              FilledButton(
                onPressed: _valid
                    ? () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => QuoteScreen(
                              draft: CashoutDraft(
                                usdcAmount: _amount,
                                bankName: _selectedBank.name,
                                accountNumber: _selectedBank.account,
                              ),
                            ),
                          ),
                        );
                      }
                    : null,
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
                child: const Text('Xem báo giá quy đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bank {
  const _Bank(this.name, this.code, this.color, this.account);
  final String name;
  final String code;
  final Color color;
  final String account;
}
