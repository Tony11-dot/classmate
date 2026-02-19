import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session.dart';

class ApiException implements Exception {
  final int status;
  final String message;
  final Map<String, dynamic>? json;

  ApiException(this.status, this.message, {this.json});

  @override
  String toString() => 'ApiException($status): $message';
}

class Api {
  Api();

  String get base {
    // default to pilot api
    const env = String.fromEnvironment('API_BASE', defaultValue: 'http://127.0.0.1:3000/api');
    return env.replaceAll(RegExp(r'\/$'), '');
  }

  Future<dynamic> getAny(String path) async {
    final token = await Session.token();
    final uri = Uri.parse('$base$path');

    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });

    return _decodeAnyOrThrow(res);
  }

  Future<dynamic> postAny(String path, {Object? body}) async {
    final token = await Session.token();
    final uri = Uri.parse('$base$path');

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: body == null ? null : jsonEncode(body),
    );

    return _decodeAnyOrThrow(res);
  }

  dynamic _decodeAnyOrThrow(http.Response res) {
    final t = (res.body).trim();
    dynamic j;
    try {
      j = t.isEmpty ? null : jsonDecode(t);
    } catch (_) {
      j = {'message': res.body};
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'HTTP ${res.statusCode}';
      if (j is Map) {
        final m = j;
        msg = (m['message'] ?? m['error'] ?? msg).toString();
      }
      throw ApiException(res.statusCode, msg, json: j is Map ? j.cast<String, dynamic>() : null);
    }

    return j;
  }
}
