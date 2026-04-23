import 'dart:convert';

import 'package:http/http.dart' as http;

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

  @override
  String toString() {
    final payload = body.trim().isEmpty ? 'empty body' : body;
    return 'HTTP $statusCode ${uri.toString()} :: $payload';
  }
}

class CMApi {
  CMApi({this.token}) : _client = http.Client();

  static const _timeout = Duration(seconds: 8);

  final String? token;
  final http.Client _client;

  List<String> get _baseCandidates {
    final primary = Env.apiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
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

  void dispose() {
    _client.close();
  }
}
