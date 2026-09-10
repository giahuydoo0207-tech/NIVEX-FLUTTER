import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nivex_flutter/app/nivex_app.dart';
import 'package:nivex_flutter/features/jobs/presentation/jobs_screen.dart';
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
    expect(find.textContaining('Đã gửi hồ sơ đến NIVEX Labs'), findsOneWidget);
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
}
