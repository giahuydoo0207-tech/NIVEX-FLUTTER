import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nivex_flutter/app/theme/app_theme_mode.dart';
import 'package:nivex_flutter/app/theme/nivex_theme.dart';
import 'package:nivex_flutter/features/posts/presentation/posts_screen.dart';
import 'package:nivex_flutter/features/posts/presentation/public_profile_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/professional_profile_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/profile_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/reputation_badges_screen.dart';
import 'package:nivex_flutter/features/profile/widgets/reputation_avatar.dart';
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
      await tester.drag(
        find.byKey(const Key('edit-profile-list')),
        const Offset(0, -500),
      );
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

    expect(find.byType(ReputationAvatar), findsNothing);
    await tester.ensureVisible(find.text('Cấp bậc uy tín Nova'));
    await tester.tap(find.text('Cấp bậc uy tín Nova'));
    await tester.pumpAndSettle();

    expect(find.byType(ReputationBadgesScreen), findsOneWidget);
    expect(find.byType(ReputationBadge), findsWidgets);
    expect(find.text('Chưa xếp hạng'), findsOneWidget);
    expect(find.text('Viền Bronze'), findsNothing);
    expect(find.text('Viền Gold'), findsNothing);
    expect(
      find.textContaining('Cấp bậc chỉ là tín hiệu tham khảo'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Bronze'),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Bronze'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Gold'),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Gold'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Xác minh chuyên môn'),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Xác minh chuyên môn'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('có thể chọn nền và thêm kỹ năng ngoài danh sách gợi ý', (
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

    await tester.tap(find.byTooltip('Chỉnh sửa hồ sơ'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pick-profile-avatar')), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('profile-theme-list')),
      const Offset(-360, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-theme-signal')));
    for (var index = 0; index < 3; index++) {
      await tester.drag(
        find.byKey(const Key('edit-profile-list')),
        const Offset(0, -420),
      );
      await tester.pumpAndSettle();
      if (find.byKey(const Key('add-custom-skill')).evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.ensureVisible(find.byKey(const Key('add-custom-skill')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-custom-skill')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('custom-skill-field')),
      'Biên tập video',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Thêm'));
    await tester.pumpAndSettle();

    expect(find.text('Biên tập video'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'không dùng reputation ring trên profile/feed và không còn chữ Viền tier',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
          home: const ProfessionalProfileScreen(),
        ),
      );
      expect(find.byType(ReputationAvatar), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
          home: const ProfileScreen(),
        ),
      );
      expect(find.byType(ReputationAvatar), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
          home: const PostsScreen(),
        ),
      );
      expect(find.byType(ReputationAvatar), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
          home: const ReputationBadgesScreen(),
        ),
      );
      expect(find.text('Viền Bronze'), findsNothing);
      expect(find.text('Viền Silver'), findsNothing);
      expect(find.text('Viền Gold'), findsNothing);
      expect(find.text('Viền Platinum'), findsNothing);
      expect(find.byType(ReputationBadge), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'PublicProfile freelancer hiển thị mục Cấp bậc uy tín và mở ReputationBadgesScreen',
    (tester) async {
      const freelancerProfile = PublicProfileData(
        kind: PublicProfileKind.freelancer,
        displayName: 'Minh Anh',
        handle: 'minhanh.test',
        headline: 'Flutter Dev',
        location: 'Đà Nẵng',
        bio: 'Lập trình viên',
        tags: ['Flutter'],
        stats: [],
      );

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
          home: const PublicProfileScreen(
            profile: freelancerProfile,
            profilePosts: [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Chuyển sang tab Giới thiệu
      await tester.tap(find.text('Giới thiệu'));
      await tester.pumpAndSettle();

      // Kiểm tra có mục Cấp bậc uy tín cho freelancer
      expect(find.text('Cấp bậc uy tín'), findsOneWidget);
      expect(find.text('Cấp bậc uy tín Nova'), findsOneWidget);

      // Bấm vào thẻ để mở ReputationBadgesScreen
      await tester.tap(find.text('Cấp bậc uy tín Nova'));
      await tester.pumpAndSettle();
      expect(find.byType(ReputationBadgesScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('PublicProfile business không có mục Cấp bậc uy tín', (
    tester,
  ) async {
    const businessProfile = PublicProfileData(
      kind: PublicProfileKind.business,
      displayName: 'Nova Labs',
      handle: 'nova.labs',
      headline: 'Tech Company',
      location: 'Đà Nẵng',
      bio: 'Công ty công nghệ',
      tags: ['Fintech'],
      stats: [],
    );

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
        home: const PublicProfileScreen(
          profile: businessProfile,
          profilePosts: [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Giới thiệu'));
    await tester.pumpAndSettle();
    expect(find.text('Cấp bậc uy tín'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nút Theo dõi trên News Feed chuyển đổi trạng thái khi bấm', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
        home: const PostsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tìm nút Theo dõi ở bài viết của Nova Labs (bài không phải của mình)
    final followButtonFinder = find.widgetWithText(TextButton, 'Theo dõi');
    expect(followButtonFinder, findsWidgets);

    // Bấm nút Theo dõi đầu tiên
    await tester.tap(followButtonFinder.first);
    await tester.pumpAndSettle();

    // Xác nhận đổi thành Đang theo dõi
    expect(find.widgetWithText(TextButton, 'Đang theo dõi'), findsOneWidget);

    // Chờ SnackBar biến mất để không che điểm tap
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Bấm lại để bỏ theo dõi
    await tester.tap(find.widgetWithText(TextButton, 'Đang theo dõi'));
    await tester.pumpAndSettle();

    // Xác nhận quay lại Theo dõi
    expect(find.widgetWithText(TextButton, 'Theo dõi'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
