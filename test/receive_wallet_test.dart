import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nivex_flutter/features/wallet/data/receive_wallet_controller.dart';
import 'package:nivex_flutter/features/wallet/domain/solana_address.dart';
import 'package:nivex_flutter/features/wallet/presentation/wallet_screen.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

const _walletA = '3fgEzVyVySaGd7N1QCbwhiPPyoFUwjSsVfnPCARsHjQ4';
const _walletB = 'HcPgN1L8NC1TQq2TboHPi2GX763FGSE3r3zDiiNLCgqY';
const _mint = 'BRjpCHtyQLNCo8gqRUr8jtdAj5AjPYQaoqbvcZiHok1k';

String _wallet(String? address) => jsonEncode({
  'status': address == null ? 'NOT_CONFIGURED' : 'CONFIGURED',
  'walletAddress': address,
  'network': 'solana:devnet',
  'tokenSymbol': 'USDC',
  'tokenMint': _mint,
  'ownershipVerified': false,
  'createdAt': address == null ? null : '2026-09-30T01:00:00Z',
  'updatedAt': address == null ? null : '2026-09-30T01:00:00Z',
});

String _summary({
  String status = 'NOT_CONFIGURED',
  String? address,
  String personal = '0',
  String legacy = '0',
  String pending = '0',
}) => jsonEncode({
  'availableBalanceMinor': personal,
  'availableBalanceUsdc': '0.00',
  'paidToPersonalWalletMinor': personal,
  'paidToPersonalWalletUsdc': '0.00',
  'paidViaDemoWalletMinor': legacy,
  'paidViaDemoWalletUsdc': '0.00',
  'earnedLast7DaysMinor': '0',
  'earnedLast7DaysUsdc': '0.00',
  'pendingBalanceMinor': pending,
  'pendingBalanceUsdc': '0.00',
  'currency': 'USDC',
  'network': 'devnet',
  'payoutWalletStatus': status,
  'isDemoWallet': false,
  'walletAddress': address,
  'demoRecipientAddress': null,
  'lastUpdatedAt': '2026-09-30T01:00:00Z',
});

http.Response _json(String body, [int status = 200]) => http.Response.bytes(
  utf8.encode(body),
  status,
  headers: {'content-type': 'application/json'},
);

/// A backend holding one wallet; [failWrites] makes PUT/DELETE fail.
class _FakeBackend {
  String? address;
  http.Response? failWrites;
  final requests = <String>[];
  final bodies = <Map<String, dynamic>>[];

  Future<http.Response> handle(http.Request request) async {
    requests.add('${request.method} ${request.url.path}');
    if (request.url.path == '/api/v1/mobile/wallet/receive') {
      if (request.method != 'GET' && failWrites != null) return failWrites!;
      if (request.method == 'PUT') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        bodies.add(body);
        address = body['walletAddress'] as String;
      } else if (request.method == 'DELETE') {
        address = null;
      }
      return _json(_wallet(address));
    }
    if (request.url.path == '/api/v1/mobile/wallet/summary') {
      return _json(
        _summary(
          status: address == null ? 'NOT_CONFIGURED' : 'CONFIGURED',
          address: address,
        ),
      );
    }
    if (request.url.path == '/api/v1/mobile/wallet/transactions') {
      return _json('[]');
    }
    return http.Response('{}', 404);
  }
}

NovaApiClient _client(Future<http.Response> Function(http.Request) handler) =>
    NovaApiClient(
      config: NovaApiConfig('https://example.test'),
      readToken: () async => 'a' * 43,
      transport: MockClient(handler),
    );

void main() {
  test('parses configured, missing and invalid receive wallets', () {
    final configured = NovaReceiveWallet.fromJson(
      jsonDecode(_wallet(_walletA)) as Map<String, dynamic>,
    );
    expect(configured.isConfigured, isTrue);
    expect(configured.walletAddress, _walletA);
    expect(configured.network, 'solana:devnet');
    expect(configured.tokenMint, _mint);

    final missing = NovaReceiveWallet.fromJson(
      jsonDecode(_wallet(null)) as Map<String, dynamic>,
    );
    expect(missing.isConfigured, isFalse);
    expect(missing.walletAddress, isNull);

    final invalid = NovaReceiveWallet.fromJson({
      ...jsonDecode(_wallet(_walletA)) as Map<String, dynamic>,
      'status': 'INVALID',
    });
    expect(invalid.isConfigured, isFalse);

    for (final broken in [
      {...jsonDecode(_wallet(null)) as Map<String, dynamic>, 'status': 'CONFIGURED'},
      {...jsonDecode(_wallet(_walletA)) as Map<String, dynamic>, 'status': 'READY?'},
    ]) {
      expect(() => NovaReceiveWallet.fromJson(broken), throwsFormatException);
    }
  });

  test('adds, edits and removes the wallet, reloading from the backend', () async {
    final backend = _FakeBackend();
    final api = _client(backend.handle);
    addTearDown(api.close);
    final controller = ReceiveWalletController(api);
    await controller.load();
    expect(controller.wallet!.isConfigured, isFalse);

    expect(await controller.save('  $_walletA \n'), isNull);
    expect(controller.wallet!.walletAddress, _walletA);
    // Only the public address, the network and the explicit confirmation are sent.
    expect(backend.bodies.single, {
      'walletAddress': _walletA,
      'network': 'solana:devnet',
      'confirmPublicAddress': true,
    });

    expect(await controller.save(_walletB), isNull);
    expect(controller.wallet!.walletAddress, _walletB);

    expect(await controller.remove(), isNull);
    expect(controller.wallet!.isConfigured, isFalse);
    expect(backend.requests, [
      'GET /api/v1/mobile/wallet/receive',
      'PUT /api/v1/mobile/wallet/receive',
      'GET /api/v1/mobile/wallet/receive',
      'PUT /api/v1/mobile/wallet/receive',
      'GET /api/v1/mobile/wallet/receive',
      'DELETE /api/v1/mobile/wallet/receive',
      'GET /api/v1/mobile/wallet/receive',
    ]);
  });

  test('a failed save or removal keeps the previous wallet and explains why', () async {
    final backend = _FakeBackend()..address = _walletA;
    final api = _client(backend.handle);
    addTearDown(api.close);
    final controller = ReceiveWalletController(api);
    await controller.load();

    backend.failWrites = _json(
      jsonEncode({
        'status': 400,
        'code': 'NOT_A_WALLET_ADDRESS',
        'message': 'Đây là địa chỉ chương trình hoặc tài khoản token, không phải ví cá nhân.',
      }),
      400,
    );
    final rejected = await controller.save(_walletB);
    expect(rejected, contains('không phải ví cá nhân'));
    expect(controller.wallet!.walletAddress, _walletA);

    backend.failWrites = http.Response('upstream down', 503);
    final removed = await controller.remove();
    expect(removed, contains('HTTP 503'));
    expect(removed, contains('vẫn giữ nguyên'));
    expect(controller.wallet!.walletAddress, _walletA);
    expect(backend.address, _walletA);
  });

  test('a lost connection keeps the previous wallet', () async {
    var offline = false;
    final backend = _FakeBackend()..address = _walletA;
    final api = _client((request) async {
      if (offline) throw http.ClientException('offline');
      return backend.handle(request);
    });
    addTearDown(api.close);
    final controller = ReceiveWalletController(api);
    await controller.load();
    offline = true;
    final error = await controller.save(_walletB);
    expect(error, contains('Không kết nối được máy chủ'));
    expect(controller.wallet!.walletAddress, _walletA);
  });

  test('never sends seed phrases, secret keys or malformed text', () async {
    final backend = _FakeBackend();
    final api = _client(backend.handle);
    addTearDown(api.close);
    final controller = ReceiveWalletController(api);
    final secretKey = '5' * 44 + 'K' * 44;
    const seed =
        'abandon ability able about above absent absorb abstract absurd abuse access accident';
    for (final value in [
      seed,
      secretKey,
      '[12,34,56,78]',
      'https://explorer.solana.com/address/$_walletA',
      '${_walletA.substring(0, 43)}0',
      '',
    ]) {
      final error = await controller.save(value);
      expect(error, isNotNull, reason: value);
      if (value.isNotEmpty) expect(error, isNot(contains(value)));
    }
    expect(backend.requests, isEmpty);
    expect(checkSolanaAddress(_walletA), isNull);
    expect(decodeBase58(_walletA)!.length, 32);
    expect(shortSolanaAddress(_walletA), '3fgE…HjQ4');
  });

  test('summary separates personal, pending and legacy demo payments', () async {
    final api = _client(
      (_) async => _json(
        _summary(
          status: 'CONFIGURED',
          address: _walletA,
          personal: '1000000',
          legacy: '250000',
          pending: '2000000',
        ),
      ),
    );
    addTearDown(api.close);
    final summary = await api.walletSummary();
    expect(summary.hasPayoutWallet, isTrue);
    expect(summary.paidToPersonalWalletMinor, BigInt.from(1000000));
    expect(summary.paidViaDemoWalletMinor, BigInt.from(250000));
    expect(summary.pendingBalanceMinor, BigInt.from(2000000));
    expect(summary.walletAddress, _walletA);

    final transactions = _client(
      (_) async => _json(
        jsonEncode([
          {
            'signature': '2' * 88,
            'amountMinor': '1000000',
            'recipient': _walletA,
            'mint': _mint,
            'recordedAt': '2026-09-30T01:00:00Z',
            'invoiceId': 'inv-1',
            'invoiceNumber': 'NOVA-2026-0001',
            'token': 'USDC',
            'network': 'solana:devnet',
            'status': 'PAID_ON_CHAIN',
            'recipientKind': 'CONTRACTOR_WALLET',
            'createdAt': '2026-09-30T01:00:00Z',
          },
          {
            'signature': '4' * 88,
            'amountMinor': '250000',
            'recipient': 'Eiz8weAjGbquFPPw98EkgLeQyoRkH2i9hUzqLHh64dyr',
            'mint': _mint,
            'recordedAt': '2026-09-01T01:00:00Z',
            'recipientKind': 'LEGACY_DEMO',
          },
        ]),
      ),
    );
    addTearDown(transactions.close);
    final items = await transactions.walletTransactions();
    expect(items.first.isLegacyDemo, isFalse);
    expect(items.first.invoiceNumber, 'NOVA-2026-0001');
    expect(items.first.status, 'PAID_ON_CHAIN');
    expect(items.first.network, 'solana:devnet');
    expect(items.last.isLegacyDemo, isTrue);
  });

  Future<void> pumpWallet(WidgetTester tester, NovaApiClient api) async {
    tester.view.physicalSize = const Size(480, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WalletScreen(
            api: api,
            onReceive: () {},
            onCashout: () {},
            onQuote: () {},
            onHistory: () {},
            onHelp: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectNoDemoBalances() {
    for (final demo in ['880', '500.00', '500,00', '0.40', '22.480.000', '12.500.000']) {
      expect(find.textContaining(demo), findsNothing, reason: demo);
    }
  }

  testWidgets('live wallet shows the real, unconfigured state and no demo balance', (
    tester,
  ) async {
    final backend = _FakeBackend();
    final api = _client(backend.handle);
    addTearDown(api.close);
    await pumpWallet(tester, api);
    expect(find.text('Chưa cấu hình ví nhận tiền'), findsOneWidget);
    expect(find.text('Chưa cấu hình'), findsOneWidget);
    expect(find.text('Thêm ví'), findsOneWidget);
    expectNoDemoBalances();
  });

  testWidgets('a failing live backend never falls back to demo numbers', (
    tester,
  ) async {
    final api = _client((_) async => http.Response('boom', 500));
    addTearDown(api.close);
    await pumpWallet(tester, api);
    expect(find.text('Chưa tải được ví. Thử lại'), findsOneWidget);
    expectNoDemoBalances();
  });

  testWidgets('adding a wallet requires confirmation; a rejected edit keeps the old one', (
    tester,
  ) async {
    final backend = _FakeBackend();
    final api = _client(backend.handle);
    addTearDown(api.close);
    await pumpWallet(tester, api);

    await tester.tap(find.text('Thêm ví'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nova không bao giờ hỏi private key'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('receive-wallet-input')), _walletA);
    await tester.pump();
    final save = find.byKey(const Key('receive-wallet-save'));
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    await tester.tap(find.byKey(const Key('receive-wallet-confirm')));
    await tester.pump();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text(_walletA), findsOneWidget);
    expect(find.text('Đã cấu hình'), findsOneWidget);

    backend.failWrites = _json(
      jsonEncode({'code': 'INVALID_WALLET_ADDRESS', 'message': 'Địa chỉ ví không hợp lệ.'}),
      400,
    );
    await tester.tap(find.byKey(const Key('receive-wallet-edit')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('receive-wallet-input')), _walletB);
    await tester.tap(find.byKey(const Key('receive-wallet-confirm')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('receive-wallet-save')));
    await tester.pumpAndSettle();
    expect(find.text('Địa chỉ ví không hợp lệ.'), findsOneWidget);
    Navigator.of(tester.element(find.byKey(const Key('receive-wallet-input')))).pop();
    await tester.pumpAndSettle();
    expect(find.text(_walletA), findsOneWidget);
    expect(find.text(_walletB), findsNothing);

    backend.failWrites = null;
    await tester.tap(find.byKey(const Key('receive-wallet-delete')));
    await tester.pumpAndSettle();
    expect(find.text('Xóa ví nhận tiền?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('receive-wallet-confirm-delete')));
    await tester.pumpAndSettle();
    expect(find.text('Chưa cấu hình'), findsOneWidget);
    expect(backend.address, isNull);
    expect(tester.takeException(), isNull);
  });
}
