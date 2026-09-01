import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nivex_flutter/app/nivex_app.dart';
import 'package:nivex_flutter/features/shell/domain/app_tab_controller.dart';

void main() {
  setUp(() => AppTabController.index.value = 0);

  testWidgets('hiển thị Home NIVEX bằng tiếng Việt', (tester) async {
    await tester.pumpWidget(const NivexApp());

    expect(find.text('Minh Anh'), findsOneWidget);
    expect(find.text('Solana Devnet'), findsOneWidget);
    expect(find.text('22.480.000 đ'), findsOneWidget);
    expect(find.text('Nhận USDC'), findsWidgets);
    expect(find.text('Rút VND'), findsWidgets);
    expect(find.text('Lịch sử'), findsOneWidget);
    expect(find.text('Quote'), findsOneWidget);
    expect(find.text('Trợ giúp'), findsOneWidget);
    expect(find.text('Chào'), findsNothing);
  });

  testWidgets('điều hướng được giữa bốn bottom tabs', (tester) async {
    await tester.pumpWidget(const NivexApp());

    expect(find.byType(NavigationDestination), findsNWidgets(4));

    await tester.tap(find.text('Ví'));
    await tester.pumpAndSettle();
    expect(find.text('Ví của bạn'), findsOneWidget);

    await tester.tap(find.text('Giao dịch'));
    await tester.pumpAndSettle();
    expect(find.text('Lịch sử hoạt động của ví'), findsOneWidget);

    await tester.tap(find.text('Thị trường'));
    await tester.pumpAndSettle();
    expect(find.text('Tỷ giá USDC/VND tham khảo'), findsOneWidget);

    await tester.tap(find.text('Trang chủ'));
    await tester.pumpAndSettle();
    expect(find.text('Minh Anh'), findsOneWidget);
  });

  testWidgets('flow Nhận USDC quay về Home', (tester) async {
    await tester.pumpWidget(const NivexApp());

    await tester.tap(find.widgetWithText(FilledButton, 'Nhận USDC'));
    await tester.pumpAndSettle();
    expect(find.text('Địa chỉ ví USDC'), findsOneWidget);
    expect(find.text('Mạng Solana Devnet'), findsOneWidget);

    await tester.tap(find.text('Về trang chủ'));
    await tester.pumpAndSettle();
    expect(find.text('Minh Anh'), findsOneWidget);
  });

  testWidgets('cashout chọn ngân hàng và đi đến biên nhận', (tester) async {
    await tester.pumpWidget(const NivexApp());

    await tester.tap(find.widgetWithText(OutlinedButton, 'Rút VND'));
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
    expect(find.text('Chia sẻ biên nhận'), findsOneWidget);

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

    for (final label in ['Ví', 'Giao dịch', 'Thị trường', 'Trang chủ']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      final error = tester.takeException();
      expect(error, isNull, reason: 'Tab $label: $error');
    }

    await tester.tap(find.widgetWithText(OutlinedButton, 'Rút VND'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('bank-selector')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
