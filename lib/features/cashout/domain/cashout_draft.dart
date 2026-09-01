class CashoutDraft {
  const CashoutDraft({
    required this.usdcAmount,
    required this.bankName,
    required this.accountNumber,
  });

  static const rate = 25545.0;

  final double usdcAmount;
  final String bankName;
  final String accountNumber;

  double get vndAmount => usdcAmount * rate;
}
