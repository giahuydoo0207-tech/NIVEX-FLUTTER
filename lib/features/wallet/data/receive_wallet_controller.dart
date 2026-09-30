import 'package:flutter/foundation.dart';
import 'package:nivex_flutter/features/wallet/domain/solana_address.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

/// The contractor's payout wallet as the backend knows it. A failed save or
/// removal leaves [wallet] exactly as it was; success reloads it from the
/// backend, so the screen never shows a change the server did not accept.
class ReceiveWalletController extends ChangeNotifier {
  ReceiveWalletController(this._api);

  final NovaApiClient _api;
  NovaReceiveWallet? wallet;
  bool loading = false;
  bool saving = false;
  String? loadError;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      wallet = await _api.receiveWallet();
      loadError = null;
    } on NovaApiException catch (error) {
      loadError = messageFor(error, action: 'tải');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Null on success, otherwise the reason to show.
  Future<String?> save(String address) async {
    final problem = checkSolanaAddress(address);
    if (problem != null) return problem;
    return _change(() => _api.saveReceiveWallet(address.trim()), 'lưu');
  }

  /// Null on success, otherwise the reason to show.
  Future<String?> remove() => _change(_api.deleteReceiveWallet, 'xóa');

  Future<String?> _change(
    Future<NovaReceiveWallet> Function() request,
    String action,
  ) async {
    if (saving) return 'Đang xử lý, vui lòng đợi.';
    saving = true;
    notifyListeners();
    try {
      final accepted = await request();
      try {
        wallet = await _api.receiveWallet();
      } on NovaApiException {
        // The change is saved; show the backend's own reply to it.
        wallet = accepted;
      }
      loadError = null;
      return null;
    } on NovaApiException catch (error) {
      return messageFor(error, action: action);
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  static String messageFor(NovaApiException error, {required String action}) {
    final server = error.serverMessage;
    if (server != null) return server;
    if (error.requiresLogin) {
      return 'Phiên đăng nhập đã hết hạn. Hãy đăng nhập lại.';
    }
    final unchanged = action == 'tải'
        ? ''
        : ' Ví nhận tiền của bạn vẫn giữ nguyên.';
    if (error.code == 'timeout' || error.code == 'connection') {
      return 'Không kết nối được máy chủ nên chưa $action được ví.$unchanged';
    }
    return 'Chưa $action được ví nhận tiền'
        '${error.statusCode == null ? '' : ' (HTTP ${error.statusCode})'}.'
        '$unchanged';
  }
}
