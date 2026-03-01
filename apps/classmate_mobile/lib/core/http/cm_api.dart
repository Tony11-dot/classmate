import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/env.dart';

class CMApi {
  CMApi({required this.token});

  final String? token;

  Uri _u(String path, [Map<String, String>? q]) {
    final base = Uri.parse(Env.apiBaseUrl);
    final p = path.startsWith('/') ? path : '/$path';
    return base.replace(
      path: (base.path.endsWith('/') ? base.path.substring(0, base.path.length - 1) : base.path) + p,
      queryParameters: (q == null || q.isEmpty) ? null : q,
    );
  }

  Map<String, String> _headers({bool json = true}) {
    final h = <String, String>{
      'x-school-id': Env.schoolId,
    };
    if (token != null && token!.trim().isNotEmpty) {
      h['authorization'] = 'Bearer ${token!.trim()}';
      // ignore: avoid_print
      // ignore: avoid_print
      print('CMApi authHeader=${h['authorization']}');
    }
    if (json) h['content-type'] = 'application/json';
    // ignore: avoid_print
    // ignore: avoid_print
    print('CMApi headers=$h');
    // ignore: avoid_print
    // ignore: avoid_print
    print('CMApi headers=$h');
    return h;
  }

  Future<Map<String, dynamic>> getJson(String path, {Map<String, String>? query}) async {
    final r = await http.get(_u(path, query), headers: _headers(json: false));
    final body = r.body.isEmpty ? '{}' : r.body;
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('GET $path failed ${r.statusCode}: $body');
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postJson(String path, Object payload) async {
    final r = await http.post(_u(path), headers: _headers(), body: jsonEncode(payload));
    final body = r.body.isEmpty ? '{}' : r.body;
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('POST $path failed ${r.statusCode}: $body');
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }
}
