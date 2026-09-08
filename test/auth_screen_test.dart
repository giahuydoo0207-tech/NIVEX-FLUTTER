import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nivex_flutter/app/nivex_app.dart';
import 'package:nivex_flutter/app/theme/app_theme_mode.dart';
import 'package:nivex_flutter/app/theme/nivex_theme.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/auth/presentation/login_screen.dart';
import 'package:nivex_flutter/features/auth/presentation/register_screen.dart';
import 'package:nivex_flutter/features/auth/presentation/widgets/auth_visual_header.dart';
import 'package:nivex_flutter/features/cashout/data/cashout_auth_state_store.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_auth_service.dart';
import 'package:nivex_flutter/features/shell/presentation/app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_biometric_auth_client.dart';

void main() {
  testWidgets('production auth flow bắt đầu ở Login', (tester) async {
    await tester.pumpWidget(const NivexApp(showAuthentication: true));

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.byType(AppShell), findsNothing);
  });

  testWidgets('Login hiển thị lỗi validation cơ bản', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: NivexTheme.light, home: const LoginScreen()),
    );

    await tester.ensureVisible(find.byKey(const Key('login-submit-button')));
    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pump();
    expect(find.text('Vui lòng nhập email hoặc số điện thoại'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('login-account-field')),
      'email-sai',
    );
    await tester.enterText(
      find.byKey(const Key('login-password-field')),
      '123',
    );
    await tester.ensureVisible(find.byKey(const Key('login-submit-button')));
    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pump();
    expect(find.text('Số điện thoại chưa hợp lệ'), findsOneWidget);
    expect(find.text('Mật khẩu cần ít nhất 6 ký tự'), findsOneWidget);
  });

  testWidgets('Login có loading và chuyển vào AppShell', (tester) async {
    await tester.pumpWidget(const NivexApp(showAuthentication: true));
    await tester.enterText(
      find.byKey(const Key('login-account-field')),
      'demo@nivex.vn',
    );
    await tester.enterText(
      find.byKey(const Key('login-password-field')),
      '123456',
    );
    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pump();
    expect(find.byKey(const Key('login-loading')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets(
    'khóa phiên mở lại bằng PIN, sinh trắc học và đăng xuất về Login',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final authService = CashoutAuthService(
        biometricClient: FakeBiometricAuthClient(),
        stateStore: InMemoryCashoutAuthStateStore(),
      );

      await tester.pumpWidget(
        NivexApp(showAuthentication: true, sessionAuthService: authService),
      );
      await tester.enterText(
        find.byKey(const Key('login-account-field')),
        'demo@nivex.vn',
      );
      await tester.enterText(
        find.byKey(const Key('login-password-field')),
        '123456',
      );
      await tester.tap(find.byKey(const Key('login-submit-button')));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pump();
      expect(find.byType(AppShell), findsOneWidget);

      Future<void> expireSession() async {
        await tester.pump(const Duration(minutes: 5));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.text('Phiên làm việc đã hết hạn'), findsOneWidget);
      }

      await expireSession();
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();
      await tester.tap(find.text('Mở khóa'));
      await tester.pumpAndSettle();
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.text('Phiên làm việc đã hết hạn'), findsNothing);

      await expireSession();
      await tester.tap(find.text('Dùng sinh trắc học'));
      await tester.pumpAndSettle();
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.text('Phiên làm việc đã hết hạn'), findsNothing);

      await expireSession();
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
    },
  );

  testWidgets('Login mở Register và link đăng nhập quay lại', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: NivexTheme.light, home: const LoginScreen()),
    );
    await tester.ensureVisible(find.text('Đăng ký').last);
    await tester.tap(find.text('Đăng ký').last);
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Tạo tài khoản'), findsOneWidget);

    await tester.ensureVisible(find.text('Đăng nhập').last);
    await tester.tap(find.text('Đăng nhập').last);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Register báo mật khẩu không khớp và yêu cầu điều khoản', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: NivexTheme.light, home: const RegisterScreen()),
    );

    await tester.enterText(
      find.byKey(const Key('register-name-field')),
      'Minh Anh',
    );
    await tester.enterText(
      find.byKey(const Key('register-email-field')),
      'minhanh@nivex.vn',
    );
    await tester.enterText(
      find.byKey(const Key('register-phone-field')),
      '0912345678',
    );
    await tester.enterText(
      find.byKey(const Key('register-password-field')),
      '123456',
    );
    await tester.enterText(
      find.byKey(const Key('register-confirm-password-field')),
      '654321',
    );
    await tester.ensureVisible(find.byKey(const Key('register-submit-button')));
    await tester.tap(find.byKey(const Key('register-submit-button')));
    await tester.pump();

    expect(find.text('Mật khẩu không khớp'), findsOneWidget);
    expect(find.text('Bạn cần đồng ý với Điều khoản sử dụng'), findsOneWidget);
  });

  testWidgets('Register hợp lệ hiển thị loading và gọi mock callback', (
    tester,
  ) async {
    var registered = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: NivexTheme.light,
        home: RegisterScreen(onRegisterSuccess: () => registered = true),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('register-name-field')),
      'Minh Anh',
    );
    await tester.enterText(
      find.byKey(const Key('register-email-field')),
      'minhanh@nivex.vn',
    );
    await tester.enterText(
      find.byKey(const Key('register-phone-field')),
      '0912345678',
    );
    await tester.enterText(
      find.byKey(const Key('register-password-field')),
      '123456',
    );
    await tester.enterText(
      find.byKey(const Key('register-confirm-password-field')),
      '123456',
    );
    await tester.ensureVisible(
      find.byKey(const Key('register-terms-checkbox')),
    );
    await tester.tap(find.byKey(const Key('register-terms-checkbox')));
    await tester.ensureVisible(find.byKey(const Key('register-submit-button')));
    await tester.tap(find.byKey(const Key('register-submit-button')));
    await tester.pump();
    expect(find.byKey(const Key('register-loading')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    expect(registered, isTrue);
  });

  testWidgets('Login và Register không overflow ở chiều rộng 320px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final screen in const <Widget>[LoginScreen(), RegisterScreen()]) {
      await tester.pumpWidget(
        MaterialApp(theme: NivexTheme.light, home: screen),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Login và Register dùng đúng token của cả 4 theme', (
    tester,
  ) async {
    for (final mode in AppThemeMode.values) {
      final appTheme = NivexTheme.forMode(mode);
      final tokens = appTheme.extension<NivexThemeExtension>()!;

      for (final entry in <({Widget screen, Key headerKey, Key fieldKey})>[
        (
          screen: const LoginScreen(),
          headerKey: const Key('login-theme-header'),
          fieldKey: const Key('login-account-field'),
        ),
        (
          screen: const RegisterScreen(),
          headerKey: const Key('register-theme-header'),
          fieldKey: const Key('register-name-field'),
        ),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey('${mode.name}-${entry.headerKey}'),
            theme: appTheme,
            home: entry.screen,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
          tokens.background,
        );

        final header = tester.widget<AuthVisualHeader>(
          find.byKey(entry.headerKey),
        );
        expect(header.subtitle, isNotEmpty);
        final pattern = tester.widget<CustomPaint>(
          find.descendant(
            of: find.byKey(entry.headerKey),
            matching: find.byKey(const Key('auth-signal-pattern')),
          ),
        );
        final painter = pattern.painter! as AuthSignalPainter;
        expect(painter.primary, tokens.primary);
        expect(painter.secondary, tokens.secondary);
        expect(painter.lineColor, tokens.border);

        final field = tester.widget<TextField>(
          find.descendant(
            of: find.byKey(entry.fieldKey),
            matching: find.byType(TextField),
          ),
        );
        expect(field.decoration!.fillColor, tokens.surfaceSubtle);

        final submitButton = tester.widget<FilledButton>(
          find.byType(FilledButton),
        );
        expect(
          submitButton.style?.backgroundColor?.resolve(<WidgetState>{}),
          tokens.primary,
        );
      }
    }
  });
}
