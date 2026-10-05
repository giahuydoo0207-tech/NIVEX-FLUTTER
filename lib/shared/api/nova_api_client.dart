import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class NovaApiException implements Exception {
  const NovaApiException(
    this.code, {
    this.statusCode,
    this.serverCode,
    this.serverMessage,
  });
  final String code;
  final int? statusCode;

  /// Stable error code from the backend body, e.g. `INVALID_WALLET_ADDRESS`.
  final String? serverCode;

  /// A message the backend marked safe to show, when it sent one.
  final String? serverMessage;
  bool get requiresLogin => statusCode == 401;
  @override
  String toString() => 'NovaApiException($code, ${serverCode ?? statusCode})';
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
      coverUrl = json['coverUrl'] as String?,
      postCount = _count(json['postCount']);

  final String id;
  final String displayName;
  final String headline;
  final String bio;
  final String? avatarUrl;
  final String? coverUrl;
  final int postCount;
}

class NovaWalletTransaction {
  NovaWalletTransaction.fromJson(Map<String, dynamic> json)
    : signature = _requiredString(json['signature']),
      amountMinor = BigInt.parse(_requiredString(json['amountMinor'])),
      recipient = _requiredString(json['recipient']),
      recordedAt = DateTime.parse(_requiredString(json['recordedAt'])),
      invoiceId = json['invoiceId'] as String?,
      invoiceNumber = json['invoiceNumber'] as String?,
      token = json['token'] is String ? json['token'] as String : 'USDC',
      network = json['network'] is String
          ? json['network'] as String
          : 'solana:devnet',
      status = json['status'] as String?,
      // Older backends only paid into the server demo wallet.
      recipientKind = json['recipientKind'] is String
          ? json['recipientKind'] as String
          : 'LEGACY_DEMO';

  final String signature;
  final BigInt amountMinor;
  final String recipient;
  final DateTime recordedAt;
  final String? invoiceId;
  final String? invoiceNumber;
  final String token;
  final String network;
  final String? status;
  final String recipientKind;

  /// Paid into the old server demo wallet, not the contractor's own wallet.
  bool get isLegacyDemo => recipientKind != 'CONTRACTOR_WALLET';
}

/// `GET /api/v1/mobile/wallet/summary`, computed from the payment ledger.
/// [paidToPersonalWalletMinor] is what Nova paid into the contractor's own
/// wallet; [paidViaDemoWalletMinor] is legacy payments into the server demo
/// wallet, never the contractor's money. Neither is an on-chain balance.
class NovaWalletSummary {
  NovaWalletSummary.fromJson(Map<String, dynamic> json)
    : availableBalanceMinor = BigInt.parse(_requiredString(json['availableBalanceMinor'])),
      paidToPersonalWalletMinor = json['paidToPersonalWalletMinor'] == null
          ? BigInt.parse(_requiredString(json['availableBalanceMinor']))
          : _amount(json['paidToPersonalWalletMinor']),
      paidViaDemoWalletMinor = BigInt.parse(_requiredString(json['paidViaDemoWalletMinor'])),
      earnedLast7DaysMinor = BigInt.parse(_requiredString(json['earnedLast7DaysMinor'])),
      pendingBalanceMinor = BigInt.parse(_requiredString(json['pendingBalanceMinor'])),
      network = _requiredString(json['network']),
      isDemoWallet = json['isDemoWallet'] == true,
      walletAddress = json['walletAddress'] as String?,
      payoutWalletStatus = json['payoutWalletStatus'] is String
          ? json['payoutWalletStatus'] as String
          : (json['walletAddress'] is String ? 'CONFIGURED' : 'NOT_CONFIGURED'),
      demoRecipientAddress = json['demoRecipientAddress'] as String?;

  final BigInt availableBalanceMinor;
  final BigInt paidToPersonalWalletMinor;
  final BigInt paidViaDemoWalletMinor;
  final BigInt earnedLast7DaysMinor;
  final BigInt pendingBalanceMinor;
  final String network;
  final bool isDemoWallet;
  final String? walletAddress;

  /// CONFIGURED, NOT_CONFIGURED or INVALID.
  final String payoutWalletStatus;
  final String? demoRecipientAddress;

  bool get hasPayoutWallet => payoutWalletStatus == 'CONFIGURED';
}

/// The signed-in contractor's public payout wallet
/// (`/api/v1/mobile/wallet/receive`). Never carries a secret.
class NovaReceiveWallet {
  NovaReceiveWallet.fromJson(Map<String, dynamic> json)
    : status = _requiredString(json['status']),
      walletAddress = json['walletAddress'] as String?,
      network = _requiredString(json['network']),
      tokenSymbol = _requiredString(json['tokenSymbol']),
      tokenMint = _requiredString(json['tokenMint']),
      ownershipVerified = json['ownershipVerified'] == true,
      updatedAt = json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'] as String)
          : null {
    if (!const {'CONFIGURED', 'NOT_CONFIGURED', 'INVALID'}.contains(status) ||
        (status == 'CONFIGURED' && walletAddress == null)) {
      throw const FormatException('Invalid receive wallet');
    }
  }

  /// CONFIGURED, NOT_CONFIGURED or INVALID.
  final String status;
  final String? walletAddress;

  /// `solana:devnet`.
  final String network;
  final String tokenSymbol;
  final String tokenMint;
  final bool ownershipVerified;
  final DateTime? updatedAt;

  bool get isConfigured => status == 'CONFIGURED';
}

/// The signed-in login account (`GET /api/v1/auth/me`). Email is null for
/// phone-only accounts.
class NovaAccount {
  NovaAccount.fromJson(Map<String, dynamic> json)
    : id = _requiredString(json['id']),
      email = json['email'] as String?,
      phoneE164 = json['phoneE164'] as String?,
      displayName = _requiredString(json['displayName']);

  final String id;
  final String? email;
  final String? phoneE164;
  final String displayName;
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
      imageUrls = json['images'] is List
          ? [
              for (final value in json['images'] as List)
                if (value is String && value.isNotEmpty) value,
            ]
          : const [],
      createdAt = DateTime.parse(_requiredString(json['createdAt'])),
      reactionCount = _count(json['reactionCount']),
      reactionCounts = _reactionCounts(json['reactionCounts']),
      myReaction = json['myReaction'] as String?,
      commentCount = _count(json['commentCount']),
      privacy = json['privacy'] is String
          ? json['privacy'] as String
          : 'PUBLIC',
      isPinned = json['isPinned'] == true,
      isSaved = json['isSaved'] == true;

  final String id;
  final NovaCommunityAuthor author;
  final String content;

  /// Relative (`/media/community/…`) or absolute image URLs, in display order.
  final List<String> imageUrls;
  final DateTime createdAt;
  final int reactionCount;
  final Map<String, int> reactionCounts;
  final String? myReaction;
  final int commentCount;
  final String privacy;
  final bool isPinned;
  final bool isSaved;
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

class NovaJob {
  NovaJob.fromJson(Map<String, dynamic> json)
    : id = _requiredString(json['id']),
      organizationName = json['organizationName'] is String
          ? json['organizationName'] as String
          : 'Doanh nghiệp',
      title = _requiredString(json['title']),
      category = _string(json['category']),
      summary = _string(json['summary']),
      skills = json['skills'] is List
          ? (json['skills'] as List).whereType<String>().toList(growable: false)
          : const [],
      engagement = json['engagement'] is String
          ? json['engagement'] as String
          : 'PROJECT',
      paymentType = json['paymentType'] is String
          ? json['paymentType'] as String
          : 'FIXED',
      duration = json['duration'] is String ? json['duration'] as String : '',
      budgetMinMinor = _wholeNumber(json['budgetMinMinor']),
      budgetMaxMinor = _wholeNumber(json['budgetMaxMinor']),
      locationScope = _string(json['locationScope']),
      applicationDeadline = DateTime.parse(
        _requiredString(json['applicationDeadline']),
      ),
      status = _requiredString(json['status']),
      createdAt = DateTime.parse(_requiredString(json['createdAt'])),
      publishedAt = json['publishedAt'] is String
          ? DateTime.parse(json['publishedAt'] as String)
          : null;

  final String id;
  final String organizationName;
  final String title;
  final String category;
  final String summary;
  final List<String> skills;
  final String engagement;
  final String paymentType;
  final String duration;
  final int budgetMinMinor;
  final int budgetMaxMinor;
  final String locationScope;
  final DateTime applicationDeadline;
  final String status;
  final DateTime createdAt;
  final DateTime? publishedAt;
}

class NovaJobApplication {
  NovaJobApplication.fromJson(Map<String, dynamic> json)
    : id = _requiredString(json['id']),
      jobId = _requiredString(json['jobId']),
      jobTitle = _requiredString(json['jobTitle']),
      organizationName = json['organizationName'] is String
          ? json['organizationName'] as String
          : 'Doanh nghiệp',
      candidateName = _requiredString(json['candidateName']),
      headline = json['headline'] is String ? json['headline'] as String : '',
      email = json['email'] is String ? json['email'] as String : '',
      location = json['location'] is String ? json['location'] as String : '',
      coverNote = _string(json['coverNote']),
      status = _requiredString(json['status']),
      submittedAt = DateTime.parse(_requiredString(json['submittedAt'])),
      updatedAt = DateTime.parse(_requiredString(json['updatedAt']));

  final String id;
  final String jobId;
  final String jobTitle;
  final String organizationName;
  final String candidateName;
  final String headline;
  final String email;
  final String location;
  final String coverNote;
  final String status;
  final DateTime submittedAt;
  final DateTime updatedAt;
}

class NovaThreadMessage {
  NovaThreadMessage.fromJson(Map<String, dynamic> json)
    : id = _requiredString(json['id']),
      senderType = _requiredString(json['senderType']),
      body = _requiredString(json['body']),
      sentAt = DateTime.parse(_requiredString(json['sentAt'])),
      deliveredAt = json['deliveredAt'] is String
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      seenAt = json['seenAt'] is String
          ? DateTime.parse(json['seenAt'] as String)
          : null;

  final String id;
  final String senderType;
  final String body;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final DateTime? seenAt;
}

class NovaMessageThread {
  NovaMessageThread.fromJson(Map<String, dynamic> json)
    : id = _requiredString(json['id']),
      organizationId = json['organizationId'] as String?,
      organizationName = json['organizationName'] is String
          ? json['organizationName'] as String
          : 'Doanh nghiệp',
      organizationAvatarUrl = json['organizationAvatarUrl'] as String?,
      candidateName = json['candidateName'] is String
          ? json['candidateName'] as String
          : '',
      requestStatus = _requiredString(json['requestStatus']),
      unreadForTalent = json['unreadForTalent'] is int
          ? json['unreadForTalent'] as int
          : 0,
      updatedAt = DateTime.parse(_requiredString(json['updatedAt'])),
      messages = _requiredList(json['messages'])
          .map((row) => NovaThreadMessage.fromJson(_requiredObject(row)))
          .toList(growable: false);

  final String id;
  final String? organizationId;
  final String organizationName;
  final String? organizationAvatarUrl;
  final String candidateName;
  final String requestStatus;
  final int unreadForTalent;
  final DateTime updatedAt;
  final List<NovaThreadMessage> messages;
}

class NovaNotification {
  NovaNotification.fromJson(Map<String, dynamic> json)
    : id = _requiredString(json['id']),
      type = _requiredString(json['type']),
      title = _requiredString(json['title']),
      body = _string(json['body']),
      readAt = json['readAt'] is String
          ? DateTime.parse(json['readAt'] as String)
          : null,
      createdAt = DateTime.parse(_requiredString(json['createdAt'])),
      data = _notificationData(json['data']);

  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime? readAt;
  final DateTime createdAt;

  /// Deep-link payload, e.g. applicationId, jobId, threadId, status.
  final Map<String, String> data;

  bool get isUnread => readAt == null;
  String? get applicationId => data['applicationId'];
  String? get threadId => data['threadId'];

  static Map<String, String> _notificationData(dynamic value) {
    try {
      final decoded = value is String ? jsonDecode(value) : value;
      if (decoded is! Map) return const {};
      return {
        for (final entry in decoded.entries)
          if (entry.value is String) '${entry.key}': entry.value as String,
      };
    } on FormatException {
      return const {};
    }
  }
}

int _wholeNumber(dynamic value) {
  if (value is! int || value < 0) {
    throw const FormatException('Expected a non-negative integer');
  }
  return value;
}

class NovaApiClient {
  NovaApiClient({
    required this.config,
    required this.readToken,
    this.refreshAccessToken,
    http.Client? transport,
    this.timeout = const Duration(seconds: 15),
  }) : _transport = transport ?? http.Client();

  final NovaApiConfig config;
  final Future<String?> Function() readToken;

  /// Obtains a new access token after the server rejects the current one.
  /// Returns null when the session can no longer be renewed.
  final Future<String?> Function()? refreshAccessToken;
  final Duration timeout;
  final http.Client _transport;

  static final _tokenPattern = RegExp(r'^[A-Za-z0-9_-]{43,128}$');

  Future<List<T>> _get<T>(
    String resource,
    T Function(Map<String, dynamic>) decode,
    int offset,
  ) async {
    if (offset < 0 || offset > 100000) throw ArgumentError.value(offset);
    final uri = config.baseUri
        .resolve('/api/v1/mobile/$resource')
        .replace(queryParameters: {'offset': '$offset', 'limit': '25'});
    final response = await _send('GET', uri);
    _expect(response, 200);
    return _decode(() {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is! List) throw const FormatException('Expected list');
      return body.map((row) => decode(row as Map<String, dynamic>)).toList();
    });
  }

  Future<List<NovaInvoice>> invoices({int offset = 0}) =>
      _get('invoices', NovaInvoice.fromJson, offset);
  Future<List<NovaTransaction>> transactions({int offset = 0}) =>
      _get('transactions', NovaTransaction.fromJson, offset);

  Future<NovaHomeSnapshot> home() => _getObject(
    config.baseUri.resolve('/api/v1/mobile/home'),
    NovaHomeSnapshot.fromJson,
  );

  Future<NovaCommunityFeed> communityFeed({String? cursor}) => _getObject(
    config.baseUri
        .resolve('/api/v1/posts/feed')
        .replace(queryParameters: cursor == null ? null : {'cursor': cursor}),
    NovaCommunityFeed.fromJson,
  );

  Uri mediaUri(String pathOrUrl) {
    final parsed = Uri.tryParse(pathOrUrl);
    if (parsed != null && parsed.hasScheme) return parsed;
    return config.baseUri.resolve(pathOrUrl);
  }

  Future<NovaPublicProfile> myProfile() => _getObject(
    config.baseUri.resolve('/api/v1/profile/me'),
    NovaPublicProfile.fromJson,
  );

  Future<NovaAccount> myAccount() => _getObject(
    config.baseUri.resolve('/api/v1/auth/me'),
    NovaAccount.fromJson,
  );

  Future<NovaProfileWall> profileWall(String userId) => _getObject(
    config.baseUri.resolve('/api/v1/profile/${Uri.encodeComponent(userId)}'),
    NovaProfileWall.fromJson,
  );

  Future<NovaPublicProfile> updateMyProfile({
    required String displayName,
    required String headline,
    required String bio,
    String? avatarUrl,
  }) => _writeObject('PATCH', config.baseUri.resolve('/api/v1/profile/me'), {
    'displayName': displayName.trim(),
    'headline': headline.trim(),
    'bio': bio.trim(),
    'avatarUrl': ?avatarUrl,
  }, NovaPublicProfile.fromJson);

  Future<NovaPublicProfile> uploadProfileAvatar(
    List<int> bytes,
    String contentType,
  ) async {
    if (bytes.isEmpty || bytes.length > 2500000) {
      throw ArgumentError.value(bytes.length, 'bytes');
    }
    final response = await _send(
      'PUT',
      config.baseUri.resolve('/api/v1/profile/me/avatar'),
      bytes: bytes,
      contentType: contentType,
    );
    _expect(response, 200);
    return _decodeObject(response, NovaPublicProfile.fromJson);
  }

  Future<NovaPublicProfile> uploadProfileCover(
    List<int> bytes,
    String contentType,
  ) async {
    if (bytes.isEmpty || bytes.length > 5000000) {
      throw ArgumentError.value(bytes.length, 'bytes');
    }
    final response = await _send(
      'PUT',
      config.baseUri.resolve('/api/v1/profile/me/cover'),
      bytes: bytes,
      contentType: contentType,
    );
    _expect(response, 200);
    return _decodeObject(response, NovaPublicProfile.fromJson);
  }

  Future<NovaPublicProfile> deleteProfileCover() async {
    final response = await _send(
      'DELETE',
      config.baseUri.resolve('/api/v1/profile/me/cover'),
    );
    _expect(response, 200);
    return _decodeObject(response, NovaPublicProfile.fromJson);
  }

  Future<NovaWalletSummary> walletSummary() => _getObject(
    config.baseUri.resolve('/api/v1/mobile/wallet/summary'),
    NovaWalletSummary.fromJson,
  );

  Future<NovaReceiveWallet> receiveWallet() => _getObject(
    config.baseUri.resolve('/api/v1/mobile/wallet/receive'),
    NovaReceiveWallet.fromJson,
  );

  /// Saves the contractor's public Solana Devnet address. The backend is the
  /// final judge of validity; only the address ever leaves the device.
  Future<NovaReceiveWallet> saveReceiveWallet(String walletAddress) =>
      _writeObject(
        'PUT',
        config.baseUri.resolve('/api/v1/mobile/wallet/receive'),
        {
          'walletAddress': walletAddress.trim(),
          'network': 'solana:devnet',
          'confirmPublicAddress': true,
        },
        NovaReceiveWallet.fromJson,
      );

  Future<NovaReceiveWallet> deleteReceiveWallet() => _writeObject(
    'DELETE',
    config.baseUri.resolve('/api/v1/mobile/wallet/receive'),
    null,
    NovaReceiveWallet.fromJson,
  );

  /// Finalized Devnet payments for the signed-in contractor's invoices.
  Future<List<NovaWalletTransaction>> walletTransactions() async {
    final response = await _send(
      'GET',
      config.baseUri.resolve('/api/v1/mobile/wallet/transactions'),
    );
    _expect(response, 200);
    return _decodeList(response, NovaWalletTransaction.fromJson);
  }

  /// [images] are URLs returned by [uploadCommunityImage].
  Future<NovaCommunityPost> createCommunityPost(
    String content, {
    String privacy = 'PUBLIC',
    List<String> images = const [],
    List<String> topics = const [],
  }) {
    final normalized = content.trim();
    if (normalized.isEmpty || normalized.length > 2000) {
      throw ArgumentError.value(content, 'content');
    }
    return _writeObject(
      'POST',
      config.baseUri.resolve('/api/v1/posts'),
      {
        'content': normalized,
        if (privacy != 'PUBLIC') 'privacy': privacy,
        if (images.isNotEmpty) 'images': images,
        if (topics.isNotEmpty) 'topics': topics,
      },
      NovaCommunityPost.fromJson,
      expectedStatus: 201,
    );
  }

  /// Uploads one post image as the signed-in member; returns its media URL.
  Future<String> uploadCommunityImage(List<int> bytes, String contentType) async {
    if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
      throw ArgumentError.value(bytes.length, 'bytes');
    }
    final response = await _send(
      'POST',
      config.baseUri.resolve('/api/v1/mobile/media'),
      bytes: bytes,
      contentType: contentType,
    );
    _expect(response, 201);
    return _decodeObject(response, (json) => _requiredString(json['url']));
  }

  /// Removes an upload that was not attached to a post; attached media is kept.
  Future<void> deleteCommunityImage(String url) async {
    final id = url.split('/').last;
    final response = await _send(
      'DELETE',
      config.baseUri.resolve('/api/v1/mobile/media/$id'),
    );
    _expect(response, 204);
  }

  Future<NovaCommunityPost> updateCommunityPost(
    String postId, {
    String? content,
    String? privacy,
  }) => _writeObject('PATCH', config.baseUri.resolve('/api/v1/posts/$postId'), {
    'content': ?content?.trim(),
    'privacy': ?privacy,
  }, NovaCommunityPost.fromJson);

  Future<void> deleteCommunityPost(String postId) async {
    final response = await _send(
      'DELETE',
      config.baseUri.resolve('/api/v1/posts/$postId'),
    );
    _expect(response, 204);
  }

  Future<NovaCommunityPost> setCommunityPostSaved(String postId, bool saved) =>
      _writeObject(
        'PUT',
        config.baseUri.resolve('/api/v1/posts/$postId/saved'),
        {'enabled': saved},
        NovaCommunityPost.fromJson,
      );

  Future<void> setCommunityPostHidden(String postId, bool hidden) async {
    final response = await _send(
      'PUT',
      config.baseUri.resolve('/api/v1/posts/$postId/hidden'),
      json: {'enabled': hidden},
    );
    _expect(response, 204);
  }

  Future<NovaCommunityPost> reactToCommunityPost(String postId, String type) {
    if (!_reactionTypes.contains(type)) {
      throw ArgumentError.value(type, 'type');
    }
    return _writeObject(
      'POST',
      config.baseUri.resolve('/api/v1/posts/$postId/reactions'),
      {'type': type},
      NovaCommunityPost.fromJson,
    );
  }

  Future<void> removeCommunityReaction(String postId) async {
    final response = await _send(
      'DELETE',
      config.baseUri.resolve('/api/v1/posts/$postId/reactions'),
    );
    _expect(response, 204);
  }

  Future<List<NovaCommunityComment>> communityComments(String postId) async {
    final response = await _send(
      'GET',
      config.baseUri.resolve('/api/v1/posts/$postId/comments'),
    );
    _expect(response, 200);
    return _decode(() {
      final body = _requiredObject(jsonDecode(utf8.decode(response.bodyBytes)));
      return _requiredList(body['items'])
          .map((row) => NovaCommunityComment.fromJson(_requiredObject(row)))
          .toList(growable: false);
    });
  }

  Future<NovaCommunityComment> createCommunityComment(
    String postId,
    String content, {
    String? parentId,
  }) {
    final normalized = content.trim();
    if (normalized.isEmpty || normalized.length > 1000) {
      throw ArgumentError.value(content, 'content');
    }
    return _writeObject(
      'POST',
      config.baseUri.resolve('/api/v1/posts/$postId/comments'),
      {'content': normalized, 'parentId': ?parentId},
      NovaCommunityComment.fromJson,
      expectedStatus: 201,
    );
  }

  Future<NovaCommunityComment> editCommunityComment(
    String commentId,
    String content,
  ) {
    final normalized = content.trim();
    if (normalized.isEmpty || normalized.length > 1000) {
      throw ArgumentError.value(content, 'content');
    }
    return _writeObject(
      'PATCH',
      config.baseUri.resolve('/api/v1/posts/comments/$commentId'),
      {'content': normalized},
      NovaCommunityComment.fromJson,
    );
  }

  Future<void> deleteCommunityComment(String commentId) async {
    final response = await _send(
      'DELETE',
      config.baseUri.resolve('/api/v1/posts/comments/$commentId'),
    );
    _expect(response, 204);
  }

  Future<NovaCommunityComment> reactToCommunityComment(
    String commentId,
    String type,
  ) {
    if (!_reactionTypes.contains(type)) {
      throw ArgumentError.value(type, 'type');
    }
    return _writeObject(
      'POST',
      config.baseUri.resolve('/api/v1/posts/comments/$commentId/reactions'),
      {'type': type},
      NovaCommunityComment.fromJson,
    );
  }

  Future<NovaCommunityComment> removeCommunityCommentReaction(
    String commentId,
  ) async {
    final response = await _send(
      'DELETE',
      config.baseUri.resolve('/api/v1/posts/comments/$commentId/reactions'),
    );
    _expect(response, 200);
    return _decodeObject(response, NovaCommunityComment.fromJson);
  }

  Future<List<NovaJob>> jobs() async {
    final response = await _send('GET', config.baseUri.resolve('/api/v1/jobs'));
    _expect(response, 200);
    return _decodeList(response, NovaJob.fromJson);
  }

  Future<List<NovaJobApplication>> myApplications() =>
      _get('applications', NovaJobApplication.fromJson, 0);

  Future<NovaJobApplication> submitApplication({
    required String jobId,
    required String coverNote,
  }) {
    final note = coverNote.trim();
    if (note.isEmpty || note.length > 4000) {
      throw ArgumentError.value(coverNote, 'coverNote');
    }
    return _writeObject(
      'POST',
      config.baseUri.resolve('/api/v1/mobile/applications'),
      {'jobId': jobId, 'coverNote': note},
      NovaJobApplication.fromJson,
      expectedStatus: 201,
    );
  }

  Future<NovaJobApplication> withdrawApplication(String applicationId) =>
      _writeObject(
        'POST',
        config.baseUri.resolve(
          '/api/v1/mobile/applications/$applicationId/withdraw',
        ),
        null,
        NovaJobApplication.fromJson,
      );

  Future<List<NovaMessageThread>> messageThreads() async {
    final response = await _send(
      'GET',
      config.baseUri.resolve('/api/v1/mobile/messages'),
    );
    _expect(response, 200);
    return _decodeList(response, NovaMessageThread.fromJson);
  }

  Future<NovaMessageThread> requestConversation(String body) => _writeObject(
    'POST',
    config.baseUri.resolve('/api/v1/mobile/messages/requests'),
    {'body': body.trim()},
    NovaMessageThread.fromJson,
    expectedStatus: 201,
  );

  Future<NovaThreadMessage> sendThreadMessage(String threadId, String body) =>
      _writeObject(
        'POST',
        config.baseUri.resolve('/api/v1/mobile/messages/$threadId/messages'),
        {'body': body.trim()},
        NovaThreadMessage.fromJson,
      );

  /// Records that the talent opened the thread; listing threads never does.
  Future<NovaMessageThread> markThreadRead(String threadId) => _writeObject(
    'POST',
    config.baseUri.resolve('/api/v1/mobile/messages/$threadId/read'),
    null,
    NovaMessageThread.fromJson,
  );

  /// Whether the business is typing in the thread. Short-lived and polled;
  /// the backend has no realtime channel.
  Future<bool> businessTyping(String threadId) async {
    final response = await _send(
      'GET',
      config.baseUri.resolve('/api/v1/mobile/messages/$threadId/typing'),
    );
    _expect(response, 200);
    return _decodeObject(response, (json) => json['typing'] == true);
  }

  Future<void> reportTyping(String threadId) async {
    final response = await _send(
      'POST',
      config.baseUri.resolve('/api/v1/mobile/messages/$threadId/typing'),
    );
    _expect(response, 204);
  }

  Future<List<NovaNotification>> notifications() async {
    final response = await _send(
      'GET',
      config.baseUri.resolve('/api/v1/mobile/notifications'),
    );
    _expect(response, 200);
    return _decodeList(response, NovaNotification.fromJson);
  }

  Future<void> markNotificationRead(String notificationId) async {
    final response = await _send(
      'POST',
      config.baseUri.resolve(
        '/api/v1/mobile/notifications/$notificationId/read',
      ),
    );
    _expect(response, 200);
  }

  /// Approves a Replyn browser login for the signed-in Talent. The backend
  /// takes the identity from the session; the QR secret travels only in the
  /// request body, never in the URL or an exception.
  Future<void> approveReplynPairing(String pairingId, String qrSecret) async {
    final id = Uri.encodeComponent(pairingId);
    final response = await _send(
      'POST',
      config.baseUri.resolve('/api/v1/mobile/replyn/pairings/$id/approve'),
      json: {'qrSecret': qrSecret},
    );
    _expect(response, 200);
  }

  static const _reactionTypes = {
    'LIKE',
    'LOVE',
    'HAHA',
    'TRUST',
    'BUILD',
    'INSIGHTFUL',
    'LAUNCH',
  };

  Future<T> _getObject<T>(
    Uri uri,
    T Function(Map<String, dynamic>) decode,
  ) async {
    final response = await _send('GET', uri);
    _expect(response, 200);
    return _decodeObject(response, decode);
  }

  Future<T> _writeObject<T>(
    String method,
    Uri uri,
    Map<String, Object?>? body,
    T Function(Map<String, dynamic>) decode, {
    int expectedStatus = 200,
  }) async {
    final response = await _send(method, uri, json: body);
    _expect(response, expectedStatus);
    return _decodeObject(response, decode);
  }

  void _expect(http.Response response, int status) {
    if (response.statusCode != status) {
      String? code;
      String? message;
      try {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body is Map<String, dynamic>) {
          if (body['code'] is String) code = body['code'] as String;
          if (body['message'] is String &&
              (body['message'] as String).isNotEmpty &&
              (body['message'] as String).length <= 300) {
            message = body['message'] as String;
          }
        }
      } on FormatException {
        // Not JSON: the status code alone describes the failure.
      }
      throw NovaApiException(
        'http',
        statusCode: response.statusCode,
        serverCode: code,
        serverMessage: code == null ? null : message,
      );
    }
  }

  T _decodeObject<T>(
    http.Response response,
    T Function(Map<String, dynamic>) decode,
  ) => _decode(
    () => decode(_requiredObject(jsonDecode(utf8.decode(response.bodyBytes)))),
  );

  List<T> _decodeList<T>(
    http.Response response,
    T Function(Map<String, dynamic>) decode,
  ) => _decode(
    () =>
        _requiredList(jsonDecode(utf8.decode(response.bodyBytes)))
            .map((row) => decode(_requiredObject(row)))
            .toList(growable: false),
  );

  T _decode<T>(T Function() parse) {
    try {
      return parse();
    } on FormatException {
      throw const NovaApiException('invalid_response');
    } on TypeError {
      throw const NovaApiException('invalid_response');
    }
  }

  /// Sends an authorized request, renewing the access token once when the
  /// server reports it expired (HTTP 401).
  Future<http.Response> _send(
    String method,
    Uri uri, {
    Map<String, Object?>? json,
    List<int>? bytes,
    String? contentType,
  }) async {
    final token = await _requiredToken();
    final response = await _sendWithToken(
      method,
      uri,
      token,
      json: json,
      bytes: bytes,
      contentType: contentType,
    );
    final refresh = refreshAccessToken;
    if (response.statusCode != 401 || refresh == null) return response;
    final renewed = await refresh();
    if (renewed == null ||
        renewed == token ||
        !_tokenPattern.hasMatch(renewed)) {
      return response;
    }
    return _sendWithToken(
      method,
      uri,
      renewed,
      json: json,
      bytes: bytes,
      contentType: contentType,
    );
  }

  Future<http.Response> _sendWithToken(
    String method,
    Uri uri,
    String token, {
    Map<String, Object?>? json,
    List<int>? bytes,
    String? contentType,
  }) async {
    try {
      final request = http.Request(method, uri)
        ..followRedirects = false
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });
      if (json != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(json);
      } else if (bytes != null) {
        request.headers['Content-Type'] =
            contentType ?? 'application/octet-stream';
        request.bodyBytes = bytes;
      }
      final streamed = await _transport.send(request).timeout(timeout);
      return await http.Response.fromStream(streamed).timeout(timeout);
    } on TimeoutException {
      throw const NovaApiException('timeout');
    } on http.ClientException {
      throw const NovaApiException('connection');
    }
  }

  Future<String> _requiredToken() async {
    final token = await readToken();
    if (token == null || !_tokenPattern.hasMatch(token)) {
      throw const NovaApiException('unauthorized', statusCode: 401);
    }
    return token;
  }

  void close() => _transport.close();
}
