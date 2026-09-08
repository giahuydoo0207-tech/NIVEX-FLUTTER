import 'package:nivex_flutter/features/cashout/data/demo_cashout_fixtures.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_auth_service.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_money.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_quote.dart';

class MockQuoteRepository {
  MockQuoteRepository({this.clock = DateTime.now});

  final Clock clock;
  int _quoteSequence = 0;

  CashoutQuote getQuote({
    required UsdcAmount amount,
    required DemoBankItem bank,
    Duration ttl = const Duration(seconds: 30),
    bool forceNewId = false,
  }) {
    final now = clock();
    final totalFee = DemoCashoutFixtures.canonicalFee.totalFee;
    if (amount <= totalFee) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Cashout amount must be greater than the total fee',
      );
    }

    if (amount == DemoCashoutFixtures.canonicalSellAmount &&
        bank.name == DemoCashoutFixtures.linkedBanks.first.name &&
        !forceNewId) {
      return CashoutQuote(
        quoteId: DemoCashoutFixtures.canonicalQuoteId,
        sellAmount: DemoCashoutFixtures.canonicalSellAmount,
        fee: DemoCashoutFixtures.canonicalFee,
        exchangeRate: DemoCashoutFixtures.canonicalRate,
        destinationBankName: bank.name,
        destinationBankCode: bank.code,
        destinationAccountNumber: bank.accountNumber,
        network: DemoCashoutFixtures.canonicalNetwork,
        createdAt: now,
        expiresAt: now.add(ttl),
      );
    }

    final fee = DemoCashoutFixtures.canonicalFee;
    final sequence = _quoteSequence++;

    return CashoutQuote(
      quoteId: 'QTE-${now.microsecondsSinceEpoch}-$sequence',
      sellAmount: amount,
      fee: fee,
      exchangeRate: DemoCashoutFixtures.canonicalRate,
      destinationBankName: bank.name,
      destinationBankCode: bank.code,
      destinationAccountNumber: bank.accountNumber,
      network: DemoCashoutFixtures.canonicalNetwork,
      createdAt: now,
      expiresAt: now.add(ttl),
    );
  }
}
