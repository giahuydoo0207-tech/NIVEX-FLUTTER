import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nivex_flutter/app/nivex_app.dart';
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

void main() {
  setUp(() => AppTabController.index.value = 0);

  testWidgets('hiển thị Home NIVEX bằng tiếng Việt', (tester) async {
    await tester.pumpWidget(const NivexApp());

    expect(find.text('Minh Anh'), findsOneWidget);
    expect(find.text('Solana Devnet'), findsOneWidget);
    expect(find.text('500.00 USDC'), findsOneWidget);
    expect(find.text('≈ 12.500.000 VND'), findsOneWidget);
    expect(find.text('Nhận USDC'), findsWidgets);
    expect(find.text('Rút VND'), findsWidgets);
    expect(find.text('Lịch sử'), findsOneWidget);
    expect(find.text('Quote'), findsOneWidget);
    expect(find.text('Trợ giúp'), findsOneWidget);
    expect(find.text('Chào'), findsNothing);
  });

  testWidgets('điều hướng được giữa ba bottom tabs', (tester) async {
    await tester.pumpWidget(const NivexApp());

    expect(find.byType(NavigationDestination), findsNWidgets(3));
    expect(find.text('Thị trường'), findsNothing);
    expect(find.text('Cá nhân'), findsNothing);

    await tester.tap(find.text('Ví'));
    await tester.pumpAndSettle();
    expect(find.text('Ví của bạn'), findsOneWidget);

    await tester.tap(find.text('Giao dịch'));
    await tester.pumpAndSettle();
    expect(find.text('Lịch sử hoạt động của ví'), findsOneWidget);

    await tester.tap(find.text('Trang chủ'));
    await tester.pumpAndSettle();
    expect(find.text('Minh Anh'), findsOneWidget);
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
    expect(find.text('Minh Anh'), findsOneWidget);
    expect(find.text('minh.anh@nivex.demo'), findsOneWidget);
    expect(find.text('Đã xác minh'), findsWidgets);
    expect(find.textContaining('NVX-000001'), findsOneWidget);

    // Sections
    expect(find.text('Tài khoản'), findsOneWidget);
    expect(find.text('Thông tin cá nhân'), findsOneWidget);
    expect(find.text('Trạng thái xác minh'), findsOneWidget);
    expect(find.text('Địa chỉ ví Solana'), findsOneWidget);
    expect(find.text('Tài khoản nhận VND'), findsOneWidget);

    expect(find.text('Tuỳ chỉnh'), findsOneWidget);
    expect(find.text('Thông báo'), findsOneWidget);
    expect(find.text('Giao diện ứng dụng'), findsOneWidget);

    expect(find.text('Hỗ trợ và thông tin'), findsOneWidget);
    expect(find.text('Trung tâm trợ giúp'), findsOneWidget);
    expect(find.text('Điều khoản & quyền riêng tư'), findsOneWidget);
    expect(find.text('Phiên bản ứng dụng'), findsOneWidget);
    expect(find.text('v0.1.0 Demo'), findsOneWidget);

    expect(find.text('Hành động tài khoản'), findsOneWidget);
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

    await tester.tap(find.text('Sao chép'));
    await tester.pump();
    expect(copiedText, equals('NVX-000001'));
    expect(find.text('Đã sao chép ID NIVEX.'), findsOneWidget);
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
    expect(find.text('Demo verified'), findsOneWidget);
    expect(find.text('NIVEX MVP không thực hiện KYC thật.'), findsOneWidget);
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
    expect(find.text('Minh A.'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // 5. Thông báo
    await tester.ensureVisible(find.text('Thông báo'));
    await tester.tap(find.text('Thông báo'));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationSettingsScreen), findsOneWidget);
    expect(find.text('Thông báo giao dịch'), findsOneWidget);
    expect(find.text('Cập nhật sản phẩm'), findsOneWidget);
    expect(find.text('Nhắc báo giá sắp hết hạn'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // 6. Giao diện ứng dụng
    await tester.ensureVisible(find.text('Giao diện ứng dụng'));
    await tester.tap(find.text('Giao diện ứng dụng'));
    await tester.pumpAndSettle();
    expect(find.byType(AppearanceScreen), findsOneWidget);
    expect(find.text('Mặc định'), findsOneWidget);
    expect(find.text('Đang dùng'), findsOneWidget);
    expect(find.text('Minimal Light'), findsOneWidget);
    expect(find.text('Cyber Night'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // 7. Trung tâm trợ giúp
    await tester.ensureVisible(find.text('Trung tâm trợ giúp'));
    await tester.tap(find.text('Trung tâm trợ giúp'));
    await tester.pumpAndSettle();
    expect(find.text('Câu hỏi thường gặp'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // 8. Điều khoản & quyền riêng tư
    await tester.ensureVisible(find.text('Điều khoản & quyền riêng tư'));
    await tester.tap(find.text('Điều khoản & quyền riêng tư'));
    await tester.pumpAndSettle();
    expect(find.byType(LegalScreen), findsOneWidget);
    expect(find.text('Điều khoản sử dụng'), findsOneWidget);
    expect(find.text('Chính sách quyền riêng tư'), findsOneWidget);
    expect(find.text('NIVEX là prototype hackathon'), findsOneWidget);
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

    // Verify initial true state
    expect(tester.widget<SwitchListTile>(switchTiles.at(0)).value, isTrue);
    expect(tester.widget<SwitchListTile>(switchTiles.at(1)).value, isTrue);
    expect(tester.widget<SwitchListTile>(switchTiles.at(2)).value, isTrue);

    // Toggle first switch tile
    await tester.tap(switchTiles.at(0));
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(switchTiles.at(0)).value, isFalse);

    // Toggle second switch tile
    await tester.tap(switchTiles.at(1));
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(switchTiles.at(1)).value, isFalse);
  });

  testWidgets('đăng xuất yêu cầu xác nhận qua dialog', (tester) async {
    await tester.pumpWidget(const NivexApp());

    await tester.tap(find.text('Minh Anh'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Đăng xuất'));
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();

    // Dialog appears
    expect(find.text('Đăng xuất khỏi NIVEX?'), findsOneWidget);
    expect(
      find.text('Đây là thao tác mô phỏng trong phiên bản demo.'),
      findsOneWidget,
    );

    // Tap Hủy -> cancels
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(find.text('Đăng xuất khỏi NIVEX?'), findsNothing);
    expect(find.byType(ProfileScreen), findsOneWidget);

    // Tap Đăng xuất again -> confirm
    await tester.ensureVisible(find.text('Đăng xuất'));
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng xuất'));
    await tester.pump();
    expect(find.text('Bạn đã đăng xuất khỏi NIVEX.'), findsOneWidget);
  });

  testWidgets(
    'flow Nhận USDC hiển thị QR thật, nhãn Demo Mode và lưu ý bảo mật',
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

      expect(find.text('Chỉ gửi USDC qua mạng Solana.'), findsOneWidget);
      expect(
        find.text(
          'Gửi token qua mạng khác có thể khiến tài sản không thể khôi phục.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Bản demo sử dụng dữ liệu mô phỏng hoặc Solana Devnet. Không gửi tài sản thật.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Sao chép'));
      await tester.pump();
      expect(
        copiedText,
        equals('7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU'),
      );

      await tester.ensureVisible(find.text('Về trang chủ'));
      await tester.tap(find.text('Về trang chủ'));
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

    await tester.tap(find.byTooltip('Sao chép địa chỉ'));
    await tester.pump();
    expect(copiedText, equals('7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU'));
  });

  testWidgets('cashout chọn ngân hàng và đi đến biên nhận', (tester) async {
    await tester.pumpWidget(const NivexApp());

    await tester.tap(find.text('Rút VND').first);
    await tester.pumpAndSettle();
    expect(find.text('Dùng tối đa'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bank-selector')));
    await tester.pumpAndSettle();
    expect(find.text('Vietcombank'), findsWidgets);
    expect(find.text('Techcombank'), findsOneWidget);
    expect(find.text('ACB'), findsWidgets);
    expect(find.text('MB Bank'), findsOneWidget);

    await tester.tap(find.text('Techcombank'));
    await tester.pumpAndSettle();
    expect(find.text('Techcombank'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('continue-to-quote')));
    await tester.tap(find.byKey(const Key('continue-to-quote')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Báo giá quy đổi'), findsOneWidget);
    expect(find.text('00:30'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -320));
    await tester.pump();
    await tester.tap(find.byKey(const Key('confirm-quote')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Đang gửi yêu cầu rút VND'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Yêu cầu đã hoàn tất'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pump();
    await tester.tap(find.text('Chia sẻ biên nhận'));
    await tester.pumpAndSettle();
    expect(find.text('Sao chép nội dung'), findsOneWidget);
    await tester.tap(find.text('Chia sẻ dưới dạng ảnh'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('receipt-home')));
    await tester.pumpAndSettle();
    expect(find.text('Minh Anh'), findsOneWidget);
  });

  testWidgets('quote hết hạn sau 30 giây và có thể làm mới', (tester) async {
    await tester.pumpWidget(const NivexApp());

    await tester.ensureVisible(find.text('Quote'));
    await tester.tap(find.text('Quote'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('00:30'), findsOneWidget);

    await tester.pump(const Duration(seconds: 30));
    expect(find.text('Báo giá đã hết hạn'), findsOneWidget);

    final confirm = tester.widget<FilledButton>(
      find.byKey(const Key('confirm-quote')),
    );
    expect(confirm.onPressed, isNull);

    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pump();
    await tester.tap(find.text('Lấy báo giá mới'));
    await tester.pump();
    await tester.drag(find.byType(ListView).last, const Offset(0, 500));
    await tester.pump();
    expect(find.text('00:30'), findsOneWidget);
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
}
