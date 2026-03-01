import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/env.dart';

class CMApi {
  CMApi({this.token}) : _client = http.Client();

  final String? token;
  final http.Client _client;

  Uri _buildUri(String path, {Map<String, String>? query}) {
    final base = Env.apiBaseUrl; // e.g. http://192.168.x.x:3001
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

  Map<String, String> _headers({required bool contentTypeJson}) {
    final h = <String, String>{
      'x-school-id': Env.schoolId,
      if (contentTypeJson) 'content-type': 'application/json',
      'accept': 'application/json',
    };
    final t = token;
    if (t != null && t.trim().isNotEmpty) {
      h['authorization'] = 'Bearer ${t.trim()}';
    }
    return h;
  }

  dynamic _decode(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) {
        return <String, dynamic>{};
      }
      final v = jsonDecode(res.body);
      return v;
    }

    // try to surface JSON error payloads nicely
    try {
      final v = jsonDecode(res.body);
      throw Exception('HTTP ${res.statusCode}: ${jsonEncode(v)}');
    } catch (_) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }

  Future<dynamic> getJson(String path, {Map<String, String>? query}) async {
    final uri = _buildUri(path, query: query);
    final res = await _client.get(
      uri,
      headers: _headers(contentTypeJson: false),
    );
    return _decode(res);
  }

  Future<dynamic> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final uri = _buildUri(path, query: query);
    final res = await _client.post(
      uri,
      headers: _headers(contentTypeJson: true),
      body: jsonEncode(body ?? const <String, dynamic>{}),
    );
    return _decode(res);
  }

  Future<dynamic> deleteJson(String path, {Map<String, String>? query}) async {
    final uri = _buildUri(path, query: query);
    final res = await _client.delete(
      uri,
      headers: _headers(contentTypeJson: false),
    );
    return _decode(res);
  }

  @mustCallSuper
  void dispose() {
    _client.close();
  }
}
