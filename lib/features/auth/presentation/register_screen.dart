import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/auth/presentation/widgets/auth_visual_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.onRegisterSuccess, this.onOpenLogin});

  final VoidCallback? onRegisterSuccess;
  final VoidCallback? onOpenLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;
  bool _showTermsError = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _requiredName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Vui lòng nhập họ tên';
    if (name.length < 2) return 'Họ tên chưa hợp lệ';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Vui lòng nhập email';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Email chưa đúng định dạng';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = (value ?? '').replaceAll(RegExp(r'[\s.-]'), '');
    if (phone.isEmpty) return 'Vui lòng nhập số điện thoại';
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

  String? _validateConfirmation(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (value != _passwordController.text) return 'Mật khẩu không khớp';
    return null;
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() => _showTermsError = !_acceptedTerms);
    if (!formValid || !_acceptedTerms) return;
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (widget.onRegisterSuccess != null) {
      widget.onRegisterSuccess!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký mô phỏng thành công')),
      );
    }
  }

  void _openLogin() {
    if (widget.onOpenLogin != null) {
      widget.onOpenLogin!();
    } else {
      Navigator.of(context).maybePop();
    }
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
                        const _RegisterHeader(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
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
                                      'Tạo tài khoản',
                                      style: TextStyle(
                                        color: theme.textPrimary,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Nhập thông tin để bắt đầu với NIVEX.',
                                      style: TextStyle(
                                        color: theme.textSecondary,
                                        fontSize: 14,
                                        height: 1.4,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    _RegisterField(
                                      key: const Key('register-name-field'),
                                      controller: _nameController,
                                      label: 'Họ và tên',
                                      icon: Icons.badge_outlined,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [AutofillHints.name],
                                      validator: _requiredName,
                                    ),
                                    const SizedBox(height: 14),
                                    _RegisterField(
                                      key: const Key('register-email-field'),
                                      controller: _emailController,
                                      label: 'Email',
                                      icon: Icons.mail_outline_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.email,
                                      ],
                                      validator: _validateEmail,
                                    ),
                                    const SizedBox(height: 14),
                                    _RegisterField(
                                      key: const Key('register-phone-field'),
                                      controller: _phoneController,
                                      label: 'Số điện thoại',
                                      icon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.telephoneNumber,
                                      ],
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9+\s.-]'),
                                        ),
                                      ],
                                      validator: _validatePhone,
                                    ),
                                    const SizedBox(height: 14),
                                    _RegisterField(
                                      key: const Key('register-password-field'),
                                      controller: _passwordController,
                                      label: 'Mật khẩu',
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.newPassword,
                                      ],
                                      validator: _validatePassword,
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
                                    const SizedBox(height: 14),
                                    _RegisterField(
                                      key: const Key(
                                        'register-confirm-password-field',
                                      ),
                                      controller: _confirmPasswordController,
                                      label: 'Xác nhận mật khẩu',
                                      icon: Icons.lock_reset_rounded,
                                      obscureText: _obscureConfirmation,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [
                                        AutofillHints.newPassword,
                                      ],
                                      validator: _validateConfirmation,
                                      onFieldSubmitted: (_) => _submit(),
                                      suffixIcon: IconButton(
                                        tooltip: _obscureConfirmation
                                            ? 'Hiện mật khẩu xác nhận'
                                            : 'Ẩn mật khẩu xác nhận',
                                        onPressed: () => setState(
                                          () => _obscureConfirmation =
                                              !_obscureConfirmation,
                                        ),
                                        icon: Icon(
                                          _obscureConfirmation
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Semantics(
                                      label:
                                          'Tôi đồng ý với Điều khoản sử dụng',
                                      child: CheckboxListTile(
                                        key: const Key(
                                          'register-terms-checkbox',
                                        ),
                                        value: _acceptedTerms,
                                        onChanged: (value) => setState(() {
                                          _acceptedTerms = value ?? false;
                                          if (_acceptedTerms) {
                                            _showTermsError = false;
                                          }
                                        }),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                        activeColor: theme.primary,
                                        checkColor: colorScheme.onPrimary,
                                        title: Text(
                                          'Tôi đồng ý với Điều khoản sử dụng',
                                          style: TextStyle(
                                            color: theme.textPrimary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_showTermsError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          'Bạn cần đồng ý với Điều khoản sử dụng',
                                          style: TextStyle(
                                            color: theme.danger,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      height: 52,
                                      child: FilledButton(
                                        key: const Key(
                                          'register-submit-button',
                                        ),
                                        onPressed: _isLoading ? null : _submit,
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
                                                      key: Key(
                                                        'register-loading',
                                                      ),
                                                      strokeWidth: 2.5,
                                                      color:
                                                          colorScheme.onPrimary,
                                                    ),
                                              )
                                            : const Text(
                                                'Đăng ký',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Đã có tài khoản?',
                                            style: TextStyle(
                                              color: theme.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: _openLogin,
                                          child: const Text('Đăng nhập'),
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

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return const AuthVisualHeader(
      key: Key('register-theme-header'),
      height: 164,
      subtitle: 'Mở tài khoản NIVEX',
    );
  }
}

class _RegisterField extends StatelessWidget {
  const _RegisterField({
    required super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.obscureText = false,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
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
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(color: theme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
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
