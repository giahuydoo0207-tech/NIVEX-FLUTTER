import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nivex_flutter/features/jobs/data/remote_application_controller.dart';
import 'package:nivex_flutter/features/jobs/domain/job_application.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

void main() {
  const job = {
    'id': 'job-1',
    'organizationId': 'org-1',
    'organizationName': 'Nova Labs',
    'title': 'Flutter Engineer',
    'category': 'Mobile',
    'summary': 'Build the wallet',
    'skills': ['Flutter'],
    'engagement': 'CONTRACT',
    'paymentType': 'MILESTONE',
    'duration': '6 tuần',
    'budgetMinMinor': 1200000000,
    'budgetMaxMinor': 1800000000,
    'currency': 'USDC',
    'locationScope': 'Remote',
    'applicationDeadline': '2099-01-01',
    'status': 'PUBLISHED',
    'applicantCount': 0,
    'createdAt': '2026-09-27T00:00:00Z',
    'publishedAt': '2026-09-27T00:00:00Z',
  };

  Map<String, Object?> application(String status) => {
    'id': 'app-1',
    'jobId': 'job-1',
    'jobTitle': 'Flutter Engineer',
    'contractorId': 'c-1',
    'candidateName': 'Gia Huy',
    'headline': 'Dev',
    'email': 'huy@example.test',
    'location': '',
    'skillsJson': '[]',
    'coverNote': 'Hello',
    'status': status,
    'submittedAt': '2026-09-27T00:00:00Z',
    'updatedAt': '2026-09-27T01:00:00Z',
    'withdrawnAt': null,
    'organizationId': 'org-1',
    'organizationName': 'Nova Labs',
    'candidateAvatarUrl': null,
  };

  Map<String, Object?> thread(String status, {String? seenAt}) => {
    'id': 't-1',
    'contractorId': 'c-1',
    'candidateName': 'Gia Huy',
    'headline': 'Dev',
    'requestStatus': status,
    'createdAt': '2026-09-27T00:00:00Z',
    'acceptedAt': null,
    'updatedAt': '2026-09-27T02:00:00Z',
    'organizationId': 'org-1',
    'organizationName': 'Nova Labs',
    'candidateAvatarUrl': null,
    'organizationAvatarUrl': null,
    'unreadForTalent': seenAt == null ? 1 : 0,
    'unreadForBusiness': 0,
    'messages': [
      {
        'id': 'm-1',
        'senderType': 'BUSINESS',
        'body': 'Chào Gia Huy',
        'sentAt': '2026-09-27T02:00:00Z',
        'deliveredAt': '2026-09-27T02:00:01Z',
        'seenAt': seenAt,
      },
    ],
  };

  http.Response json(Object body, [int status = 200]) =>
      http.Response.bytes(utf8.encode(jsonEncode(body)), status);

  NovaApiClient api(Future<http.Response> Function(http.Request) handler) =>
      NovaApiClient(
        config: NovaApiConfig('https://example.test'),
        readToken: () async => 'a' * 43,
        transport: MockClient(handler),
      );

  test(
    'maps backend status and business messages into one conversation',
    () async {
      final client = api((request) async {
        return switch (request.url.path) {
          '/api/v1/jobs' => json([job]),
          '/api/v1/mobile/applications' => json([application('interview')]),
          '/api/v1/mobile/messages' => json([thread('ACCEPTED')]),
          _ => http.Response('', 404),
        };
      });
      addTearDown(client.close);
      final controller = RemoteApplicationController.of(client);

      await controller.refresh();

      expect(controller.errorMessage, isNull);
      expect(controller.jobs.single.budgetMinUsdc, 1200);
      final conversation = controller.conversations.single;
      expect(conversation.status, JobApplicationStatus.interview);
      expect(conversation.statusLabel, 'Phỏng vấn');
      expect(conversation.threadStatus, 'ACCEPTED');
      final business = conversation.messages.where(
        (message) => message.role == JobMessageRole.business,
      );
      expect(business.single.senderName, 'Nova Labs');
      expect(
        business.single.deliveryStatus,
        JobMessageDeliveryStatus.delivered,
      );
      expect(controller.unreadCount, 1);
    },
  );

  test(
    'pending conversation sends a message request, accepted sends a chat',
    () async {
      var status = 'PENDING';
      final posted = <String>[];
      final client = api((request) async {
        if (request.method == 'POST') posted.add(request.url.path);
        return switch (request.url.path) {
          '/api/v1/jobs' => json([job]),
          '/api/v1/mobile/applications' => json([application('submitted')]),
          '/api/v1/mobile/messages' => json([thread(status)]),
          '/api/v1/mobile/messages/requests' => json(thread(status), 201),
          '/api/v1/mobile/messages/t-1/messages' => json({
            'id': 'm-2',
            'senderType': 'TALENT',
            'body': 'Cảm ơn',
            'sentAt': '2026-09-27T03:00:00Z',
            'deliveredAt': null,
            'seenAt': null,
          }),
          _ => http.Response('', 404),
        };
      });
      addTearDown(client.close);
      final controller = RemoteApplicationController.of(client);
      await controller.refresh();

      expect(await controller.sendTalentMessage('app-1', 'Xin chào'), isTrue);
      status = 'ACCEPTED';
      await controller.refresh();
      expect(await controller.sendTalentMessage('app-1', 'Cảm ơn'), isTrue);

      expect(posted, [
        '/api/v1/mobile/messages/requests',
        '/api/v1/mobile/messages/t-1/messages',
      ]);
    },
  );

  test('listing never marks seen; opening the thread does', () async {
    final posted = <String>[];
    var seen = false;
    final client = api((request) async {
      if (request.method == 'POST') posted.add(request.url.path);
      return switch (request.url.path) {
        '/api/v1/jobs' => json([job]),
        '/api/v1/mobile/applications' => json([application('submitted')]),
        '/api/v1/mobile/messages' => json([
          thread('ACCEPTED', seenAt: seen ? '2026-09-27T04:00:00Z' : null),
        ]),
        '/api/v1/mobile/messages/t-1/read' => () {
          seen = true;
          return json(thread('ACCEPTED', seenAt: '2026-09-27T04:00:00Z'));
        }(),
        _ => http.Response('', 404),
      };
    });
    addTearDown(client.close);
    final controller = RemoteApplicationController.of(client);

    await controller.refresh();
    expect(posted, isEmpty);

    await controller.markConversationRead('app-1');
    expect(posted, ['/api/v1/mobile/messages/t-1/read']);
    expect(controller.unreadCount, 0);

    await controller.markConversationRead('app-1');
    expect(posted, hasLength(1));
  });

  test(
    'duplicate application reports a conflict instead of a fake success',
    () async {
      final client = api((request) async {
        if (request.method == 'POST') return http.Response('', 409);
        return switch (request.url.path) {
          '/api/v1/jobs' => json([job]),
          '/api/v1/mobile/applications' => json(<Object>[]),
          '/api/v1/mobile/messages' => json(<Object>[]),
          _ => http.Response('', 404),
        };
      });
      addTearDown(client.close);
      final controller = RemoteApplicationController.of(client);
      await controller.refresh();

      expect(await controller.apply(controller.jobs.single), isNull);
      expect(controller.errorMessage, contains('đã ứng tuyển'));
    },
  );
}
