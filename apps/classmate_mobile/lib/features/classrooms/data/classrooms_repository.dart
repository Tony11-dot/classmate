import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  static const _hiddenClassroomsKey = 'hidden_classrooms_v1';

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

  Future<Set<String>> _readHiddenClassrooms() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_hiddenClassroomsKey) ?? const <String>[];
    return raw.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
  }

  Future<void> _writeHiddenClassrooms(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _hiddenClassroomsKey,
      ids.map((e) => e.trim()).where((e) => e.isNotEmpty).toList()..sort(),
    );
  }

  Future<void> leaveClassroom(String courseId) async {
    final id = courseId.trim();
    if (id.isEmpty) return;
    final hidden = await _readHiddenClassrooms();
    hidden.add(id);
    await _writeHiddenClassrooms(hidden);
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
    final uri = _uri('/student/classrooms/$courseId/people');

    final res = await _client
        .get(uri, headers: await _headers())
        .timeout(_timeout);

    if (res.statusCode == 404) {
      return <String, dynamic>{
        'ok': true,
        'items': <dynamic>[],
        'teachers': <dynamic>[],
        'students': <dynamic>[],
      };
    }

    if (!_ok(res)) {
      _fail('classrooms.people', res);
    }

    if (res.body.trim().isEmpty) {
      return <String, dynamic>{
        'ok': true,
        'items': <dynamic>[],
        'teachers': <dynamic>[],
        'students': <dynamic>[],
      };
    }

    final j = jsonDecode(res.body);
    if (j is! Map) {
      return <String, dynamic>{
        'ok': true,
        'items': <dynamic>[],
        'teachers': <dynamic>[],
        'students': <dynamic>[],
      };
    }

    return Map<String, dynamic>.from(j);
  }

  Future<Map<String, dynamic>> chat(
    String courseId, {
    int limit = 30,
    String? cursor,
  }) async {
    final q = <String, String>{'limit': '$limit'};
    if ((cursor ?? '').trim().isNotEmpty) q['cursor'] = cursor!.trim();

    final uri = _uri('/student/classrooms/$courseId/chat', q);

    final res = await _client
        .get(uri, headers: await _headers())
        .timeout(_timeout);

    if (res.statusCode == 404) {
      return <String, dynamic>{'ok': true, 'items': []};
    }

    if (!_ok(res)) {
      _fail('classrooms.chat', res);
    }

    if (res.body.trim().isEmpty) {
      return <String, dynamic>{'ok': true, 'items': []};
    }

    final j = jsonDecode(res.body);
    if (j is! Map) {
      return <String, dynamic>{'ok': true, 'items': []};
    }

    return Map<String, dynamic>.from(j);
  }

  Future<Map<String, dynamic>> assignments(String courseId) async {
    final uri = _uri('/student/classrooms/$courseId/assignments');

    final res = await _client
        .get(uri, headers: await _headers())
        .timeout(_timeout);

    if (res.statusCode == 404) {
      return <String, dynamic>{'ok': true, 'items': []};
    }

    if (!_ok(res)) {
      _fail('classrooms.assignments', res);
    }

    if (res.body.trim().isEmpty) {
      return <String, dynamic>{'ok': true, 'items': []};
    }

    final j = jsonDecode(res.body);
    if (j is! Map) {
      return <String, dynamic>{'ok': true, 'items': []};
    }

    return Map<String, dynamic>.from(j);
  }

  Future<Map<String, dynamic>> materials(String courseId) async {
    final uri = _uri('/student/classrooms/$courseId/materials');

    final res = await _client
        .get(uri, headers: await _headers())
        .timeout(_timeout);

    if (res.statusCode == 404) {
      return <String, dynamic>{'ok': true, 'items': []};
    }

    if (!_ok(res)) {
      _fail('classrooms.materials', res);
    }

    if (res.body.trim().isEmpty) {
      return <String, dynamic>{'ok': true, 'items': []};
    }

    final j = jsonDecode(res.body);
    if (j is! Map) {
      return <String, dynamic>{'ok': true, 'items': []};
    }

    return Map<String, dynamic>.from(j);
  }

  Future<Map<String, dynamic>> forwardChatMessage(
    String courseId, {
    required String messageId,
    required List<String> targetThreadIds,
  }) async {
    final uri = _uri('/student/classrooms/$courseId/chat/forward');
    final res = await _client
        .post(
          uri,
          headers: {...(await _headers()), 'Content-Type': 'application/json'},
          body: jsonEncode({
            'messageId': messageId,
            'targetThreadIds': targetThreadIds,
          }),
        )
        .timeout(_timeout);

    if (!_ok(res)) {
      _fail('classrooms.forwardChatMessage', res);
    }

    if (res.body.trim().isEmpty) {
      return <String, dynamic>{'ok': true};
    }

    final j = jsonDecode(res.body);
    if (j is! Map) return <String, dynamic>{'ok': true};
    return Map<String, dynamic>.from(j);
  }

  Future<Map<String, dynamic>> meetings(String courseId) async {
    final uri = _uri('/student/classrooms/$courseId/meetings');

    final res = await _client
        .get(uri, headers: await _headers())
        .timeout(_timeout);

    if (res.statusCode == 404) {
      return <String, dynamic>{'ok': true, 'items': []};
    }

    if (!_ok(res)) {
      _fail('classrooms.meetings', res);
    }

    if (res.body.trim().isEmpty) {
      return <String, dynamic>{'ok': true, 'items': []};
    }

    final j = jsonDecode(res.body);
    if (j is! Map) {
      return <String, dynamic>{'ok': true, 'items': []};
    }

    return Map<String, dynamic>.from(j);
  }

  Future<Map<String, dynamic>> announcements(String courseId) async {
    final uri = _uri('/student/classrooms/$courseId/announcements');

    final res = await _client
        .get(uri, headers: await _headers())
        .timeout(_timeout);

    if (res.statusCode == 404) {
      return <String, dynamic>{'ok': true, 'items': []};
    }

    if (!_ok(res)) {
      _fail('classrooms.announcements', res);
    }

    if (res.body.trim().isEmpty) {
      return <String, dynamic>{'ok': true, 'items': []};
    }

    final j = jsonDecode(res.body);
    if (j is! Map) {
      return <String, dynamic>{'ok': true, 'items': []};
    }

    return Map<String, dynamic>.from(j);
  }

  Future<Map<String, dynamic>> sendChatText(
    String courseId,
    String text,
  ) async {
    final headers = await _headers();
    headers['Content-Type'] = 'application/json';

    final res = await _client
        .post(
          _uri('/student/classrooms/$courseId/chat/text'),
          headers: headers,
          body: jsonEncode(<String, dynamic>{'text': text}),
        )
        .timeout(_timeout);

    if (res.statusCode == 404) {
      return <String, dynamic>{
        'ok': true,
        'message': <String, dynamic>{
          'id': 'local-${DateTime.now().microsecondsSinceEpoch}',
          'text': text,
          'body': text,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'senderName': 'You',
          'mine': true,
        },
      };
    }

    if (!_ok(res)) {
      _fail('classrooms.sendChatText', res);
    }

    if (res.body.trim().isEmpty) {
      return <String, dynamic>{'ok': true};
    }

    final j = jsonDecode(res.body);
    if (j is! Map) {
      return <String, dynamic>{'ok': true};
    }

    return Map<String, dynamic>.from(j);
  }

  Future<void> sendChatMedia(
    String courseId,
    String filePath, {
    String? messageId,
    String? text,
    String? mimeType,
    String? fileName,
  }) async {
    final path = filePath.trim();
    if (path.isEmpty) {
      throw ArgumentError('filePath cannot be empty');
    }

    final uri = _uri('/student/classrooms/$courseId/chat/media');
    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(await _headers());

    if ((messageId ?? '').trim().isNotEmpty) {
      req.fields['messageId'] = messageId!.trim();
    }
    if ((text ?? '').trim().isNotEmpty) {
      req.fields['text'] = text!.trim();
    }
    if ((mimeType ?? '').trim().isNotEmpty) {
      req.fields['mimeType'] = mimeType!.trim();
    }

    final resolvedName = (fileName ?? '').trim().isNotEmpty
        ? fileName!.trim()
        : path.split('/').last;
    req.files.add(
      await http.MultipartFile.fromPath('file', path, filename: resolvedName),
    );

    final streamed = await req.send().timeout(_timeout);
    final res = await http.Response.fromStream(streamed);
    if (!_ok(res)) {
      _fail('classrooms.sendChatMedia', res);
    }
  }
}


final classroomsRepositoryProvider = Provider<ClassroomsRepository>(
  (ref) => ClassroomsRepository(),
);
