import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_auth_service.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_quote.dart';

class TransactionAuthSheet extends StatefulWidget {
  const TransactionAuthSheet({
    required this.quote,
    required this.authService,
    this.clock = DateTime.now,
    super.key,
  });

  final CashoutQuote quote;
  final CashoutAuthService authService;
  final Clock clock;

  static Future<TransactionAuthResult?> show({
    required BuildContext context,
    required CashoutQuote quote,
    required CashoutAuthService authService,
    Clock clock = DateTime.now,
  }) {
    return showModalBottomSheet<TransactionAuthResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionAuthSheet(
        quote: quote,
        authService: authService,
        clock: clock,
      ),
    );
  }

  @override
  State<TransactionAuthSheet> createState() => _TransactionAuthSheetState();
}

class _TransactionAuthSheetState extends State<TransactionAuthSheet> {
  String _enteredPin = '';
  String? _errorMessage;
  Timer? _lockoutTimer;
  int _lockoutSeconds = 0;
  bool _isAuthenticatingBiometric = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await widget.authService.initialize();
      if (!mounted) return;
      setState(() => _isInitializing = false);
      _checkLockout();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Không thể tải trạng thái xác thực. Vui lòng thử lại.';
      });
    }
  }

  void _checkLockout() {
    final now = widget.clock();
    if (widget.authService.isLocked(now)) {
      _lockoutSeconds = widget.authService.lockoutSecondsRemaining(now);
      _startLockoutCountdown();
    }
  }

  void _startLockoutCountdown() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final now = widget.clock();
      if (!widget.authService.isLocked(now)) {
        timer.cancel();
        setState(() {
          _lockoutSeconds = 0;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _lockoutSeconds = widget.authService.lockoutSecondsRemaining(now);
        });
      }
    });
  }

  void _onDigitPressed(String digit) {
    if (_isInitializing) return;
    if (widget.authService.isLocked(widget.clock())) return;
    if (_enteredPin.length >= 6) return;

    setState(() {
      _enteredPin += digit;
      _errorMessage = null;
    });

    if (_enteredPin.length == 6) {
      _verifyPin();
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _errorMessage = null;
    });
  }

  Future<void> _verifyPin() async {
    final outcome = await widget.authService.verifyPin(
      _enteredPin,
      widget.clock(),
    );
    if (!mounted) return;
    switch (outcome) {
      case PinSuccessOutcome(:final authenticatedAt):
        Navigator.of(context).pop(
          TransactionAuthSuccess(
            method: AuthMethod.pin,
            authenticatedAt: authenticatedAt,
          ),
        );
      case PinIncorrectOutcome(:final remainingAttempts):
        setState(() {
          _enteredPin = '';
          _errorMessage =
              'Mã PIN không đúng. Còn lại $remainingAttempts lần thử.';
        });
      case PinLockedOutcome(:final remainingSeconds):
        setState(() {
          _enteredPin = '';
          _lockoutSeconds = remainingSeconds;
          _errorMessage =
              'Bạn đã nhập sai quá số lần quy định. Xác thực giao dịch tạm khóa $remainingSeconds giây.';
        });
        _startLockoutCountdown();
    }
  }

  Future<void> _tryBiometricAuth() async {
    if (_isInitializing) return;
    if (widget.authService.isLocked(widget.clock())) return;
    setState(() {
      _isAuthenticatingBiometric = true;
      _errorMessage = null;
    });

    try {
      final res = await widget.authService.authenticateBiometric(
        atTime: widget.clock(),
      );
      if (!mounted) return;

      switch (res) {
        case TransactionAuthSuccess():
          Navigator.of(context).pop(res);
        case TransactionAuthCancelled():
          // User cancelled prompt, remain on sheet
          break;
        case TransactionAuthLocked(:final remainingSeconds):
          setState(() {
            _lockoutSeconds = remainingSeconds;
            _errorMessage =
                'Xác thực giao dịch tạm khóa. Vui lòng đợi $remainingSeconds giây.';
          });
          _startLockoutCountdown();
        case TransactionAuthUnavailable(:final reason):
          setState(() {
            _errorMessage = reason;
          });
        case TransactionAuthError(:final message):
          setState(() {
            _errorMessage = message;
          });
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticatingBiometric = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final isLocked = widget.authService.isLocked(widget.clock());

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: theme.border),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Drag handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.disabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),

              // 2. Title & Cancel button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Xác thực giao dịch',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: theme.textSecondary),
                    onPressed: () =>
                        Navigator.of(context)
                            .pop(const TransactionAuthCancelled()),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3. Recap Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đổi từ',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textSecondary,
                          ),
                        ),
                        Text(
                          widget.quote.sellAmount.toFormattedString(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng phí',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textSecondary,
                          ),
                        ),
                        Text(
                          widget.quote.fee.totalFee.toFormattedString(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Thực nhận',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textSecondary,
                          ),
                        ),
                        Text(
                          widget.quote.netVnd.toFormattedString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: theme.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ngân hàng nhận',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textSecondary,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            '${widget.quote.destinationBankName} • ${widget.quote.destinationAccountNumber}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              if (_isInitializing) ...[
                LinearProgressIndicator(
                  color: theme.primary,
                  backgroundColor: theme.surfaceSubtle,
                ),
                const SizedBox(height: 16),
              ],

              // 4. PIN Instruction or Lockout Alert
              if (isLocked)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.dangerSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.danger),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_clock_rounded,
                        color: theme.danger,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Xác thực giao dịch bị tạm khóa do nhập sai quá nhiều lần. Thử lại sau ${_lockoutSeconds}s.',
                          style: TextStyle(
                            color: theme.danger,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    Text(
                      'Nhập mã PIN 6 chữ số để xác nhận',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 6 Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        final filled = index < _enteredPin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 14,
                          height: 14,
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
                  ],
                ),

              if (_errorMessage != null && !isLocked) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // 5. Numeric Keypad
              if (!isLocked) ...[
                _buildKeypad(theme),
                const SizedBox(height: 10),
                // Biometric shortcut button
                TextButton.icon(
                  onPressed: _isAuthenticatingBiometric
                      ? null
                      : _tryBiometricAuth,
                  icon: _isAuthenticatingBiometric
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.primary,
                          ),
                        )
                      : Icon(
                          Icons.fingerprint_rounded,
                          color: theme.primary,
                          size: 22,
                        ),
                  label: Text(
                    'Xác thực bằng Sinh trắc học',
                    style: TextStyle(
                      color: theme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(NivexThemeExtension theme) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['bio', '0', 'back'],
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        children: keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key == 'bio') {
                return _buildKeyButton(
                  theme: theme,
                  child: Icon(Icons.fingerprint_rounded, color: theme.primary),
                  onTap: _isAuthenticatingBiometric ? null : _tryBiometricAuth,
                );
              }
              if (key == 'back') {
                return _buildKeyButton(
                  theme: theme,
                  child: Icon(
                    Icons.backspace_outlined,
                    color: theme.textSecondary,
                  ),
                  onTap: _onBackspacePressed,
                );
              }
              return _buildKeyButton(
                theme: theme,
                child: Text(
                  key,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                  ),
                ),
                onTap: () => _onDigitPressed(key),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyButton({
    required NivexThemeExtension theme,
    required Widget child,
    required VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: 64,
      height: 48,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.surfaceSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
