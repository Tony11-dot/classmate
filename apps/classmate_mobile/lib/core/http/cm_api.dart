import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env.dart';

class CMApi {
  CMApi({this.token}) : _client = http.Client();

  final String? token;
  final http.Client _client;

  Uri _buildUri(String path, {Map<String, String>? query}) {
    final base = Env.apiBaseUrl.trim();
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

  Map<String, String> _headers({bool json = true}) {
    final t = (token ?? '').trim();

    final headers = <String, String>{
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final looksJwt = t.split('.').length >= 3;
    final looksEmailish = t.contains('@') && t.contains('.');

    if (t.isNotEmpty && looksJwt && !looksEmailish) {
      headers['Authorization'] = 'Bearer $t';
      return headers;
    }

    headers['x-dev-role'] = 'STUDENT';
    headers['x-dev-user-id'] = 'dev-student';
    headers['x-dev-grade'] = '10';
    headers['x-dev-school-id'] = 'test-school';

    final devToken = Env.devToken.trim();
    if (devToken.isNotEmpty) {
      headers['x-dev-token'] = devToken;
    }

    return headers;
  }

  dynamic _decodeOrNull(http.Response res) {
    if (res.body.trim().isEmpty) return null;
    return jsonDecode(res.body);
  }

  void _throwIfBad(http.Response res, Uri uri) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw Exception(
      'HTTP ${res.statusCode} ${uri.toString()} :: '
      '${res.body.trim().isEmpty ? 'empty body' : res.body}',
    );
  }

  Future<dynamic> getJson(String path, {Map<String, String>? query}) async {
    final uri = _buildUri(path, query: query);
    final res = await _client.get(uri, headers: _headers());
    _throwIfBad(res, uri);
    return _decodeOrNull(res);
  }

  Future<dynamic> postJson(String path, {Object? body}) async {
    final uri = _buildUri(path);
    final res = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode(body ?? const <String, dynamic>{}),
    );
    _throwIfBad(res, uri);
    return _decodeOrNull(res);
  }

  Future<dynamic> deleteJson(String path) async {
    final uri = _buildUri(path);
    final res = await _client.delete(uri, headers: _headers(json: false));
    _throwIfBad(res, uri);
    return _decodeOrNull(res);
  }

  void dispose() {
    _client.close();
  }
}
