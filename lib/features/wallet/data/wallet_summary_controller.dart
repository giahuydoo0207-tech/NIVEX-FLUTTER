import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

/// The one wallet summary shown by Home and Wallet, so both always agree.
class WalletSummaryController extends ChangeNotifier {
  WalletSummaryController._(this._api);

  static final _instances = Expando<WalletSummaryController>();

  static WalletSummaryController of(NovaApiClient api) =>
      _instances[api] ??= WalletSummaryController._(api);

  final NovaApiClient _api;
  NovaWalletSummary? summary;
  bool failed = false;
  Future<void>? _inFlight;

  Future<void> refresh() =>
      _inFlight ??= _load().whenComplete(() => _inFlight = null);

  Future<void> _load() async {
    try {
      summary = await _api.walletSummary();
      failed = false;
    } on NovaApiException {
      failed = true;
    }
    notifyListeners();
  }
}

/// Plain-number USDC with two decimals, e.g. 400000 → "0.40".
String formatUsdc2(BigInt minor) {
  final cents = minor ~/ BigInt.from(10000);
  final whole = cents ~/ BigInt.from(100);
  final fraction = (cents % BigInt.from(100)).toString().padLeft(2, '0');
  return '$whole.$fraction';
}
