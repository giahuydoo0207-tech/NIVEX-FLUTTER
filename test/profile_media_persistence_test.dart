import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nivex_flutter/features/profile/data/demo_freelancer_profile_controller.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.documents);
  final String documents;

  @override
  Future<String?> getApplicationDocumentsPath() async => documents;
}

void main() {
  late Directory root;
  late Directory documents;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('nova_profile_media_');
    documents = await Directory('${root.path}/documents').create();
    PathProviderPlatform.instance = _FakePathProvider(documents.path);
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() => root.delete(recursive: true));

  Future<String> pickedImage(String name, List<int> bytes) async {
    final file = File('${root.path}/$name');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  test('cover is copied to a stable file and survives a restart', () async {
    final controller = DemoFreelancerProfileController.fresh();
    await controller.mediaRestored;
    final picked = await pickedImage('picker_cache.jpg', [1, 2, 3]);

    await controller.update(controller.profile.copyWith(coverPath: picked));
    final saved = controller.profile.coverPath!;
    expect(saved, startsWith(documents.path));
    expect(await File(saved).readAsBytes(), [1, 2, 3]);

    // image_picker's cache file may be deleted by the OS.
    await File(picked).delete();
    final restarted = DemoFreelancerProfileController.fresh();
    await restarted.mediaRestored;
    expect(restarted.profile.coverPath, saved);
  });

  test('a new cover gets a new path and the old file is removed', () async {
    final controller = DemoFreelancerProfileController.fresh();
    await controller.mediaRestored;
    await controller.update(
      controller.profile.copyWith(
        coverPath: await pickedImage('a.jpg', [1]),
      ),
    );
    final first = controller.profile.coverPath!;

    await controller.update(
      controller.profile.copyWith(
        coverPath: await pickedImage('b.jpg', [2]),
      ),
    );
    final second = controller.profile.coverPath!;

    expect(second, isNot(first));
    expect(await File(first).exists(), isFalse);
    expect(await File(second).readAsBytes(), [2]);
  });

  test('removing the cover deletes the file and the preference', () async {
    final controller = DemoFreelancerProfileController.fresh();
    await controller.mediaRestored;
    await controller.update(
      controller.profile.copyWith(coverPath: await pickedImage('c.jpg', [3])),
    );
    final saved = controller.profile.coverPath!;

    await controller.update(controller.profile.copyWith(clearCover: true));

    expect(controller.profile.coverPath, isNull);
    expect(await File(saved).exists(), isFalse);
    final restarted = DemoFreelancerProfileController.fresh();
    await restarted.mediaRestored;
    expect(restarted.profile.coverPath, isNull);
  });

  test('a slow startup restore does not overwrite a newly saved cover',
      () async {
    final first = DemoFreelancerProfileController.fresh();
    await first.mediaRestored;
    await first.update(
      first.profile.copyWith(coverPath: await pickedImage('old.jpg', [5])),
    );

    final restarted = DemoFreelancerProfileController.fresh();
    // Save before the restore of the previous cover has completed.
    await restarted.update(
      restarted.profile.copyWith(coverPath: await pickedImage('new.jpg', [6])),
    );
    final saved = restarted.profile.coverPath!;
    await restarted.mediaRestored;

    expect(restarted.profile.coverPath, saved);
    expect(await File(saved).readAsBytes(), [6]);
  });

  test('a missing picked file fails loudly instead of clearing the cover',
      () async {
    final controller = DemoFreelancerProfileController.fresh();
    await controller.mediaRestored;
    await controller.update(
      controller.profile.copyWith(coverPath: await pickedImage('d.jpg', [4])),
    );
    final saved = controller.profile.coverPath;

    await expectLater(
      controller.update(
        controller.profile.copyWith(coverPath: '${root.path}/gone.jpg'),
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(controller.profile.coverPath, saved);
  });

  test('connected account shows backend identity, never the demo one',
      () async {
    final requests = <String>[];
    final api = NovaApiClient(
      config: NovaApiConfig('https://example.test'),
      readToken: () async => 'a' * 43,
      transport: MockClient((request) async {
        requests.add('${request.method} ${request.url.path}');
        final json = switch (request.url.path) {
          '/api/v1/profile/me' when request.method == 'GET' =>
            '{"id":"contractor-gia-huy","displayName":"Gia Huy Đỗ","headline":"","bio":"","avatarUrl":null,"postCount":1}',
          '/api/v1/profile/me' =>
            '{"id":"contractor-gia-huy","displayName":"Gia Huy","headline":"Mobile","bio":"Hi","avatarUrl":null,"postCount":1}',
          '/api/v1/auth/me' =>
            '{"id":"7b4c7a1e-0000-4000-8000-000000000001","email":"huy@example.test","phoneE164":null,"displayName":"Gia Huy Đỗ","headline":null}',
          _ => '{}',
        };
        return http.Response.bytes(utf8.encode(json), 200,
            headers: {'content-type': 'application/json'});
      }),
    );
    final controller = DemoFreelancerProfileController.fresh()..connect(api);
    expect(controller.displayName, isEmpty);
    expect(controller.novaId, isNull);
    await controller.refreshRemote();

    expect(controller.displayName, 'Gia Huy Đỗ');
    expect(controller.novaId, 'contractor-gia-huy');
    expect(controller.email, 'huy@example.test');
    expect(controller.initials, 'GĐ');
    expect(controller.profile.headline, isEmpty);

    await controller.saveBasics(displayName: 'Gia Huy', headline: 'Mobile', bio: 'Hi');
    expect(requests, contains('PATCH /api/v1/profile/me'));
    expect(controller.displayName, 'Gia Huy');
    expect(controller.profile.bio, 'Hi');
  });

  test('a connected cover is uploaded before it is saved locally', () async {
    var uploads = 0;
    var failUpload = false;
    final api = NovaApiClient(
      config: NovaApiConfig('https://example.test'),
      readToken: () async => 'a' * 43,
      transport: MockClient((request) async {
        if (request.url.path == '/api/v1/profile/me/cover') {
          uploads++;
          if (failUpload) return http.Response('{}', 500);
          return http.Response(
            '{"id":"c-1","displayName":"Gia Huy","headline":"","bio":"",'
            '"avatarUrl":null,"postCount":0,"coverUrl":"/api/v1/profile/c-1/cover?v=$uploads"}',
            200,
          );
        }
        return http.Response('{}', 404);
      }),
    );
    final controller = DemoFreelancerProfileController.fresh()..connect(api);
    await controller.mediaRestored;

    await controller.update(
      controller.profile.copyWith(coverPath: await pickedImage('e.jpg', [7])),
    );
    expect(uploads, 1);
    expect(controller.coverUrl, 'https://example.test/api/v1/profile/c-1/cover?v=1');
    final saved = controller.profile.coverPath;

    failUpload = true;
    await expectLater(
      controller.update(
        controller.profile.copyWith(coverPath: await pickedImage('f.jpg', [8])),
      ),
      throwsA(isA<NovaApiException>()),
    );
    // The failed upload changed nothing locally or remotely.
    expect(controller.profile.coverPath, saved);
    expect(controller.coverUrl, 'https://example.test/api/v1/profile/c-1/cover?v=1');
  });

  test('offline demo identity is only used without a backend', () {
    final controller = DemoFreelancerProfileController.fresh();
    expect(controller.hasBackend, isFalse);
    expect(controller.displayName, 'Minh Anh');
    expect(controller.initials, 'MA');
  });
}
