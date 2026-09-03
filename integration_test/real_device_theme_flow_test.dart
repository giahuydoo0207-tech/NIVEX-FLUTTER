import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nivex_flutter/app/nivex_app.dart';
import 'package:nivex_flutter/app/theme/app_theme_mode.dart';
import 'package:nivex_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Real Device End-to-End Theme Flow Test', (tester) async {
    // 1. Launch app on device
    app.main();
    await tester.pumpAndSettle();

    final controller = tester
        .widget<NivexApp>(find.byType(NivexApp))
        .controller;
    expect(controller, isNotNull);

    // Verify initial state
    expect(find.text('Minh Anh'), findsOneWidget);
    expect(find.text('500.00 USDC'), findsOneWidget);

    // 2. Open Profile Screen by tapping Avatar/Name
    await tester.tap(find.text('Minh Anh'));
    await tester.pumpAndSettle();

    expect(find.text('Cá nhân'), findsOneWidget);
    expect(find.text('Giao diện ứng dụng'), findsOneWidget);

    // 3. Open Appearance Screen
    await tester.tap(find.text('Giao diện ứng dụng'));
    await tester.pumpAndSettle();

    expect(find.text('Mặc định'), findsOneWidget);
    expect(find.text('Cyber Night'), findsOneWidget);
    expect(find.text('Blockchain Flow'), findsOneWidget);
    expect(find.text('Vietnam Future'), findsOneWidget);

    Future<void> selectTheme(String label, AppThemeMode mode) async {
      if (controller!.mode == mode) return;

      await tester.tap(find.text(label));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Đã áp dụng giao diện mới.'), findsOneWidget);
      expect(controller.mode, mode);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    }

    // Always starts with a real change, even when a previous run persisted a
    // non-default theme on the device.
    final firstMode = controller!.mode == AppThemeMode.cyberNight
        ? AppThemeMode.defaultTheme
        : AppThemeMode.cyberNight;
    await selectTheme(firstMode.label, firstMode);
    await selectTheme('Cyber Night', AppThemeMode.cyberNight);
    await selectTheme('Blockchain Flow', AppThemeMode.blockchainFlow);
    await selectTheme('Vietnam Future', AppThemeMode.vietnamFuture);

    // 7. Go back to Profile screen
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 8. Go back to Home screen
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Verify Vietnam Future is live on Home screen
    expect(find.text('500.00 USDC'), findsOneWidget);
    expect(controller.mode, AppThemeMode.vietnamFuture);
  });
}
