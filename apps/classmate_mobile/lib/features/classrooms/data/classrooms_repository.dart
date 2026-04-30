import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/env.dart';

class ClassroomsRepository {
  ClassroomsRepository({String? token, http.Client? client, String? baseUrl})
    : _token = (token ?? '').trim(),
      _client = client ?? http.Client(),
      _baseUrl = Env.ensureApiSuffix(
        Env.normalizeApiBaseUrl(
          (baseUrl ?? Env.apiBaseUrl).replaceAll(RegExp(r'/$'), ''),
        ),
      );

  final String _token;
  final http.Client _client;
  final String _baseUrl;

  static const _timeout = Duration(seconds: 12);
  static const _hiddenClassroomsKey = 'hidden_classrooms_v1';

  List<String> get _baseCandidates {
    final primary = _baseUrl.replaceAll(RegExp(r'/+$'), '');
    final withApi = Env.ensureApiSuffix(primary);
    final withoutApi = Env.stripApiSuffix(primary).replaceAll(RegExp(r'/+$'), '');

    return <String>{primary, withApi, withoutApi}
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

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

    return '';
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

  Future<void> joinByCode(String code) async {
    try {
      final j = await _postJson(
        '/student/classrooms/join',
        <String, dynamic>{'code': code.trim()},
        label: 'classrooms.joinByCode',
      );
      if (j is Map && j['ok'] != true) {
        throw Exception((j['message'] ?? 'Invalid or expired code').toString());
      }
    } on Exception catch (e) {
      // Parse NestJS error body: "label failed (404): {"message":"..."}"
      final raw = e.toString();
      final bodyMatch = RegExp(r'\{.*\}').firstMatch(raw);
      if (bodyMatch != null) {
        try {
          final decoded = jsonDecode(bodyMatch.group(0)!);
          final msg = (decoded is Map ? decoded['message'] : null)?.toString().trim() ?? '';
          if (msg.isNotEmpty) throw Exception(msg);
        } catch (parseErr) {
          if (parseErr is Exception && parseErr.toString() != 'Exception: $raw') rethrow;
        }
      }
      rethrow;
    }
  }

  Future<void> leaveClassroom(String courseId) async {
    final id = courseId.trim();
    if (id.isEmpty) return;

    // Server-side leave (remove enrollment)
    try {
      await _postJson('/student/classrooms/$id/leave', <String, dynamic>{}, label: 'classrooms.leave');
    } catch (_) {
      // Fall through — still hide locally even if server fails
    }

    // Local hide so the classroom disappears immediately from the list
    final hidden = await _readHiddenClassrooms();
    hidden.add(id);
    await _writeHiddenClassrooms(hidden);
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final clean = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$clean').replace(queryParameters: query);
  }

  Uri _uriWithBase(String base, String path, [Map<String, String>? query]) {
    final clean = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$clean').replace(queryParameters: query);
  }

  Future<Map<String, String>> _headers() async {
    final token = await _readToken();
    return <String, String>{
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
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
    final headers = await _headers();
    late http.Response res;

    for (var index = 0; index < _baseCandidates.length; index++) {
      res = await _client
          .get(_uriWithBase(_baseCandidates[index], path, query), headers: headers)
          .timeout(_timeout);
      if (res.statusCode != 404 || index == _baseCandidates.length - 1) {
        if (!_ok(res)) _fail(label, res);
        if (res.body.trim().isEmpty) return null;
        return jsonDecode(res.body);
      }
    }

    return null;
  }

  // POST variant that tries each base candidate (same logic as _getJson).
  // Needed because some base URLs have an /api suffix that doesn't exist on the
  // server — trying candidates ensures the real URL is hit.
  Future<dynamic> _postJson(
    String path,
    Map<String, dynamic> body, {
    required String label,
  }) async {
    final hdrs = await _headers();
    hdrs['Content-Type'] = 'application/json';
    final encoded = jsonEncode(body);
    late http.Response res;

    for (var index = 0; index < _baseCandidates.length; index++) {
      res = await _client
          .post(_uriWithBase(_baseCandidates[index], path), headers: hdrs, body: encoded)
          .timeout(_timeout);
      if (res.statusCode != 404 || index == _baseCandidates.length - 1) {
        if (!_ok(res)) _fail(label, res);
        if (res.body.trim().isEmpty) return null;
        final j = jsonDecode(res.body);
        return j;
      }
    }

    return null;
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

  Future<List<Map<String, dynamic>>> studentAssessments() async {
    final j = await _getJson(
      '/student/assessments',
      label: 'classrooms.studentAssessments',
    );

    if (j is Map && j['assessments'] is List) {
      return (j['assessments'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);
    }

    if (j is List) {
      return j
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);
    }

    return const <Map<String, dynamic>>[];
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
    final j = await _postJson(
      '/student/classrooms/$courseId/chat/forward',
      <String, dynamic>{
        'messageId': messageId,
        'targetThreadIds': targetThreadIds,
      },
      label: 'classrooms.forwardChatMessage',
    );
    if (j == null) return <String, dynamic>{'ok': true};
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

  Future<Map<String, dynamic>> submitAssignment(
    String courseId,
    String assignmentId, {
    String? note,
  }) async {
    final j = await _postJson(
      '/student/classrooms/$courseId/assignments/$assignmentId/submit',
      <String, dynamic>{
        if ((note ?? '').trim().isNotEmpty) 'note': note!.trim(),
      },
      label: 'classrooms.submitAssignment',
    );
    if (j == null) return <String, dynamic>{'ok': true};
    if (j is! Map) return <String, dynamic>{'ok': true};
    return Map<String, dynamic>.from(j);
  }

  Future<Map<String, dynamic>> sendChatText(
    String courseId,
    String text,
  ) async {
    final j = await _postJson(
      '/student/classrooms/$courseId/chat/text',
      <String, dynamic>{'text': text},
      label: 'classrooms.sendChatText',
    );
    if (j == null) return <String, dynamic>{'ok': true};
    if (j is! Map) return <String, dynamic>{'ok': true};
    return Map<String, dynamic>.from(j);
  }

  Future<void> editChatMessage(
    String courseId, {
    required String messageId,
    required String text,
  }) async {
    final trimmedCourseId = courseId.trim();
    final trimmedMessageId = messageId.trim();
    final trimmedText = text.trim();

    if (trimmedCourseId.isEmpty ||
        trimmedMessageId.isEmpty ||
        trimmedText.isEmpty) {
      throw Exception('courseId, messageId, and text are required');
    }

    final candidates = <Uri>[
      _uri('/student/classrooms/$trimmedCourseId/chat/messages/$trimmedMessageId'),
      _uri('/student/classrooms/$trimmedCourseId/chat/messages/$trimmedMessageId/edit'),
      _uri('/student/classrooms/$trimmedCourseId/messages/$trimmedMessageId'),
      _uri('/student/classrooms/$trimmedCourseId/messages/$trimmedMessageId/edit'),
      _uri('/student/classrooms/$trimmedCourseId/chat/edit'),
      _uri('/student/classrooms/$trimmedCourseId/chat/edit-message'),
    ];

    http.Response? lastRes;

    for (final uri in candidates) {
      final res = await _client
          .patch(
            uri,
            headers: {
              ...await _headers(),
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, dynamic>{
              'messageId': trimmedMessageId,
              'text': trimmedText,
            }),
          )
          .timeout(_timeout);

      if (_ok(res)) {
        return;
      }

      lastRes = res;

      if (res.statusCode != 404) {
        _fail('classrooms.editChatMessage', res);
      }
    }

    if (lastRes != null) {
      _fail('classrooms.editChatMessage', lastRes);
    }

    throw Exception('classrooms.editChatMessage failed: no edit endpoint matched');
  }

  /// Uploads a media file to the classroom chat.
  /// Returns a map that may contain `url`, `mimeType`, and similar fields
  /// extracted from the server response body (empty map if body is not JSON).
  Future<Map<String, dynamic>> sendChatMedia(
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

    final resolvedName = (fileName ?? '').trim().isNotEmpty
        ? fileName!.trim()
        : path.split('/').last;
    final hdrs = await _headers();

    for (var index = 0; index < _baseCandidates.length; index++) {
      final uri = _uriWithBase(_baseCandidates[index], '/student/classrooms/$courseId/chat/media');
      final req = http.MultipartRequest('POST', uri);
      req.headers.addAll(hdrs);

      if ((messageId ?? '').trim().isNotEmpty) req.fields['messageId'] = messageId!.trim();
      if ((text ?? '').trim().isNotEmpty) req.fields['text'] = text!.trim();
      if ((mimeType ?? '').trim().isNotEmpty) req.fields['mimeType'] = mimeType!.trim();

      req.files.add(
        await http.MultipartFile.fromPath('file', path, filename: resolvedName),
      );

      final streamed = await req.send().timeout(_timeout);
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 404 && index < _baseCandidates.length - 1) continue;
      if (!_ok(res)) _fail('classrooms.sendChatMedia', res);

      // Parse the response body for the CDN URL (best-effort).
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
      return const {};
    }
    return const {};
  }
}


final classroomsRepositoryProvider = Provider<ClassroomsRepository>(
  (ref) => ClassroomsRepository(),
);
