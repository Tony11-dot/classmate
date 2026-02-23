import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl, required this.tokenProvider});

  final String baseUrl;
  final Future<String?> Function() tokenProvider;

  Uri _u(String path, [Map<String, dynamic>? query]) {
    final qp = query == null
        ? null
        : query.map((k, v) => MapEntry(k, v == null ? '' : '$v'));
    return Uri.parse('$baseUrl$path').replace(queryParameters: qp);
  }

  Future<http.Response> get(String path, {Map<String, dynamic>? query}) async {
    final t = await tokenProvider();
    final r = await http.get(
      _u(path, query),
      headers: {
        'accept': 'application/json',
        if (t != null && t.isNotEmpty) 'authorization': 'Bearer $t',
      },
    );
    return r;
  }

  Future<http.Response> post(String path, {Object? body}) async {
    final t = await tokenProvider();
    final r = await http.post(
      _u(path),
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        if (t != null && t.isNotEmpty) 'authorization': 'Bearer $t',
      },
      body: body == null ? null : jsonEncode(body),
    );
    return r;
  }
}
