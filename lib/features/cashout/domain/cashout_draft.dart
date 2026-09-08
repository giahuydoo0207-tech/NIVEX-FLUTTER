import 'package:nivex_flutter/features/cashout/domain/cashout_money.dart';

@Deprecated('Pass a validated CashoutQuote between cashout screens instead.')
class CashoutDraft {
  const CashoutDraft({
    required this.usdcAmount,
    required this.bankName,
    required this.accountNumber,
  });

  final UsdcAmount usdcAmount;
  final String bankName;
  final String accountNumber;
}
