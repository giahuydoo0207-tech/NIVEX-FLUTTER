import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nivex_flutter/features/invoices/presentation/mobile_invoices_screen.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

void main() {
  testWidgets('shows invoice details and explains missing mobile API', (
    tester,
  ) async {
    var unavailable = false;
    final api = NovaApiClient(
      config: NovaApiConfig('https://example.test'),
      readToken: () async => 'a' * 43,
      transport: MockClient((_) async {
        if (unavailable) return http.Response('{}', 404);
        return http.Response(
          jsonEncode([
            {
              'id': '1',
              'invoiceNumber': 'NOVA-DETAIL',
              'description': 'Mobile invoice',
              'amountMinor': '20000',
              'status': 'ISSUED',
              'dueDate': '2026-09-24',
            },
          ]),
          200,
        );
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(MaterialApp(home: MobileInvoicesScreen(api: api)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NOVA-DETAIL'));
    await tester.pumpAndSettle();
    expect(find.text('Hạn thanh toán: 24/09/2026'), findsOneWidget);
    expect(find.text('Solana Devnet'), findsOneWidget);
    Navigator.of(tester.element(find.text('Solana Devnet'))).pop();
    await tester.pumpAndSettle();
    unavailable = true;
    await tester.tap(find.byTooltip('Tải lại'));
    await tester.pumpAndSettle();
    expect(
      find.text('Máy chủ chưa hỗ trợ dữ liệu Mobile. Vui lòng thử lại sau.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'transactions paginate, show details and clear both tabs on expiry',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var expired = false;
      final offsets = <String>[];
      final api = NovaApiClient(
        config: NovaApiConfig('https://example.test'),
        readToken: () async => 'a' * 43,
        transport: MockClient((request) async {
          if (expired) return http.Response('{}', 401);
          if (request.url.path.endsWith('/invoices')) {
            return http.Response(
              '[{"id":"1","invoiceNumber":"NOVA-1","description":"Invoice","amountMinor":"20000","status":"PAID_ON_CHAIN"}]',
              200,
            );
          }
          offsets.add(request.url.queryParameters['offset']!);
          final offset = int.parse(offsets.last);
          return http.Response(
            jsonEncode(
              List.generate(
                offset == 0 ? 25 : 1,
                (i) => {
                  'signature': 'signature-${offset + i}',
                  'amountMinor': '20000',
                  'recipient': 'r' * 44,
                  'mint': 'm' * 44,
                  'recordedAt': '2026-09-22T00:00:00Z',
                },
              ),
            ),
            200,
          );
        }),
      );
      addTearDown(api.close);
      await tester.pumpWidget(
        MaterialApp(home: MobileInvoicesScreen(api: api)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Giao dịch'));
      await tester.pumpAndSettle();
      expect(find.text('NOVA-1'), findsNothing);
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      expect(find.text('signature-0'), findsOneWidget);
      expect(tester.takeException(), isNull);
      Navigator.of(tester.element(find.text('Giao dịch Devnet'))).pop();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Tải thêm'), 500);
      await tester.tap(find.text('Tải thêm'));
      await tester.pumpAndSettle();
      expect(offsets, ['0', '25']);
      expect(find.text('Tải thêm'), findsNothing);
      expired = true;
      await tester.tap(find.byTooltip('Tải lại'));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNothing);
      await tester.ensureVisible(find.text('Hóa đơn'));
      await tester.tap(find.text('Hóa đơn'));
      await tester.pumpAndSettle();
      expect(find.text('NOVA-1'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'renders real invoice, refreshes, and clears data on expired session',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var calls = 0;
      final api = NovaApiClient(
        config: NovaApiConfig('https://example.test'),
        readToken: () async => 'a' * 43,
        transport: MockClient((_) async {
          calls++;
          return calls == 1
              ? http.Response(
                  '[{"id":"1","invoiceNumber":"NOVA-2026-0006","description":"Test invoice","amountMinor":"20000","status":"PAID_ON_CHAIN"}]',
                  200,
                )
              : http.Response('{}', 401);
        }),
      );
      addTearDown(api.close);
      await tester.pumpWidget(
        MaterialApp(home: MobileInvoicesScreen(api: api)),
      );
      await tester.pumpAndSettle();
      expect(find.text('NOVA-2026-0006'), findsOneWidget);
      expect(find.text('0.02 USDC'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Tải lại'));
      await tester.pumpAndSettle();
      expect(find.text('NOVA-2026-0006'), findsNothing);
      expect(
        find.text('Phiên truy cập chưa có hoặc đã hết hạn.'),
        findsOneWidget,
      );
    },
  );
}
