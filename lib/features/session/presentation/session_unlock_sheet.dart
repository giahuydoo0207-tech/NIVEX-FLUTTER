import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_auth_service.dart';

class SessionUnlockSheet extends StatefulWidget {
  const SessionUnlockSheet({
    required this.authService,
    this.clock = DateTime.now,
    this.title = 'Phiên làm việc đã hết hạn',
    this.description = 'Xác thực lại để tiếp tục. Nova không lưu dữ liệu sinh trắc học của bạn.',
    this.pinLabel = 'PIN giao dịch gồm 6 số',
    this.biometricReason = 'Xác thực để tiếp tục sử dụng Nova',
    this.cancelLabel = 'Đăng xuất',
    super.key,
  });

  final CashoutAuthService authService;
  final Clock clock;
  final String title;
  final String description;
  final String pinLabel;
  final String biometricReason;
  final String cancelLabel;

  static Future<bool> show({
    required BuildContext context,
    required CashoutAuthService authService,
    Clock clock = DateTime.now,
    String title = 'Phiên làm việc đã hết hạn',
    String description = 'Xác thực lại để tiếp tục. Nova không lưu dữ liệu sinh trắc học của bạn.',
    String pinLabel = 'PIN giao dịch gồm 6 số',
    String biometricReason = 'Xác thực để tiếp tục sử dụng Nova',
    String cancelLabel = 'Đăng xuất',
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SessionUnlockSheet(
        authService: authService,
        clock: clock,
        title: title,
        description: description,
        pinLabel: pinLabel,
        biometricReason: biometricReason,
        cancelLabel: cancelLabel,
      ),
    );
    return result ?? false;
  }

  @override
  State<SessionUnlockSheet> createState() => _SessionUnlockSheetState();
}

class _SessionUnlockSheetState extends State<SessionUnlockSheet> {
  String _enteredPin = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
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
    if (_loading || _enteredPin.length != 6) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final outcome = await widget.authService.verifyPin(
      _enteredPin,
      widget.clock(),
    );
    if (!mounted) return;

    switch (outcome) {
      case PinSuccessOutcome():
        Navigator.of(context).pop(true);
      case PinIncorrectOutcome(:final remainingAttempts):
        setState(() {
          _enteredPin = '';
          _loading = false;
          _error = 'Mã PIN không đúng. Còn $remainingAttempts lần thử.';
        });
      case PinLockedOutcome(:final remainingSeconds):
        setState(() {
          _enteredPin = '';
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
      reason: widget.biometricReason,
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

  void _onDigitPressed(String digit) {
    if (_loading || _enteredPin.length >= 6) return;
    setState(() {
      _enteredPin += digit;
      _error = null;
    });
    if (_enteredPin.length == 6) _unlockWithPin();
  }

  void _onBackspacePressed() {
    if (_loading || _enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;

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
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.pinLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final filled = index < _enteredPin.length;
                      return Container(
                        width: 13,
                        height: 13,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled ? theme.primary : theme.surfaceSubtle,
                          border: Border.all(
                            color: filled ? theme.primary : theme.border,
                            width: 1.5,
                          ),
                        ),
                      );
                    }),
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
                  const SizedBox(height: 12),
                  _PinKeypad(
                    isLoading: _loading,
                    onDigitPressed: _onDigitPressed,
                    onBackspacePressed: _onBackspacePressed,
                    onBiometricPressed: _unlockWithBiometric,
                  ),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: Text(widget.cancelLabel),
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

class _PinKeypad extends StatelessWidget {
  const _PinKeypad({
    required this.isLoading,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    required this.onBiometricPressed,
  });

  final bool isLoading;
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onBiometricPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['bio', '0', 'back'],
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        children: rows.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key == 'bio') {
                return _PinKeyButton(
                  key: const Key('pin-key-bio'),
                  onTap: isLoading ? null : onBiometricPressed,
                  child: Icon(Icons.fingerprint_rounded, color: theme.primary),
                );
              }
              if (key == 'back') {
                return _PinKeyButton(
                  key: const Key('pin-key-back'),
                  onTap: isLoading ? null : onBackspacePressed,
                  child: Icon(
                    Icons.backspace_outlined,
                    color: theme.textSecondary,
                  ),
                );
              }
              return _PinKeyButton(
                key: ValueKey('pin-key-$key'),
                onTap: isLoading ? null : () => onDigitPressed(key),
                child: Text(
                  key,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class _PinKeyButton extends StatelessWidget {
  const _PinKeyButton({required this.child, required this.onTap, super.key});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return SizedBox(
      width: 64,
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: theme.surfaceSubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.border),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
