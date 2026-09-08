import 'package:flutter/foundation.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_money.dart';

@immutable
sealed class UsdcParseResult {
  const UsdcParseResult();
}

@immutable
class UsdcParseSuccess extends UsdcParseResult {
  const UsdcParseSuccess(this.amount);
  final UsdcAmount amount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsdcParseSuccess && amount == other.amount;

  @override
  int get hashCode => amount.hashCode;
}

@immutable
class UsdcParseEmpty extends UsdcParseResult {
  const UsdcParseEmpty();

  @override
  bool operator ==(Object other) => other is UsdcParseEmpty;

  @override
  int get hashCode => 0;
}

@immutable
class UsdcParseInvalid extends UsdcParseResult {
  const UsdcParseInvalid(this.message);
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsdcParseInvalid && message == other.message;

  @override
  int get hashCode => message.hashCode;
}

abstract final class UsdcParser {
  static UsdcParseResult parse(String? rawInput) {
    if (rawInput == null) return const UsdcParseEmpty();
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return const UsdcParseEmpty();

    if (trimmed.startsWith('-')) {
      return const UsdcParseInvalid('Số tiền không được âm');
    }

    // Check for multiple separators
    var separatorCount = 0;
    for (var i = 0; i < trimmed.length; i++) {
      final char = trimmed[i];
      if (char == '.' || char == ',') {
        separatorCount++;
      }
    }
    if (separatorCount > 1) {
      return const UsdcParseInvalid('Định dạng số không hợp lệ');
    }

    if (trimmed == '.' || trimmed == ',') {
      return const UsdcParseInvalid('Vui lòng nhập số tiền hợp lệ');
    }

    final normalized = trimmed.replaceAll(',', '.');
    final parts = normalized.split('.');

    final wholePartStr = parts[0];
    final fracPartStr = parts.length > 1 ? parts[1] : '';

    if (wholePartStr.isEmpty && fracPartStr.isEmpty) {
      return const UsdcParseInvalid('Vui lòng nhập số tiền hợp lệ');
    }

    // Verify all chars in wholePart are digits
    if (wholePartStr.isNotEmpty && !_isAllDigits(wholePartStr)) {
      return const UsdcParseInvalid('Chỉ nhập số');
    }

    // Verify all chars in fracPart are digits
    if (fracPartStr.isNotEmpty && !_isAllDigits(fracPartStr)) {
      return const UsdcParseInvalid('Chỉ nhập số');
    }

    if (fracPartStr.length > UsdcAmount.decimals) {
      return const UsdcParseInvalid('Tối đa 6 chữ số thập phân');
    }

    final wholeBigInt = wholePartStr.isEmpty
        ? BigInt.zero
        : (BigInt.tryParse(wholePartStr) ?? BigInt.zero);

    final paddedFracStr = fracPartStr.padRight(UsdcAmount.decimals, '0');
    final fracBigInt = paddedFracStr.isEmpty
        ? BigInt.zero
        : (BigInt.tryParse(paddedFracStr) ?? BigInt.zero);

    final totalMicroUnits =
        (wholeBigInt * UsdcAmount.scalingFactor) + fracBigInt;

    return UsdcParseSuccess(UsdcAmount.fromMinorUnits(totalMicroUnits));
  }

  static bool _isAllDigits(String s) {
    for (var i = 0; i < s.length; i++) {
      final code = s.codeUnitAt(i);
      if (code < 48 || code > 57) {
        return false;
      }
    }
    return true;
  }
}
