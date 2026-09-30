import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/wallet/data/receive_wallet_controller.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// "Địa chỉ ví nhận tiền": the public Solana Devnet address Nova pays into.
/// Everything shown comes from the backend; [onChanged] runs after the backend
/// accepted a change so balances can be reloaded.
class ReceiveWalletSection extends StatefulWidget {
  const ReceiveWalletSection({required this.controller, this.onChanged, super.key});

  final ReceiveWalletController controller;
  final VoidCallback? onChanged;

  @override
  State<ReceiveWalletSection> createState() => _ReceiveWalletSectionState();
}

class _ReceiveWalletSectionState extends State<ReceiveWalletSection> {
  bool _showQr = false;

  ReceiveWalletController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_changed);
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final wallet = _controller.wallet;
    final address = wallet?.walletAddress;
    final configured = wallet?.isConfigured == true && address != null;
    final invalid = wallet?.status == 'INVALID';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ĐỊA CHỈ VÍ NHẬN TIỀN',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: theme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          key: const Key('receive-wallet-card'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.border),
          ),
          child: wallet == null
              ? _loadingOrError(theme)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Solana Devnet · ${wallet.tokenSymbol}',
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _StatusChip(
                          label: configured
                              ? 'Đã cấu hình'
                              : invalid
                              ? 'Không hợp lệ'
                              : 'Chưa cấu hình',
                          color: configured ? theme.success : theme.warning,
                          background: configured
                              ? theme.successSoft
                              : theme.warningSoft,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (configured) ...[
                      SelectableText(
                        address,
                        key: const Key('receive-wallet-address'),
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (_showQr) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(8),
                            child: QrImageView(
                              data: address,
                              version: QrVersions.auto,
                              size: 168,
                              semanticsLabel: 'Mã QR địa chỉ ví nhận tiền',
                            ),
                          ),
                        ),
                      ],
                    ] else
                      Text(
                        invalid
                            ? 'Ví đã lưu không còn hợp lệ trên Solana Devnet. '
                                  'Hãy cập nhật ví để doanh nghiệp có thể thanh toán.'
                            : 'Chưa cấu hình ví nhận tiền. Doanh nghiệp chưa thể '
                                  'thanh toán USDC cho bạn cho tới khi bạn thêm ví.',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (configured) ...[
                          OutlinedButton.icon(
                            onPressed: () => _copy(address),
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            label: const Text('Sao chép'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => setState(() => _showQr = !_showQr),
                            icon: const Icon(Icons.qr_code_rounded, size: 16),
                            label: Text(_showQr ? 'Ẩn QR' : 'Mã QR'),
                          ),
                        ],
                        FilledButton.tonalIcon(
                          key: const Key('receive-wallet-edit'),
                          onPressed: _controller.saving ? null : _edit,
                          icon: Icon(
                            configured ? Icons.edit_outlined : Icons.add,
                            size: 16,
                          ),
                          label: Text(configured || invalid ? 'Sửa ví' : 'Thêm ví'),
                        ),
                        if (configured || invalid)
                          TextButton.icon(
                            key: const Key('receive-wallet-delete'),
                            onPressed: _controller.saving ? null : _delete,
                            icon: Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: theme.danger,
                            ),
                            label: Text(
                              'Xóa ví',
                              style: TextStyle(color: theme.danger),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _loadingOrError(NivexThemeExtension theme) {
    final error = _controller.loadError;
    if (error == null) {
      return const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Row(
      children: [
        Expanded(
          child: Text(error, style: TextStyle(color: theme.textSecondary)),
        ),
        TextButton(onPressed: _controller.load, child: const Text('Thử lại')),
      ],
    );
  }

  void _copy(String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép địa chỉ ví nhận tiền'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _edit() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReceiveWalletEditor(
        controller: _controller,
        initialAddress: _controller.wallet?.walletAddress ?? '',
      ),
    );
    if (saved == true && mounted) {
      widget.onChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu ví nhận tiền')),
      );
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ví nhận tiền?'),
        content: const Text(
          'Doanh nghiệp sẽ không thể tạo yêu cầu thanh toán cho bạn cho tới khi '
          'bạn thêm ví mới. Lịch sử thanh toán đã có không bị xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            key: const Key('receive-wallet-confirm-delete'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa ví'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final error = await _controller.remove();
    if (!mounted) return;
    if (error == null) widget.onChanged?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Đã xóa ví nhận tiền')),
    );
  }
}

/// Add or change the payout address. Only a public address is ever asked for.
class ReceiveWalletEditor extends StatefulWidget {
  const ReceiveWalletEditor({
    required this.controller,
    required this.initialAddress,
    super.key,
  });

  final ReceiveWalletController controller;
  final String initialAddress;

  @override
  State<ReceiveWalletEditor> createState() => _ReceiveWalletEditorState();
}

class _ReceiveWalletEditorState extends State<ReceiveWalletEditor> {
  late final TextEditingController _address = TextEditingController(
    text: widget.initialAddress,
  );
  bool _confirmed = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await widget.controller.save(_address.text);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _saving = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.initialAddress.isEmpty ? 'Thêm ví nhận tiền' : 'Sửa ví nhận tiền',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.warningSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Chỉ nhập địa chỉ ví công khai (public address) trên Solana Devnet, '
                'ví dụ địa chỉ hiển thị trong Phantom hoặc Solflare. Nova không bao '
                'giờ hỏi private key hay cụm từ khôi phục (seed phrase) — đừng nhập '
                'chúng ở bất kỳ đâu.',
                style: TextStyle(color: theme.textPrimary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              key: const Key('receive-wallet-input'),
              controller: _address,
              enabled: !_saving,
              autocorrect: false,
              enableSuggestions: false,
              maxLines: 2,
              minLines: 1,
              decoration: InputDecoration(
                labelText: 'Địa chỉ ví Solana Devnet',
                errorText: _error,
                errorMaxLines: 4,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              key: const Key('receive-wallet-confirm'),
              contentPadding: EdgeInsets.zero,
              value: _confirmed,
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _confirmed = value == true),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'Tôi xác nhận đây là địa chỉ ví công khai của tôi trên Solana Devnet.',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('receive-wallet-save'),
              onPressed: _confirmed && !_saving ? _save : null,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Lưu ví'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
