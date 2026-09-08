import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_auth_service.dart';

class SessionUnlockSheet extends StatefulWidget {
  const SessionUnlockSheet({
    required this.authService,
    this.clock = DateTime.now,
    super.key,
  });

  final CashoutAuthService authService;
  final Clock clock;

  static Future<bool> show({
    required BuildContext context,
    required CashoutAuthService authService,
    Clock clock = DateTime.now,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          SessionUnlockSheet(authService: authService, clock: clock),
    );
    return result ?? false;
  }

  @override
  State<SessionUnlockSheet> createState() => _SessionUnlockSheetState();
}

class _SessionUnlockSheetState extends State<SessionUnlockSheet> {
  final _pinController = TextEditingController();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await widget.authService.initialize();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Không thể tải trạng thái xác thực.';
      });
    }
  }

  Future<void> _unlockWithPin() async {
    if (_loading || _pinController.text.length != 6) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final outcome = await widget.authService.verifyPin(
      _pinController.text,
      widget.clock(),
    );
    if (!mounted) return;

    switch (outcome) {
      case PinSuccessOutcome():
        Navigator.of(context).pop(true);
      case PinIncorrectOutcome(:final remainingAttempts):
        _pinController.clear();
        setState(() {
          _loading = false;
          _error = 'Mã PIN không đúng. Còn $remainingAttempts lần thử.';
        });
      case PinLockedOutcome(:final remainingSeconds):
        _pinController.clear();
        setState(() {
          _loading = false;
          _error =
              'Mở khóa phiên tạm thời bị khóa. Thử lại sau $remainingSeconds giây.';
        });
    }
  }

  Future<void> _unlockWithBiometric() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await widget.authService.authenticateBiometric(
      reason: 'Xác thực để tiếp tục sử dụng NIVEX',
      atTime: widget.clock(),
    );
    if (!mounted) return;

    switch (result) {
      case TransactionAuthSuccess():
        Navigator.of(context).pop(true);
      case TransactionAuthCancelled():
        setState(() => _loading = false);
      case TransactionAuthLocked(:final remainingSeconds):
        setState(() {
          _loading = false;
          _error =
              'Mở khóa phiên tạm thời bị khóa. Thử lại sau $remainingSeconds giây.';
        });
      case TransactionAuthUnavailable(:final reason):
        setState(() {
          _loading = false;
          _error = reason;
        });
      case TransactionAuthError(:final message):
        setState(() {
          _loading = false;
          _error = message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: theme.border),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_clock_outlined,
                    color: theme.primary,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Phiên làm việc đã hết hạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Xác thực lại để tiếp tục. NIVEX không lưu dữ liệu sinh trắc học của bạn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _pinController,
                    enabled: !_loading,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _unlockWithPin(),
                    decoration: const InputDecoration(
                      labelText: 'PIN giao dịch gồm 6 số',
                      counterText: '',
                      prefixIcon: Icon(Icons.pin_outlined),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: _loading || _pinController.text.length != 6
                        ? null
                        : _unlockWithPin,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: theme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: _loading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Text('Mở khóa'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _loading ? null : _unlockWithBiometric,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: const Text('Dùng sinh trắc học'),
                  ),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Đăng xuất'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
