import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

void main() {
  NovaApiClient client(
    Future<http.Response> Function(http.Request) handler, {
    String? token = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    Duration timeout = const Duration(seconds: 1),
  }) => NovaApiClient(
    config: NovaApiConfig('https://example.test'),
    readToken: () async => token,
    transport: MockClient(handler),
    timeout: timeout,
  );

  test('requires HTTPS and rejects credentials or path in origin', () {
    for (final url in [
      'http://example.test',
      'https://u:p@example.test',
      'https://example.test/api',
    ]) {
      expect(() => NovaApiConfig(url), throwsArgumentError);
    }
    expect(
      NovaApiConfig('http://127.0.0.1:8080', allowLocalHttp: true).baseUri.port,
      8080,
    );
  });

  test(
    'sends scoped bearer and pagination and preserves u64 precision',
    () async {
      final api = client((request) async {
        expect(request.headers['Authorization'], startsWith('Bearer '));
        expect(request.headers.containsKey('X-Nova-Demo-Key'), isFalse);
        expect(request.url.path, '/api/v1/mobile/invoices');
        expect(request.url.queryParameters['offset'], '25');
        expect(request.followRedirects, isFalse);
        return http.Response(
          '[{"id":"1","invoiceNumber":"NOVA-1","description":"test","amountMinor":"18446744073709551615","status":"ISSUED"}]',
          200,
        );
      });
      addTearDown(api.close);
      expect(
        (await api.invoices(offset: 25)).single.amountMinor.toString(),
        '18446744073709551615',
      );
      expect(formatUsdc(BigInt.from(10000)), '0.01');
      expect(formatUsdc(BigInt.from(200000)), '0.2');
      expect(formatUsdc(BigInt.from(1000000)), '1');
    },
  );

  test('missing session does not call network', () async {
    final api = client(
      (_) async => throw StateError('must not send'),
      token: null,
    );
    addTearDown(api.close);
    await expectLater(
      api.invoices(),
      throwsA(
        isA<NovaApiException>().having((e) => e.requiresLogin, 'login', true),
      ),
    );
  });

  test(
    'loads the session-scoped Home snapshot without losing minor units',
    () async {
      final api = client((request) async {
        expect(request.url.path, '/api/v1/mobile/home');
        expect(request.url.query, isEmpty);
        const body = '''{
          "profile":{"displayName":"Minh Anh","headline":"Flutter Developer"},
          "finalizedIncomeMinor":"12345678901234567890",
          "finalizedIncomeLast7DaysMinor":"5000000",
          "activeApplicationCount":2,
          "completedProjectCount":3,
          "unreadNotificationCount":1,
          "communityHighlight":{
            "postId":"post-1",
            "content":"Bài viết nổi bật",
            "authorName":"Nova Labs",
            "authorHeadline":"Fintech",
            "authorAvatarUrl":null,
            "reactionCount":12,
            "createdAt":"2026-09-27T00:00:00Z"
          },
          "generatedAt":"2026-09-27T00:00:00Z"
        }''';
        return http.Response.bytes(utf8.encode(body), 200);
      });
      addTearDown(api.close);

      final home = await api.home();
      expect(home.profile.displayName, 'Minh Anh');
      expect(home.finalizedIncomeMinor.toString(), '12345678901234567890');
      expect(home.finalizedIncomeLast7DaysMinor, BigInt.from(5000000));
      expect(home.activeApplicationCount, 2);
      expect(home.communityHighlight?.authorName, 'Nova Labs');
    },
  );

  test('loads, creates, and reacts to community posts', () async {
    const post = '''{
      "id":"post-1",
      "author":{"id":"user-1","displayName":"Minh Anh"},
      "content":"Bài viết Nova",
      "createdAt":"2026-09-27T00:00:00Z",
      "reactionCount":2,
      "reactionCounts":{"LOVE":1,"HAHA":1},
      "myReaction":"HAHA",
      "commentCount":3
    }''';
    final api = client((request) async {
      expect(request.headers['Authorization'], startsWith('Bearer '));
      if (request.method == 'GET') {
        expect(request.url.path, '/api/v1/posts/feed');
        expect(request.url.queryParameters['cursor'], 'next-page');
        return http.Response.bytes(
          utf8.encode('{"items":[$post],"nextCursor":null}'),
          200,
        );
      }
      if (request.url.path == '/api/v1/posts') {
        expect(request.method, 'POST');
        expect(request.body, '{"content":"Bài viết Nova"}');
        return http.Response.bytes(utf8.encode(post), 201);
      }
      expect(request.url.path, '/api/v1/posts/post-1/reactions');
      expect(request.method, 'POST');
      expect(request.headers['content-type'], 'application/json');
      expect(request.body, '{"type":"LOVE"}');
      return http.Response.bytes(utf8.encode(post), 200);
    });
    addTearDown(api.close);

    final feed = await api.communityFeed(cursor: 'next-page');
    expect(feed.items.single.commentCount, 3);
    expect(feed.items.single.reactionCounts['HAHA'], 1);

    final created = await api.createCommunityPost(' Bài viết Nova ');
    expect(created.content, 'Bài viết Nova');

    final updated = await api.reactToCommunityPost('post-1', 'LOVE');
    expect(updated.myReaction, 'HAHA');
  });

  test('loads and creates nested community comments', () async {
    const comment = '''{
      "id":"comment-1",
      "author":{"id":"user-1","displayName":"Minh Anh"},
      "content":"Bình luận Nova",
      "createdAt":"2026-09-27T00:00:00Z",
      "replies":[]
    }''';
    final api = client((request) async {
      expect(request.url.path, '/api/v1/posts/post-1/comments');
      if (request.method == 'GET') {
        return http.Response.bytes(utf8.encode('{"items":[$comment]}'), 200);
      }
      expect(request.method, 'POST');
      expect(request.body, '{"content":"Bình luận Nova","parentId":"root-1"}');
      return http.Response.bytes(utf8.encode(comment), 201);
    });
    addTearDown(api.close);

    final comments = await api.communityComments('post-1');
    expect(comments.single.content, 'Bình luận Nova');
    await api.createCommunityComment(
      'post-1',
      'Bình luận Nova',
      parentId: 'root-1',
    );
  });

  test('loads a public profile wall with enriched post authors', () async {
    final api = client((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/v1/profile/user-1');
      return http.Response.bytes(
        utf8.encode('''{
          "profile":{
            "id":"user-1",
            "displayName":"Minh Anh",
            "headline":"Flutter Developer",
            "bio":"Building Nova",
            "avatarUrl":"/api/v1/profile/user-1/avatar",
            "postCount":1
          },
          "posts":[{
            "id":"post-1",
            "author":{
              "id":"user-1",
              "displayName":"Minh Anh",
              "headline":"Flutter Developer",
              "avatarUrl":"/api/v1/profile/user-1/avatar"
            },
            "content":"Bài viết trên wall",
            "createdAt":"2026-09-28T00:00:00Z",
            "reactionCount":4,
            "reactionCounts":{"LOVE":3,"HAHA":1},
            "myReaction":"LOVE",
            "commentCount":2
          }]
        }'''),
        200,
      );
    });
    addTearDown(api.close);

    final wall = await api.profileWall('user-1');
    expect(wall.profile.displayName, 'Minh Anh');
    expect(wall.profile.postCount, 1);
    expect(wall.posts.single.author.headline, 'Flutter Developer');
    expect(
      api.mediaUri(wall.profile.avatarUrl!).path,
      '/api/v1/profile/user-1/avatar',
    );
  });

  test('adds and removes a persisted comment reaction', () async {
    const comment = '''{
      "id":"comment-1",
      "author":{
        "id":"user-1",
        "displayName":"Minh Anh",
        "headline":"Flutter Developer",
        "avatarUrl":null
      },
      "content":"Bình luận Nova",
      "createdAt":"2026-09-28T00:00:00Z",
      "reactionCount":1,
      "reactionCounts":{"LIKE":1},
      "myReaction":"LIKE",
      "replies":[]
    }''';
    final api = client((request) async {
      expect(request.url.path, '/api/v1/posts/comments/comment-1/reactions');
      if (request.method == 'POST') {
        expect(request.body, '{"type":"LIKE"}');
      } else {
        expect(request.method, 'DELETE');
      }
      return http.Response.bytes(utf8.encode(comment), 200);
    });
    addTearDown(api.close);

    final liked = await api.reactToCommunityComment('comment-1', 'LIKE');
    expect(liked.myReaction, 'LIKE');
    expect(liked.reactionCounts['LIKE'], 1);
    final removed = await api.removeCommunityCommentReaction('comment-1');
    expect(removed.author.headline, 'Flutter Developer');
  });

  test('does not expose response content in errors', () async {
    final api = client((_) async => http.Response('secret diagnostic', 401));
    addTearDown(api.close);
    await expectLater(
      api.invoices(),
      throwsA(
        isA<NovaApiException>().having(
          (e) => e.toString().contains('secret'),
          'no leak',
          false,
        ),
      ),
    );
  });

  test('rejects malformed response and numeric token amounts', () async {
    final api = client(
      (_) async => http.Response(
        '[{"id":"1","invoiceNumber":"N","description":"d","amountMinor":0.01,"status":"ISSUED"}]',
        200,
      ),
    );
    addTearDown(api.close);
    await expectLater(
      api.invoices(),
      throwsA(
        isA<NovaApiException>().having(
          (e) => e.code,
          'code',
          'invalid_response',
        ),
      ),
    );
  });

  test('times out stalled requests', () async {
    final api = client(
      (_) => Completer<http.Response>().future,
      timeout: const Duration(milliseconds: 5),
    );
    addTearDown(api.close);
    await expectLater(
      api.invoices(),
      throwsA(isA<NovaApiException>().having((e) => e.code, 'code', 'timeout')),
    );
  });
}
