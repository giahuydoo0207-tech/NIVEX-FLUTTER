import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nivex_flutter/app/theme/app_theme_mode.dart';
import 'package:nivex_flutter/app/theme/nivex_theme.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/cashout/data/cashout_auth_state_store.dart';
import 'package:nivex_flutter/features/cashout/data/demo_cashout_fixtures.dart';
import 'package:nivex_flutter/features/cashout/data/mock_quote_repository.dart';
import 'package:nivex_flutter/features/cashout/domain/biometric_auth_client.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_auth_service.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_money.dart';
import 'package:nivex_flutter/features/cashout/domain/usdc_parser.dart';
import 'package:nivex_flutter/features/cashout/presentation/cashout_screen.dart';
import 'package:nivex_flutter/features/cashout/presentation/processing_screen.dart';
import 'package:nivex_flutter/features/cashout/presentation/quote_screen.dart';
import 'package:nivex_flutter/features/cashout/presentation/receipt_screen.dart';
import 'package:nivex_flutter/features/cashout/presentation/widgets/transaction_auth_sheet.dart';
import 'package:nivex_flutter/features/session/presentation/session_guard.dart';
import 'package:nivex_flutter/shared/constants/app_environment.dart';
import 'package:nivex_flutter/shared/widgets/demo_notice.dart';

import 'fakes/fake_biometric_auth_client.dart';

void main() {
  group('1. BigInt Money & Canonical Test Vector', () {
    test('UsdcAmount arithmetic, minorUnits and formatting', () {
      final a = UsdcAmount.fromUnits(100);
      final b = UsdcAmount.fromMinorUnits(BigInt.from(1510000)); // 1.51 USDC
      final net = a - b;

      expect(a.minorUnits, equals(BigInt.from(100000000)));
      expect(b.minorUnits, equals(BigInt.from(1510000)));
      expect(net.minorUnits, equals(BigInt.from(98490000)));
      expect(a.toFormattedString(), equals('100,00 USDC'));
      expect(b.toFormattedString(), equals('1,51 USDC'));
      expect(net.toFormattedString(), equals('98,49 USDC'));

      expect(() => b - a, throwsStateError);
      expect(
        () => UsdcAmount.fromMinorUnits(BigInt.from(-1)),
        throwsArgumentError,
      );
      expect(() => VndAmount.fromUnits(BigInt.from(-1)), throwsArgumentError);
      expect(() => ExchangeRate(BigInt.zero), throwsArgumentError);
    });

    test('Canonical test vector math gives exact 2.418.520 VND', () {
      final sell = DemoCashoutFixtures.canonicalSellAmount; // 100 USDC
      final fee = DemoCashoutFixtures.canonicalFee; // 0.01 net + 1.50 serv
      final rate = DemoCashoutFixtures.canonicalRate; // 24,556 VND/USDC

      expect(sell.minorUnits, equals(BigInt.from(100000000)));
      expect(fee.networkFee.minorUnits, equals(BigInt.from(10000)));
      expect(fee.serviceFee.minorUnits, equals(BigInt.from(1500000)));
      expect(fee.totalFee.minorUnits, equals(BigInt.from(1510000)));

      final netUsdc = sell - fee.totalFee;
      expect(netUsdc.minorUnits, equals(BigInt.from(98490000))); // 98.49 USDC

      final netVnd = rate.convert(netUsdc);
      expect(netVnd.minorUnits, equals(BigInt.from(2418520))); // 2,418,520 VND
      expect(netVnd.toFormattedString(), equals('2.418.520 VND'));
      expect(rate.toFormattedString(), equals('1 USDC = 24.556 VND'));
    });
  });

  group('2. UsdcParser Zero-Double and Ambiguity Handling', () {
    test('parses empty and whitespace', () {
      expect(UsdcParser.parse(''), equals(const UsdcParseEmpty()));
      expect(UsdcParser.parse('   '), equals(const UsdcParseEmpty()));
      expect(UsdcParser.parse(null), equals(const UsdcParseEmpty()));
    });

    test('parses valid inputs with comma or dot', () {
      final r1 = UsdcParser.parse('100');
      expect(r1, isA<UsdcParseSuccess>());
      expect(
        (r1 as UsdcParseSuccess).amount.minorUnits,
        equals(BigInt.from(100000000)),
      );

      final r2 = UsdcParser.parse('0.01');
      expect(
        (r2 as UsdcParseSuccess).amount.minorUnits,
        equals(BigInt.from(10000)),
      );

      final r3 = UsdcParser.parse('1,50');
      expect(
        (r3 as UsdcParseSuccess).amount.minorUnits,
        equals(BigInt.from(1500000)),
      );

      final r4 = UsdcParser.parse('00100');
      expect(
        (r4 as UsdcParseSuccess).amount.minorUnits,
        equals(BigInt.from(100000000)),
      );
    });

    test('rejects ambiguous or invalid input without converting to double', () {
      expect(UsdcParser.parse('.'), isA<UsdcParseInvalid>());
      expect(UsdcParser.parse(','), isA<UsdcParseInvalid>());
      expect(UsdcParser.parse('1.2.3'), isA<UsdcParseInvalid>());
      expect(UsdcParser.parse('1,2,3'), isA<UsdcParseInvalid>());
      expect(UsdcParser.parse('-50'), isA<UsdcParseInvalid>());
      expect(UsdcParser.parse('abc'), isA<UsdcParseInvalid>());
      expect(
        UsdcParser.parse('1.1234567'),
        isA<UsdcParseInvalid>(),
      ); // > 6 decimals
    });
  });

  group('3. CashoutQuote Invariants and Expiry', () {
    test('rejects an amount that cannot cover the full fee', () {
      final repository = MockQuoteRepository();
      expect(
        () => repository.getQuote(
          amount: DemoCashoutFixtures.canonicalTotalFee,
          bank: DemoCashoutFixtures.linkedBanks.first,
        ),
        throwsArgumentError,
      );
    });

    test('refresh creates a distinct quote ID', () {
      final repository = MockQuoteRepository();
      final original = repository.getQuote(
        amount: DemoCashoutFixtures.canonicalSellAmount,
        bank: DemoCashoutFixtures.linkedBanks.first,
      );
      final refreshed = repository.getQuote(
        amount: original.sellAmount,
        bank: DemoCashoutFixtures.linkedBanks.first,
        forceNewId: true,
      );
      expect(refreshed.quoteId, isNot(original.quoteId));
    });

    test('expiration logic with injected clock', () {
      var simulatedTime = DateTime(2026, 9, 5, 14, 0, 0);
      final quote = DemoCashoutFixtures.createCanonicalQuote(
        now: simulatedTime,
      );

      expect(quote.isExpiredAt(simulatedTime), isFalse);
      expect(quote.remainingSecondsAt(simulatedTime), equals(30));

      // Advance by 15s
      simulatedTime = simulatedTime.add(const Duration(seconds: 15));
      expect(quote.isExpiredAt(simulatedTime), isFalse);
      expect(quote.remainingSecondsAt(simulatedTime), equals(15));

      // Advance past 30s
      simulatedTime = simulatedTime.add(const Duration(seconds: 16));
      expect(quote.isExpiredAt(simulatedTime), isTrue);
      expect(quote.remainingSecondsAt(simulatedTime), equals(0));
    });
  });

  group('4. CashoutScreen UI, Chips, and Validation', () {
    testWidgets('initial value 100 USDC shows exact 2.418.520 VND preview', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: NivexTheme.light, home: const CashoutScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('100'), findsOneWidget);
      expect(find.text('2.418.520 VND'), findsOneWidget);
      expect(find.text('Khả dụng: 880,00 USDC'), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.text('Xem báo giá quy đổi'), findsOneWidget);
    });

    testWidgets('quick chips 25%, 50%, 75%, Tối đa calculate correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: NivexTheme.light, home: const CashoutScreen()),
      );
      await tester.pumpAndSettle();

      // Tap 25% (25% of 880 = 220)
      await tester.tap(find.text('25%'));
      await tester.pumpAndSettle();
      expect(find.text('220'), findsOneWidget);

      // Tap 50% (50% of 880 = 440)
      await tester.tap(find.text('50%'));
      await tester.pumpAndSettle();
      expect(find.text('440'), findsOneWidget);

      // Tap 75% (75% of 880 = 660)
      await tester.tap(find.text('75%'));
      await tester.pumpAndSettle();
      expect(find.text('660'), findsOneWidget);

      // Tap Tối đa (880)
      await tester.tap(find.text('Tối đa'));
      await tester.pumpAndSettle();
      expect(find.text('880'), findsOneWidget);
    });

    testWidgets('exceeding balance shows inline error and disables submit', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: NivexTheme.light, home: const CashoutScreen()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '950');
      await tester.pumpAndSettle();

      expect(find.text('Vượt quá số dư'), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -400));
      await tester.pumpAndSettle();
      final submitBtn = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Xem báo giá quy đổi'),
      );
      expect(submitBtn.onPressed, isNull);
    });

    testWidgets('zero amount disables submit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: NivexTheme.light, home: const CashoutScreen()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '0');
      await tester.pumpAndSettle();

      expect(find.text('Số tiền phải lớn hơn 0 USDC'), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -400));
      await tester.pumpAndSettle();
      final submitBtn = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Xem báo giá quy đổi'),
      );
      expect(submitBtn.onPressed, isNull);
    });

    testWidgets('amount at or below total fee is rejected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: NivexTheme.light, home: const CashoutScreen()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '1.51');
      await tester.pumpAndSettle();

      expect(
        find.text('Số tiền phải lớn hơn tổng phí 1,51 USDC'),
        findsOneWidget,
      );
    });
  });

  group('5. TransactionAuthSheet, Biometrics & PIN Lockout Persistence', () {
    testWidgets('successful PIN 123456 returns TransactionAuthSuccess', (
      tester,
    ) async {
      final fakeBio = FakeBiometricAuthClient();
      final authService = CashoutAuthService(
        biometricClient: fakeBio,
        stateStore: InMemoryCashoutAuthStateStore(),
      );
      final quote = DemoCashoutFixtures.createCanonicalQuote();

      TransactionAuthResult? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  result = await TransactionAuthSheet.show(
                    context: ctx,
                    quote: quote,
                    authService: authService,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Xác thực giao dịch'), findsOneWidget);
      expect(find.text('100,00 USDC'), findsOneWidget);
      expect(find.text('2.418.520 VND'), findsOneWidget);

      for (final d in ['1', '2', '3', '4', '5', '6']) {
        await tester.tap(find.text(d).last);
        await tester.pump(const Duration(milliseconds: 30));
      }
      await tester.pumpAndSettle();

      expect(result, isA<TransactionAuthSuccess>());
      expect((result as TransactionAuthSuccess).method, equals(AuthMethod.pin));
    });

    testWidgets('wrong PIN decrements attempts and 5 failures locks for 30s', (
      tester,
    ) async {
      final fakeBio = FakeBiometricAuthClient();
      final store = InMemoryCashoutAuthStateStore();
      final authService = CashoutAuthService(
        biometricClient: fakeBio,
        stateStore: store,
      );
      final quote = DemoCashoutFixtures.createCanonicalQuote();

      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => TransactionAuthSheet.show(
                  context: ctx,
                  quote: quote,
                  authService: authService,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Enter wrong PIN: 1 1 1 1 1 1
      for (final _ in [1, 2, 3, 4, 5]) {
        for (var i = 0; i < 6; i++) {
          await tester.tap(find.text('1').last);
          await tester.pump(const Duration(milliseconds: 20));
        }
        await tester.pumpAndSettle();
      }

      expect(authService.isLocked(), isTrue);
      expect(
        find.textContaining('Xác thực giao dịch bị tạm khóa'),
        findsOneWidget,
      );

      // Close bottom sheet
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // REOPEN sheet: MUST PRESERVE LOCKOUT STATE!
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Xác thực giao dịch bị tạm khóa'),
        findsOneWidget,
      );

      final restoredService = CashoutAuthService(
        biometricClient: fakeBio,
        stateStore: store,
      );
      await restoredService.initialize();
      expect(restoredService.isLocked(), isTrue);
    });

    testWidgets('biometric success returns TransactionAuthSuccess', (
      tester,
    ) async {
      final fakeBio = FakeBiometricAuthClient(
        canAuth: true,
        initialResult: BiometricAuthSuccess(authenticatedAt: DateTime.now()),
      );
      final authService = CashoutAuthService(
        biometricClient: fakeBio,
        stateStore: InMemoryCashoutAuthStateStore(),
      );
      final quote = DemoCashoutFixtures.createCanonicalQuote();

      TransactionAuthResult? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  result = await TransactionAuthSheet.show(
                    context: ctx,
                    quote: quote,
                    authService: authService,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Xác thực bằng Sinh trắc học'));
      await tester.pumpAndSettle();

      expect(result, isA<TransactionAuthSuccess>());
      expect(
        (result as TransactionAuthSuccess).method,
        equals(AuthMethod.biometric),
      );
    });
  });

  group('6. QuoteScreen 30s Countdown and Post-Auth Expiry Check', () {
    testWidgets('QuoteScreen disables CTA when expired and refreshes', (
      tester,
    ) async {
      var simulatedTime = DateTime(2026, 9, 5, 14, 0, 0);
      final quoteRepo = MockQuoteRepository(clock: () => simulatedTime);
      final quote = quoteRepo.getQuote(
        amount: DemoCashoutFixtures.canonicalSellAmount,
        bank: DemoCashoutFixtures.linkedBanks.first,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.light,
          home: QuoteScreen(
            quote: quote,
            clock: () => simulatedTime,
            quoteRepository: quoteRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2.418.520 VND'), findsOneWidget);
      expect(find.text('Báo giá còn hiệu lực 0:30'), findsOneWidget);

      // Advance time past 30s
      simulatedTime = simulatedTime.add(const Duration(seconds: 31));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Báo giá đã hết hạn'), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -400));
      await tester.pumpAndSettle();
      final confirmBtn = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Tiếp tục xác thực'),
      );
      expect(confirmBtn.onPressed, isNull);

      // Refresh quote
      await tester.drag(find.byType(ListView).last, const Offset(0, 400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lấy báo giá mới'));
      await tester.pumpAndSettle();

      expect(find.text('Báo giá còn hiệu lực 0:30'), findsOneWidget);
    });

    testWidgets(
      'post-auth quote expiry blocks transition to ProcessingScreen',
      (tester) async {
        var simulatedTime = DateTime(2026, 9, 5, 14, 0, 0);
        final quoteRepo = MockQuoteRepository(clock: () => simulatedTime);
        final quote = quoteRepo.getQuote(
          amount: DemoCashoutFixtures.canonicalSellAmount,
          bank: DemoCashoutFixtures.linkedBanks.first,
        );

        final fakeBio = FakeBiometricAuthClient(
          canAuth: true,
          initialResult: BiometricAuthSuccess(authenticatedAt: simulatedTime),
        );
        final authService = CashoutAuthService(
          biometricClient: fakeBio,
          clock: () => simulatedTime,
          stateStore: InMemoryCashoutAuthStateStore(),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: NivexTheme.light,
            home: QuoteScreen(
              quote: quote,
              clock: () => simulatedTime,
              authService: authService,
              quoteRepository: quoteRepo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open auth sheet
        await tester.drag(find.byType(ListView).last, const Offset(0, -400));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Tiếp tục xác thực'));
        await tester.pumpAndSettle();

        // SIMULATE EXPIRATION while user was in sheet!
        simulatedTime = simulatedTime.add(const Duration(seconds: 35));

        // User enters PIN
        for (final d in ['1', '2', '3', '4', '5', '6']) {
          await tester.tap(find.text(d).last);
          await tester.pump(const Duration(milliseconds: 20));
        }
        await tester.pumpAndSettle();

        // Must remain on QuoteScreen and show expiry warning
        expect(find.byType(ProcessingScreen), findsNothing);
        expect(
          find.textContaining('Báo giá đã hết hạn trong quá trình xác thực'),
          findsOneWidget,
        );
      },
    );
  });

  group('7. ProcessingScreen States and Error Taxonomy', () {
    testWidgets(
      'timeoutUnknown displays exact required copy and NO retry button',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: NivexTheme.light,
            home: const ProcessingScreen(
              initialStatus: CashoutProcessingStatus.timeoutUnknown,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Chưa xác định được kết quả'), findsOneWidget);
        expect(
          find.text(
            'Chúng tôi chưa nhận được trạng thái cuối cùng.\nKhông thực hiện lại giao dịch lúc này.',
          ),
          findsOneWidget,
        );
        expect(find.text('Kiểm tra lại trạng thái'), findsOneWidget);
        expect(find.text('Liên hệ hỗ trợ'), findsOneWidget);

        // Verify ABSENCE of "Chưa có giao dịch nào được thực hiện"
        expect(
          find.textContaining('Chưa có giao dịch nào được thực hiện'),
          findsNothing,
        );

        // Verify ABSENCE of any retry / resend button
        expect(find.text('Thử lại'), findsNothing);
        expect(find.text('Gửi lại'), findsNothing);
      },
    );

    testWidgets('rejected displays exact "Yêu cầu bị từ chối" and disclaimer', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.light,
          home: const ProcessingScreen(
            initialStatus: CashoutProcessingStatus.rejected,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Yêu cầu bị từ chối'), findsOneWidget);
      expect(
        find.textContaining('Chưa có giao dịch nào được thực hiện.'),
        findsOneWidget,
      );
      expect(find.text('Tạo báo giá mới'), findsOneWidget);
      expect(find.text('Về Trang chủ'), findsOneWidget);
    });

    testWidgets('preSubmitFailed displays disclaimer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.light,
          home: const ProcessingScreen(
            initialStatus: CashoutProcessingStatus.preSubmitFailed,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Giao dịch chưa hoàn tất'), findsOneWidget);
      expect(
        find.textContaining('Chưa có giao dịch nào được thực hiện.'),
        findsOneWidget,
      );
      expect(find.text('Tạo báo giá mới'), findsOneWidget);
    });
  });

  group('8. ReceiptScreen Breakdown and Copy Tx ID', () {
    testWidgets(
      'displays 100 USDC debited, 1.51 fee, 98.49 converted, 2.418.520 VND',
      (tester) async {
        String? copiedData;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall methodCall) async {
            if (methodCall.method == 'Clipboard.setData') {
              copiedData = (methodCall.arguments as Map)['text'] as String?;
              return null;
            }
            return null;
          },
        );

        await tester.pumpWidget(
          MaterialApp(theme: NivexTheme.light, home: const ReceiptScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Payout VND mô phỏng hoàn tất'), findsOneWidget);
        expect(find.text('2.418.520 VND'), findsOneWidget);
        expect(find.text('-100,00 USDC'), findsOneWidget);
        expect(find.text('0,01 USDC'), findsOneWidget);
        expect(find.text('1,50 USDC'), findsOneWidget);
        expect(find.text('-1,51 USDC'), findsOneWidget);
        expect(find.text('98,49 USDC'), findsOneWidget);
        expect(find.text('1 USDC = 24.556 VND'), findsOneWidget);
        expect(find.text('Vietcombank'), findsOneWidget);
        expect(find.text('•••• 1092'), findsOneWidget);
        expect(find.text('Solana Devnet'), findsOneWidget);
        expect(find.text('NXV-20260901-0042'), findsOneWidget);

        // Tap copy icon
        await tester.drag(find.byType(ListView).last, const Offset(0, -200));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.copy_rounded));
        await tester.pump();
        expect(copiedData, equals('NXV-20260901-0042'));
        expect(find.text('Đã sao chép mã giao dịch'), findsOneWidget);
      },
    );
  });

  group('9. Environment Scopes (Demo vs Production)', () {
    testWidgets('DemoNotice shown in Demo mode, hidden in Production mode', (
      tester,
    ) async {
      // Demo mode
      await tester.pumpWidget(
        const AppEnvironmentScope(
          environment: AppEnvironment.demo,
          child: MaterialApp(home: Scaffold(body: DemoNotice())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Bản demo hackathon'), findsOneWidget);

      // Production mode
      await tester.pumpWidget(
        const AppEnvironmentScope(
          environment: AppEnvironment.production,
          child: MaterialApp(home: Scaffold(body: DemoNotice())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Bản demo hackathon'), findsNothing);
    });

    testWidgets('production removes simulation copy from cashout and receipt', (
      tester,
    ) async {
      await tester.pumpWidget(
        AppEnvironmentScope(
          environment: AppEnvironment.production,
          child: MaterialApp(
            theme: NivexTheme.light,
            home: const ReceiptScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Payout VND hoàn tất'), findsOneWidget);
      expect(find.textContaining('mô phỏng'), findsNothing);
      expect(find.textContaining('demo'), findsNothing);
      expect(find.text('Ngân hàng nhận'), findsOneWidget);
    });
  });

  group('10. Session timeout', () {
    testWidgets('timeout opens unlock sheet and logout ends the session', (
      tester,
    ) async {
      var expired = false;
      final authService = CashoutAuthService(
        biometricClient: FakeBiometricAuthClient(),
        stateStore: InMemoryCashoutAuthStateStore(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: NivexTheme.light,
          home: SessionGuard(
            authService: authService,
            timeout: const Duration(seconds: 1),
            onSessionExpired: () => expired = true,
            child: const Scaffold(body: Text('Nội dung bảo vệ')),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Phiên làm việc đã hết hạn'), findsOneWidget);

      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(expired, isTrue);
    });
  });

  group(
    '11. Multi-Dimensional QA Matrix (Viewports, Text Scales, 4 Themes)',
    () {
      final viewports = [
        const Size(320, 680), // iPhone SE / Compact
        const Size(360, 800), // Standard Android
        const Size(407, 890), // Xiaomi Redmi Note 13
        const Size(600, 960), // Tablet / Foldable
      ];

      testWidgets('no overflow across viewports and text scales', (
        tester,
      ) async {
        for (final size in viewports) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          for (final textScale in [1.0, 1.3, 1.5]) {
            for (final screen in [
              const CashoutScreen(),
              const QuoteScreen(),
              const ReceiptScreen(),
              const ProcessingScreen(
                initialStatus: CashoutProcessingStatus.timeoutUnknown,
              ),
            ]) {
              await tester.pumpWidget(
                MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: MaterialApp(theme: NivexTheme.light, home: screen),
                ),
              );
              final exc = tester.takeException();
              expect(
                exc,
                isNull,
                reason:
                    'Overflow on $screen at $size with textScale $textScale',
              );
            }
          }
        }
      });

      testWidgets('all 4 themes render correctly without hardcoded colors', (
        tester,
      ) async {
        for (final mode in AppThemeMode.values) {
          final appTheme = NivexTheme.forMode(mode);
          final tokens = appTheme.extension<NivexThemeExtension>()!;

          await tester.pumpWidget(
            MaterialApp(theme: appTheme, home: const CashoutScreen()),
          );
          await tester.pumpAndSettle();

          final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
          expect(scaffold.backgroundColor, equals(tokens.background));

          final submitBtn = tester.widget<FilledButton>(
            find.byType(FilledButton, skipOffstage: false),
          );
          expect(
            submitBtn.style?.backgroundColor?.resolve(<WidgetState>{}),
            equals(tokens.primary),
          );

          await tester.pumpWidget(
            MaterialApp(theme: appTheme, home: const QuoteScreen()),
          );
          await tester.pump();
          expect(find.text('Báo giá & xác nhận'), findsOneWidget);
          await tester.drag(find.byType(ListView), const Offset(0, -700));
          await tester.pump();
          expect(
            find.text(
              'Chưa có giao dịch nào được thực hiện. Bạn sẽ xác thực ở bước tiếp theo.',
            ),
            findsOneWidget,
          );
          await tester.ensureVisible(find.text('Tiếp tục xác thực'));
          await tester.pump();
          expect(find.text('Tiếp tục xác thực'), findsOneWidget);
          expect(
            tester.takeException(),
            isNull,
            reason: 'Quote overflowed in ${mode.label}',
          );
        }
      });
    },
  );
}
