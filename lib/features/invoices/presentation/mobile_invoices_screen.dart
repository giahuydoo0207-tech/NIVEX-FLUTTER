import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

class MobileInvoicesScreen extends StatefulWidget {
  const MobileInvoicesScreen({this.api, super.key});
  final NovaApiClient? api;
  @override
  State<MobileInvoicesScreen> createState() => _MobileInvoicesScreenState();
}

class _MobileInvoicesScreenState extends State<MobileInvoicesScreen> {
  static const _storage = FlutterSecureStorage();
  final _tokenInput = TextEditingController();
  NovaApiClient? _api;
  String? _storageKey;
  List<NovaInvoice> _invoices = [];
  List<NovaTransaction> _transactions = [];
  bool _showTransactions = false;
  String? _error;
  bool _busy = false;
  bool _needsSession = false;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    if (widget.api != null) {
      _api = widget.api;
      _load();
      return;
    }
    try {
      final config = NovaApiConfig.fromBuild();
      _storageKey = 'nova.mobile.session.${config.baseUri.origin}';
      _api = NovaApiClient(
        config: config,
        readToken: () => _storage.read(key: _storageKey!),
      );
      _load();
    } on ArgumentError {
      _error = 'Chưa cấu hình máy chủ.';
    } on FormatException {
      _error = 'Địa chỉ máy chủ không hợp lệ.';
    }
  }

  Future<void> _load({bool next = false}) async {
    if (_busy || _api == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final rows = _showTransactions
          ? await _api!.transactions(offset: next ? _transactions.length : 0)
          : await _api!.invoices(offset: next ? _invoices.length : 0);
      if (!mounted) return;
      setState(() {
        if (_showTransactions) {
          final transactions = rows.cast<NovaTransaction>();
          _transactions = next
              ? [..._transactions, ...transactions]
              : transactions;
        } else {
          final invoices = rows.cast<NovaInvoice>();
          _invoices = next ? [..._invoices, ...invoices] : invoices;
        }
        _needsSession = false;
        _hasMore = rows.length == 25;
      });
    } on NovaApiException catch (error) {
      if (error.requiresLogin && _storageKey != null) {
        try {
          await _storage.delete(key: _storageKey!);
        } catch (_) {
          // Still clear visible data when secure storage is unavailable.
        }
      }
      if (!mounted) return;
      setState(() {
        _needsSession = error.requiresLogin;
        if (_needsSession) {
          _invoices = [];
          _transactions = [];
          _hasMore = false;
        }
        _error = error.requiresLogin
            ? 'Phiên truy cập chưa có hoặc đã hết hạn.'
            : _apiError(error);
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _invoices = [];
          _transactions = [];
          _hasMore = false;
          _error = 'Không đọc được phiên truy cập.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  String _apiError(NovaApiException error) {
    if (error.statusCode == 404) {
      return 'Máy chủ chưa hỗ trợ dữ liệu Mobile. Vui lòng thử lại sau.';
    }
    if (error.statusCode == 403) {
      return 'Phiên truy cập không có quyền xem dữ liệu này.';
    }
    if (error.code == 'timeout') {
      return 'Máy chủ phản hồi chậm. Vui lòng thử lại.';
    }
    if (error.code == 'connection') {
      return 'Không kết nối được máy chủ. Kiểm tra mạng rồi thử lại.';
    }
    if (error.code == 'invalid_response') {
      return 'Dữ liệu máy chủ chưa hợp lệ. Vui lòng thử lại sau.';
    }
    return _showTransactions
        ? 'Không tải được giao dịch. Vui lòng thử lại.'
        : 'Không tải được hóa đơn. Vui lòng thử lại.';
  }

  String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  void _showInvoice(NovaInvoice invoice) {
    final dueDate = DateTime.tryParse(invoice.dueDate ?? '');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                invoice.number,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(_status(invoice.status)),
              const SizedBox(height: 12),
              Text('${formatUsdc(invoice.amountMinor)} USDC'),
              const SizedBox(height: 12),
              Text(invoice.description),
              if (dueDate != null) ...[
                const SizedBox(height: 12),
                Text('Hạn thanh toán: ${_date(dueDate)}'),
              ],
              const SizedBox(height: 12),
              const Text('Solana Devnet'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _connect() async {
    if (_busy) return;
    final token = _tokenInput.text.trim();
    if (!RegExp(r'^[A-Za-z0-9_-]{43,128}$').hasMatch(token)) {
      setState(() {
        _error = 'Mã phiên không hợp lệ.';
      });
      return;
    }
    setState(() => _busy = true);
    try {
      await _storage.write(key: _storageKey!, value: token);
      if (!mounted) return;
      _tokenInput.clear();
      setState(() => _busy = false);
      await _load();
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Không lưu được phiên truy cập.';
          _busy = false;
        });
      }
    }
  }

  Future<void> _disconnect() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _storage.delete(key: _storageKey!);
      if (!mounted) return;
      setState(() {
        _invoices = [];
        _transactions = [];
        _hasMore = false;
        _needsSession = true;
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Không xóa được phiên truy cập.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    if (widget.api == null) _api?.close();
    _tokenInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Hóa đơn Devnet'),
      actions: [
        IconButton(
          onPressed: _busy ? null : () => _load(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Tải lại',
        ),
        if (_storageKey != null && !_needsSession)
          IconButton(
            onPressed: _busy ? null : _disconnect,
            icon: const Icon(Icons.logout),
            tooltip: 'Ngắt phiên',
          ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: () => _load(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Hóa đơn'),
                icon: Icon(Icons.receipt_long),
              ),
              ButtonSegment(
                value: true,
                label: Text('Giao dịch'),
                icon: Icon(Icons.history),
              ),
            ],
            selected: {_showTransactions},
            onSelectionChanged: _busy
                ? null
                : (selection) {
                    setState(() {
                      _showTransactions = selection.single;
                      _hasMore = false;
                    });
                    _load();
                  },
          ),
          const SizedBox(height: 16),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_needsSession && _storageKey != null) ...[
            TextField(
              controller: _tokenInput,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'Mã phiên thử nghiệm',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _connect,
              child: const Text('Kết nối'),
            ),
          ],
          if (!_busy &&
              !_needsSession &&
              _error == null &&
              (_showTransactions ? _transactions.isEmpty : _invoices.isEmpty))
            Text(
              _showTransactions
                  ? 'Chưa có giao dịch đã xác nhận.'
                  : 'Chưa có hóa đơn.',
            ),
          for (final transaction
              in _showTransactions ? _transactions : <NovaTransaction>[])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.verified_outlined),
              title: Text('${formatUsdc(transaction.amountMinor)} USDC'),
              subtitle: Text(
                'Đã hoàn tất trên Devnet\n${_date(transaction.recordedAt)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (context) => SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Giao dịch Devnet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Text('${formatUsdc(transaction.amountMinor)} USDC'),
                        const SizedBox(height: 16),
                        const Text('Mã giao dịch'),
                        SelectableText(transaction.signature),
                        const SizedBox(height: 16),
                        const Text('Ví nhận'),
                        SelectableText(transaction.recipient),
                        const SizedBox(height: 16),
                        const Text('Địa chỉ token'),
                        SelectableText(transaction.mint),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          for (final invoice in _showTransactions ? <NovaInvoice>[] : _invoices)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              title: Text(invoice.number),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(invoice.description),
                  Text('${formatUsdc(invoice.amountMinor)} USDC'),
                  Text(_status(invoice.status)),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showInvoice(invoice),
            ),
          if (_hasMore && !_needsSession)
            TextButton(
              onPressed: _busy ? null : () => _load(next: true),
              child: const Text('Tải thêm'),
            ),
        ],
      ),
    ),
  );

  String _status(String value) => switch (value) {
    'PAID_ON_CHAIN' => 'Đã hoàn tất trên Devnet',
    'PAYMENT_DETECTED' => 'Đang xác nhận',
    'ISSUED' || 'AWAITING_PAYMENT' => 'Chờ thanh toán',
    'CANCELLED' => 'Đã hủy',
    'EXPIRED' => 'Đã hết hạn',
    _ => 'Đang xử lý',
  };
}
