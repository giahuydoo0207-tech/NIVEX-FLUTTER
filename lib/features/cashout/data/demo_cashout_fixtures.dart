import 'package:flutter/foundation.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_money.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_quote.dart';

@immutable
class DemoBankItem {
  const DemoBankItem({
    required this.name,
    required this.code,
    required this.accountNumber,
    required this.accountHolder,
  });

  final String name;
  final String code;
  final String accountNumber;
  final String accountHolder;
}

abstract final class DemoCashoutFixtures {
  static final UsdcAmount availableBalance = UsdcAmount.fromUnits(880);

  static const String defaultReceiptId = 'NXV-20260901-0042';
  static const String canonicalQuoteId = 'QTE-20260901-0088';
  static const String canonicalNetwork = 'Solana Devnet';

  // Canonical Test Vector values
  static final UsdcAmount canonicalSellAmount = UsdcAmount.fromUnits(100);
  static final UsdcAmount canonicalNetworkFee = UsdcAmount.fromMinorUnits(
    BigInt.from(10000),
  ); // 0.01 USDC
  static final UsdcAmount canonicalServiceFee = UsdcAmount.fromMinorUnits(
    BigInt.from(1500000),
  ); // 1.50 USDC
  static final CashoutFee canonicalFee = CashoutFee(
    networkFee: canonicalNetworkFee,
    serviceFee: canonicalServiceFee,
  );
  static final UsdcAmount canonicalTotalFee = UsdcAmount.fromMinorUnits(
    BigInt.from(1510000),
  ); // 1.51 USDC
  static final UsdcAmount canonicalNetUsdc = UsdcAmount.fromMinorUnits(
    BigInt.from(98490000),
  ); // 98.49 USDC
  static final ExchangeRate canonicalRate = ExchangeRate.fromInt(24556);
  static final VndAmount canonicalNetVnd = VndAmount.fromUnits(
    BigInt.from(2418520),
  ); // 2,418,520 VND

  static const List<DemoBankItem> linkedBanks = [
    DemoBankItem(
      name: 'Vietcombank',
      code: 'VCB',
      accountNumber: '•••• 1092',
      accountHolder: 'MINH ANH',
    ),
    DemoBankItem(
      name: 'Techcombank',
      code: 'TCB',
      accountNumber: '•••• 2868',
      accountHolder: 'MINH ANH',
    ),
    DemoBankItem(
      name: 'ACB',
      code: 'ACB',
      accountNumber: '•••• 7741',
      accountHolder: 'MINH ANH',
    ),
    DemoBankItem(
      name: 'MB Bank',
      code: 'MB',
      accountNumber: '•••• 5530',
      accountHolder: 'MINH ANH',
    ),
  ];

  static CashoutQuote createCanonicalQuote({
    DateTime? now,
    Duration ttl = const Duration(seconds: 30),
  }) {
    final created = now ?? DateTime.now();
    final bank = linkedBanks.first;
    return CashoutQuote(
      quoteId: canonicalQuoteId,
      sellAmount: canonicalSellAmount,
      fee: canonicalFee,
      exchangeRate: canonicalRate,
      destinationBankName: bank.name,
      destinationBankCode: bank.code,
      destinationAccountNumber: bank.accountNumber,
      network: canonicalNetwork,
      createdAt: created,
      expiresAt: created.add(ttl),
    );
  }
}
