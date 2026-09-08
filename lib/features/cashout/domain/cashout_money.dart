import 'package:flutter/foundation.dart';

@immutable
class UsdcAmount implements Comparable<UsdcAmount> {
  UsdcAmount.fromMinorUnits(this.minorUnits) {
    if (minorUnits < BigInt.zero) {
      throw ArgumentError.value(
        minorUnits,
        'minorUnits',
        'USDC amount cannot be negative',
      );
    }
  }

  factory UsdcAmount.fromUnits(int wholeUnits, [int microUnits = 0]) {
    if (wholeUnits < 0 || microUnits < 0 || microUnits >= 1000000) {
      throw ArgumentError('Invalid units or microUnits');
    }
    final total =
        BigInt.from(wholeUnits) * scalingFactor + BigInt.from(microUnits);
    return UsdcAmount.fromMinorUnits(total);
  }

  static final BigInt zeroMinorUnits = BigInt.zero;
  static final UsdcAmount zero = UsdcAmount.fromMinorUnits(BigInt.zero);
  static const int decimals = 6;
  static final BigInt scalingFactor = BigInt.from(1000000);

  final BigInt minorUnits;

  UsdcAmount operator +(UsdcAmount other) =>
      UsdcAmount.fromMinorUnits(minorUnits + other.minorUnits);

  UsdcAmount operator -(UsdcAmount other) {
    final result = minorUnits - other.minorUnits;
    if (result < BigInt.zero) {
      throw StateError(
        'Cannot subtract a larger USDC amount: $minorUnits - ${other.minorUnits}',
      );
    }
    return UsdcAmount.fromMinorUnits(result);
  }

  bool operator <(UsdcAmount other) => minorUnits < other.minorUnits;
  bool operator <=(UsdcAmount other) => minorUnits <= other.minorUnits;
  bool operator >(UsdcAmount other) => minorUnits > other.minorUnits;
  bool operator >=(UsdcAmount other) => minorUnits >= other.minorUnits;

  @override
  int compareTo(UsdcAmount other) => minorUnits.compareTo(other.minorUnits);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsdcAmount && minorUnits == other.minorUnits;

  @override
  int get hashCode => minorUnits.hashCode;

  String toFormattedString({
    int fractionDigits = 2,
    bool includeSymbol = true,
  }) {
    final whole = minorUnits ~/ scalingFactor;
    final remainder = minorUnits % scalingFactor;
    final remainderStr = remainder.toString().padLeft(decimals, '0');
    final frac = remainderStr.substring(0, fractionDigits);

    final wholeStr = _formatWithThousandSeparators(whole, '.');
    final formatted = fractionDigits > 0 ? '$wholeStr,$frac' : wholeStr;
    return includeSymbol ? '$formatted USDC' : formatted;
  }

  @override
  String toString() => toFormattedString();
}

@immutable
class VndAmount implements Comparable<VndAmount> {
  VndAmount.fromUnits(this.minorUnits) {
    if (minorUnits < BigInt.zero) {
      throw ArgumentError.value(
        minorUnits,
        'minorUnits',
        'VND amount cannot be negative',
      );
    }
  }

  static final VndAmount zero = VndAmount.fromUnits(BigInt.zero);
  static const int decimals = 0;

  final BigInt minorUnits;

  VndAmount operator +(VndAmount other) =>
      VndAmount.fromUnits(minorUnits + other.minorUnits);

  VndAmount operator -(VndAmount other) {
    final result = minorUnits - other.minorUnits;
    if (result < BigInt.zero) {
      throw StateError('Cannot subtract a larger VND amount');
    }
    return VndAmount.fromUnits(result);
  }

  bool operator <(VndAmount other) => minorUnits < other.minorUnits;
  bool operator <=(VndAmount other) => minorUnits <= other.minorUnits;
  bool operator >(VndAmount other) => minorUnits > other.minorUnits;
  bool operator >=(VndAmount other) => minorUnits >= other.minorUnits;

  @override
  int compareTo(VndAmount other) => minorUnits.compareTo(other.minorUnits);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VndAmount && minorUnits == other.minorUnits;

  @override
  int get hashCode => minorUnits.hashCode;

  String toFormattedString({bool includeSymbol = true}) {
    final wholeStr = _formatWithThousandSeparators(minorUnits, '.');
    return includeSymbol ? '$wholeStr VND' : wholeStr;
  }

  @override
  String toString() => toFormattedString();
}

@immutable
class ExchangeRate {
  ExchangeRate(this.rateVndPerUsdc) {
    if (rateVndPerUsdc <= BigInt.zero) {
      throw ArgumentError.value(
        rateVndPerUsdc,
        'rateVndPerUsdc',
        'Exchange rate must be positive',
      );
    }
  }

  factory ExchangeRate.fromInt(int rate) => ExchangeRate(BigInt.from(rate));

  final BigInt rateVndPerUsdc;

  VndAmount convert(UsdcAmount usdc) {
    final netVndUnits =
        (usdc.minorUnits * rateVndPerUsdc) ~/ UsdcAmount.scalingFactor;
    return VndAmount.fromUnits(netVndUnits);
  }

  String toFormattedString() {
    final rateStr = _formatWithThousandSeparators(rateVndPerUsdc, '.');
    return '1 USDC = $rateStr VND';
  }

  @override
  String toString() => toFormattedString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExchangeRate && rateVndPerUsdc == other.rateVndPerUsdc;

  @override
  int get hashCode => rateVndPerUsdc.hashCode;
}

@immutable
class CashoutFee {
  const CashoutFee({required this.networkFee, required this.serviceFee});

  static final zero = CashoutFee(
    networkFee: UsdcAmount.zero,
    serviceFee: UsdcAmount.zero,
  );

  final UsdcAmount networkFee;
  final UsdcAmount serviceFee;

  UsdcAmount get totalFee => networkFee + serviceFee;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashoutFee &&
          networkFee == other.networkFee &&
          serviceFee == other.serviceFee;

  @override
  int get hashCode => Object.hash(networkFee, serviceFee);
}

String _formatWithThousandSeparators(BigInt number, String separator) {
  final digits = number.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(separator);
    }
    buffer.write(digits[index]);
  }
  return buffer.toString();
}
