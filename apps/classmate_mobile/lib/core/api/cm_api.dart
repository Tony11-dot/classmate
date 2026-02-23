import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_client.dart';

class CMApi {
  Future<dynamic> getAny(String path, {Map<String, dynamic>? query}) async {
    final r = await client.get(path, query: query);
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw HttpException("GET " + path + " failed " + r.statusCode.toString() + ": " + r.body);
    }
    return jsonDecode(r.body);
  }

  CMApi(this.client);

  final ApiClient client;

  Future<Map<String, dynamic>> getJson(String path, {Map<String, dynamic>? query}) async {
    final r = await client.get(path, query: query);
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw HttpException('GET $path failed ${r.statusCode}: ${r.body}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
    }

  Future<List<dynamic>> getList(String path, {Map<String, dynamic>? query}) async {
    final r = await client.get(path, query: query);
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw HttpException('GET $path failed ${r.statusCode}: ${r.body}');
    }
    return jsonDecode(r.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> postJson(String path, {Object? body}) async {
    final r = await client.post(path, body: body);
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw HttpException('POST $path failed ${r.statusCode}: ${r.body}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> multipart(
    String path, {
    required Map<String, String> fields,
    required List<File> files,
    String fileField = 'files',
  }) async {
    final u = Uri.parse('${client.baseUrl}$path');
    final t = await client.tokenProvider();

    final req = http.MultipartRequest('POST', u);
    req.headers['accept'] = 'application/json';
    if (t != null && t.isNotEmpty) req.headers['authorization'] = 'Bearer $t';

    req.fields.addAll(fields);

    for (final f in files) {
      final name = f.path.split('/').last;
      req.files.add(await http.MultipartFile.fromPath(fileField, f.path, filename: name));
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw HttpException('MULTIPART $path failed ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
