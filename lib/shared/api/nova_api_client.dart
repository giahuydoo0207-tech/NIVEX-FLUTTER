import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class NovaApiException implements Exception {
  const NovaApiException(this.code, {this.statusCode});
  final String code;
  final int? statusCode;
  bool get requiresLogin => statusCode == 401;
  @override
  String toString() => 'NovaApiException($code)';
}

class NovaApiConfig {
  NovaApiConfig(String url, {bool allowLocalHttp = false})
    : baseUri = Uri.parse(url) {
    final local = _isPrivateDevelopmentHost(baseUri.host);
    if (!baseUri.hasAuthority ||
        baseUri.userInfo.isNotEmpty ||
        baseUri.hasQuery ||
        baseUri.hasFragment ||
        (baseUri.path.isNotEmpty && baseUri.path != '/') ||
        (baseUri.scheme != 'https' &&
            !(allowLocalHttp && local && baseUri.scheme == 'http'))) {
      throw ArgumentError('NOVA_API_URL must be an HTTPS origin');
    }
  }
  factory NovaApiConfig.fromBuild() => NovaApiConfig(
    const String.fromEnvironment('NOVA_API_URL'),
    allowLocalHttp: const bool.fromEnvironment('NOVA_API_ALLOW_LOCAL_HTTP'),
  );
  final Uri baseUri;
}

bool _isPrivateDevelopmentHost(String host) {
  if (const {'localhost', '127.0.0.1', '10.0.2.2'}.contains(host)) {
    return true;
  }
  final octets = host.split('.').map(int.tryParse).toList();
  if (octets.length != 4 || octets.any((octet) => octet == null)) return false;
  final values = octets.cast<int>();
  return values[0] == 10 ||
      (values[0] == 172 && values[1] >= 16 && values[1] <= 31) ||
      (values[0] == 192 && values[1] == 168);
}

class NovaInvoice {
  NovaInvoice.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      number = json['invoiceNumber'] as String,
      description = json['description'] as String,
      amountMinor = _amount(json['amountMinor']),
      status = json['status'] as String,
      dueDate = json['dueDate'] as String?;
  final String id;
  final String number;
  final String description;
  final BigInt amountMinor;
  final String status;
  final String? dueDate;
}

class NovaTransaction {
  NovaTransaction.fromJson(Map<String, dynamic> json)
    : signature = json['signature'] as String,
      amountMinor = _amount(json['amountMinor']),
      mint = json['mint'] as String,
      recipient = json['recipient'] as String,
      recordedAt = DateTime.parse(json['recordedAt'] as String);
  final String signature;
  final BigInt amountMinor;
  final String mint;
  final String recipient;
  final DateTime recordedAt;
}

class NovaHomeProfile {
  NovaHomeProfile.fromJson(Map<String, dynamic> json)
    : displayName = _requiredString(json['displayName']),
      headline = _string(json['headline']);

  final String displayName;
  final String headline;
}

class NovaCommunityHighlight {
  NovaCommunityHighlight.fromJson(Map<String, dynamic> json)
    : postId = _requiredString(json['postId']),
      content = _requiredString(json['content']),
      authorName = _requiredString(json['authorName']),
      authorHeadline = _string(json['authorHeadline']),
      authorAvatarUrl = json['authorAvatarUrl'] as String?,
      reactionCount = _count(json['reactionCount']),
      createdAt = DateTime.parse(_requiredString(json['createdAt']));

  final String postId;
  final String content;
  final String authorName;
  final String authorHeadline;
  final String? authorAvatarUrl;
  final int reactionCount;
  final DateTime createdAt;
}

class NovaHomeSnapshot {
  NovaHomeSnapshot.fromJson(Map<String, dynamic> json)
    : profile = NovaHomeProfile.fromJson(_requiredObject(json['profile'])),
      finalizedIncomeMinor = _amount(json['finalizedIncomeMinor']),
      finalizedIncomeLast7DaysMinor = _amount(
        json['finalizedIncomeLast7DaysMinor'],
      ),
      activeApplicationCount = _count(json['activeApplicationCount']),
      completedProjectCount = _count(json['completedProjectCount']),
      unreadNotificationCount = _count(json['unreadNotificationCount']),
      communityHighlight = json['communityHighlight'] == null
          ? null
          : NovaCommunityHighlight.fromJson(
              _requiredObject(json['communityHighlight']),
            ),
      generatedAt = DateTime.parse(_requiredString(json['generatedAt']));

  final NovaHomeProfile profile;
  final BigInt finalizedIncomeMinor;
  final BigInt finalizedIncomeLast7DaysMinor;
  final int activeApplicationCount;
  final int completedProjectCount;
  final int unreadNotificationCount;
  final NovaCommunityHighlight? communityHighlight;
  final DateTime generatedAt;
}

class NovaCommunityAuthor {
  NovaCommunityAuthor.fromJson(Map<String, dynamic> json)
    : id = _requiredString(json['id']),
      displayName = _requiredString(json['displayName']),
      headline = json['headline'] is String ? json['headline'] as String : '',
      avatarUrl = json['avatarUrl'] as String?;

  final String id;
  final String displayName;
  final String headline;
  final String? avatarUrl;
}

class NovaPublicProfile {
  NovaPublicProfile.fromJson(Map<String, dynamic> json)
    : id = _requiredString(json['id']),
      displayName = _requiredString(json['displayName']),
      headline = _string(json['headline']),
      bio = _string(json['bio']),
      avatarUrl = json['avatarUrl'] as String?,
      postCount = _count(json['postCount']);

  final String id;
  final String displayName;
  final String headline;
  final String bio;
  final String? avatarUrl;
  final int postCount;
}

class NovaProfileWall {
  NovaProfileWall.fromJson(Map<String, dynamic> json)
    : profile = NovaPublicProfile.fromJson(_requiredObject(json['profile'])),
      posts = _requiredList(json['posts'])
          .map((row) => NovaCommunityPost.fromJson(_requiredObject(row)))
          .toList(growable: false);

  final NovaPublicProfile profile;
  final List<NovaCommunityPost> posts;
}

class NovaCommunityPost {
  NovaCommunityPost.fromJson(Map<String, dynamic> json)
    : id = _requiredString(json['id']),
      author = NovaCommunityAuthor.fromJson(_requiredObject(json['author'])),
      content = _requiredString(json['content']),
      createdAt = DateTime.parse(_requiredString(json['createdAt'])),
      reactionCount = _count(json['reactionCount']),
      reactionCounts = _reactionCounts(json['reactionCounts']),
      myReaction = json['myReaction'] as String?,
      commentCount = _count(json['commentCount']);

  final String id;
  final NovaCommunityAuthor author;
  final String content;
  final DateTime createdAt;
  final int reactionCount;
  final Map<String, int> reactionCounts;
  final String? myReaction;
  final int commentCount;
}

class NovaCommunityFeed {
  NovaCommunityFeed.fromJson(Map<String, dynamic> json)
    : items = (_requiredList(json['items']))
          .map((row) => NovaCommunityPost.fromJson(_requiredObject(row)))
          .toList(growable: false),
      nextCursor = json['nextCursor'] as String?;

  final List<NovaCommunityPost> items;
  final String? nextCursor;
}

class NovaCommunityComment {
  NovaCommunityComment.fromJson(Map<String, dynamic> json)
    : id = _requiredString(json['id']),
      author = NovaCommunityAuthor.fromJson(_requiredObject(json['author'])),
      content = _requiredString(json['content']),
      createdAt = DateTime.parse(_requiredString(json['createdAt'])),
      reactionCount = _count(json['reactionCount'] ?? 0),
      reactionCounts = json['reactionCounts'] == null
          ? const {}
          : _reactionCounts(json['reactionCounts']),
      myReaction = json['myReaction'] as String?,
      replies = _requiredList(json['replies'])
          .map((row) => NovaCommunityComment.fromJson(_requiredObject(row)))
          .toList(growable: false);

  final String id;
  final NovaCommunityAuthor author;
  final String content;
  final DateTime createdAt;
  final int reactionCount;
  final Map<String, int> reactionCounts;
  final String? myReaction;
  final List<NovaCommunityComment> replies;
}

Map<String, dynamic> _requiredObject(dynamic value) {
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Expected object');
  }
  return value;
}

String _requiredString(dynamic value) {
  if (value is! String || value.isEmpty) {
    throw const FormatException('Expected non-empty string');
  }
  return value;
}

String _string(dynamic value) {
  if (value is! String) throw const FormatException('Expected string');
  return value;
}

int _count(dynamic value) {
  if (value is! int || value < 0 || value > 1000000) {
    throw const FormatException('Invalid count');
  }
  return value;
}

Map<String, int> _reactionCounts(dynamic value) {
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Expected reaction count object');
  }
  return Map.unmodifiable({
    for (final entry in value.entries)
      if (entry.key.isNotEmpty) entry.key: _count(entry.value),
  });
}

List<dynamic> _requiredList(dynamic value) {
  if (value is! List<dynamic>) throw const FormatException('Expected list');
  return value;
}

BigInt _amount(dynamic value) {
  if (value is! String || !RegExp(r'^[0-9]{1,20}$').hasMatch(value)) {
    throw const FormatException('Invalid minor amount');
  }
  final amount = BigInt.parse(value);
  if (amount > BigInt.parse('18446744073709551615')) {
    throw const FormatException('Amount exceeds u64');
  }
  return amount;
}

String formatUsdc(BigInt amount) {
  final digits = amount.toString().padLeft(7, '0');
  final whole = digits.substring(0, digits.length - 6);
  final fraction = digits
      .substring(digits.length - 6)
      .replaceFirst(RegExp(r'0+$'), '');
  return fraction.isEmpty ? whole : '$whole.$fraction';
}

class NovaApiClient {
  NovaApiClient({
    required this.config,
    required this.readToken,
    http.Client? transport,
    this.timeout = const Duration(seconds: 15),
  }) : _transport = transport ?? http.Client();

  final NovaApiConfig config;
  final Future<String?> Function() readToken;
  final Duration timeout;
  final http.Client _transport;

  Future<List<T>> _get<T>(
    String resource,
    T Function(Map<String, dynamic>) decode,
    int offset,
  ) async {
    if (offset < 0 || offset > 100000) throw ArgumentError.value(offset);
    final token = await readToken();
    if (token == null || !RegExp(r'^[A-Za-z0-9_-]{43,128}$').hasMatch(token)) {
      throw const NovaApiException('unauthorized', statusCode: 401);
    }
    final uri = config.baseUri
        .resolve('/api/v1/mobile/$resource')
        .replace(queryParameters: {'offset': '$offset', 'limit': '25'});
    try {
      final request = http.Request('GET', uri)
        ..followRedirects = false
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });
      final response = await (() async {
        final streamed = await _transport.send(request);
        return http.Response.fromStream(streamed);
      })().timeout(timeout);
      if (response.statusCode != 200) {
        throw NovaApiException('http', statusCode: response.statusCode);
      }
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is! List) throw const FormatException('Expected list');
      return body.map((row) => decode(row as Map<String, dynamic>)).toList();
    } on TimeoutException {
      throw const NovaApiException('timeout');
    } on http.ClientException {
      throw const NovaApiException('connection');
    } on FormatException {
      throw const NovaApiException('invalid_response');
    } on TypeError {
      throw const NovaApiException('invalid_response');
    }
  }

  Future<List<NovaInvoice>> invoices({int offset = 0}) =>
      _get('invoices', NovaInvoice.fromJson, offset);
  Future<List<NovaTransaction>> transactions({int offset = 0}) =>
      _get('transactions', NovaTransaction.fromJson, offset);

  Future<NovaHomeSnapshot> home() async {
    final token = await readToken();
    if (token == null || !RegExp(r'^[A-Za-z0-9_-]{43,128}$').hasMatch(token)) {
      throw const NovaApiException('unauthorized', statusCode: 401);
    }
    final uri = config.baseUri.resolve('/api/v1/mobile/home');
    try {
      final request = http.Request('GET', uri)
        ..followRedirects = false
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });
      final streamed = await _transport.send(request).timeout(timeout);
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode != 200) {
        throw NovaApiException('http', statusCode: response.statusCode);
      }
      return NovaHomeSnapshot.fromJson(
        _requiredObject(jsonDecode(utf8.decode(response.bodyBytes))),
      );
    } on TimeoutException {
      throw const NovaApiException('timeout');
    } on http.ClientException {
      throw const NovaApiException('connection');
    } on FormatException {
      throw const NovaApiException('invalid_response');
    } on TypeError {
      throw const NovaApiException('invalid_response');
    }
  }

  Future<NovaCommunityFeed> communityFeed({String? cursor}) async {
    final uri = config.baseUri
        .resolve('/api/v1/posts/feed')
        .replace(queryParameters: cursor == null ? null : {'cursor': cursor});
    final response = await _authorizedJsonRequest('GET', uri);
    if (response.statusCode != 200) {
      throw NovaApiException('http', statusCode: response.statusCode);
    }
    try {
      return NovaCommunityFeed.fromJson(
        _requiredObject(jsonDecode(utf8.decode(response.bodyBytes))),
      );
    } on FormatException {
      throw const NovaApiException('invalid_response');
    } on TypeError {
      throw const NovaApiException('invalid_response');
    }
  }

  Uri mediaUri(String pathOrUrl) {
    final parsed = Uri.tryParse(pathOrUrl);
    if (parsed != null && parsed.hasScheme) return parsed;
    return config.baseUri.resolve(pathOrUrl);
  }

  Future<NovaPublicProfile> myProfile() async {
    final response = await _authorizedJsonRequest(
      'GET',
      config.baseUri.resolve('/api/v1/profile/me'),
    );
    if (response.statusCode != 200) {
      throw NovaApiException('http', statusCode: response.statusCode);
    }
    return NovaPublicProfile.fromJson(
      _requiredObject(jsonDecode(utf8.decode(response.bodyBytes))),
    );
  }

  Future<NovaProfileWall> profileWall(String userId) async {
    final response = await _authorizedJsonRequest(
      'GET',
      config.baseUri.resolve('/api/v1/profile/$userId'),
    );
    if (response.statusCode != 200) {
      throw NovaApiException('http', statusCode: response.statusCode);
    }
    return NovaProfileWall.fromJson(
      _requiredObject(jsonDecode(utf8.decode(response.bodyBytes))),
    );
  }

  Future<NovaPublicProfile> updateMyProfile({
    required String displayName,
    required String headline,
    required String bio,
    String? avatarUrl,
  }) async {
    final response = await _authorizedJsonRequest(
      'PATCH',
      config.baseUri.resolve('/api/v1/profile/me'),
      body: {
        'displayName': displayName.trim(),
        'headline': headline.trim(),
        'bio': bio.trim(),
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
    );
    if (response.statusCode != 200) {
      throw NovaApiException('http', statusCode: response.statusCode);
    }
    return NovaPublicProfile.fromJson(
      _requiredObject(jsonDecode(utf8.decode(response.bodyBytes))),
    );
  }

  Future<NovaPublicProfile> uploadProfileAvatar(
    List<int> bytes,
    String contentType,
  ) async {
    if (bytes.isEmpty || bytes.length > 2500000) {
      throw ArgumentError.value(bytes.length, 'bytes');
    }
    final token = await _requiredToken();
    try {
      final request =
          http.Request(
              'PUT',
              config.baseUri.resolve('/api/v1/profile/me/avatar'),
            )
            ..followRedirects = false
            ..headers.addAll({
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': contentType,
            })
            ..bodyBytes = bytes;
      final streamed = await _transport.send(request).timeout(timeout);
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode != 200) {
        throw NovaApiException('http', statusCode: response.statusCode);
      }
      return NovaPublicProfile.fromJson(
        _requiredObject(jsonDecode(utf8.decode(response.bodyBytes))),
      );
    } on TimeoutException {
      throw const NovaApiException('timeout');
    } on http.ClientException {
      throw const NovaApiException('connection');
    }
  }

  Future<NovaCommunityPost> createCommunityPost(String content) async {
    final normalized = content.trim();
    if (normalized.isEmpty || normalized.length > 2000) {
      throw ArgumentError.value(content, 'content');
    }
    return _writeCommunityPost(
      'POST',
      config.baseUri.resolve('/api/v1/posts'),
      {'content': normalized},
      expectedStatus: 201,
    );
  }

  Future<NovaCommunityPost> reactToCommunityPost(String postId, String type) {
    if (!const {
      'LIKE',
      'LOVE',
      'HAHA',
      'TRUST',
      'BUILD',
      'INSIGHTFUL',
      'LAUNCH',
    }.contains(type)) {
      throw ArgumentError.value(type, 'type');
    }
    return _writeCommunityPost(
      'POST',
      config.baseUri.resolve('/api/v1/posts/$postId/reactions'),
      {'type': type},
      expectedStatus: 200,
    );
  }

  Future<void> removeCommunityReaction(String postId) async {
    final response = await _authorizedJsonRequest(
      'DELETE',
      config.baseUri.resolve('/api/v1/posts/$postId/reactions'),
    );
    if (response.statusCode != 204) {
      throw NovaApiException('http', statusCode: response.statusCode);
    }
  }

  Future<List<NovaCommunityComment>> communityComments(String postId) async {
    final response = await _authorizedJsonRequest(
      'GET',
      config.baseUri.resolve('/api/v1/posts/$postId/comments'),
    );
    if (response.statusCode != 200) {
      throw NovaApiException('http', statusCode: response.statusCode);
    }
    try {
      final body = _requiredObject(jsonDecode(utf8.decode(response.bodyBytes)));
      return _requiredList(body['items'])
          .map((row) => NovaCommunityComment.fromJson(_requiredObject(row)))
          .toList(growable: false);
    } on FormatException {
      throw const NovaApiException('invalid_response');
    } on TypeError {
      throw const NovaApiException('invalid_response');
    }
  }

  Future<NovaCommunityComment> createCommunityComment(
    String postId,
    String content, {
    String? parentId,
  }) async {
    final normalized = content.trim();
    if (normalized.isEmpty || normalized.length > 1000) {
      throw ArgumentError.value(content, 'content');
    }
    final response = await _authorizedJsonRequest(
      'POST',
      config.baseUri.resolve('/api/v1/posts/$postId/comments'),
      body: {'content': normalized, if (parentId != null) 'parentId': parentId},
    );
    if (response.statusCode != 201) {
      throw NovaApiException('http', statusCode: response.statusCode);
    }
    try {
      return NovaCommunityComment.fromJson(
        _requiredObject(jsonDecode(utf8.decode(response.bodyBytes))),
      );
    } on FormatException {
      throw const NovaApiException('invalid_response');
    } on TypeError {
      throw const NovaApiException('invalid_response');
    }
  }

  Future<NovaCommunityComment> editCommunityComment(
    String commentId,
    String content,
  ) async {
    final normalized = content.trim();
    if (normalized.isEmpty || normalized.length > 1000) {
      throw ArgumentError.value(content, 'content');
    }
    final response = await _authorizedJsonRequest(
      'PATCH',
      config.baseUri.resolve('/api/v1/posts/comments/$commentId'),
      body: {'content': normalized},
    );
    if (response.statusCode != 200) {
      throw NovaApiException('http', statusCode: response.statusCode);
    }
    return NovaCommunityComment.fromJson(
      _requiredObject(jsonDecode(utf8.decode(response.bodyBytes))),
    );
  }

  Future<void> deleteCommunityComment(String commentId) async {
    final response = await _authorizedJsonRequest(
      'DELETE',
      config.baseUri.resolve('/api/v1/posts/comments/$commentId'),
    );
    if (response.statusCode != 204) {
      throw NovaApiException('http', statusCode: response.statusCode);
    }
  }

  Future<NovaCommunityComment> reactToCommunityComment(
    String commentId,
    String type,
  ) async {
    final response = await _authorizedJsonRequest(
      'POST',
      config.baseUri.resolve('/api/v1/posts/comments/$commentId/reactions'),
      body: {'type': type},
    );
    if (response.statusCode != 200) {
      throw NovaApiException('http', statusCode: response.statusCode);
    }
    return NovaCommunityComment.fromJson(
      _requiredObject(jsonDecode(utf8.decode(response.bodyBytes))),
    );
  }

  Future<NovaCommunityComment> removeCommunityCommentReaction(
    String commentId,
  ) async {
    final response = await _authorizedJsonRequest(
      'DELETE',
      config.baseUri.resolve('/api/v1/posts/comments/$commentId/reactions'),
    );
    if (response.statusCode != 200) {
      throw NovaApiException('http', statusCode: response.statusCode);
    }
    return NovaCommunityComment.fromJson(
      _requiredObject(jsonDecode(utf8.decode(response.bodyBytes))),
    );
  }

  Future<NovaCommunityPost> _writeCommunityPost(
    String method,
    Uri uri,
    Map<String, String> body, {
    required int expectedStatus,
  }) async {
    final response = await _authorizedJsonRequest(method, uri, body: body);
    if (response.statusCode != expectedStatus) {
      throw NovaApiException('http', statusCode: response.statusCode);
    }
    try {
      return NovaCommunityPost.fromJson(
        _requiredObject(jsonDecode(utf8.decode(response.bodyBytes))),
      );
    } on FormatException {
      throw const NovaApiException('invalid_response');
    } on TypeError {
      throw const NovaApiException('invalid_response');
    }
  }

  Future<http.Response> _authorizedJsonRequest(
    String method,
    Uri uri, {
    Map<String, String>? body,
  }) async {
    final token = await _requiredToken();
    try {
      final request = http.Request(method, uri)
        ..followRedirects = false
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          if (body != null) 'Content-Type': 'application/json',
        });
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _transport.send(request).timeout(timeout);
      return http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const NovaApiException('timeout');
    } on http.ClientException {
      throw const NovaApiException('connection');
    }
  }

  Future<String> _requiredToken() async {
    final token = await readToken();
    if (token == null || !RegExp(r'^[A-Za-z0-9_-]{43,128}$').hasMatch(token)) {
      throw const NovaApiException('unauthorized', statusCode: 401);
    }
    return token;
  }

  void close() => _transport.close();
}
