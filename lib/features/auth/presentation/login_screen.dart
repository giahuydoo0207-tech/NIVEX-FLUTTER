import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/auth/presentation/register_screen.dart';
import 'package:nivex_flutter/features/auth/presentation/widgets/auth_visual_header.dart';
import 'package:nivex_flutter/features/cashout/data/local_auth_biometric_client.dart';
import 'package:nivex_flutter/features/cashout/domain/biometric_auth_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onLoginSuccess, this.biometricClient});

  final VoidCallback? onLoginSuccess;
  final BiometricAuthClient? biometricClient;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  late final BiometricAuthClient _biometricClient;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricLoading = false;

  @override
  void initState() {
    super.initState();
    _biometricClient = widget.biometricClient ?? LocalAuthBiometricClient();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateAccount(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Vui lòng nhập email hoặc số điện thoại';
    if (input.contains('@')) {
      final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      if (!emailPattern.hasMatch(input)) return 'Email chưa đúng định dạng';
      return null;
    }
    final phone = input.replaceAll(RegExp(r'[\s.-]'), '');
    if (!RegExp(r'^\+?\d{9,11}$').hasMatch(phone)) {
      return 'Số điện thoại chưa hợp lệ';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu cần ít nhất 6 ký tự';
    return null;
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);
    _completeLogin();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _biometricClient.canAuthenticate();
    if (!mounted) return;
    setState(() => _isBiometricAvailable = isAvailable);
  }

  Future<void> _authenticateWithBiometrics() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isBiometricLoading = true);

    final result = await _biometricClient.authenticate(
      localizedReason: 'Dùng vân tay để đăng nhập vào NIVEX',
    );
    if (!mounted) return;
    setState(() => _isBiometricLoading = false);

    switch (result) {
      case BiometricAuthSuccess():
        _completeLogin();
      case BiometricAuthUserCancelled():
        return;
      case BiometricAuthFailed(:final reason):
        _showBiometricMessage(reason);
      case BiometricAuthUnavailable(:final reason):
        setState(() => _isBiometricAvailable = false);
        _showBiometricMessage(reason);
      case BiometricAuthErrorResult(:final message):
        _showBiometricMessage(message);
    }
  }

  void _completeLogin() {
    widget.onLoginSuccess?.call();
    if (widget.onLoginSuccess == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập mô phỏng thành công')),
      );
    }
  }

  void _showBiometricMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openRegister() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => RegisterScreen(
          onOpenLogin: () => Navigator.of(context).pop(),
          onRegisterSuccess: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đăng ký thành công. Vui lòng đăng nhập.'),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showForgotPassword() {
    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng khôi phục mật khẩu đang ở chế độ mô phỏng.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: theme.systemOverlayStyle,
      child: Scaffold(
        backgroundColor: theme.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        const _LoginHeader(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 440),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Chào mừng trở lại',
                                      style: TextStyle(
                                        color: theme.textPrimary,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Đăng nhập để tiếp tục sử dụng NIVEX.',
                                      style: TextStyle(
                                        color: theme.textSecondary,
                                        fontSize: 14,
                                        height: 1.4,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    _LoginField(
                                      key: const Key('login-account-field'),
                                      controller: _accountController,
                                      label: 'Email hoặc số điện thoại',
                                      hint: 'name@example.com',
                                      icon: Icons.person_outline_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.username,
                                        AutofillHints.email,
                                        AutofillHints.telephoneNumber,
                                      ],
                                      validator: _validateAccount,
                                    ),
                                    const SizedBox(height: 16),
                                    _LoginField(
                                      key: const Key('login-password-field'),
                                      controller: _passwordController,
                                      label: 'Mật khẩu',
                                      hint: 'Nhập mật khẩu',
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [
                                        AutofillHints.password,
                                      ],
                                      validator: _validatePassword,
                                      onFieldSubmitted: (_) => _submit(),
                                      suffixIcon: IconButton(
                                        tooltip: _obscurePassword
                                            ? 'Hiện mật khẩu'
                                            : 'Ẩn mật khẩu',
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _showForgotPassword,
                                        child: const Text('Quên mật khẩu?'),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 52,
                                      child: FilledButton(
                                        key: const Key('login-submit-button'),
                                        onPressed:
                                            _isLoading || _isBiometricLoading
                                            ? null
                                            : _submit,
                                        style: FilledButton.styleFrom(
                                          backgroundColor: theme.primary,
                                          foregroundColor:
                                              colorScheme.onPrimary,
                                          disabledBackgroundColor:
                                              theme.disabled,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      key: Key('login-loading'),
                                                      strokeWidth: 2.5,
                                                      color:
                                                          colorScheme.onPrimary,
                                                    ),
                                              )
                                            : const Text(
                                                'Đăng nhập',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                      ),
                                    ),
                                    if (_isBiometricAvailable) ...[
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: theme.divider,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                            ),
                                            child: Text(
                                              'Hoặc',
                                              style: TextStyle(
                                                color: theme.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: theme.divider,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        height: 52,
                                        child: OutlinedButton.icon(
                                          key: const Key(
                                            'login-biometric-button',
                                          ),
                                          onPressed:
                                              _isLoading || _isBiometricLoading
                                              ? null
                                              : _authenticateWithBiometrics,
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: theme.textPrimary,
                                            side: BorderSide(
                                              color: theme.primary,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          icon: _isBiometricLoading
                                              ? SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        key: const Key(
                                                          'login-biometric-loading',
                                                        ),
                                                        strokeWidth: 2.2,
                                                        color: theme.primary,
                                                      ),
                                                )
                                              : Icon(
                                                  Icons.fingerprint_rounded,
                                                  color: theme.primary,
                                                  size: 24,
                                                ),
                                          label: Text(
                                            _isBiometricLoading
                                                ? 'Đang xác thực...'
                                                : 'Đăng nhập bằng vân tay',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Chưa có tài khoản?',
                                            style: TextStyle(
                                              color: theme.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: _openRegister,
                                          child: const Text('Đăng ký'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return const AuthVisualHeader(
      key: Key('login-theme-header'),
      height: 210,
      subtitle: 'Thanh toán quốc tế, rõ ràng hơn',
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: keyboardType == TextInputType.phone
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s.-]'))]
          : null,
      style: TextStyle(color: theme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: theme.surfaceSubtle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.danger, width: 1.5),
        ),
      ),
    );
  }
}
