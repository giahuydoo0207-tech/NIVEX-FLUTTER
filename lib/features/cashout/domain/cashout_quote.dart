import 'package:flutter/foundation.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_money.dart';

@immutable
class CashoutQuote {
  CashoutQuote({
    required this.quoteId,
    required this.sellAmount,
    required this.fee,
    required this.exchangeRate,
    required this.destinationBankName,
    required this.destinationBankCode,
    required this.destinationAccountNumber,
    required this.network,
    required this.createdAt,
    required this.expiresAt,
  }) {
    if (sellAmount <= UsdcAmount.zero) {
      throw ArgumentError.value(
        sellAmount,
        'sellAmount',
        'Sell amount must be greater than zero',
      );
    }
    if (fee.totalFee >= sellAmount) {
      throw ArgumentError.value(
        fee.totalFee,
        'fee',
        'Total fee must be lower than the sell amount',
      );
    }
    if (!expiresAt.isAfter(createdAt)) {
      throw ArgumentError.value(
        expiresAt,
        'expiresAt',
        'Expiration time must be after creation time',
      );
    }
    if (quoteId.trim().isEmpty) {
      throw ArgumentError.value(quoteId, 'quoteId', 'Quote ID cannot be empty');
    }
    if (destinationBankName.trim().isEmpty) {
      throw ArgumentError.value(
        destinationBankName,
        'destinationBankName',
        'Destination bank name cannot be empty',
      );
    }
    if (destinationAccountNumber.trim().isEmpty) {
      throw ArgumentError.value(
        destinationAccountNumber,
        'destinationAccountNumber',
        'Destination account number cannot be empty',
      );
    }
  }

  final String quoteId;
  final UsdcAmount sellAmount;
  final CashoutFee fee;
  final ExchangeRate exchangeRate;
  final String destinationBankName;
  final String destinationBankCode;
  final String destinationAccountNumber;
  final String network;
  final DateTime createdAt;
  final DateTime expiresAt;

  UsdcAmount get netUsdc => sellAmount - fee.totalFee;
  VndAmount get netVnd => exchangeRate.convert(netUsdc);

  bool isExpiredAt(DateTime currentTime) => !currentTime.isBefore(expiresAt);

  int remainingSecondsAt(DateTime currentTime) {
    if (isExpiredAt(currentTime)) return 0;
    final diffMs = expiresAt.difference(currentTime).inMilliseconds;
    if (diffMs <= 0) return 0;
    return (diffMs / 1000).ceil();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashoutQuote &&
          quoteId == other.quoteId &&
          sellAmount == other.sellAmount &&
          fee == other.fee &&
          exchangeRate == other.exchangeRate &&
          destinationBankName == other.destinationBankName &&
          destinationBankCode == other.destinationBankCode &&
          destinationAccountNumber == other.destinationAccountNumber &&
          network == other.network &&
          createdAt == other.createdAt &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode => Object.hash(
    quoteId,
    sellAmount,
    fee,
    exchangeRate,
    destinationBankName,
    destinationBankCode,
    destinationAccountNumber,
    network,
    createdAt,
    expiresAt,
  );
}
