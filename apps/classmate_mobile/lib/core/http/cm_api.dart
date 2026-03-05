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

  Future<dynamic> getJson(String path, {Map<String, String>? query}) async {
    final res = await _client.get(
      _buildUri(path, query: query),
      headers: _headers(),
    );

    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }

  Future<dynamic> postJson(String path, {Object? body}) async {
    final res = await _client.post(
      _buildUri(path),
      headers: _headers(),
      body: jsonEncode(body ?? {}),
    );

    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }

  Future<dynamic> deleteJson(String path) async {
    final res = await _client.delete(_buildUri(path), headers: _headers());

    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }
}
