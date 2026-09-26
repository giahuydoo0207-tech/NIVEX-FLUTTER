import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/auth/data/nova_auth_api.dart';
import 'package:nivex_flutter/features/auth/data/nova_auth_session_manager.dart';
import 'package:nivex_flutter/features/auth/presentation/widgets/auth_visual_header.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({super.key, this.onAuthenticated});

  final VoidCallback? onAuthenticated;

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  String? _challengeId;
  String? _debugOtp;
  bool _isSubmitting = false;

  bool get _hasChallenge => _challengeId != null;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final compact = (value ?? '').replaceAll(RegExp(r'[\s.-]'), '');
    if (!RegExp(r'^\+?\d{9,11}$').hasMatch(compact)) {
      return 'Số điện thoại chưa hợp lệ';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (!_hasChallenge) return null;
    final name = value?.trim() ?? '';
    if (name.isNotEmpty && name.length < 2) {
      return 'Họ tên chưa hợp lệ';
    }
    return null;
  }

  String? _validateCode(String? value) {
    if (!_hasChallenge) return null;
    if (!RegExp(r'^\d{6}$').hasMatch(value ?? '')) {
      return 'Nhập đủ 6 chữ số';
    }
    return null;
  }

  String _normalizedPhone() {
    final compact = _phoneController.text.replaceAll(RegExp(r'[\s.-]'), '');
    if (compact.startsWith('+')) return compact;
    if (compact.startsWith('0')) return '+84${compact.substring(1)}';
    return '+$compact';
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);
    try {
      final config = NovaApiConfig.fromBuild();
      final api = NovaAuthApi(config: config);
      try {
        if (!_hasChallenge) {
          final challenge = await api.requestPhoneOtp(
            phoneE164: _normalizedPhone(),
          );
          if (!mounted) return;
          setState(() {
            _challengeId = challenge.id;
            _debugOtp = challenge.debugOtp;
          });
          _showMessage('Mã xác minh đã được gửi.');
          return;
        }

        final session = await api.verifyPhoneOtp(
          challengeId: _challengeId!,
          code: _codeController.text,
          displayName: _nameController.text.trim(),
        );
        await SecureNovaAuthSessionStore(origin: config.baseUri.origin)
            .save(session);
      } finally {
        api.close();
      }
      if (!mounted) return;
      widget.onAuthenticated?.call();
      if (widget.onAuthenticated == null) {
        _showMessage('Đăng nhập số điện thoại thành công.');
      }
    } on ArgumentError {
      _showMessage('Đăng nhập OTP cần kết nối máy chủ Nova.');
    } on NovaApiException catch (error) {
      _showMessage(_errorMessage(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _errorMessage(NovaApiException error) => switch (error.code) {
    'connection' => 'Không thể kết nối máy chủ Nova.',
    'timeout' => 'Máy chủ phản hồi quá lâu. Hãy thử lại.',
    'invalid_response' => 'Phản hồi máy chủ không hợp lệ.',
    _ =>
      _hasChallenge
          ? 'Mã xác minh không đúng hoặc đã hết hạn.'
          : 'Không thể gửi mã xác minh.',
  };

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: theme.systemOverlayStyle,
      child: Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(
          title: const Text('Đăng nhập bằng số điện thoại'),
          backgroundColor: theme.background,
          foregroundColor: theme.textPrimary,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthVisualHeader(
                        height: 172,
                        subtitle: 'Xác minh an toàn bằng mã một lần',
                      ),
                      const SizedBox(height: 26),
                      Text(
                        _hasChallenge
                            ? 'Nhập mã xác minh'
                            : 'Xác minh số điện thoại',
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _hasChallenge
                            ? 'Nhập mã 6 chữ số. Họ tên dùng khi tạo tài khoản mới.'
                            : 'Chúng tôi sẽ gửi mã xác minh tới số của bạn.',
                        style: TextStyle(
                          color: theme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        key: const Key('phone-otp-phone-field'),
                        controller: _phoneController,
                        enabled: !_hasChallenge && !_isSubmitting,
                        keyboardType: TextInputType.phone,
                        textInputAction: _hasChallenge
                            ? TextInputAction.next
                            : TextInputAction.done,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+\s.-]'),
                          ),
                        ],
                        validator: _validatePhone,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại',
                          hintText: '0912 345 678',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      if (_hasChallenge) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const Key('phone-otp-name-field'),
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          validator: _validateName,
                          decoration: const InputDecoration(
                            labelText: 'Họ và tên',
                            hintText: 'Nhập nếu đây là tài khoản mới',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const Key('phone-otp-code-field'),
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: _validateCode,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: const InputDecoration(
                            labelText: 'Mã xác minh',
                            hintText: '000000',
                            prefixIcon: Icon(Icons.password_rounded),
                          ),
                        ),
                        if (kDebugMode && _debugOtp != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Mã thử nghiệm: $_debugOtp',
                              style: TextStyle(
                                color: theme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          key: const Key('phone-otp-submit-button'),
                          onPressed: _isSubmitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSubmitting
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : Text(
                                  _hasChallenge
                                      ? 'Xác minh và tiếp tục'
                                      : 'Gửi mã xác minh',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
