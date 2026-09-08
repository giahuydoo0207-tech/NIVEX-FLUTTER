import 'package:nivex_flutter/features/cashout/domain/cashout_money.dart';

String formatVnd(VndAmount value) => value.toFormattedString();

String formatUsdc(UsdcAmount value) => value.toFormattedString();

abstract final class CashoutFormat {
  static String vnd(VndAmount value) => value.toFormattedString();

  static String usdc(UsdcAmount value) =>
      value.toFormattedString(includeSymbol: false);

  static VndAmount estimateVnd(UsdcAmount usdc, ExchangeRate rate) =>
      rate.convert(usdc);
}
