import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nivex_flutter/app/nivex_app.dart';
import 'package:nivex_flutter/features/jobs/presentation/application_thread_screen.dart';
import 'package:nivex_flutter/features/jobs/presentation/jobs_screen.dart';
import 'package:nivex_flutter/features/messages/presentation/messages_screen.dart';
import 'package:nivex_flutter/features/shell/domain/app_tab_controller.dart';

void main() {
  setUp(() {
    AppTabController.index.value = 0;
  });

  testWidgets('tab Công việc hiển thị cơ hội và hoàn tất ứng tuyển', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NivexApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Công việc'));
    await tester.pumpAndSettle();

    expect(find.byType(JobsScreen), findsOneWidget);
    expect(find.text('Tín hiệu việc làm'), findsOneWidget);
    expect(find.text('Flutter Developer - Payment Experience'), findsOneWidget);
    expect(find.text('1200 - 1800 USDC'), findsOneWidget);

    await tester.tap(find.text('Flutter Developer - Payment Experience'));
    await tester.pumpAndSettle();
    expect(find.text('Ứng tuyển ngay'), findsOneWidget);

    await tester.tap(find.text('Ứng tuyển ngay'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Đã gửi hồ sơ'), findsOneWidget);
    expect(find.textContaining('Đã gửi hồ sơ đến Nova Labs'), findsOneWidget);

    await tester.tap(find.text('Đã gửi hồ sơ'));
    await tester.pumpAndSettle();
    expect(find.byType(ApplicationThreadScreen), findsOneWidget);
    expect(find.text('Doanh nghiệp đã nhận hồ sơ'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('application-message-input')),
      'Mình có thể gửi thêm portfolio Flutter.',
    );
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const Key('application-message-send')),
    );
    await tester.tap(find.byKey(const Key('application-message-send')));
    await tester.pumpAndSettle();
    final composer = tester.widget<TextField>(
      find.byKey(const Key('application-message-input')),
    );
    expect(composer.controller?.text, isEmpty);
    expect(
      find.text('Mình có thể gửi thêm portfolio Flutter.'),
      findsOneWidget,
    );
  });

  testWidgets('thông báo trên Home dẫn đến danh sách công việc', (
    tester,
  ) async {
    await tester.pumpWidget(const NivexApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.notifications_none_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('2 công việc mới phù hợp'), findsOneWidget);

    await tester.tap(find.text('2 công việc mới phù hợp'));
    await tester.pumpAndSettle();

    expect(find.byType(JobsScreen), findsOneWidget);
    expect(find.text('Dành cho bạn'), findsOneWidget);
  });

  testWidgets('màn Công việc không overflow ở 320dp và 407dp', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    for (final width in [320.0, 407.0]) {
      AppTabController.index.value = 0;
      tester.view.physicalSize = Size(width, 844);
      await tester.pumpWidget(const NivexApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Công việc'));
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: 'Màn Công việc bị lỗi layout ở chiều rộng $width',
      );

      await tester.drag(
        find.byKey(const PageStorageKey('jobs-scroll')),
        const Offset(0, -520),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Ví nằm giữa và tab Tin nhắn mở hội thoại mượt', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NivexApp());
    await tester.pumpAndSettle();

    final walletCenter = tester.getCenter(find.text('Ví'));
    final messagesCenter = tester.getCenter(find.text('Tin nhắn'));
    expect((walletCenter.dx - 195).abs(), lessThan(8));
    expect(messagesCenter.dx, greaterThan(walletCenter.dx));

    await tester.tap(find.text('Tin nhắn'));
    await tester.pumpAndSettle();
    expect(find.byType(MessagesScreen), findsOneWidget);
    expect(find.text('HỘI THOẠI GẦN ĐÂY'), findsOneWidget);
    expect(find.text('Nova Labs'), findsWidgets);

    await tester.tap(find.text('Nova Labs').first);
    await tester.pumpAndSettle();
    expect(find.byType(ApplicationThreadScreen), findsOneWidget);
    expect(find.byKey(const Key('application-message-input')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('application-message-input')),
      'Mình gửi thêm portfolio nhé.',
    );
    await tester.tap(find.byKey(const Key('application-message-send')));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();
    expect(find.text('Mình gửi thêm portfolio nhé.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('màn Tin nhắn không overflow ở 320dp', (tester) async {
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NivexApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tin nhắn'));
    await tester.pumpAndSettle();

    expect(find.byType(MessagesScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
