import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nivex_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const demoNotice =
      'Bản demo hackathon · Solana Devnet\n'
      'Payout VND chỉ là mô phỏng. Không có tiền thật được chuyển.';

  testWidgets('P0 demo claims, education stories, and payout flow', (
    tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('Hiểu nhanh cùng NIVEX'), findsOneWidget);
    await tester.ensureVisible(find.text(demoNotice));
    await tester.pumpAndSettle();
    expect(find.text(demoNotice), findsOneWidget);

    const storyTitles = [
      'NIVEX hoạt động thế nào?',
      'Web3 là gì?',
      'Blockchain là gì?',
      'Solana Devnet là gì?',
      'Sử dụng an toàn',
      'Tình huống minh họa',
    ];

    final pager = find.byType(PageView).first;
    for (var index = 0; index < storyTitles.length; index++) {
      expect(find.text(storyTitles[index]), findsOneWidget);
      if (index < storyTitles.length - 1) {
        await tester.drag(pager, const Offset(-650, 0));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    await tester.tap(find.text('Tìm hiểu thêm').first);
    await tester.pumpAndSettle();
    expect(find.text('Tình huống minh họa'), findsWidgets);
    expect(find.text('Bên gửi tạo khoản thanh toán 100 USDC'), findsOneWidget);
    expect(
      find.text('Payout VND được đánh dấu hoàn tất trong môi trường mô phỏng'),
      findsOneWidget,
    );
    expect(find.text(demoNotice), findsOneWidget);

    final understoodButton = find.widgetWithText(FilledButton, 'Đã hiểu');
    expect(understoodButton, findsOneWidget);
    expect(tester.getSize(understoodButton).height, greaterThanOrEqualTo(48));
    await tester.tap(understoodButton);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Nhận USDC').first);
    await tester.tap(find.text('Nhận USDC').first);
    await tester.pumpAndSettle();
    expect(find.text('Demo Mode • Solana Devnet'), findsOneWidget);
    expect(find.text(demoNotice), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Rút VND').first);
    await tester.tap(find.text('Rút VND').first);
    await tester.pumpAndSettle();
    expect(find.text('Mô phỏng quy đổi USDC sang VND'), findsOneWidget);
    expect(find.text(demoNotice), findsOneWidget);

    await tester.ensureVisible(find.text('Xem báo giá quy đổi'));
    await tester.tap(find.text('Xem báo giá quy đổi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Tỷ giá tham khảo trong bản demo'), findsOneWidget);
    expect(find.text(demoNotice), findsOneWidget);

    await tester.ensureVisible(find.text('Xác nhận payout mô phỏng'));
    await tester.tap(find.text('Xác nhận payout mô phỏng'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Đang xử lý payout mô phỏng'), findsOneWidget);
    expect(find.text(demoNotice), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.text('Payout VND mô phỏng hoàn tất'), findsOneWidget);
    expect(
      find.text('Dữ liệu mô phỏng • Không có tiền thật được chuyển'),
      findsOneWidget,
    );
    expect(find.text(demoNotice), findsOneWidget);
  });
}
