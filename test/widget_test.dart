import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nivex_flutter/app/nivex_app.dart';
import 'package:nivex_flutter/app/theme/app_theme_mode.dart';
import 'package:nivex_flutter/app/theme/nivex_theme.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/app/theme/theme_controller.dart';
import 'package:nivex_flutter/app/theme/theme_store.dart';
import 'package:nivex_flutter/features/help/presentation/help_screen.dart';
import 'package:nivex_flutter/features/home/presentation/home_screen.dart';
import 'package:nivex_flutter/features/home/presentation/widgets/nivex_education_section.dart';
import 'package:nivex_flutter/features/profile/presentation/appearance_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/bank_account_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/legal_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/notification_settings_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/personal_info_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/profile_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/verification_screen.dart';
import 'package:nivex_flutter/features/receive/presentation/receive_usdc_screen.dart';
import 'package:nivex_flutter/features/shell/domain/app_tab_controller.dart';
import 'package:qr_flutter/qr_flutter.dart';

double _luminance(Color c) => c.computeLuminance();

double _contrastRatio(Color c1, Color c2) {
  final l1 = _luminance(c1);
  final l2 = _luminance(c2);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  setUp(() {
    AppTabController.index.value = 0;
  });

  // =========================================================================
  // 1. ORIGINAL FUNCTIONAL COVERAGE (13 TESTS)
  // =========================================================================

  testWidgets('hiển thị Home NIVEX bằng tiếng Việt', (tester) async {
    await tester.pumpWidget(const NivexApp());
    expect(find.text('Trang chủ'), findsWidgets);
    expect(find.text('Ví'), findsOneWidget);
    expect(find.text('Giao dịch'), findsOneWidget);
    expect(find.text('Minh Anh'), findsOneWidget);
    expect(find.text('500.00 USDC'), findsOneWidget);
    expect(find.text('≈ 12.500.000 VND'), findsOneWidget);
    expect(find.text('Solana Devnet'), findsOneWidget);
    expect(find.text('Hiểu nhanh cùng NIVEX'), findsOneWidget);
    expect(find.text('NIVEX hoạt động thế nào?'), findsOneWidget);
    expect(
      find.textContaining('Bản demo hackathon · Solana Devnet'),
      findsOneWidget,
    );
    expect(find.text('Nhận USDC'), findsWidgets);
    expect(find.text('Rút VND'), findsWidgets);
    expect(find.text('Lịch sử'), findsOneWidget);
    expect(find.text('Quote'), findsOneWidget);
    expect(find.text('Trợ giúp'), findsOneWidget);
  });

  testWidgets('điều hướng được giữa ba bottom tabs', (tester) async {
    await tester.pumpWidget(const NivexApp());

    // Tab 0: Home is visible
    expect(find.text('500.00 USDC'), findsOneWidget);

    // Tab 1: Tap Ví
    await tester.tap(find.text('Ví'));
    await tester.pumpAndSettle();
    expect(find.text('Ví của bạn'), findsOneWidget);
    expect(find.text('Demo Mode • Solana Devnet'), findsOneWidget);
    expect(find.text('880,00 USDC'), findsWidgets);
    expect(find.text('ĐỊA CHỈ VÍ SOLANA DEVNET'), findsOneWidget);

    // Tab 2: Tap Giao dịch
    await tester.tap(find.text('Giao dịch'));
    await tester.pumpAndSettle();
    expect(find.text('Lịch sử hoạt động của ví'), findsOneWidget);
    expect(find.text('Tất cả'), findsOneWidget);
    expect(find.text('Tiền vào'), findsOneWidget);
    expect(find.text('Tiền ra'), findsOneWidget);

    // Tab 0: Back to Home
    await tester.tap(find.text('Trang chủ'));
    await tester.pumpAndSettle();
    expect(find.text('500.00 USDC'), findsOneWidget);
  });

  testWidgets('nhấn avatar hoặc tên Minh Anh đều mở ProfileScreen', (
    tester,
  ) async {
    await tester.pumpWidget(const NivexApp());

    // 1. Tap Avatar icon
    await tester.tap(find.byIcon(Icons.account_circle_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Cá nhân'), findsOneWidget);
    expect(find.textContaining('NVX-000001'), findsOneWidget);

    // Pop back to Home
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsNothing);

    // 2. Tap Name text
    await tester.tap(find.text('Minh Anh'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('minh.anh@nivex.demo'), findsOneWidget);
  });

  testWidgets('ProfileScreen hiển thị đầy đủ các phần và thông tin', (
    tester,
  ) async {
    await tester.pumpWidget(const NivexApp());

    await tester.tap(find.text('Minh Anh'));
    await tester.pumpAndSettle();

    // Header info
    expect(find.text('MA'), findsOneWidget);
    expect(find.text('Minh Anh'), findsWidgets);
    expect(find.text('minh.anh@nivex.demo'), findsOneWidget);
    expect(find.text('Đã xác minh'), findsWidgets);
    expect(find.textContaining('NVX-000001'), findsOneWidget);

    // Section 1: TÀI KHOẢN & BẢO MẬT
    expect(find.text('TÀI KHOẢN & BẢO MẬT'), findsOneWidget);
    expect(find.text('Thông tin cá nhân'), findsOneWidget);
    expect(find.text('Trạng thái xác minh'), findsOneWidget);
    expect(find.text('Địa chỉ ví Solana'), findsOneWidget);
    expect(find.text('Tài khoản nhận VND'), findsOneWidget);

    // Section 2: CÀI ĐẶT ỨNG DỤNG
    expect(find.text('CÀI ĐẶT ỨNG DỤNG'), findsOneWidget);
    expect(find.text('Thông báo'), findsOneWidget);
    expect(find.text('Giao diện ứng dụng'), findsOneWidget);

    // Section 3: HỖ TRỢ & PHÁP LÝ
    expect(find.text('HỖ TRỢ & PHÁP LÝ'), findsOneWidget);
    expect(find.text('Trung tâm trợ giúp'), findsOneWidget);
    expect(find.text('Điều khoản & quyền riêng tư'), findsOneWidget);
    expect(find.text('Phiên bản ứng dụng'), findsOneWidget);

    // Action: Đăng xuất
    await tester.ensureVisible(find.text('Đăng xuất'));
    expect(find.text('Đăng xuất'), findsOneWidget);
  });

  testWidgets('sao chép ID NIVEX trả đúng NVX-000001', (tester) async {
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copiedText = (methodCall.arguments as Map)['text'] as String?;
          return null;
        }
        return null;
      },
    );

    await tester.pumpWidget(const NivexApp());

    await tester.tap(find.text('Minh Anh'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Sao chép'));
    await tester.tap(find.text('Sao chép'));
    await tester.pump();
    expect(copiedText, equals('NVX-000001'));
    expect(find.text('Đã sao chép NIVEX ID'), findsOneWidget);
  });

  testWidgets('tất cả các hàng cài đặt mở đúng màn hình con', (tester) async {
    await tester.pumpWidget(const NivexApp());

    await tester.tap(find.text('Minh Anh'));
    await tester.pumpAndSettle();

    // 1. Thông tin cá nhân
    await tester.ensureVisible(find.text('Thông tin cá nhân'));
    await tester.tap(find.text('Thông tin cá nhân'));
    await tester.pumpAndSettle();
    expect(find.byType(PersonalInfoScreen), findsOneWidget);
    expect(find.text('Hồ sơ người dùng demo'), findsOneWidget);
    expect(find.text('Tiếng Việt'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // 2. Trạng thái xác minh
    await tester.ensureVisible(find.text('Trạng thái xác minh'));
    await tester.tap(find.text('Trạng thái xác minh'));
    await tester.pumpAndSettle();
    expect(find.byType(VerificationScreen), findsOneWidget);
    expect(find.text('Định danh Cấp 2'), findsOneWidget);
    expect(find.text('Hạn mức giao dịch: 50.000 USDC / ngày'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // 3. Địa chỉ ví Solana -> mở ReceiveUsdcScreen
    await tester.ensureVisible(find.text('Địa chỉ ví Solana'));
    await tester.tap(find.text('Địa chỉ ví Solana'));
    await tester.pumpAndSettle();
    expect(find.byType(ReceiveUsdcScreen), findsOneWidget);
    expect(
      find.text('7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU'),
      findsOneWidget,
    );
    expect(find.byType(QrImageView), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // 4. Tài khoản nhận VND
    await tester.ensureVisible(find.text('Tài khoản nhận VND'));
    await tester.tap(find.text('Tài khoản nhận VND'));
    await tester.pumpAndSettle();
    expect(find.byType(BankAccountScreen), findsOneWidget);
    expect(find.text('Vietcombank'), findsOneWidget);
    expect(find.text('•••• 2868'), findsOneWidget);
    expect(find.text('MINH ANH'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // 5. Thông báo
    await tester.ensureVisible(find.text('Thông báo'));
    await tester.tap(find.text('Thông báo'));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationSettingsScreen), findsOneWidget);
    expect(find.text('Giao dịch nạp/rút'), findsOneWidget);
    expect(find.text('Biến động số dư'), findsOneWidget);
    expect(find.text('Tin tức & Khuyến mãi'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // 6. Giao diện ứng dụng
    await tester.ensureVisible(find.text('Giao diện ứng dụng'));
    await tester.tap(find.text('Giao diện ứng dụng'));
    await tester.pumpAndSettle();
    expect(find.byType(AppearanceScreen), findsOneWidget);
    expect(find.text('Mặc định'), findsOneWidget);
    expect(find.text('Đang dùng'), findsOneWidget);
    expect(find.text('Cyber Night'), findsOneWidget);
    expect(find.text('Blockchain Flow'), findsOneWidget);
    expect(find.text('Vietnam Future'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // 7. Trung tâm trợ giúp
    await tester.ensureVisible(find.text('Trung tâm trợ giúp'));
    await tester.tap(find.text('Trung tâm trợ giúp'));
    await tester.pumpAndSettle();
    expect(find.byType(HelpScreen), findsOneWidget);
    expect(find.text('CÂU HỎI THƯỜNG GẶP'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // 8. Điều khoản & quyền riêng tư
    await tester.ensureVisible(find.text('Điều khoản & quyền riêng tư'));
    await tester.tap(find.text('Điều khoản & quyền riêng tư'));
    await tester.pumpAndSettle();
    expect(find.byType(LegalScreen), findsOneWidget);
    expect(find.text('1. Mục đích thử nghiệm MVP'), findsOneWidget);
    expect(find.text('2. Bảo mật dữ liệu người dùng'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  });

  testWidgets('công tắc thông báo thay đổi trạng thái cục bộ', (tester) async {
    await tester.pumpWidget(const NivexApp());

    await tester.tap(find.text('Minh Anh'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Thông báo'));
    await tester.tap(find.text('Thông báo'));
    await tester.pumpAndSettle();

    final switchTiles = find.byType(SwitchListTile);
    expect(switchTiles, findsNWidgets(3));

    // Verify initial states
    expect(tester.widget<SwitchListTile>(switchTiles.at(0)).value, isTrue);
    expect(tester.widget<SwitchListTile>(switchTiles.at(1)).value, isTrue);
    expect(tester.widget<SwitchListTile>(switchTiles.at(2)).value, isFalse);

    // Toggle first switch tile
    await tester.tap(switchTiles.at(0));
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(switchTiles.at(0)).value, isFalse);

    // Toggle back
    await tester.tap(switchTiles.at(0));
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(switchTiles.at(0)).value, isTrue);

    // Toggle third switch tile
    await tester.tap(switchTiles.at(2));
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(switchTiles.at(2)).value, isTrue);
  });

  testWidgets('đăng xuất yêu cầu xác nhận qua dialog', (tester) async {
    await tester.pumpWidget(const NivexApp());

    await tester.tap(find.text('Minh Anh'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Đăng xuất'));
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();

    // Dialog appears
    expect(find.text('Đăng xuất'), findsWidgets);
    expect(
      find.text(
        'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản demo này không?',
      ),
      findsOneWidget,
    );

    // Tap Hủy -> cancels
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản demo này không?',
      ),
      findsNothing,
    );
    expect(find.byType(ProfileScreen), findsOneWidget);

    // Tap Đăng xuất again -> confirm
    await tester.ensureVisible(find.text('Đăng xuất'));
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng xuất'));
    await tester.pump();
    expect(find.text('Đã đăng xuất phiên demo.'), findsOneWidget);
  });

  testWidgets(
    'flow Nhận USDC hiển thị QR thật, nhãn Demo Mode, lưu ý bảo mật và Android Back',
    (tester) async {
      String? copiedText;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            copiedText = (methodCall.arguments as Map)['text'] as String?;
            return null;
          }
          return null;
        },
      );

      await tester.pumpWidget(const NivexApp());

      await tester.tap(find.text('Nhận USDC').first);
      await tester.pumpAndSettle();

      expect(find.text('Demo Mode • Solana Devnet'), findsOneWidget);
      expect(find.text('Địa chỉ ví USDC'), findsOneWidget);
      expect(find.text('Mạng Solana Devnet'), findsOneWidget);
      expect(
        find.text('7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU'),
        findsOneWidget,
      );

      expect(find.byType(QrImageView), findsOneWidget);
      final qrValidation = QrValidator.validate(
        data: ReceiveUsdcScreen.address,
        version: QrVersions.auto,
      );
      expect(qrValidation.status, equals(QrValidationStatus.valid));
      expect(qrValidation.qrCode, isNotNull);

      expect(
        find.textContaining('Chỉ gửi USDC qua mạng Solana'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Gửi token qua mạng khác có thể khiến tài sản không thể khôi phục',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Không gửi tài sản thật'), findsOneWidget);

      await tester.tap(find.text('Sao chép'));
      await tester.pump();
      expect(
        copiedText,
        equals('7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU'),
      );

      // Test Android back
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Minh Anh'), findsOneWidget);
    },
  );

  testWidgets('sao chép địa chỉ ví từ màn Ví trả đúng địa chỉ Solana đầy đủ', (
    tester,
  ) async {
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copiedText = (methodCall.arguments as Map)['text'] as String?;
          return null;
        }
        return null;
      },
    );

    await tester.pumpWidget(const NivexApp());

    await tester.tap(find.text('Ví'));
    await tester.pumpAndSettle();
    expect(find.text('Demo Mode • Solana Devnet'), findsOneWidget);
    expect(find.text('7xKXtg...sgAsU'), findsOneWidget);

    await tester.drag(
      find.byKey(const PageStorageKey('wallet-scroll')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Sao chép'));
    await tester.pump();
    expect(copiedText, equals('7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU'));
  });

  testWidgets('cashout chọn ngân hàng và đi đến biên nhận', (tester) async {
    await tester.pumpWidget(const NivexApp());

    await tester.tap(find.text('Rút VND').first);
    await tester.pumpAndSettle();
    expect(find.text('Dùng tối đa'), findsOneWidget);

    expect(find.text('Vietcombank'), findsWidgets);
    expect(find.text('Techcombank'), findsOneWidget);
    expect(find.text('ACB'), findsWidgets);
    expect(find.text('MB Bank'), findsOneWidget);

    await tester.tap(find.text('Techcombank'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).last, const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xem báo giá quy đổi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Báo giá quy đổi'), findsOneWidget);
    expect(
      find.textContaining('Tỷ giá tham khảo còn hiệu lực:'),
      findsOneWidget,
    );

    await tester.drag(find.byType(ListView).last, const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận payout mô phỏng'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Đang xử lý payout mô phỏng'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Payout VND mô phỏng hoàn tất'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Về Trang chủ'));
    await tester.pumpAndSettle();
    expect(find.text('Minh Anh'), findsOneWidget);
  });

  testWidgets('quote hết hạn sau 30 giây và có thể làm mới', (tester) async {
    await tester.pumpWidget(const NivexApp());

    await tester.ensureVisible(find.text('Quote'));
    await tester.tap(find.text('Quote'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(
      find.textContaining('Tỷ giá tham khảo còn hiệu lực: 30s'),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 30));
    expect(find.text('Báo giá đã hết hạn'), findsOneWidget);

    final confirm = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Xác nhận payout mô phỏng'),
    );
    expect(confirm.onPressed, isNull);

    await tester.tap(find.text('Làm mới'));
    await tester.pump();
    expect(
      find.textContaining('Tỷ giá tham khảo còn hiệu lực: 30s'),
      findsOneWidget,
    );
  });

  testWidgets('không overflow ở chiều rộng 320px', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NivexApp());
    expect(tester.takeException(), isNull);

    for (final label in ['Ví', 'Giao dịch', 'Trang chủ']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      final error = tester.takeException();
      expect(error, isNull, reason: 'Tab overflow');
    }

    // Check Profile on 320px
    await tester.tap(find.text('Minh Anh'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Check Profile child screens on 320px
    for (final screenRow in [
      'Thông tin cá nhân',
      'Trạng thái xác minh',
      'Tài khoản nhận VND',
      'Thông báo',
      'Giao diện ứng dụng',
      'Điều khoản & quyền riêng tư',
    ]) {
      await tester.ensureVisible(find.text(screenRow));
      await tester.tap(find.text(screenRow));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }
  });

  // =========================================================================
  // 2. THEME SUITE & PERSISTENCE COVERAGE (8 TESTS)
  // =========================================================================

  testWidgets('AppearanceScreen có đúng 4 lựa chọn theme', (tester) async {
    final store = FakeThemePreferenceStore();
    final controller = ThemeController(store: store);

    await tester.pumpWidget(
      MaterialApp(
        theme: NivexTheme.forMode(AppThemeMode.defaultTheme),
        home: Scaffold(body: AppearanceScreen(themeController: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mặc định'), findsOneWidget);
    expect(find.text('Cyber Night'), findsOneWidget);
    expect(find.text('Blockchain Flow'), findsOneWidget);
    expect(find.text('Vietnam Future'), findsOneWidget);

    // Confirm deprecated options are deleted
    expect(find.text('Minimal Light'), findsNothing);
    expect(find.text('Abstract Finance'), findsNothing);

    controller.dispose();
  });

  testWidgets(
    'chuyển liên tục giữa cả 4 theme cập nhật AppThemeMode và lưu storage',
    (tester) async {
      final store = FakeThemePreferenceStore();
      final controller = ThemeController(store: store);
      await controller.load();

      await tester.pumpWidget(NivexApp(controller: controller));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Minh Anh'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Giao diện ứng dụng'));
      await tester.tap(find.text('Giao diện ứng dụng'));
      await tester.pumpAndSettle();

      final modesToTest = [
        ('Cyber Night', AppThemeMode.cyberNight),
        ('Blockchain Flow', AppThemeMode.blockchainFlow),
        ('Vietnam Future', AppThemeMode.vietnamFuture),
        ('Mặc định', AppThemeMode.defaultTheme),
      ];

      for (final (label, expectedMode) in modesToTest) {
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(controller.mode, equals(expectedMode));
        expect(store.storedValue, equals(expectedMode.toStorageString()));
      }

      controller.dispose();
    },
  );

  testWidgets('khởi động lại app khôi phục đúng theme đã lưu', (tester) async {
    final store = FakeThemePreferenceStore('vietnamFuture');
    final controller = ThemeController(store: store);
    await controller.load();

    expect(controller.mode, equals(AppThemeMode.vietnamFuture));

    await tester.pumpWidget(NivexApp(controller: controller));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(HomeScreen));
    expect(context.nivexTheme.mode, equals(AppThemeMode.vietnamFuture));

    controller.dispose();
  });

  testWidgets('fallback về Mặc định khi giá trị lưu trữ không hợp lệ', (
    tester,
  ) async {
    final store = FakeThemePreferenceStore('corrupted_unknown_theme_string');
    final controller = ThemeController(store: store);
    await controller.load();

    expect(controller.mode, equals(AppThemeMode.defaultTheme));

    controller.dispose();
  });

  testWidgets('xử lý lỗi lưu storage bằng rollback và hiển thị thông báo lỗi', (
    tester,
  ) async {
    final store = FakeThemePreferenceStore('defaultTheme', true);
    final controller = ThemeController(store: store);
    await controller.load();

    await tester.pumpWidget(NivexApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Minh Anh'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Giao diện ứng dụng'));
    await tester.tap(find.text('Giao diện ứng dụng'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cyber Night'));
    await tester.tap(find.text('Cyber Night'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Mode must rollback to defaultTheme
    expect(controller.mode, equals(AppThemeMode.defaultTheme));

    // SnackBar error displayed
    expect(
      find.text('Không thể lưu giao diện. Vui lòng thử lại.'),
      findsOneWidget,
    );

    controller.dispose();
  });

  testWidgets('kiểm tra độ tương phản relative luminance trên cả 4 theme', (
    tester,
  ) async {
    for (final mode in AppThemeMode.values) {
      final ext = NivexTheme.forMode(mode).extension<NivexThemeExtension>()!;

      // 1. Text Primary on Background: WCAG AA normal text >= 4.5:1
      final ratioTextBg = _contrastRatio(ext.textPrimary, ext.background);
      expect(
        ratioTextBg,
        greaterThanOrEqualTo(4.5),
        reason:
            'textPrimary on background failed WCAG in ${mode.name}: $ratioTextBg',
      );

      // 2. Text Primary on Surface: WCAG AA normal text >= 4.5:1
      final ratioTextSurface = _contrastRatio(ext.textPrimary, ext.surface);
      expect(
        ratioTextSurface,
        greaterThanOrEqualTo(4.5),
        reason:
            'textPrimary on surface failed WCAG in ${mode.name}: $ratioTextSurface',
      );

      // 3. Primary accent on surface: UI component / large text >= 3.0:1
      final ratioPrimarySurface = _contrastRatio(ext.primary, ext.surface);
      expect(
        ratioPrimarySurface,
        greaterThanOrEqualTo(3.0),
        reason:
            'primary on surface failed 3.0:1 in ${mode.name}: $ratioPrimarySurface',
      );
    }
  });

  testWidgets(
    'dữ liệu Solana và tài khoản ngân hàng không thay đổi qua các theme',
    (tester) async {
      for (final mode in AppThemeMode.values) {
        AppTabController.index.value = 0;
        final store = FakeThemePreferenceStore(mode.name);
        final controller = ThemeController(store: store);
        await controller.load();

        await tester.pumpWidget(
          NivexApp(key: UniqueKey(), controller: controller),
        );
        await tester.pumpAndSettle();

        // Home data check
        expect(find.text('500.00 USDC'), findsOneWidget);
        expect(find.text('≈ 12.500.000 VND'), findsOneWidget);
        expect(find.text('Solana Devnet'), findsOneWidget);

        // Receive screen check
        await tester.tap(find.text('Nhận USDC').first);
        await tester.pumpAndSettle();
        expect(
          find.text('7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU'),
          findsOneWidget,
        );
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // Profile screen check
        await tester.tap(find.text('Minh Anh'));
        await tester.pumpAndSettle();
        expect(find.textContaining('NVX-000001'), findsOneWidget);

        // Bank account check
        await tester.ensureVisible(find.text('Tài khoản nhận VND'));
        await tester.tap(find.text('Tài khoản nhận VND'));
        await tester.pumpAndSettle();
        expect(find.text('Vietcombank'), findsOneWidget);
        expect(find.text('•••• 2868'), findsOneWidget);

        controller.dispose();
      }
    },
  );

  testWidgets('không overflow ở chiều rộng 320px cho cả 4 theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final mode in AppThemeMode.values) {
      AppTabController.index.value = 0;
      final store = FakeThemePreferenceStore(mode.name);
      final controller = ThemeController(store: store);
      await controller.load();

      await tester.pumpWidget(
        NivexApp(key: UniqueKey(), controller: controller),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Home 320px overflow in ${mode.name}',
      );

      await tester.tap(find.text('Ví'));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Wallet 320px overflow in ${mode.name}',
      );

      await tester.tap(find.text('Giao dịch'));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Transactions 320px overflow in ${mode.name}',
      );

      await tester.tap(find.text('Trang chủ'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Minh Anh'));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Profile 320px overflow in ${mode.name}',
      );

      await tester.ensureVisible(find.text('Giao diện ứng dụng'));
      await tester.tap(find.text('Giao diện ứng dụng'));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Appearance 320px overflow in ${mode.name}',
      );

      controller.dispose();
    }
  });

  // =========================================================================
  // 3. HIỂU NHANH CÙNG NIVEX (EDUCATION CAROUSEL & BANNER TESTS)
  // =========================================================================

  testWidgets('Home hiển thị Hiểu nhanh cùng NIVEX và dải minh họa đầu tiên', (
    tester,
  ) async {
    await tester.pumpWidget(const NivexApp());
    expect(find.text('Hiểu nhanh cùng NIVEX'), findsOneWidget);
    expect(find.text('1/6'), findsOneWidget);
    expect(find.text('NIVEX hoạt động thế nào?'), findsOneWidget);
    expect(find.text('USDC Devnet'), findsOneWidget);
    expect(find.text('Bên gửi'), findsOneWidget);
    expect(find.text('Payout mô phỏng'), findsOneWidget);
  });

  testWidgets('vuốt carousel cập nhật từ 1/6 sang 2/6 và đổi card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const NivexApp());
    await tester.pumpAndSettle();

    expect(find.text('1/6'), findsOneWidget);
    expect(find.text('NIVEX hoạt động thế nào?'), findsOneWidget);

    // Vuốt sang trái để chuyển trang kế tiếp
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(find.text('2/6'), findsOneWidget);
    expect(find.text('Web3 là gì?'), findsOneWidget);
  });

  testWidgets(
    'nhấn Tìm hiểu thêm mở bottom sheet chi tiết và nút Đã hiểu đóng lại',
    (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const NivexApp());
      await tester.pumpAndSettle();

      // Cuộn nhẹ để card giáo dục nằm hoàn toàn trong vùng bấm
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -180),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tìm hiểu thêm').first);
      await tester.pumpAndSettle();

      expect(find.text('ĐIỀU CẦN NHỚ'), findsOneWidget);
      expect(find.text('Đã hiểu'), findsOneWidget);

      final actionRect = tester.getRect(
        find.widgetWithText(FilledButton, 'Đã hiểu'),
      );
      final logicalHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(actionRect.top, greaterThanOrEqualTo(0));
      expect(actionRect.bottom, lessThanOrEqualTo(logicalHeight));
      expect(actionRect.height, greaterThanOrEqualTo(48));

      await tester.tap(find.text('Đã hiểu'));
      await tester.pumpAndSettle();

      expect(find.text('ĐIỀU CẦN NHỚ'), findsNothing);
    },
  );

  testWidgets('Home hiển thị đầy đủ thông báo demo bắt buộc', (tester) async {
    await tester.pumpWidget(const NivexApp());

    expect(
      find.text(
        'Bản demo hackathon · Solana Devnet\n'
        'Payout VND chỉ là mô phỏng. Không có tiền thật được chuyển.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('cuộn Home 320px kiểm tra không overflow trên cả 4 theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320 * 2.0, 700 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    for (final mode in AppThemeMode.values) {
      final store = FakeThemePreferenceStore(mode.name);
      final controller = ThemeController(store: store);
      await controller.load();

      await tester.pumpWidget(
        NivexApp(key: UniqueKey(), controller: controller),
      );
      await tester.pumpAndSettle();

      // Cuộn trang để hiển thị trọn vẹn khu vực giáo dục và banner
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -350),
      );
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: 'Education scroll 320px overflow in ${mode.name}',
      );

      controller.dispose();
    }
  });

  testWidgets(
    'bottom navigation không che banner hoặc story card khi cuộn hết trang',
    (tester) async {
      tester.view.physicalSize = const Size(360 * 2.0, 700 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const NivexApp());
      await tester.pumpAndSettle();

      // Cuộn xuống hết trang
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Bản demo hackathon · Solana Devnet'),
        findsOneWidget,
      );
      expect(find.text('Trang chủ'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  test('timeline animation tiến triển đúng 7 giai đoạn theo brief', () {
    final t0 = EducationAnimationTimeline(0.0);
    expect(t0.node1Opacity, closeTo(0.0, 0.001));
    expect(t0.line1Progress, closeTo(0.0, 0.001));
    expect(t0.node2Opacity, closeTo(0.0, 0.001));
    expect(t0.line2Progress, closeTo(0.0, 0.001));
    expect(t0.node3Opacity, closeTo(0.0, 0.001));
    expect(t0.completionOpacity, closeTo(0.0, 0.001));

    // Giai đoạn 1: 0 - 15%
    final t1 = EducationAnimationTimeline(0.15);
    expect(t1.node1Opacity, closeTo(1.0, 0.001));
    expect(t1.node1Scale, closeTo(1.0, 0.001));
    expect(t1.line1Progress, closeTo(0.0, 0.001));

    // Giai đoạn 2: 15 - 35%
    final t2 = EducationAnimationTimeline(0.35);
    expect(t2.line1Progress, closeTo(1.0, 0.001));
    expect(t2.node2Opacity, closeTo(0.0, 0.001));

    // Giai đoạn 3: 35 - 50%
    final t3 = EducationAnimationTimeline(0.50);
    expect(t3.node2Opacity, closeTo(1.0, 0.001));
    expect(t3.line2Progress, closeTo(0.0, 0.001));

    // Giai đoạn 4: 50 - 70%
    final t4 = EducationAnimationTimeline(0.70);
    expect(t4.line2Progress, closeTo(1.0, 0.001));
    expect(t4.node3Opacity, closeTo(0.0, 0.001));

    // Giai đoạn 5: 70 - 85%
    final t5 = EducationAnimationTimeline(0.85);
    expect(t5.node3Opacity, closeTo(1.0, 0.001));
    expect(t5.completionOpacity, closeTo(0.0, 0.001));

    // Giai đoạn 6: 85 - 95%
    final t6 = EducationAnimationTimeline(0.95);
    expect(t6.completionOpacity, closeTo(1.0, 0.001));

    // Giai đoạn 7: 95 - 100% (giữ trạng thái cuối)
    final t7 = EducationAnimationTimeline(1.0);
    expect(t7.node1Opacity, closeTo(1.0, 0.001));
    expect(t7.line1Progress, closeTo(1.0, 0.001));
    expect(t7.node2Opacity, closeTo(1.0, 0.001));
    expect(t7.line2Progress, closeTo(1.0, 0.001));
    expect(t7.node3Opacity, closeTo(1.0, 0.001));
    expect(t7.completionOpacity, closeTo(1.0, 0.001));
  });

  testWidgets(
    'chế độ giảm chuyển động (disableAnimations) hiển thị trạng thái hoàn chỉnh ngay',
    (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: NivexApp(),
        ),
      );
      await tester.pump();

      expect(find.text('Hiểu nhanh cùng NIVEX'), findsOneWidget);
      expect(find.text('NIVEX hoạt động thế nào?'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'bottom sheet có nút phát lại với tooltip và có thể nhấn phát lại',
    (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const NivexApp());
      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -180),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tìm hiểu thêm').first);
      await tester.pumpAndSettle();

      // Nút phát lại có mặt và có tooltip
      final replayFinder = find.byTooltip('Phát lại');
      expect(replayFinder, findsOneWidget);

      await tester.tap(replayFinder);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('ĐIỀU CẦN NHỚ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('đóng bottom sheet tiếp tục animation card chưa hoàn tất', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const NivexApp());
    await tester.pump(const Duration(milliseconds: 700));
    await tester.ensureVisible(find.text('Tìm hiểu thêm').first);
    await tester.pump(const Duration(milliseconds: 200));

    double homeProgress() {
      final semantics = tester.widget<Semantics>(
        find
            .byWidgetPredicate(
              (widget) =>
                  widget is Semantics &&
                  widget.properties.label ==
                      'Tiến trình minh họa NIVEX hoạt động thế nào?',
            )
            .first,
      );
      return double.parse(semantics.properties.value!.split(' ').first);
    }

    final progressBeforeSheet = homeProgress();
    expect(progressBeforeSheet, greaterThan(0));
    expect(progressBeforeSheet, lessThan(100));

    await tester.tap(find.text('Tìm hiểu thêm').first);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.text('Đã hiểu'));
    await tester.pump(const Duration(milliseconds: 350));

    final progressWhenClosed = homeProgress();
    expect(progressWhenClosed, greaterThanOrEqualTo(progressBeforeSheet));
    expect(progressWhenClosed, lessThan(100));

    await tester.pump(const Duration(milliseconds: 500));
    expect(homeProgress(), greaterThan(progressWhenClosed));
  });

  testWidgets(
    'animation không làm thay đổi kích thước hay vị trí của bottom navigation',
    (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const NivexApp());
      await tester.pump();

      final initialNavRect = tester.getRect(find.byType(NavigationBar));

      // Bơm tiến trình animation qua từng mốc thời gian
      await tester.pump(const Duration(seconds: 1));
      expect(tester.getRect(find.byType(NavigationBar)), initialNavRect);

      await tester.pump(const Duration(seconds: 2));
      expect(tester.getRect(find.byType(NavigationBar)), initialNavRect);

      await tester.pump(const Duration(seconds: 3));
      expect(tester.getRect(find.byType(NavigationBar)), initialNavRect);

      await tester.pump(const Duration(seconds: 2));
      expect(tester.getRect(find.byType(NavigationBar)), initialNavRect);
    },
  );

  testWidgets(
    'vuốt đến card thứ 6 Tình huống minh họa và mở quy trình tuần tự',
    (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const NivexApp());
      await tester.pumpAndSettle();

      // Vuốt liên tục 5 lần để đến card thứ 6
      for (int i = 0; i < 5; i++) {
        await tester.drag(find.byType(PageView), const Offset(-320, 0));
        await tester.pumpAndSettle();
      }

      expect(find.text('6/6'), findsOneWidget);
      expect(find.text('Tình huống minh họa'), findsOneWidget);

      // Cuộn nhẹ để card nằm trong vùng tương tác
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -180),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tình huống minh họa'));
      await tester.pumpAndSettle();

      expect(find.text('QUY TRÌNH TUẦN TỰ MINH HỌA'), findsOneWidget);
      expect(
        find.text('Bên gửi tạo khoản thanh toán 100 USDC'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Payout VND được đánh dấu hoàn tất trong môi trường mô phỏng',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Đây chỉ là ví dụ minh họa'), findsOneWidget);

      await tester.ensureVisible(find.text('Đã hiểu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đã hiểu'));
      await tester.pumpAndSettle();

      expect(find.text('QUY TRÌNH TUẦN TỰ MINH HỌA'), findsNothing);
    },
  );

  testWidgets(
    'nhãn trong dải minh họa cho phép tối đa 2 dòng không bị ellipsis',
    (tester) async {
      await tester.pumpWidget(const NivexApp());
      await tester.pumpAndSettle();

      final nodeTexts = tester
          .widgetList<Text>(find.byType(Text))
          .where(
            (widget) =>
                widget.data == 'Bên gửi' || widget.data == 'Payout mô phỏng',
          );
      for (final textWidget in nodeTexts) {
        expect(textWidget.maxLines, 2);
        expect(textWidget.overflow, isNot(TextOverflow.ellipsis));
      }
    },
  );
}
