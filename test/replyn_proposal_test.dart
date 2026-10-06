import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nivex_flutter/app/theme/app_theme_mode.dart';
import 'package:nivex_flutter/app/theme/nivex_theme.dart';
import 'package:nivex_flutter/features/jobs/data/application_controller.dart';
import 'package:nivex_flutter/features/jobs/data/remote_application_controller.dart';
import 'package:nivex_flutter/features/jobs/domain/job_application.dart';
import 'package:nivex_flutter/features/jobs/domain/job_opportunity.dart';
import 'package:nivex_flutter/features/jobs/presentation/application_thread_screen.dart';
import 'package:nivex_flutter/features/replyn_proposals/domain/replyn_proposal.dart';
import 'package:nivex_flutter/features/replyn_proposals/presentation/replyn_proposal_card.dart';
import 'package:nivex_flutter/features/replyn_proposals/presentation/replyn_proposal_screen.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

// Made-up ids; no real Nova data.
const _threadId = '0b7c9d2e-1f3a-4b5c-8d6e-7f8091a2b3c4';
const _proposalId = '5d4c3b2a-1908-4f7e-8d6c-5b4a39281706';
const _workspaceId = '9a8b7c6d-5e4f-4a3b-9c2d-1e0f9a8b7c6d';

Map<String, dynamic> _proposalJson({
  String status = 'PENDING',
  String? workspaceId,
}) => {
  'id': _proposalId,
  'threadId': _threadId,
  'status': status,
  'projectName': 'Landing page mùa thu',
  'scope': 'Thiết kế và code landing page 6 section.',
  'deliverables': ['File Figma', 'Mã nguồn Next.js'],
  'revisionLimit': 2,
  'currency': 'USDC',
  'totalAmount': 2500.00,
  'startDate': '2026-10-12',
  'deadline': '2026-11-10',
  'reviewPeriodDays': 3,
  'milestones': [
    {'title': 'Thiết kế UI', 'amount': 1000, 'deadline': '2026-10-25'},
    {'title': 'Code & bàn giao', 'amount': 1500, 'deadline': '2026-11-10'},
  ],
  'notes': '',
  'sentAt': '2026-10-05T03:00:00Z',
  'expiresAt': '2026-10-12T03:00:00Z',
  'workspaceId': workspaceId,
};

Map<String, Object?> _threadJson(String proposalStatus) => {
  'id': _threadId,
  'organizationName': 'Nova Labs',
  'candidateName': 'Minh Anh',
  'requestStatus': 'ACCEPTED',
  'unreadForTalent': 0,
  'updatedAt': '2026-10-05T03:00:00Z',
  'messages': <Object>[],
  'replynProposals': [
    _proposalJson(
      status: proposalStatus,
      workspaceId: proposalStatus == 'ACCEPTED' ? _workspaceId : null,
    ),
  ],
};

http.Response _jsonResponse(Object body) =>
    http.Response.bytes(utf8.encode(jsonEncode(body)), 200);

/// Polls until [condition] holds; the fake backend answers asynchronously.
Future<void> _until(bool Function() condition) async {
  for (var i = 0; i < 200 && !condition(); i++) {
    await Future<void>.delayed(Duration.zero);
  }
  expect(condition(), isTrue);
}

class _FakeController extends ApplicationController {
  _FakeController(this.proposal);

  ReplynProposal proposal;
  final calls = <String>[];

  /// When set, the response waits for it, like a slow network.
  Completer<void>? gate;

  JobApplication get _conversation => JobApplication(
    id: 'thread-$_threadId',
    jobId: '',
    jobTitle: 'Trò chuyện trực tiếp',
    organizationName: 'Nova Labs',
    candidateName: 'Minh Anh',
    candidateHeadline: '',
    candidateEmail: '',
    location: '',
    coverNote: '',
    portfolioLabel: '',
    availability: '',
    status: JobApplicationStatus.submitted,
    submittedAt: DateTime.utc(2026, 10, 5, 2),
    messages: [
      JobApplicationMessage(
        id: 'm1',
        role: JobMessageRole.business,
        senderName: 'Nova Labs',
        body: 'Chào bạn, mình gửi đề xuất nhé.',
        sentAt: DateTime.utc(2026, 10, 5, 2, 59),
      ),
    ],
    threadId: _threadId,
    threadStatus: 'ACCEPTED',
    replynProposals: [proposal],
  );

  @override
  List<JobOpportunity> get jobs => const [];
  @override
  List<JobApplication> get applications => const [];
  @override
  List<JobApplication> get conversations => [_conversation];
  @override
  JobApplication? forJob(String jobId) => null;
  @override
  JobApplication? byId(String applicationId) =>
      applicationId == _conversation.id ? _conversation : null;
  @override
  Future<JobApplication?> apply(JobOpportunity job) async => null;
  @override
  Future<bool> sendTalentMessage(
    String applicationId,
    String body, {
    String? replyToId,
  }) async => true;

  @override
  Future<String?> respondToProposal(
    String applicationId,
    String proposalId, {
    required bool accept,
    String? reason,
  }) async {
    calls.add('${accept ? 'accept' : 'reject'}:$proposalId:${reason ?? ''}');
    final pending = gate;
    if (pending != null) await pending.future;
    proposal = ReplynProposal.tryParse(
      _proposalJson(
        status: accept ? 'ACCEPTED' : 'REJECTED',
        workspaceId: accept ? _workspaceId : null,
      ),
    )!;
    notifyListeners();
    return null;
  }
}

Widget _app(Widget home) =>
    MaterialApp(theme: NivexTheme.forMode(AppThemeMode.cyberNight), home: home);

void main() {
  test('parses a sent proposal and ignores drafts or malformed rows', () {
    final proposal = ReplynProposal.tryParse(_proposalJson())!;
    expect(proposal.status, ReplynProposalStatus.pending);
    expect(proposal.totalAmount, 2500);
    expect(proposal.milestones, hasLength(2));
    expect(proposal.deliverables, ['File Figma', 'Mã nguồn Next.js']);
    expect(proposal.talentStatusLabel, 'Chờ bạn xác nhận');
    expect(ReplynProposal.tryParse(_proposalJson(status: 'DRAFT')), isNull);
    expect(
      ReplynProposal.tryParse({..._proposalJson(), 'sentAt': null}),
      isNull,
    );
    expect(ReplynProposal.tryParse('nope'), isNull);
  });

  test('threads from an older backend without proposals still parse', () {
    final base = {
      'id': _threadId,
      'organizationName': 'Nova Labs',
      'requestStatus': 'ACCEPTED',
      'updatedAt': '2026-10-05T03:00:00Z',
      'messages': <Object>[],
    };
    expect(NovaMessageThread.fromJson(base).replynProposals, isEmpty);
    final withProposals = NovaMessageThread.fromJson({
      ...base,
      'replynProposals': [_proposalJson(), _proposalJson(status: 'DRAFT')],
    });
    expect(withProposals.replynProposals.single.id, _proposalId);
  });

  test('workspace links carry only the opaque id', () {
    expect(
      replynWorkspaceUri('replyn-web.vercel.app', _workspaceId).toString(),
      'https://replyn-web.vercel.app/workspace/$_workspaceId',
    );
  });

  testWidgets(
    'the conversation shows the proposal as a card that opens the details',
    (tester) async {
      final controller = _FakeController(
        ReplynProposal.tryParse(_proposalJson())!,
      );
      await tester.pumpWidget(
        _app(
          ApplicationThreadScreen(
            applicationId: 'thread-$_threadId',
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ĐỀ XUẤT REPLYN'), findsOneWidget);
      expect(find.text('Landing page mùa thu'), findsOneWidget);
      expect(find.text('Chờ bạn xác nhận'), findsOneWidget);
      // The talent never gets an action to propose Replyn themselves.
      expect(find.textContaining('Đề xuất Replyn'), findsNothing);

      await tester.tap(
        find.byKey(const Key('replyn-proposal-open-$_proposalId')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ReplynProposalScreen), findsOneWidget);
      expect(find.byKey(const Key('replyn-proposal-accept')), findsOneWidget);
    },
  );

  testWidgets(
    'accepting asks for confirmation and then offers to open Replyn',
    (tester) async {
      final controller = _FakeController(
        ReplynProposal.tryParse(_proposalJson())!,
      );
      await tester.pumpWidget(
        _app(
          ReplynProposalScreen(
            controller: controller,
            applicationId: 'thread-$_threadId',
            proposalId: _proposalId,
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('replyn-proposal-accept')));
      await tester.pumpAndSettle();
      expect(find.text('Chấp nhận đề xuất?'), findsOneWidget);
      expect(controller.calls, isEmpty);

      await tester.tap(find.byKey(const Key('replyn-proposal-accept-confirm')));
      await tester.pumpAndSettle();
      expect(controller.calls, ['accept:$_proposalId:']);
      expect(find.text('Đã chấp nhận · Mở Replyn'), findsOneWidget);
      expect(find.byKey(const Key('replyn-proposal-accept')), findsNothing);

      await tester.tap(find.byKey(const Key('replyn-proposal-open-replyn')));
      await tester.pumpAndSettle();
      expect(
        find.text('https://replyn-web.vercel.app/workspace/$_workspaceId'),
        findsOneWidget,
      );
    },
  );

  testWidgets('rejecting sends the optional reason and creates no workspace', (
    tester,
  ) async {
    final controller = _FakeController(
      ReplynProposal.tryParse(_proposalJson())!,
    );
    await tester.pumpWidget(
      _app(
        ReplynProposalScreen(
          controller: controller,
          applicationId: 'thread-$_threadId',
          proposalId: _proposalId,
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('replyn-proposal-reject')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('replyn-proposal-reject-reason')),
      'Deadline chưa phù hợp',
    );
    await tester.tap(find.byKey(const Key('replyn-proposal-reject-confirm')));
    await tester.pumpAndSettle();
    expect(controller.calls, ['reject:$_proposalId:Deadline chưa phù hợp']);
    expect(find.text('Đã từ chối'), findsOneWidget);
    expect(find.byKey(const Key('replyn-proposal-open-replyn')), findsNothing);
    expect(controller.proposal.workspaceId, isNull);
  });

  test('a proposal without a currency shows no guessed unit', () {
    final proposal = ReplynProposal.tryParse({
      ..._proposalJson(),
      'currency': null,
    })!;
    expect(proposal.currency, isNull);
    expect(formatProposalAmount(proposal.totalAmount, proposal.currency), '—');
    expect(
      formatSimulatedProposalAmount(proposal.totalAmount, proposal.currency),
      '—',
    );
  });

  testWidgets('the card marks the budget as simulated', (tester) async {
    final controller = _FakeController(
      ReplynProposal.tryParse(_proposalJson())!,
    );
    await tester.pumpWidget(
      _app(
        ApplicationThreadScreen(
          applicationId: 'thread-$_threadId',
          controller: controller,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2.500 USDC (mô phỏng)'), findsOneWidget);
  });

  testWidgets(
    'a second tap while confirming or sending sends only one response',
    (tester) async {
      final controller = _FakeController(
        ReplynProposal.tryParse(_proposalJson())!,
      )..gate = Completer<void>();
      await tester.pumpWidget(
        _app(
          ReplynProposalScreen(
            controller: controller,
            applicationId: 'thread-$_threadId',
            proposalId: _proposalId,
          ),
        ),
      );
      final accept = find.byKey(const Key('replyn-proposal-accept'));
      final reject = find.byKey(const Key('replyn-proposal-reject'));

      // Double tap before the dialog is on screen: still one dialog.
      await tester.tap(accept);
      await tester.tap(accept, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Chấp nhận đề xuất?'), findsOneWidget);

      await tester.tap(find.byKey(const Key('replyn-proposal-accept-confirm')));
      await tester.pumpAndSettle();

      // The request is in flight: both buttons stay disabled.
      expect(find.text('Đang gửi…'), findsOneWidget);
      expect(tester.widget<FilledButton>(accept).onPressed, isNull);
      expect(tester.widget<OutlinedButton>(reject).onPressed, isNull);
      await tester.tap(accept, warnIfMissed: false);
      await tester.tap(reject, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Chấp nhận đề xuất?'), findsNothing);
      expect(find.text('Từ chối đề xuất?'), findsNothing);

      controller.gate!.complete();
      await tester.pumpAndSettle();
      expect(controller.calls, ['accept:$_proposalId:']);
      expect(find.text('Đã chấp nhận · Mở Replyn'), findsOneWidget);
    },
  );

  testWidgets('cancelling the dialog lets the talent respond again', (
    tester,
  ) async {
    final controller = _FakeController(
      ReplynProposal.tryParse(_proposalJson())!,
    );
    await tester.pumpWidget(
      _app(
        ReplynProposalScreen(
          controller: controller,
          applicationId: 'thread-$_threadId',
          proposalId: _proposalId,
        ),
      ),
    );
    final accept = find.byKey(const Key('replyn-proposal-accept'));
    await tester.tap(accept);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(accept).onPressed, isNotNull);
    expect(controller.calls, isEmpty);
  });

  group('RemoteApplicationController proposals', () {
    late List<Completer<void>> heldThreadLoads;
    late bool holdThreadLoads;
    late String backendStatus;
    late NovaApiClient client;

    setUp(() {
      heldThreadLoads = [];
      holdThreadLoads = false;
      backendStatus = 'PENDING';
      client = NovaApiClient(
        config: NovaApiConfig('https://example.test'),
        readToken: () async => 'a' * 43,
        transport: MockClient((request) async {
          final path = request.url.path;
          if (request.method == 'POST' &&
              path ==
                  '/api/v1/mobile/messages/$_threadId/replyn-proposals/$_proposalId/accept') {
            backendStatus = 'ACCEPTED';
            return _jsonResponse(
              _proposalJson(status: 'ACCEPTED', workspaceId: _workspaceId),
            );
          }
          if (path == '/api/v1/mobile/messages') {
            // The answer reflects the backend when the request arrived.
            final status = backendStatus;
            if (holdThreadLoads) {
              final hold = Completer<void>();
              heldThreadLoads.add(hold);
              await hold.future;
            }
            return _jsonResponse([_threadJson(status)]);
          }
          if (path == '/api/v1/jobs' ||
              path == '/api/v1/mobile/applications') {
            return _jsonResponse(<Object>[]);
          }
          return http.Response('', 404);
        }),
      );
      addTearDown(client.close);
    });

    const conversationId = 'thread-$_threadId';

    test('accepting shows the accepted proposal before the refresh returns',
        () async {
      final controller = RemoteApplicationController.of(client);
      await controller.refresh();
      ReplynProposal current() =>
          controller.byId(conversationId)!.replynProposals.single;
      expect(current().status, ReplynProposalStatus.pending);

      holdThreadLoads = true;
      final response = controller.respondToProposal(
        conversationId,
        _proposalId,
        accept: true,
      );
      await _until(() => heldThreadLoads.isNotEmpty);

      // The refresh is still waiting, yet the card already shows the result.
      expect(controller.isLoading, isTrue);
      expect(current().status, ReplynProposalStatus.accepted);
      expect(current().workspaceId, _workspaceId);

      heldThreadLoads.single.complete();
      expect(await response, isNull);
      expect(current().status, ReplynProposalStatus.accepted);
      expect(controller.isLoading, isFalse);
    });

    test('a refresh started before accepting cannot bring back the old status',
        () async {
      final controller = RemoteApplicationController.of(client);
      await controller.refresh();
      ReplynProposal current() =>
          controller.byId(conversationId)!.replynProposals.single;

      holdThreadLoads = true;
      final staleRefresh = controller.refresh();
      await _until(() => heldThreadLoads.length == 1);

      final response = controller.respondToProposal(
        conversationId,
        _proposalId,
        accept: true,
      );
      await _until(() => heldThreadLoads.length == 2);

      // The new refresh answers first, then the stale one (still PENDING).
      heldThreadLoads[1].complete();
      expect(await response, isNull);
      heldThreadLoads[0].complete();
      await staleRefresh;

      expect(current().status, ReplynProposalStatus.accepted);
      expect(controller.isLoading, isFalse);
    });
  });
}
