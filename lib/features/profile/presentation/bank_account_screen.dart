import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/profile/widgets/demo_notice.dart';
import 'package:nivex_flutter/features/profile/widgets/status_badge.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class _BankOption {
  const _BankOption({
    required this.name,
    required this.subtitle,
    required this.shortCode,
    required this.logoAsset,
  });

  final String name;
  final String subtitle;
  final String shortCode;
  final String logoAsset;
}

const List<_BankOption> _bankOptions = [
  _BankOption(
    name: 'Vietcombank',
    subtitle: 'Ngân hàng TMCP Ngoại thương VN',
    shortCode: 'VCB',
    logoAsset: 'assets/images/banks/vietcombank.png',
  ),
  _BankOption(
    name: 'Techcombank',
    subtitle: 'Ngân hàng TMCP Kỹ thương VN',
    shortCode: 'TCB',
    logoAsset: 'assets/images/banks/techcombank.png',
  ),
  _BankOption(
    name: 'ACB',
    subtitle: 'Ngân hàng TMCP Á Châu',
    shortCode: 'ACB',
    logoAsset: 'assets/images/banks/acb.png',
  ),
  _BankOption(
    name: 'MB Bank',
    subtitle: 'Ngân hàng Quân đội',
    shortCode: 'MB',
    logoAsset: 'assets/images/banks/mb_bank.png',
  ),
];

class _BankAccount {
  const _BankAccount({
    required this.bankName,
    required this.bankSubtitle,
    required this.shortCode,
    required this.logoAsset,
    required this.accountName,
    required this.accountNumber,
    this.isDefault = false,
    this.status = 'Đã liên kết (Khớp KYC)',
  });

  final String bankName;
  final String bankSubtitle;
  final String shortCode;
  final String logoAsset;
  final String accountName;
  final String accountNumber;
  final bool isDefault;
  final String status;
}

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  final List<_BankAccount> _accounts = [
    const _BankAccount(
      bankName: 'Vietcombank',
      bankSubtitle: 'Ngân hàng TMCP Ngoại thương VN',
      shortCode: 'VCB',
      logoAsset: 'assets/images/banks/vietcombank.png',
      accountName: 'MINH ANH',
      accountNumber: '2868',
      isDefault: true,
    ),
  ];

  String _formatMaskedAccountNumber(String raw) {
    final clean = raw.replaceAll(' ', '');
    if (clean.startsWith('••••')) {
      return clean;
    }
    final last4 = clean.length > 4 ? clean.substring(clean.length - 4) : clean;
    return '•••• $last4';
  }

  void _showAddAccountSheet() {
    final theme = context.nivexTheme;
    _BankOption selectedBank = _bankOptions.first;
    final accountNumberController = TextEditingController();
    final accountNameController = TextEditingController(text: 'MINH ANH');
    String? accountNumberError;
    String? accountNameError;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'Thêm tài khoản nhận VND',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Thông tin ngân hàng trong bản demo mô phỏng (không chuyển tiền thật).',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<_BankOption>(
                      key: const Key('bank-select-field'),
                      initialValue: selectedBank,
                      isExpanded: true,
                      dropdownColor: theme.surface,
                      decoration: const InputDecoration(
                        labelText: 'Ngân hàng',
                        prefixIcon: Icon(Icons.account_balance_outlined),
                      ),
                      items: _bankOptions.map((b) {
                        return DropdownMenuItem<_BankOption>(
                          value: b,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: theme.surfaceSubtle,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: theme.border),
                                  ),
                                  child: Image.asset(
                                    b.logoAsset,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => Center(
                                      child: Text(
                                        b.shortCode,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: theme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  b.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedBank = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('bank-account-number-field'),
                      controller: accountNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(20),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Số tài khoản',
                        hintText: 'Nhập số tài khoản (tối thiểu 6 số)',
                        prefixIcon: const Icon(Icons.credit_card_rounded),
                        errorText: accountNumberError,
                      ),
                      onChanged: (_) {
                        if (accountNumberError != null) {
                          setModalState(() => accountNumberError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('bank-account-name-field'),
                      controller: accountNameController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Chủ tài khoản',
                        hintText: 'Họ và tên không dấu',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        errorText: accountNameError,
                      ),
                      onChanged: (_) {
                        if (accountNameError != null) {
                          setModalState(() => accountNameError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      key: const Key('save-bank-account-button'),
                      onPressed: () {
                        final numText = accountNumberController.text.trim();
                        final nameText = accountNameController.text.trim();
                        var hasError = false;

                        if (numText.isEmpty ||
                            numText.length < 6 ||
                            !RegExp(r'^\d+$').hasMatch(numText)) {
                          setModalState(
                            () => accountNumberError =
                                'Số tài khoản không hợp lệ.',
                          );
                          hasError = true;
                        }
                        if (nameText.isEmpty) {
                          setModalState(
                            () => accountNameError =
                                'Vui lòng nhập chủ tài khoản.',
                          );
                          hasError = true;
                        }

                        if (hasError) return;

                        setState(() {
                          _accounts.add(
                            _BankAccount(
                              bankName: selectedBank.name,
                              bankSubtitle: selectedBank.subtitle,
                              shortCode: selectedBank.shortCode,
                              logoAsset: selectedBank.logoAsset,
                              accountName: nameText.toUpperCase(),
                              accountNumber: numText,
                              isDefault: false,
                              status: 'Đã liên kết (Khớp KYC)',
                            ),
                          );
                        });

                        Navigator.of(sheetContext).pop();

                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Đã thêm tài khoản nhận VND trong bản demo.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Lưu tài khoản'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexPage(
      title: 'Tài khoản nhận VND',
      subtitle: 'Tài khoản ngân hàng liên kết',
      showBackButton: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final account in _accounts) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: theme.surfaceSubtle,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: theme.border),
                                      ),
                                      child: Image.asset(
                                        account.logoAsset,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) => Center(
                                          child: Text(
                                            account.shortCode,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: theme.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          account.bankName,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: theme.textPrimary,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          account.bankSubtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.textSecondary,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (account.isDefault) ...[
                              const SizedBox(width: 8),
                              const StatusBadge(label: 'Mặc định'),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(height: 1, thickness: 1, color: theme.divider),
                        const SizedBox(height: 12),
                        _BankDetailRow(
                          label: 'Số tài khoản',
                          value: _formatMaskedAccountNumber(
                            account.accountNumber,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _BankDetailRow(
                          label: 'Chủ tài khoản',
                          value: account.accountName,
                        ),
                        const SizedBox(height: 8),
                        _BankDetailRow(
                          label: 'Trạng thái',
                          value: account.status,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                InkWell(
                  key: const Key('add-bank-account-button'),
                  onTap: _showAddAccountSheet,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.primary.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, color: theme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Thêm tài khoản',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: theme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const DemoNotice(
                  text: 'Tài khoản ngân hàng dùng để nhận tiền khi rút VND (mô phỏng). Trong bản demo MVP, thông tin ngân hàng được cấu hình sẵn theo hồ sơ KYC và không chuyển tiền thật.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BankDetailRow extends StatelessWidget {
  const _BankDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: theme.textSecondary,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
