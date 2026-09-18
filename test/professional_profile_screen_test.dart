import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nivex_flutter/app/theme/app_theme_mode.dart';
import 'package:nivex_flutter/app/theme/nivex_theme.dart';
import 'package:nivex_flutter/features/cashout/presentation/cashout_screen.dart';
import 'package:nivex_flutter/features/posts/presentation/posts_screen.dart';
import 'package:nivex_flutter/features/posts/presentation/public_profile_screen.dart';
import 'package:nivex_flutter/features/profile/data/demo_freelancer_profile_controller.dart';
import 'package:nivex_flutter/features/profile/presentation/bank_account_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/professional_profile_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/profile_screen.dart';
import 'package:nivex_flutter/features/profile/presentation/reputation_badges_screen.dart';
import 'package:nivex_flutter/features/profile/widgets/profile_row.dart';
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

  testWidgets(
    'có thể tương tác đổi avatar/ảnh nền qua action sheet và thêm kỹ năng ngoài danh sách gợi ý',
    (tester) async {
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

      // Kiểm tra Section 01 hiển thị preview mini với tap touch thay vì card cũ
      expect(
        find.byKey(const Key('edit-profile-avatar-touch')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('edit-profile-cover-touch')), findsOneWidget);

      // Không còn preset nền cũ hay nút text cũ
      expect(find.byKey(const Key('profile-theme-list')), findsNothing);
      expect(find.text('Chọn nền thẻ hồ sơ'), findsNothing);
      expect(find.byKey(const Key('pick-profile-avatar')), findsNothing);

      // Không có chữ Thay đổi avatar/ảnh nền thường trực làm rối UI
      expect(find.text('Thay đổi avatar'), findsNothing);
      expect(find.text('Thay đổi ảnh nền'), findsNothing);

      // Bấm avatar -> mở action sheet Thay đổi avatar
      await tester.tap(find.byKey(const Key('edit-profile-avatar-touch')));
      await tester.pumpAndSettle();
      expect(find.text('Thay đổi avatar'), findsOneWidget);
      expect(find.text('Chọn từ thư viện'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);

      // Đóng action sheet bằng cách bấm Hủy
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(find.text('Thay đổi avatar'), findsNothing);

      // Bấm cover -> mở action sheet Thay đổi ảnh nền
      await tester.tap(find.byKey(const Key('edit-profile-cover-touch')));
      await tester.pumpAndSettle();
      expect(find.text('Thay đổi ảnh nền'), findsOneWidget);
      expect(find.text('Chọn từ thư viện'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);

      // Đóng action sheet bằng cách bấm Hủy
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(find.text('Thay đổi ảnh nền'), findsNothing);

      // Thêm kỹ năng ngoài danh sách gợi ý
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
    },
  );

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

  testWidgets(
    'kéo xuống từ đầu feed kích hoạt RefreshIndicator và làm mới bảng tin',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
          home: const PostsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Kéo feed xuống từ đầu trang
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Đợi hoàn thành refresh (delay 650ms + settle)
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Xác nhận hiển thị thông báo đã làm mới bảng tin
      expect(find.text('Đã làm mới bảng tin.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'PublicProfile của chính mình (isSelf=true) không có nút Chỉnh sửa hồ sơ, của người khác vẫn có Theo dõi',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const selfProfile = PublicProfileData(
        kind: PublicProfileKind.freelancer,
        displayName: 'Minh Anh',
        handle: 'minhanh.nova',
        headline: 'Flutter Dev',
        location: 'Đà Nẵng',
        bio: 'Hồ sơ của chính mình',
        tags: ['Flutter'],
        stats: [],
        isSelf: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
          home: const PublicProfileScreen(
            profile: selfProfile,
            profilePosts: [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Không còn nút Chỉnh sửa hồ sơ
      expect(find.text('Chỉnh sửa hồ sơ'), findsNothing);
      expect(find.text('Theo dõi'), findsNothing);

      // Mở profile người khác (isSelf=false)
      const otherProfile = PublicProfileData(
        kind: PublicProfileKind.freelancer,
        displayName: 'Ngọc Lan',
        handle: 'lan.design',
        headline: 'UI/UX Designer',
        location: 'Hà Nội',
        bio: 'Hồ sơ người khác',
        tags: ['Figma'],
        stats: [],
        isSelf: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
          home: const PublicProfileScreen(
            profile: otherProfile,
            profilePosts: [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Vẫn có nút Theo dõi
      expect(find.text('Theo dõi'), findsOneWidget);
      expect(find.text('Chỉnh sửa hồ sơ'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'màn Rút VND hiển thị logo ngân hàng cho các tài khoản liên kết',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
          home: const CashoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tìm 4 ngân hàng
      expect(find.text('Vietcombank'), findsOneWidget);
      expect(find.text('Techcombank'), findsOneWidget);
      expect(find.text('ACB'), findsOneWidget);
      expect(find.text('MB Bank'), findsOneWidget);

      // Xác nhận có Image widget hiển thị logo ngân hàng
      expect(find.byType(Image), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'chọn avatar và cover trong EditProfile cập nhật draft và chỉ commit khi Lưu',
    (tester) async {
      final controller = DemoFreelancerProfileController.instance;
      final initialCover = controller.profile.coverPath;
      final initialAvatar = controller.profile.avatarPath;

      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
          home: const ProfessionalProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Chỉnh sửa hồ sơ'));
      await tester.pumpAndSettle();

      // Kiểm tra widgets preview mini
      expect(
        find.byKey(const Key('edit-profile-avatar-touch')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('edit-profile-cover-touch')), findsOneWidget);

      // Nếu người dùng chưa lưu (controller không bị đổi)
      expect(controller.profile.coverPath, equals(initialCover));
      expect(controller.profile.avatarPath, equals(initialAvatar));

      // Bấm Lưu hồ sơ
      for (var index = 0; index < 5; index++) {
        await tester.drag(
          find.byKey(const Key('edit-profile-list')),
          const Offset(0, -420),
        );
        await tester.pumpAndSettle();
      }
      expect(
        find.byKey(const Key('save-professional-profile')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('save-professional-profile')));
      await tester.pumpAndSettle();

      // Đã commit thành công
      expect(find.text('Đã cập nhật hồ sơ nghề nghiệp'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'PublicProfileScreen hiển thị cover khi có coverPath và fallback khi không có',
    (tester) async {
      // 1. Profile không có coverPath -> fallback CustomPaint grid
      const noCoverProfile = PublicProfileData(
        kind: PublicProfileKind.freelancer,
        displayName: 'Minh Anh',
        handle: 'minhanh.nova',
        headline: 'Flutter Developer',
        location: 'Đà Nẵng',
        bio: 'Mô tả',
        tags: ['Flutter'],
        stats: [],
        coverPath: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
          home: const PublicProfileScreen(
            profile: noCoverProfile,
            profilePosts: [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);

      // 2. Business profile không có coverPath -> fallback CustomPaint grid với theme.warning
      const businessProfile = PublicProfileData(
        kind: PublicProfileKind.business,
        displayName: 'Nova Labs',
        handle: 'nova.labs',
        headline: 'Web3 Builder',
        location: 'Singapore',
        bio: 'Business bio',
        tags: ['Web3'],
        stats: [],
        coverPath: null,
      );

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

      expect(find.text('Hồ sơ doanh nghiệp'), findsOneWidget);
      expect(find.text('Cơ hội'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'mũi tên chevron > ở item Trạng thái xác minh và các item khác nằm cùng trục phải',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
          home: const ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final rowTitles = [
        'Thông tin cá nhân',
        'Trạng thái xác minh',
        'Địa chỉ ví Solana',
        'Tài khoản nhận VND',
      ];

      final chevronXPositions = <String, double>{};
      for (final title in rowTitles) {
        final rowFinder = find.ancestor(
          of: find.text(title),
          matching: find.byType(ProfileRow),
        );
        expect(rowFinder, findsOneWidget);
        final chevronFinder = find.descendant(
          of: rowFinder,
          matching: find.byIcon(Icons.chevron_right_rounded),
        );
        expect(chevronFinder, findsOneWidget);
        chevronXPositions[title] = tester.getTopRight(chevronFinder).dx;
      }

      final referenceX = chevronXPositions['Thông tin cá nhân']!;
      expect(chevronXPositions['Trạng thái xác minh'], equals(referenceX));
      expect(chevronXPositions['Địa chỉ ví Solana'], equals(referenceX));
      expect(chevronXPositions['Tài khoản nhận VND'], equals(referenceX));

      // Kiểm tra cả trên màn hẹp 320dp
      tester.view.physicalSize = const Size(320, 760);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
          home: const ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final narrowChevronX = <String, double>{};
      for (final title in rowTitles) {
        final rowFinder = find.ancestor(
          of: find.text(title),
          matching: find.byType(ProfileRow),
        );
        final chevronFinder = find.descendant(
          of: rowFinder,
          matching: find.byIcon(Icons.chevron_right_rounded),
        );
        narrowChevronX[title] = tester.getTopRight(chevronFinder).dx;
      }
      final narrowReferenceX = narrowChevronX['Thông tin cá nhân']!;
      expect(narrowChevronX['Trạng thái xác minh'], equals(narrowReferenceX));
      expect(narrowChevronX['Địa chỉ ví Solana'], equals(narrowReferenceX));
      expect(narrowChevronX['Tài khoản nhận VND'], equals(narrowReferenceX));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'màn Tài khoản nhận VND hiển thị logo Vietcombank mặc định và có thể thêm tài khoản ngân hàng mới qua modal form',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.blockchainFlow),
          home: const BankAccountScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Card mặc định Vietcombank
      expect(find.text('Vietcombank'), findsOneWidget);
      expect(find.text('Ngân hàng TMCP Ngoại thương VN'), findsOneWidget);
      expect(find.text('Mặc định'), findsOneWidget);
      expect(find.text('•••• 2868'), findsOneWidget);
      expect(find.text('MINH ANH'), findsOneWidget);
      expect(find.text('Đã liên kết (Khớp KYC)'), findsOneWidget);

      // Nút Thêm tài khoản
      expect(find.byKey(const Key('add-bank-account-button')), findsOneWidget);
      expect(find.text('Thêm tài khoản'), findsOneWidget);
      expect(find.text('+ Thêm tài khoản'), findsNothing);
      await tester.tap(find.byKey(const Key('add-bank-account-button')));
      await tester.pumpAndSettle();

      // Bottom sheet đã mở
      expect(find.text('Thêm tài khoản nhận VND'), findsOneWidget);
      expect(find.byKey(const Key('bank-select-field')), findsOneWidget);
      expect(
        find.byKey(const Key('bank-account-number-field')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('bank-account-name-field')), findsOneWidget);
      expect(find.byKey(const Key('save-bank-account-button')), findsOneWidget);

      // Test validation: số tài khoản < 6 ký tự
      await tester.enterText(
        find.byKey(const Key('bank-account-number-field')),
        '12345',
      );
      await tester.tap(find.byKey(const Key('save-bank-account-button')));
      await tester.pumpAndSettle();
      expect(find.text('Số tài khoản không hợp lệ.'), findsOneWidget);

      // Test validation: chủ tài khoản rỗng
      await tester.enterText(
        find.byKey(const Key('bank-account-name-field')),
        '',
      );
      await tester.tap(find.byKey(const Key('save-bank-account-button')));
      await tester.pumpAndSettle();
      expect(find.text('Vui lòng nhập chủ tài khoản.'), findsOneWidget);

      // Nhập thông tin hợp lệ
      await tester.enterText(
        find.byKey(const Key('bank-account-number-field')),
        '987654321',
      );
      await tester.enterText(
        find.byKey(const Key('bank-account-name-field')),
        'le thi b',
      );
      await tester.tap(find.byKey(const Key('save-bank-account-button')));
      await tester.pumpAndSettle();

      // Modal đã đóng và hiện SnackBar demo
      expect(find.text('Thêm tài khoản nhận VND'), findsNothing);
      expect(
        find.text('Đã thêm tài khoản nhận VND trong bản demo.'),
        findsOneWidget,
      );

      // Card mới xuất hiện trong list
      expect(find.text('•••• 4321'), findsOneWidget);
      expect(find.text('LE THI B'), findsOneWidget);

      // Vietcombank vẫn giữ badge Mặc định, tài khoản mới không có Mặc định
      expect(find.text('Mặc định'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
