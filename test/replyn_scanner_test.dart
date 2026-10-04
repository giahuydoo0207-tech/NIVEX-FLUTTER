import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nivex_flutter/app/theme/app_theme_mode.dart';
import 'package:nivex_flutter/app/theme/nivex_theme.dart';
import 'package:nivex_flutter/features/home/presentation/home_screen.dart';
import 'package:nivex_flutter/features/replyn_pairing/data/camera_permission_gateway.dart';
import 'package:nivex_flutter/features/replyn_pairing/data/nova_account_source.dart';
import 'package:nivex_flutter/features/replyn_pairing/data/qr_camera.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_pairing_request.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_pairing_service.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_qr_parser.dart';
import 'package:nivex_flutter/features/replyn_pairing/presentation/replyn_pairing_confirm_screen.dart';
import 'package:nivex_flutter/features/replyn_pairing/presentation/replyn_scanner_screen.dart';
import 'package:nivex_flutter/shared/widgets/nivex_logo.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

// Made-up prototype session IDs, not real Replyn codes.
const _host = 'replyn-web.vercel.app';
const _idA = '0a1b2c3d4e5f';
const _idB = 'f5e4d3c2b1a0';
const _codeA = 'https://$_host/auth/nova?demo-qr=$_idA';
const _codeB = 'https://$_host/auth/nova?demo-qr=$_idB';

class _FakeCamera implements QrCamera {
  final _codes = StreamController<String?>.broadcast();
  final calls = <String>[];
  final _torchAvailable = ValueNotifier<bool?>(true);
  final _torchOn = ValueNotifier<bool>(false);
  ValueChanged<QrCameraFailure>? _onFailure;
  bool disposed = false;

  void show(String? code) => _codes.add(code);
  void fail(QrCameraFailure failure) => _onFailure?.call(failure);
  int count(String call) => calls.where((c) => c == call).length;

  @override
  Stream<String?> get codes => _codes.stream;
  @override
  ValueListenable<bool?> get torchAvailable => _torchAvailable;
  @override
  ValueListenable<bool> get torchOn => _torchOn;

  @override
  Widget buildPreview(
    BuildContext context, {
    required ValueChanged<QrCameraFailure> onFailure,
    required VoidCallback onStarted,
  }) {
    _onFailure = onFailure;
    return const ColoredBox(key: Key('fake-preview'), color: Colors.black);
  }

  @override
  Future<void> start() async => calls.add('start');
  @override
  Future<void> pause() async => calls.add('pause');
  @override
  Future<void> stop() async => calls.add('stop');
  @override
  Future<void> toggleTorch() async {
    calls.add('torch');
    _torchOn.value = !_torchOn.value;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await _codes.close();
  }
}

class _FakePermissions implements CameraPermissionGateway {
  _FakePermissions({
    this.current = CameraPermissionState.granted,
    this.onRequest = CameraPermissionState.granted,
  });

  CameraPermissionState current;
  CameraPermissionState onRequest;
  Completer<CameraPermissionState>? pendingStatus;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<CameraPermissionState> status() =>
      pendingStatus?.future ?? Future.value(current);

  @override
  Future<CameraPermissionState> request() async {
    requests++;
    current = onRequest;
    return onRequest;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

class _FakeAccount extends ChangeNotifier implements ReplynAccountSource {
  _FakeAccount([this._identity = _talent]);

  NovaTalentIdentity? _identity;
  @override
  NovaTalentIdentity? get identity => _identity;
  set identity(NovaTalentIdentity? value) {
    _identity = value;
    notifyListeners();
  }

  @override
  ImageProvider? get avatar => null;
  @override
  bool failed = false;
}

class _CountingPairing implements ReplynPairingService {
  int confirmations = 0;
  NovaTalentIdentity? lastTalent;

  @override
  Future<ReplynPairingOutcome> confirm(
    ReplynPairingRequest request,
    NovaTalentIdentity talent,
  ) async {
    confirmations++;
    lastTalent = talent;
    return ReplynPairingOutcome.prototypeOnly;
  }
}

const _talent = NovaTalentIdentity(
  displayName: 'Trần Thu Hà',
  initials: 'TH',
  profileId: 'contractor-42',
  email: 'ha@example.com',
);

class _Harness {
  _Harness({
    CameraPermissionState permission = CameraPermissionState.granted,
    CameraPermissionState onRequest = CameraPermissionState.granted,
    _FakeAccount? account,
  }) : permissions = _FakePermissions(
         current: permission,
         onRequest: onRequest,
       ),
       account = account ?? _FakeAccount();

  final camera = _FakeCamera();
  final _FakePermissions permissions;
  final _FakeAccount account;
  final pairing = _CountingPairing();
  DateTime now = DateTime.utc(2026, 10, 4, 10);

  Widget scanner() => ReplynScannerScreen(
    cameraFactory: () => camera,
    permissions: permissions,
    parser: ReplynQrParser(
      const ReplynQrConfig(allowedHosts: {_host}),
      now: () => now,
    ),
    accountSource: account,
    pairingService: pairing,
    now: () => now,
  );

  /// Opens the scanner from a host page so popping it can be observed.
  /// Reduced motion stops the scan line so `pumpAndSettle` can settle.
  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NivexTheme.forMode(AppThemeMode.cyberNight),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => scanner())),
                child: const Text('HOST'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('HOST'));
    await tester.pumpAndSettle();
  }

  Future<void> scan(WidgetTester tester, String? code) async {
    camera.show(code);
    await tester.pumpAndSettle();
  }
}

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

const _instruction = 'Đưa mã QR đăng nhập Replyn vào trong khung';

void main() {
  late InMemorySharedPreferencesAsync preferences;

  setUp(() {
    preferences = InMemorySharedPreferencesAsync.empty();
    SharedPreferencesAsyncPlatform.instance = preferences;
  });

  group('Home header', () {
    Future<void> pumpHome(WidgetTester tester, Size size) async {
      _setSize(tester, size);
      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.cyberNight),
          home: Scaffold(
            body: HomeScreen(
              onJobs: () {},
              onProfile: () {},
              onCreatePost: () {},
              replynScannerBuilder: (_) =>
                  const Scaffold(body: Text('SCANNER ROUTE')),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }

    for (final size in const [
      Size(320, 640),
      Size(360, 800),
      Size(393, 873),
      Size(412, 915),
    ]) {
      testWidgets(
        'scan button sits left of the bell at ${size.width.toInt()}dp',
        (tester) async {
          final errors = <FlutterErrorDetails>[];
          final previous = FlutterError.onError;
          FlutterError.onError = errors.add;
          await pumpHome(tester, size);
          FlutterError.onError = previous;

          final scan = tester.getRect(
            find.bySemanticsLabel(replynScannerTitle),
          );
          final bell = tester.getRect(
            find.ancestor(
              of: find.byIcon(Icons.notifications_none_rounded),
              matching: find.byType(InkWell),
            ),
          );
          final logo = tester.getRect(find.byType(NivexLogo));
          final badge = tester.getRect(
            find.descendant(
              of: find
                  .ancestor(
                    of: find.byIcon(Icons.notifications_none_rounded),
                    matching: find.byType(Stack),
                  )
                  .first,
              matching: find.text('1'),
            ),
          );

          expect(scan.size, const Size(44, 44));
          expect(bell.size, const Size(44, 44));
          expect(scan.center.dy, bell.center.dy, reason: 'same row');
          expect(scan.right, lessThanOrEqualTo(bell.left));
          expect(bell.left - scan.right, 4);
          expect(scan.overlaps(badge), isFalse, reason: 'badge stays visible');
          expect(logo.left, greaterThanOrEqualTo(0));
          expect(logo.right, lessThan(scan.left));
          expect(bell.right, lessThanOrEqualTo(size.width));
          expect(
            tester.getSize(find.byIcon(Icons.qr_code_scanner_rounded)),
            tester.getSize(find.byIcon(Icons.notifications_none_rounded)),
          );
          final headerOverflows = errors.where(
            (e) =>
                e.exceptionAsString().contains('overflowed') &&
                e.toString().contains('NivexLogo'),
          );
          expect(headerOverflows, isEmpty);
        },
      );
    }

    testWidgets('has the accessibility label and a tooltip', (tester) async {
      await pumpHome(tester, const Size(393, 873));
      final semantics = tester.ensureSemantics();
      expect(find.bySemanticsLabel(replynScannerTitle), findsOneWidget);
      expect(find.byTooltip(replynScannerTitle), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('opens the scanner once even when tapped repeatedly', (
      tester,
    ) async {
      await pumpHome(tester, const Size(393, 873));
      final button = find.bySemanticsLabel(replynScannerTitle);
      await tester.tap(button);
      await tester.tap(button, warnIfMissed: false);
      await tester.tap(button, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('SCANNER ROUTE'), findsOneWidget);

      Navigator.of(tester.element(find.text('SCANNER ROUTE'))).pop();
      await tester.pumpAndSettle();
      expect(find.text('SCANNER ROUTE'), findsNothing);
      // Home is still there and the button works again.
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('SCANNER ROUTE'), findsOneWidget);
    });
  });

  group('Scanner states', () {
    testWidgets('shows a loading state while the permission is checked', (
      tester,
    ) async {
      final h = _Harness();
      h.permissions.pendingStatus = Completer();
      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.defaultTheme),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: h.scanner(),
        ),
      );
      await tester.pump();
      expect(find.text('Đang chuẩn bị camera…'), findsOneWidget);
      expect(find.byKey(const Key('fake-preview')), findsNothing);

      h.permissions.pendingStatus!.complete(CameraPermissionState.granted);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('fake-preview')), findsOneWidget);
      expect(find.text(_instruction), findsOneWidget);
      expect(h.camera.count('start'), 1);
    });

    testWidgets('denied permission explains why and can ask again', (
      tester,
    ) async {
      final h = _Harness(
        permission: CameraPermissionState.denied,
        onRequest: CameraPermissionState.denied,
      );
      await h.open(tester);
      expect(h.permissions.requests, 1);
      expect(find.text('Chưa có quyền camera'), findsOneWidget);
      expect(h.camera.count('start'), 0);

      h.permissions.onRequest = CameraPermissionState.granted;
      await tester.tap(find.text('Cấp quyền camera'));
      await tester.pumpAndSettle();
      expect(h.permissions.requests, 2);
      expect(find.text(_instruction), findsOneWidget);
    });

    testWidgets('permanent denial offers Settings instead of a dialog loop', (
      tester,
    ) async {
      final h = _Harness(permission: CameraPermissionState.permanentlyDenied);
      await h.open(tester);
      expect(find.text('Quyền camera đang bị tắt'), findsOneWidget);
      await tester.tap(find.text('Mở Cài đặt'));
      await tester.pumpAndSettle();
      expect(h.permissions.settingsOpened, 1);
      expect(h.permissions.requests, 0);

      // Coming back from Settings with the permission granted starts the camera.
      h.permissions.current = CameraPermissionState.granted;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text(_instruction), findsOneWidget);
      expect(h.permissions.requests, 0);
    });

    testWidgets('camera failures show a retry or a clear dead end', (
      tester,
    ) async {
      final h = _Harness();
      await h.open(tester);
      h.camera.fail(QrCameraFailure.failed);
      await tester.pumpAndSettle();
      expect(find.text('Không khởi động được camera'), findsOneWidget);
      expect(find.textContaining('Exception'), findsNothing);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.text(_instruction), findsOneWidget);
      expect(h.camera.count('start'), 2);

      h.camera.fail(QrCameraFailure.unsupported);
      await tester.pumpAndSettle();
      expect(find.text('Không tìm thấy camera phù hợp'), findsOneWidget);
      await tester.tap(find.text('Đóng'));
      await tester.pumpAndSettle();
      expect(find.text('HOST'), findsOneWidget);
    });

    testWidgets(
      'a foreign code is refused, the camera pauses, and rescanning works',
      (tester) async {
        final h = _Harness();
        await h.open(tester);
        await h.scan(tester, 'https://evil.example/auth/nova?demo-qr=$_idA');
        expect(
          find.text('Đây không phải mã đăng nhập Replyn.'),
          findsOneWidget,
        );
        expect(h.camera.calls.last, 'pause');
        expect(find.textContaining('evil.example'), findsNothing);

        // Further detections are ignored while the result is shown.
        await h.scan(tester, _codeA);
        expect(find.text('Xác nhận trên Nova'), findsNothing);

        await tester.tap(find.text('Quét lại'));
        await tester.pumpAndSettle();
        expect(find.text(_instruction), findsOneWidget);
        expect(h.camera.calls.last, 'start');
        await h.scan(tester, null);
        expect(find.text('Không đọc được mã. Hãy thử lại.'), findsOneWidget);
      },
    );

    testWidgets('malformed and expired Replyn codes get their own messages', (
      tester,
    ) async {
      final h = _Harness();
      await h.open(tester);
      await h.scan(
        tester,
        'https://$_host/auth/nova?demo-qr=$_idA&returnTo=/x',
      );
      expect(find.textContaining('Mã Replyn không hợp lệ'), findsOneWidget);
      await tester.tap(find.text('Quét lại'));
      await tester.pumpAndSettle();

      final past = h.now.subtract(const Duration(minutes: 5));
      await h.scan(
        tester,
        '$_codeB&exp=${past.millisecondsSinceEpoch ~/ 1000}',
      );
      expect(
        find.text('Mã đã hết hạn. Hãy tạo mã mới trên Replyn.'),
        findsOneWidget,
      );
    });

    testWidgets('a valid code opens one confirmation and releases the camera', (
      tester,
    ) async {
      final h = _Harness();
      await h.open(tester);
      h.camera.show(_codeA);
      h.camera.show(_codeA);
      h.camera.show(_codeB);
      await tester.pumpAndSettle();

      expect(find.text('Xác nhận trên Nova'), findsOneWidget);
      expect(find.byType(ReplynPairingConfirmScreen), findsOneWidget);
      expect(h.camera.calls.last, 'stop');
    });

    testWidgets('cancel returns to scanning without reopening the same code', (
      tester,
    ) async {
      final h = _Harness();
      await h.open(tester);
      await h.scan(tester, _codeA);
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(find.text(_instruction), findsOneWidget);
      expect(h.camera.calls.last, 'start');
      expect(h.pairing.confirmations, 0);

      // The same code, still in front of the camera, is ignored for a moment.
      await h.scan(tester, _codeA);
      expect(find.byType(ReplynPairingConfirmScreen), findsNothing);
      // A different code is handled right away.
      await h.scan(tester, _codeB);
      expect(find.byType(ReplynPairingConfirmScreen), findsOneWidget);
      // The system back button behaves like cancel.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text(_instruction), findsOneWidget);
      h.now = h.now.add(const Duration(seconds: 4));
      await h.scan(tester, _codeB);
      expect(find.byType(ReplynPairingConfirmScreen), findsOneWidget);
    });

    testWidgets('the scan line moves only when motion is allowed', (
      tester,
    ) async {
      final h = _Harness();
      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.forMode(AppThemeMode.cyberNight),
          home: h.scanner(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(_instruction), findsOneWidget);
      expect(tester.hasRunningAnimations, isTrue);
      h.camera.show('https://evil.example/');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Paused on a result: the line stops.
      expect(find.text('Đây không phải mã đăng nhập Replyn.'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('the torch button toggles the flash', (tester) async {
      final h = _Harness();
      await h.open(tester);
      await tester.tap(find.byTooltip('Bật đèn flash'));
      await tester.pump();
      expect(h.camera.calls.last, 'torch');
      expect(find.byTooltip('Tắt đèn flash'), findsOneWidget);
    });

    testWidgets('leaving the scanner releases the camera', (tester) async {
      final h = _Harness();
      await h.open(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('HOST'), findsOneWidget);
      expect(h.camera.disposed, isTrue);
    });
  });

  group('Confirmation', () {
    testWidgets('shows the signed-in account and never the raw code', (
      tester,
    ) async {
      final h = _Harness();
      await h.open(tester);
      await h.scan(tester, _codeA);
      expect(find.text('Trần Thu Hà'), findsOneWidget);
      expect(find.text('TH'), findsOneWidget);
      expect(find.text('Mã hồ sơ Nova contractor-42'), findsOneWidget);
      expect(find.text('ha@example.com'), findsOneWidget);
      expect(find.text('Talent · Freelancer'), findsOneWidget);
      expect(find.text(_host), findsOneWidget);
      expect(find.textContaining(_idA), findsNothing);
      expect(find.textContaining('demo-qr'), findsNothing);
    });

    testWidgets('does not present the Talent profile ID as a Nova ID', (
      tester,
    ) async {
      final h = _Harness();
      await h.open(tester);
      await h.scan(tester, _codeA);
      // Only Business has a public Nova ID (NVB-…); Talent has a profile ID.
      expect(find.textContaining('Nova ID'), findsNothing);
      expect(find.textContaining('Mã hồ sơ Nova'), findsOneWidget);

      await tester.tap(find.text('Xác nhận trên Nova'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Nova ID'), findsNothing);
    });

    testWidgets('confirming only reports the prototype state', (tester) async {
      final h = _Harness();
      await h.open(tester);
      await h.scan(tester, _codeA);
      await tester.tap(find.text('Xác nhận trên Nova'));
      await tester.pumpAndSettle();

      expect(h.pairing.confirmations, 1);
      expect(h.pairing.lastTalent?.displayName, 'Trần Thu Hà');
      expect(find.text(replynPrototypeMessage), findsOneWidget);
      expect(find.textContaining('thành công'), findsNothing);
      // Nothing from the scan is persisted on the phone.
      expect(
        await preferences.getKeys(
          const GetPreferencesParameters(filter: PreferencesFilters()),
          const SharedPreferencesOptions(),
        ),
        isEmpty,
      );

      await tester.tap(find.text('Quét mã khác'));
      await tester.pumpAndSettle();
      expect(find.text(_instruction), findsOneWidget);
      expect(h.camera.calls.last, 'start');
    });

    testWidgets(
      'Đóng after the prototype step returns to the previous screen',
      (tester) async {
        final h = _Harness();
        await h.open(tester);
        await h.scan(tester, _codeA);
        await tester.tap(find.text('Xác nhận trên Nova'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Đóng'));
        await tester.pumpAndSettle();
        expect(find.text('HOST'), findsOneWidget);
        expect(h.camera.disposed, isTrue);
      },
    );

    testWidgets('confirm waits for the account to load', (tester) async {
      final h = _Harness(account: _FakeAccount(null));
      await h.open(tester);
      // The loading spinner never settles; pump past the route transition.
      h.camera.show(_codeA);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Đang tải tài khoản Nova…'), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Xác nhận trên Nova'),
      );
      expect(button.onPressed, isNull);

      h.account.identity = _talent;
      await tester.pump();
      expect(find.text('Trần Thu Hà'), findsOneWidget);

      h.account
        ..failed = true
        ..identity = null;
      await tester.pump();
      expect(
        find.text('Không tải được tài khoản Nova. Hãy thử lại sau.'),
        findsOneWidget,
      );
    });

    testWidgets('a code that expires while the user decides is not confirmed', (
      tester,
    ) async {
      final h = _Harness();
      await h.open(tester);
      final exp = h.now.add(const Duration(seconds: 60));
      await h.scan(tester, '$_codeA&exp=${exp.millisecondsSinceEpoch ~/ 1000}');
      h.now = h.now.add(const Duration(minutes: 2));
      await tester.tap(find.text('Xác nhận trên Nova'));
      await tester.pumpAndSettle();
      expect(find.text('Mã đã hết hạn'), findsOneWidget);
      expect(h.pairing.confirmations, 0);
    });

    testWidgets('scanner and confirmation fit a 320x640 screen', (
      tester,
    ) async {
      _setSize(tester, const Size(320, 640));
      final h = _Harness(
        account: _FakeAccount(
          const NovaTalentIdentity(
            displayName: 'Nguyễn Hoàng Bảo Ngọc Phương Thảo Trâm',
            initials: 'NT',
            profileId: 'contractor-with-a-rather-long-identifier-0001',
            email: 'a.very.long.email.address.for.testing@example-company.vn',
          ),
        ),
      );
      await h.open(tester);
      expect(tester.takeException(), isNull);
      await h.scan(tester, 'https://evil.example/');
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Quét lại'));
      await tester.pumpAndSettle();
      await h.scan(tester, _codeA);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Xác nhận trên Nova'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('permission screens fit a 320x640 screen', (tester) async {
      _setSize(tester, const Size(320, 640));
      final h = _Harness(permission: CameraPermissionState.permanentlyDenied);
      await h.open(tester);
      expect(find.text('Mở Cài đặt'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  test('the prototype pairing service reports no login', () async {
    const service = PrototypeReplynPairingService();
    final outcome = await service.confirm(
      const ReplynPairingRequest(
        action: ReplynPairingAction.login,
        pairingSessionId: _idA,
        displayOrigin: _host,
        isPrototype: true,
      ),
      _talent,
    );
    expect(outcome, ReplynPairingOutcome.prototypeOnly);
  });
}
