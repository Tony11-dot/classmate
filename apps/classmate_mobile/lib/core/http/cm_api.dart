import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/env.dart';

class CMApiException implements Exception {
  CMApiException({
    required this.statusCode,
    required this.uri,
    required this.body,
  });

  final int statusCode;
  final Uri uri;
  final String body;

  // Technical details for logging/debugging.
  String get debugString {
    final payload = body.trim().isEmpty ? 'empty body' : body;
    return 'HTTP $statusCode ${uri.toString()} :: $payload';
  }

  // User-facing message: parses the backend JSON body first, then falls back
  // to status-code descriptions.
  String get friendlyMessage {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final msg = decoded['message'];
        if (msg is String && msg.isNotEmpty && !_isTechnical(msg)) return msg;
      }
    } catch (_) {}
    return switch (statusCode) {
      400 => 'Invalid request. Please check your input.',
      401 => 'Your session has expired. Please sign in again.',
      403 => 'You don\'t have permission to do this.',
      404 => 'The item you\'re looking for could not be found.',
      409 => 'A conflict occurred. This item may already exist.',
      429 => 'You\'re making requests too quickly. Please wait a moment.',
      _ when statusCode >= 500 => 'Something went wrong on our end. Please try again.',
      _ => 'An error occurred. Please try again.',
    };
  }

  static bool _isTechnical(String msg) {
    final lower = msg.toLowerCase();
    return lower == 'unauthorized' ||
        lower == 'forbidden' ||
        lower == 'invalid token' ||
        lower == 'bad request' ||
        lower.contains('internal server error') ||
        lower.contains('prisma') ||
        // Framework exception names / internals must never reach the UI
        // (e.g. "ThrottlerException: Too Many Requests").
        lower.contains('exception') ||
        lower.contains('throttler') ||
        lower.contains('stack') ||
        lower.contains('/api/') ||
        lower.contains('http');
  }

  @override
  String toString() => friendlyMessage;
}

class CMApi {
  CMApi({this.token}) : _client = http.Client();

  // Railway's container can take 5–10s on a cold start (first request
  // after the service has been idle). The previous 8s ceiling was
  // killing every login attempt right at the cold-start boundary —
  // user reports "request timed out" became the norm after periods of
  // inactivity. 25s is comfortable for cold starts while still failing
  // fast when the backend is truly down.
  static const _timeout = Duration(seconds: 25);

  final String? token;
  final http.Client _client;

  String get primaryBaseUrl => Env.apiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');

  List<String> get _baseCandidates {
    final primary = primaryBaseUrl;
    final withApi = Env.ensureApiSuffix(primary);
    final withoutApi = Env.stripApiSuffix(primary).replaceAll(RegExp(r'/+$'), '');

    return <String>{primary, withApi, withoutApi}.where((value) => value.isNotEmpty).toList(growable: false);
  }

  Uri _buildUri(String base, String path, {Map<String, String>? query}) {
    final baseUri = Uri.parse(base);
    final cleanPath = path.startsWith('/') ? path : '/$path';

    final normalizedBasePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;

    return Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      path: '$normalizedBasePath$cleanPath',
      queryParameters: (query == null || query.isEmpty) ? null : query,
    );
  }

  Future<http.Response> _sendWithFallback(
    Future<http.Response> Function(Uri uri) send, {
    required String path,
    Map<String, String>? query,
  }) async {
    late http.Response lastResponse;
    late Uri lastUri;

    for (var index = 0; index < _baseCandidates.length; index++) {
      lastUri = _buildUri(_baseCandidates[index], path, query: query);
      lastResponse = await send(lastUri).timeout(_timeout);
      if (lastResponse.statusCode != 404 || index == _baseCandidates.length - 1) {
        _throwIfBad(lastResponse, lastUri);
        return lastResponse;
      }
    }

    _throwIfBad(lastResponse, lastUri);
    return lastResponse;
  }

  Map<String, String> _headers({bool json = true}) {
    final t = (token ?? '').trim();

    final headers = <String, String>{
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final looksJwt = t.split('.').length >= 3;
    final looksEmailish = t.contains('@') && t.contains('.');
    // dev-token-* are accepted by the backend when ALLOW_DEV_TOKEN=1.
    final isDevToken = t.startsWith('dev-token-');
    final hasToken = t.isNotEmpty && ((looksJwt && !looksEmailish) || isDevToken);

    if (hasToken) {
      headers['Authorization'] = 'Bearer $t';
    }

    return headers;
  }

  dynamic _decodeOrNull(http.Response res) {
    if (res.body.trim().isEmpty) return null;
    return jsonDecode(res.body);
  }

  void _throwIfBad(http.Response res, Uri uri) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw CMApiException(
      statusCode: res.statusCode,
      uri: uri,
      body: res.body,
    );
  }

  Future<dynamic> getJson(String path, {Map<String, String>? query}) async {
    final res = await _sendWithFallback(
      (uri) => _client.get(uri, headers: _headers()),
      path: path,
      query: query,
    );
    return _decodeOrNull(res);
  }

  Future<dynamic> postJson(String path, {Object? body}) async {
    final res = await _sendWithFallback(
      (uri) => _client.post(
        uri,
        headers: _headers(),
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
      path: path,
    );
    return _decodeOrNull(res);
  }

  Future<dynamic> putJson(String path, {Object? body}) async {
    final res = await _sendWithFallback(
      (uri) => _client.put(
        uri,
        headers: _headers(),
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
      path: path,
    );
    return _decodeOrNull(res);
  }

  Future<dynamic> patchJson(String path, {Object? body}) async {
    final res = await _sendWithFallback(
      (uri) => _client.patch(
        uri,
        headers: _headers(),
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
      path: path,
    );
    return _decodeOrNull(res);
  }

  Future<dynamic> deleteJson(String path) async {
    final res = await _sendWithFallback(
      (uri) => _client.delete(uri, headers: _headers(json: false)),
      path: path,
    );
    return _decodeOrNull(res);
  }

  /// Multipart file upload — returns decoded JSON response body.
  Future<Map<String, dynamic>> multipartUpload(Uri uri, String filePath, {String? mimeType}) async {
    final t = (token ?? '').trim();
    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $t'
      ..files.add(await http.MultipartFile.fromPath('file', filePath,
          contentType: mimeType != null ? _mediaType(mimeType) : null));
    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed);
    _throwIfBad(response, uri);
    final decoded = _decodeOrNull(response);
    if (decoded is Map<String, dynamic>) return decoded;
    return const <String, dynamic>{};
  }

  static MediaType? _mediaType(String mime) {
    try { return MediaType.parse(mime); } catch (_) { return null; }
  }

  void dispose() {
    _client.close();
  }
}
