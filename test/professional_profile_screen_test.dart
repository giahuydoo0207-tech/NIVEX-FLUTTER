import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nivex_flutter/app/theme/app_theme_mode.dart';
import 'package:nivex_flutter/app/theme/nivex_theme.dart';
import 'package:nivex_flutter/features/profile/presentation/professional_profile_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/reputation_badges_screen.dart';
import 'package:nivex_flutter/features/profile/widgets/reputation_badge.dart';

void main() {
  testWidgets('hồ sơ nghề nghiệp chỉnh sửa và hiển thị tốt ở 320dp', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
        home: const ProfessionalProfileScreen(),
      ),
    );

    expect(find.text('Hồ sơ nghề nghiệp'), findsOneWidget);
    expect(
      find.text('Flutter Developer | Fintech Mobile Applications'),
      findsOneWidget,
    );
    expect(find.text('Portfolio nổi bật'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Chỉnh sửa hồ sơ'));
    await tester.pumpAndSettle();
    expect(find.byType(EditProfessionalProfileScreen), findsOneWidget);

    const updatedHeadline = 'Flutter Developer | Mobile Payment Products';
    await tester.enterText(
      find.byKey(const Key('profile-headline-field')),
      updatedHeadline,
    );
    for (var index = 0; index < 5; index++) {
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const Key('save-professional-profile')), findsOneWidget);
    await tester.tap(find.byKey(const Key('save-professional-profile')));
    await tester.pumpAndSettle();

    expect(find.text(updatedHeadline), findsOneWidget);
    expect(find.text('Đã cập nhật hồ sơ nghề nghiệp'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gallery badge hiển thị đủ tier và không overflow ở 320dp', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
        home: const ProfessionalProfileScreen(),
      ),
    );

    await tester.ensureVisible(find.text('Cấp bậc uy tín NIVEX'));
    await tester.tap(find.text('Cấp bậc uy tín NIVEX'));
    await tester.pumpAndSettle();

    expect(find.byType(ReputationBadgesScreen), findsOneWidget);
    expect(find.byType(ReputationBadge), findsWidgets);
    expect(find.text('Chưa xếp hạng'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('NIVEX Bronze'),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('NIVEX Bronze'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('NIVEX Gold'),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('NIVEX Gold'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Verified Expert'),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Verified Expert'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
