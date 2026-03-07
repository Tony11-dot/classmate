import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';

class CMApi {
  CMApi({this.token}) : _client = http.Client();

  final String? token;
  final http.Client _client;

  Uri _buildUri(String path, {Map<String, String>? query}) {
    final base = Env.apiBaseUrl;
    final baseUri = Uri.parse(base);
    final p = path.startsWith('/') ? path : '/$path';

    return Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      path:
          (baseUri.path.endsWith('/')
              ? baseUri.path.substring(0, baseUri.path.length - 1)
              : baseUri.path) +
          p,
      queryParameters: (query == null || query.isEmpty) ? null : query,
    );
  }

  Map<String, String> _headers({bool json = true}) {
    final t = (token ?? '').trim();
    return {
      if (json) 'Content-Type': 'application/json',
      if (t.isNotEmpty) 'Authorization': 'Bearer $t',
      if (t.isEmpty) 'x-dev-role': 'STUDENT',
      if (t.isEmpty) 'x-dev-user-id': 'dev-student',
      if (t.isEmpty) 'x-dev-grade': '10',
      if (t.isEmpty) 'x-dev-school-id': 'test-school',
    };
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
      body: jsonEncode(body ?? {}),
    );
    _throwIfBad(res, uri);
    return _decodeOrNull(res);
  }

  Future<dynamic> deleteJson(String path) async {
    final uri = _buildUri(path);
    final res = await _client.delete(uri, headers: _headers());
    _throwIfBad(res, uri);
    return _decodeOrNull(res);
  }
}
