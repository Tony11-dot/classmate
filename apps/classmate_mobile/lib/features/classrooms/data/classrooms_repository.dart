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
  Future<void> deleteClassroomMaterial(String courseId, String materialId) async {
    final hdrs = await _headers();
    for (final base in _baseCandidates) {
      final paths = [
        '/teacher/classrooms/$courseId/materials/$materialId',
        '/student/classrooms/$courseId/materials/$materialId',
      ];
      for (final path in paths) {
        final res = await _client.delete(_uriWithBase(base, path), headers: hdrs).timeout(_timeout);
        if (res.statusCode == 200 || res.statusCode == 204) return;
        if (res.statusCode != 404 && res.statusCode != 403) {
          _fail('classrooms.deleteClassroomMaterial', res);
        }
      }
    }
  }

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
    // Handle both bare array and wrapped {items:[]} or {classrooms:[]} responses
    List raw = const [];
    if (j is List) {
      raw = j;
    } else if (j is Map) {
      raw = (j['items'] ?? j['classrooms'] ?? j['data'] ?? const []) as List? ?? const [];
    }
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
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
    // Try student endpoint first, then teacher endpoint as fallback.
    Future<Map<String, dynamic>?> tryPath(String path) async {
      final headers = await _headers();
      final clean = path.startsWith('/') ? path : '/$path';
      for (final base in _baseCandidates) {
        try {
          final uri = Uri.parse('$base$clean');
          final res = await _client.get(uri, headers: headers).timeout(_timeout);
          if (res.statusCode == 403 || res.statusCode == 401) return null;
          if (res.statusCode == 404) continue;
          if (res.statusCode == 500) return <String, dynamic>{'ok': true};
          if (!_ok(res)) return <String, dynamic>{'ok': true};
          if (res.body.trim().isEmpty) return <String, dynamic>{'ok': true};
          final j = jsonDecode(res.body);
          if (j is! Map) return <String, dynamic>{'ok': true};
          return Map<String, dynamic>.from(j);
        } catch (_) {
          continue;
        }
      }
      return <String, dynamic>{'ok': true};
    }

    bool hasPeople(Map<String, dynamic>? m) {
      if (m == null) return false;
      if (m['teacher'] != null) return true;
      if (m['teachers'] is List && (m['teachers'] as List).isNotEmpty) return true;
      if (m['students'] is List && (m['students'] as List).isNotEmpty) return true;
      if (m['members'] is List && (m['members'] as List).isNotEmpty) return true;
      if (m['items'] is List && (m['items'] as List).isNotEmpty) return true;
      if (m['items'] is Map) return true;
      return false;
    }

    final student = await tryPath('/student/classrooms/$courseId/people');
    if (hasPeople(student)) return student!;

    final teacher = await tryPath('/teacher/classrooms/$courseId/people');
    if (hasPeople(teacher)) return teacher!;

    return student ?? <String, dynamic>{'ok': true};
  }

  Future<Map<String, dynamic>> chat(
    String courseId, {
    int limit = 30,
    String? cursor,
  }) async {
    final q = <String, String>{'limit': '$limit'};
    if ((cursor ?? '').trim().isNotEmpty) q['cursor'] = cursor!.trim();
    final headers = await _headers();
    final suffix = '/student/classrooms/$courseId/chat';
    for (final base in _baseCandidates) {
      try {
        final uri = Uri.parse('$base$suffix').replace(queryParameters: q);
        final res = await _client.get(uri, headers: headers).timeout(_timeout);
        if (res.statusCode == 404) continue;
        if (res.statusCode == 500) return <String, dynamic>{'ok': true, 'items': []};
        if (!_ok(res)) return <String, dynamic>{'ok': true, 'items': []};
        if (res.body.trim().isEmpty) return <String, dynamic>{'ok': true, 'items': []};
        final j = jsonDecode(res.body);
        if (j is! Map) return <String, dynamic>{'ok': true, 'items': []};
        return Map<String, dynamic>.from(j);
      } catch (_) {
        continue;
      }
    }
    return <String, dynamic>{'ok': true, 'items': []};
  }

  Future<Map<String, dynamic>> assignments(String courseId) async {
    // Try the student endpoint first; if it returns empty, fall back to the
    // teacher endpoint. This allows teacher-published assignments to be visible
    // to students even when the server serves them from the teacher namespace.
    final result = await _fetchWithTeacherFallback(
      studentPath: '/student/classrooms/$courseId/assignments',
      teacherPath: '/teacher/classrooms/$courseId/assignments',
      label: 'classrooms.assignments',
    );
    return result;
  }

  /// Calls the debug endpoint to show this student's enrollment state.
  /// Used by the in-app debug button in ClassroomsHomeScreen.
  Future<Map<String, dynamic>> debugMyEnrollments() async {
    final j = await _getJson('/student/classrooms/debug/me',
        label: 'classrooms.debugMe');
    if (j is! Map) return {'error': 'Unexpected response: $j'};
    return Map<String, dynamic>.from(j);
  }

  /// Fetches exams from the new /student/exams endpoint that the teacher
  /// explicitly published for this student (with grade + attachments).
  Future<List<Map<String, dynamic>>> studentTeacherExams() async {
    try {
      final j = await _getJson('/student/exams', label: 'classrooms.studentTeacherExams');
      final raw = (j is Map ? j['items'] : null);
      if (raw is List) {
        return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
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
    return _fetchWithTeacherFallback(
      studentPath: '/student/classrooms/$courseId/materials',
      teacherPath: '/teacher/classrooms/$courseId/materials',
      label: 'classrooms.materials',
    );
  }

  Future<Map<String, dynamic>> forwardChatMessage(
    String courseId, {
    required String messageId,
    required List<String> targetThreadIds,
  }) async {
    final body = <String, dynamic>{
      'messageId': messageId,
      'targetThreadIds': targetThreadIds,
    };
    // Try the teacher-specific endpoint first; fall back to student endpoint.
    // This ensures teachers use a path that explicitly validates teacher ownership.
    Object? lastError;
    for (final path in [
      '/teacher/classrooms/$courseId/chat/forward',
      '/student/classrooms/$courseId/chat/forward',
    ]) {
      try {
        final j = await _postJson(path, body, label: 'classrooms.forwardChatMessage');
        if (j == null) return <String, dynamic>{'ok': true};
        if (j is! Map) return <String, dynamic>{'ok': true};
        return Map<String, dynamic>.from(j);
      } catch (e) {
        lastError = e;
        // Always fall through to the next endpoint candidate.
        // The server now skips invalid targets gracefully, so any error here
        // is an auth/network issue — try student endpoint next.
        continue;
      }
    }
    // Both endpoints failed — surface the error.
    throw lastError ?? Exception('classrooms.forwardChatMessage failed');
  }

  Future<List<Map<String, dynamic>>> allStudentMaterials() async {
    // Use _getJson — it already retries all base candidates.
    try {
      final j = await _getJson('/student/classrooms/all-materials', label: 'classrooms.allMaterials');
      final list = (j is Map ? j['items'] : j) as List? ?? [];
      return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<Map<String, dynamic>> meetings(String courseId) async {
    return _fetchWithTeacherFallback(
      studentPath: '/student/classrooms/$courseId/meetings',
      teacherPath: '/teacher/classrooms/$courseId/meetings',
      label: 'classrooms.meetings',
    );
  }

  /// Fetches from [studentPath]; if the response has an empty `items` list,
  /// tries [teacherPath] so teacher-published data is visible to students.
  Future<Map<String, dynamic>> _fetchWithTeacherFallback({
    required String studentPath,
    required String teacherPath,
    required String label,
  }) async {
    // Tries all base-URL candidates (with and without /api suffix), same as
    // _getJson. Without this, a primary base URL like host/api would get 404
    // from every endpoint and silently return empty items.
    Future<Map<String, dynamic>?> tryPath(String path) async {
      final headers = await _headers();
      final clean = path.startsWith('/') ? path : '/$path';
      for (final base in _baseCandidates) {
        try {
          final uri = Uri.parse('$base$clean');
          final res = await _client.get(uri, headers: headers).timeout(_timeout);
          if (res.statusCode == 403 || res.statusCode == 401) return null;
          if (res.statusCode == 404) continue; // try next base candidate
          if (!_ok(res)) return null;
          if (res.body.trim().isEmpty) return <String, dynamic>{'ok': true, 'items': []};
          final j = jsonDecode(res.body);
          if (j is! Map) return <String, dynamic>{'ok': true, 'items': []};
          return Map<String, dynamic>.from(j);
        } catch (_) {
          continue;
        }
      }
      // All candidates 404'd or failed — return empty (not an error)
      return <String, dynamic>{'ok': true, 'items': []};
    }

    final studentResult = await tryPath(studentPath);
    final studentItems = studentResult?['items'];
    if (studentItems is List && studentItems.isNotEmpty) {
      return studentResult!;
    }

    // Student endpoint returned empty — try teacher endpoint.
    final teacherResult = await tryPath(teacherPath);
    if (teacherResult != null) {
      final teacherItems = teacherResult['items'];
      if (teacherItems is List && teacherItems.isNotEmpty) return teacherResult;
    }

    // Both empty — return student result or empty.
    return studentResult ?? <String, dynamic>{'ok': true, 'items': []};
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

  /// Submits an assignment. [files] is a list of already-uploaded file maps
  /// with `{url, name}` fields. Files must be uploaded via the teacher
  /// repository's [uploadAttachmentFile] before calling this.
  Future<Map<String, dynamic>> submitAssignment(
    String courseId,
    String assignmentId, {
    String? note,
    List<Map<String, String>> files = const [],
    // Legacy path-based param kept for callers that haven't migrated yet.
    List<String> filePaths = const [],
  }) async {
    final j = await _postJson(
      '/student/classrooms/$courseId/assignments/$assignmentId/submit',
      <String, dynamic>{
        if ((note ?? '').trim().isNotEmpty) 'note': note!.trim(),
        if (files.isNotEmpty) 'files': files,
      },
      label: 'classrooms.submitAssignment',
    );
    if (j == null) return <String, dynamic>{'ok': true};
    if (j is! Map) return <String, dynamic>{'ok': true};
    return Map<String, dynamic>.from(j);
  }

  // Legacy multipart path — kept for backward compat but no longer called.
  Future<Map<String, dynamic>> _submitMultipart(
    String courseId,
    String assignmentId, {
    String? note,
    List<String> filePaths = const [],
  }) async {
    final uri = _uri('/student/classrooms/$courseId/assignments/$assignmentId/submit');
    final headers = await _headers();
    final req = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers);
    if ((note ?? '').trim().isNotEmpty) req.fields['note'] = note!.trim();
    for (final path in filePaths) {
      if (path.trim().isEmpty) continue;
      try {
        final name = path.split('/').last;
        req.files.add(await http.MultipartFile.fromPath('files', path, filename: name));
      } catch (_) {}
    }
    final streamed = await req.send().timeout(_timeout);
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode >= 400) {
      throw Exception('Submit failed: ${streamed.statusCode}');
    }
    if (body.trim().isEmpty) return <String, dynamic>{'ok': true};
    try {
      final j = jsonDecode(body);
      if (j is! Map) return <String, dynamic>{'ok': true};
      return Map<String, dynamic>.from(j);
    } catch (_) {
      return <String, dynamic>{'ok': true};
    }
  }

  Future<Map<String, dynamic>> sendChatText(
    String courseId,
    String text, {
    String? replyToMessageId,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw ArgumentError('Message text cannot be empty');
    final body = <String, dynamic>{'text': trimmed};
    if ((replyToMessageId ?? '').trim().isNotEmpty) {
      body['replyToMessageId'] = replyToMessageId!.trim();
    }
    final j = await _postJson(
      '/student/classrooms/$courseId/chat/text',
      body,
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
