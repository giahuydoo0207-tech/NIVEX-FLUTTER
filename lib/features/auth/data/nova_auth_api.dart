import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

class NovaAuthSession {
  const NovaAuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
  });

  factory NovaAuthSession.fromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'];
    final refreshToken = json['refreshToken'];
    final expiresAt = json['accessExpiresAt'];
    if (accessToken is! String ||
        !RegExp(r'^[A-Za-z0-9_-]{43,128}$').hasMatch(accessToken) ||
        refreshToken is! String ||
        !RegExp(r'^[A-Za-z0-9_-]{43,128}$').hasMatch(refreshToken) ||
        expiresAt is! String) {
      throw const FormatException('Invalid auth response');
    }
    return NovaAuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessExpiresAt: DateTime.parse(expiresAt),
    );
  }

  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;
}

class NovaPhoneOtpChallenge {
  const NovaPhoneOtpChallenge({
    required this.id,
    required this.expiresInSeconds,
    this.debugOtp,
  });

  factory NovaPhoneOtpChallenge.fromJson(Map<String, dynamic> json) {
    final id = json['challengeId'];
    final expiresInSeconds = json['expiresInSeconds'];
    final debugOtp = json['debugOtp'];
    if (id is! String ||
        !RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          caseSensitive: false,
        ).hasMatch(id) ||
        expiresInSeconds is! int ||
        expiresInSeconds < 1 ||
        expiresInSeconds > 600 ||
        (debugOtp != null &&
            (debugOtp is! String ||
                !RegExp(r'^[0-9]{6}$').hasMatch(debugOtp)))) {
      throw const FormatException('Invalid OTP challenge response');
    }
    return NovaPhoneOtpChallenge(
      id: id,
      expiresInSeconds: expiresInSeconds,
      debugOtp: debugOtp as String?,
    );
  }

  final String id;
  final int expiresInSeconds;
  final String? debugOtp;
}

class NovaAuthApi {
  NovaAuthApi({
    required this.config,
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  final NovaApiConfig config;
  final Duration timeout;
  final http.Client _client;

  Future<NovaAuthSession> registerEmail({
    required String email,
    required String phoneE164,
    required String displayName,
    required String password,
  }) => _postSession('/api/v1/auth/register/email', {
    'email': email,
    'phoneE164': phoneE164,
    'displayName': displayName,
    'password': password,
  });

  Future<NovaAuthSession> loginEmail({
    required String email,
    required String password,
  }) => _postSession('/api/v1/auth/login/email', {
    'email': email,
    'password': password,
  });

  Future<NovaAuthSession> refreshSession({required String refreshToken}) =>
      _postSession('/api/v1/auth/refresh', {'refreshToken': refreshToken});

  Future<NovaPhoneOtpChallenge> requestPhoneOtp({
    required String phoneE164,
  }) async {
    try {
      final response = await _client
          .post(
            config.baseUri.resolve('/api/v1/auth/phone/request-otp'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'phoneE164': phoneE164}),
          )
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NovaApiException(
          'otp_request_failed',
          statusCode: response.statusCode,
        );
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected OTP challenge');
      }
      return NovaPhoneOtpChallenge.fromJson(decoded);
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

  Future<NovaAuthSession> verifyPhoneOtp({
    required String challengeId,
    required String code,
    required String displayName,
  }) => _postSession('/api/v1/auth/phone/verify-otp', {
    'challengeId': challengeId,
    'code': code,
    'displayName': displayName,
  });

  Future<void> validateAccessToken({required String accessToken}) async {
    try {
      final response = await _client
          .get(
            config.baseUri.resolve('/api/v1/auth/me'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NovaApiException('auth_failed', statusCode: response.statusCode);
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected authenticated user');
      }
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

  Future<NovaAuthSession> _postSession(
    String path,
    Map<String, Object> body,
  ) async {
    try {
      final response = await _client
          .post(
            config.baseUri.resolve(path),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NovaApiException('auth_failed', statusCode: response.statusCode);
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected auth session');
      }
      return NovaAuthSession.fromJson(decoded);
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

  void close() => _client.close();
}
