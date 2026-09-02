import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nivex_flutter/app/nivex_app.dart';
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

      // Verify badge and titles
      expect(find.text('Demo Mode • Solana Devnet'), findsOneWidget);
      expect(find.text('Địa chỉ ví USDC'), findsOneWidget);
      expect(find.text('Mạng Solana Devnet'), findsOneWidget);
      expect(
        find.text('7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU'),
        findsOneWidget,
      );

      // Verify scannable QR Code widget and payload
      expect(find.byType(QrImageView), findsOneWidget);
      final qrValidation = QrValidator.validate(
        data: ReceiveUsdcScreen.address,
        version: QrVersions.auto,
      );
      expect(qrValidation.status, equals(QrValidationStatus.valid));
      expect(qrValidation.qrCode, isNotNull);

      // Verify all 3 required security and network warnings
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

      // Verify Copy button copies the exact full 44-character Solana address
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
    expect(find.text('25%'), findsNothing);
    expect(find.text('50%'), findsNothing);

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

  testWidgets('Trợ giúp có nội dung MVP và Android Back hoạt động', (
    tester,
  ) async {
    await tester.pumpWidget(const NivexApp());

    await tester.ensureVisible(find.text('Trợ giúp'));
    await tester.tap(find.text('Trợ giúp'));
    await tester.pumpAndSettle();
    expect(find.text('Câu hỏi thường gặp'), findsOneWidget);
    expect(find.text('Email hỗ trợ'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Minh Anh'), findsOneWidget);

    await tester.tap(find.text('Ví'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Minh Anh'), findsOneWidget);
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
      expect(error, isNull, reason: 'Tab $label: $error');
    }

    await tester.tap(find.text('Rút VND').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('bank-selector')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
