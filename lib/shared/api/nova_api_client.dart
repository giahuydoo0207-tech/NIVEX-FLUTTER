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
    final local = const [
      'localhost',
      '127.0.0.1',
      '10.0.2.2',
    ].contains(baseUri.host);
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
  factory NovaApiConfig.fromBuild() =>
      NovaApiConfig(const String.fromEnvironment('NOVA_API_URL'));
  final Uri baseUri;
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
  final fraction = digits.substring(digits.length - 6).replaceFirst(
    RegExp(r'0+$'),
    '',
  );
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
  void close() => _transport.close();
}
