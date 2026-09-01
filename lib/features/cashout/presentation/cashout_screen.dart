import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_draft.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_format.dart';
import 'package:nivex_flutter/features/cashout/presentation/quote_screen.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class CashoutScreen extends StatefulWidget {
  const CashoutScreen({super.key});

  @override
  State<CashoutScreen> createState() => _CashoutScreenState();
}

class _CashoutScreenState extends State<CashoutScreen> {
  static const _available = 880.0;
  static const _banks = [
    _Bank('Vietcombank', 'VCB', Color(0xFF147D64), '•••• 2868'),
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
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Số USDC muốn đổi',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _amountController.text = '880';
                      setState(() {});
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 44),
                    ),
                    child: const Text('Dùng tối đa'),
                  ),
                ],
              ),
              TextField(
                key: const Key('cashout-amount'),
                controller: _amountController,
                onChanged: (_) => setState(() {}),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  suffixText: 'USDC',
                  filled: true,
                  fillColor: NivexColors.white,
                  helperText: 'Khả dụng: 880,00 USDC',
                  errorText: _amount > _available
                      ? 'Số dư USDC không đủ'
                      : (_amountController.text.isNotEmpty && _amount <= 0
                            ? 'Nhập số USDC lớn hơn 0'
                            : null),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: NivexColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: NivexColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ngân hàng nhận',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Material(
                color: NivexColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: NivexColors.border),
                ),
                child: ListTile(
                  key: const Key('bank-selector'),
                  minTileHeight: 64,
                  onTap: _selectBank,
                  leading: _BankLogo(bank: _selectedBank),
                  title: Text(_selectedBank.name),
                  subtitle: Text('Minh Anh • ${_selectedBank.accountNumber}'),
                  trailing: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ),
              const SizedBox(height: 20),
              NivexCard(
                color: NivexColors.greenSoft,
                child: Column(
                  children: [
                    const _SummaryRow(
                      label: 'Tỷ giá tạm tính',
                      value: '1 USDC = 25.545 VND',
                    ),
                    const SizedBox(height: 12),
                    const _SummaryRow(label: 'Phí giao dịch', value: '0 VND'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    _SummaryRow(
                      label: 'Dự kiến nhận',
                      value: formatVnd(_amount * CashoutDraft.rate),
                      emphasized: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Báo giá chính thức sẽ được giữ trong 30 giây ở bước tiếp theo.',
                style: TextStyle(
                  color: NivexColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const Key('continue-to-quote'),
                onPressed: _valid ? _continueToQuote : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Tiếp tục nhận báo giá'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectBank() async {
    final selected = await showModalBottomSheet<_Bank>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn ngân hàng nhận',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final bank in _banks)
                ListTile(
                  minTileHeight: 58,
                  contentPadding: EdgeInsets.zero,
                  leading: _BankLogo(bank: bank),
                  title: Text(bank.name),
                  subtitle: Text('Minh Anh • ${bank.accountNumber}'),
                  trailing: bank == _selectedBank
                      ? const Icon(Icons.check_circle, color: NivexColors.blue)
                      : null,
                  onTap: () => Navigator.of(context).pop(bank),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted) setState(() => _selectedBank = selected);
  }

  void _continueToQuote() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => QuoteScreen(
          draft: CashoutDraft(
            usdcAmount: _amount,
            bankName: _selectedBank.name,
            accountNumber: _selectedBank.accountNumber,
          ),
        ),
      ),
    );
  }
}

class _Bank {
  const _Bank(this.name, this.code, this.color, this.accountNumber);

  final String name;
  final String code;
  final Color color;
  final String accountNumber;
}

class _BankLogo extends StatelessWidget {
  const _BankLogo({required this.bank});

  final _Bank bank;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: bank.color,
      child: Text(
        bank.code,
        style: const TextStyle(
          color: NivexColors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasized ? NivexColors.navy : NivexColors.textSecondary,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: emphasized ? NivexColors.green : NivexColors.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
