import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/env.dart';
import '../../l10n/app_localizations.dart';
import 'server_messages.dart';

class CMApiException implements Exception {
  CMApiException({
    required this.statusCode,
    required this.uri,
    required this.body,
  });

  /// The language the UI currently renders in, set by the app root. Exceptions
  /// have no BuildContext, so this is how [friendlyMessage] (and therefore
  /// every `'$e'` shown in a toast or banner) comes out localized. Null → English.
  static Locale? uiLocale;

  static AppLocalizations _l10n() {
    try {
      return lookupAppLocalizations(uiLocale ?? const Locale('en'));
    } catch (_) {
      return lookupAppLocalizations(const Locale('en'));
    }
  }

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
        if (msg is String && msg.isNotEmpty && !_isTechnical(msg)) {
          final known = localizeServerMessage(msg, _l10n());
          if (known != null) return known;
          // Unknown text is English developer wording ("studentId is
          // required"). Only an English UI shows it as is; everywhere else
          // the status-based message below is the better answer.
          if ((uiLocale?.languageCode ?? 'en') == 'en') return msg;
        }
      }
    } catch (_) {}
    final l = _l10n();
    return switch (statusCode) {
      400 => l.errApiBadRequest,
      401 => l.errApiSessionExpired,
      403 => l.errApiForbidden,
      404 => l.errApiNotFound,
      409 => l.errApiConflict,
      429 => l.errApiTooManyRequests,
      _ when statusCode >= 500 => l.errApiServer,
      _ => l.errApiGeneric,
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

  /// Bytes variant of [multipartUpload] — required on web, where picked files
  /// have no filesystem path (only in-memory bytes) so `MultipartFile.fromPath`
  /// can't be used.
  Future<Map<String, dynamic>> multipartUploadBytes(
    Uri uri,
    List<int> bytes,
    String filename, {
    String? mimeType,
  }) async {
    final t = (token ?? '').trim();
    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $t'
      ..files.add(http.MultipartFile.fromBytes('file', bytes,
          filename: filename,
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
