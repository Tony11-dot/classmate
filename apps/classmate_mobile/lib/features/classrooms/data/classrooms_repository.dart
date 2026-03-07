import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClassroomsRepository {
  ClassroomsRepository({String? token, http.Client? client, String? baseUrl})
    : _token = (token ?? '').trim(),
      _client = client ?? http.Client(),
      _baseUrl =
          (baseUrl ??
                  const String.fromEnvironment(
                    'CM_API_BASE_URL',
                    defaultValue: 'http://127.0.0.1:3001/api',
                  ))
              .replaceAll(RegExp(r'/$'), '');

  final String _token;
  final http.Client _client;
  final String _baseUrl;

  static const _timeout = Duration(seconds: 12);
  static const _devStudentToken = 'dev-token-student@classmate.local';

  Future<String> _readToken() async {
    if (_token.isNotEmpty && _token != 'SIM_TOKEN') return _token;

    final prefs = await SharedPreferences.getInstance();

    const candidates = <String>[
      'auth_token_v2',
      'auth_token',
      'token',
      'jwt',
      'access_token',
      'accessToken',
      'cm_token',
    ];

    for (final key in candidates) {
      final value = prefs.getString(key)?.trim() ?? '';
      if (value.isNotEmpty && value != 'SIM_TOKEN') return value;
    }

    return _devStudentToken;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final clean = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$clean').replace(queryParameters: query);
  }

  Future<Map<String, String>> _headers() async {
    final token = await _readToken();
    return <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  bool _ok(http.Response res) => res.statusCode >= 200 && res.statusCode < 300;

  Never _fail(String label, http.Response res) {
    throw Exception(
      '$label failed (${res.statusCode}): ${res.body.isEmpty ? 'empty body' : res.body}',
    );
  }

  Future<dynamic> _getJson(
    String path, {
    Map<String, String>? query,
    required String label,
  }) async {
    final res = await _client
        .get(_uri(path, query), headers: await _headers())
        .timeout(_timeout);

    if (!_ok(res)) _fail(label, res);
    if (res.body.trim().isEmpty) return null;

    return jsonDecode(res.body);
  }

  Future<dynamic> _postJson(
    String path, {
    Object? body,
    required String label,
  }) async {
    final headers = await _headers();
    headers['Content-Type'] = 'application/json';

    final res = await _client
        .post(
          _uri(path),
          headers: headers,
          body: jsonEncode(body ?? <String, dynamic>{}),
        )
        .timeout(_timeout);

    if (!_ok(res)) _fail(label, res);
    if (res.body.trim().isEmpty) return null;

    return jsonDecode(res.body);
  }

  Future<List<Map<String, dynamic>>> list() async {
    final j = await _getJson('/student/classrooms', label: 'classrooms.list');

    final raw = (j is List) ? j : const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> detail(String courseId) async {
    final j = await _getJson(
      '/student/classrooms/$courseId',
      label: 'classrooms.detail',
    );
    if (j is! Map) return <String, dynamic>{};
    return Map<String, dynamic>.from(j);
  }

  Future<Map<String, dynamic>> people(String courseId) async {
    final j = await _getJson(
      '/student/classrooms/$courseId/people',
      label: 'classrooms.people',
    );
    if (j is! Map) return <String, dynamic>{'ok': true, 'items': {}};
    return Map<String, dynamic>.from(j);
  }

  Future<Map<String, dynamic>> chat(
    String courseId, {
    int limit = 30,
    String? cursor,
  }) async {
    final q = <String, String>{'limit': '$limit'};
    if ((cursor ?? '').trim().isNotEmpty) q['cursor'] = cursor!.trim();

    final j = await _getJson(
      '/student/classrooms/$courseId/chat',
      query: q,
      label: 'classrooms.chat',
    );
    if (j is! Map) return <String, dynamic>{'ok': true, 'items': []};
    return Map<String, dynamic>.from(j);
  }

  Future<Map<String, dynamic>> assignments(String courseId) async {
    final j = await _getJson(
      '/student/classrooms/$courseId/assignments',
      label: 'classrooms.assignments',
    );
    if (j is! Map) return <String, dynamic>{'ok': true, 'items': []};
    return Map<String, dynamic>.from(j);
  }

  Future<Map<String, dynamic>> materials(String courseId) async {
    final j = await _getJson(
      '/student/classrooms/$courseId/materials',
      label: 'classrooms.materials',
    );
    if (j is! Map) return <String, dynamic>{'ok': true, 'items': []};
    return Map<String, dynamic>.from(j);
  }

  Future<Map<String, dynamic>> meetings(String courseId) async {
    final j = await _getJson(
      '/student/classrooms/$courseId/meetings',
      label: 'classrooms.meetings',
    );
    if (j is! Map) return <String, dynamic>{'ok': true, 'items': []};
    return Map<String, dynamic>.from(j);
  }

  Future<Map<String, dynamic>> announcements(String courseId) async {
    final j = await _getJson(
      '/student/classrooms/$courseId/announcements',
      label: 'classrooms.announcements',
    );
    if (j is! Map) return <String, dynamic>{'ok': true, 'items': []};
    return Map<String, dynamic>.from(j);
  }

  Future<Map<String, dynamic>> sendChatText(
    String courseId,
    String text,
  ) async {
    final j = await _postJson(
      '/student/classrooms/$courseId/chat/text',
      body: {'text': text},
      label: 'classrooms.sendChatText',
    );
    if (j is! Map) return <String, dynamic>{'ok': true};
    return Map<String, dynamic>.from(j);
  }
}
