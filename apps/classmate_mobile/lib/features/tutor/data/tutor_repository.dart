import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'sse_client.dart';

class TutorRepository {
  TutorRepository(this.baseUrl, this.getToken);

  static int _cmLastTutorLogMs = 0;

  final String baseUrl;
  final Future<String?> Function() getToken;
  final SseClient _sse = SseClient();

  static const _timeout = Duration(seconds: 20);

  String _apiBase() {
    return baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  Uri _uri(String path, {Map<String, String>? q}) {
    final u = Uri.parse('${_apiBase()}$path');
    return (q == null || q.isEmpty) ? u : u.replace(queryParameters: q);
  }

  Future<Map<String, String>> _headers() async {
    final raw = ((await getToken()) ?? '').trim();
    final token = raw == 'SIM_TOKEN' ? '' : raw;
    final isJwtish = token.split('.').length >= 3;
    final isDevToken = token.startsWith('dev-token-');
    final hasToken = token.isNotEmpty && (isJwtish || isDevToken);

    if (kDebugMode) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _cmLastTutorLogMs > 1500) {
        _cmLastTutorLogMs = now;
        debugPrint(
          '[TUTOR_HEADERS] hasToken=$hasToken tokenLen=${token.length}',
        );
      }
    }

    return <String, String>{
      'Content-Type': 'application/json',
      if (hasToken) 'Authorization': 'Bearer $token',
      if (!hasToken) ...<String, String>{
        'x-dev-role': 'STUDENT',
        'x-dev-user-id': 'dev-student',
        'x-dev-grade': '10',
        'x-dev-school-id': 'test-school',
      },
    };
  }

  bool _isOk(http.Response res) =>
      res.statusCode == 200 || res.statusCode == 201;

  Never _fail(String label, http.Response res) {
    final body = res.body;
    final snippet = body.length > 500 ? '${body.substring(0, 500)}…' : body;
    throw Exception(
      '$label failed: ${res.statusCode} ${res.reasonPhrase} body=$snippet',
    );
  }

  Future<List<dynamic>> fetchCharacters({String? subject}) async {
    final headers = await _headers();
    final uri = _uri(
      '/tutor/characters',
      q: subject == null ? null : {'subject': subject},
    );

    try {
      final res = await http.get(uri, headers: headers).timeout(_timeout);
      if (!_isOk(res)) {
        _fail('fetchCharacters', res);
      }
      final jsonBody = json.decode(res.body) as Map<String, dynamic>;
      return (jsonBody['characters'] as List<dynamic>?) ?? <dynamic>[];
    } on SocketException catch (e) {
      throw Exception('fetchCharacters network error: $e (uri=$uri)');
    }
  }

  Future<List<dynamic>> fetchSessions() async {
    final headers = await _headers();
    final uri = _uri('/tutor/sessions');

    try {
      final res = await http.get(uri, headers: headers).timeout(_timeout);
      if (!_isOk(res)) {
        _fail('fetchSessions', res);
      }
      final jsonBody = json.decode(res.body) as Map<String, dynamic>;
      return (jsonBody['sessions'] as List<dynamic>?) ?? <dynamic>[];
    } on SocketException catch (e) {
      throw Exception('fetchSessions network error: $e (uri=$uri)');
    }
  }

  Future<Map<String, dynamic>> fetchSessionById(String sessionId) async {
    final headers = await _headers();
    final uri = _uri('/tutor/sessions/$sessionId');

    try {
      final res = await http.get(uri, headers: headers).timeout(_timeout);
      if (!_isOk(res)) {
        _fail('fetchSessionById', res);
      }
      return (json.decode(res.body) as Map<String, dynamic>);
    } on SocketException catch (e) {
      throw Exception('fetchSessionById network error: $e (uri=$uri)');
    }
  }

  Future<Map<String, dynamic>> fetchAcademicContext() async {
    final headers = await _headers();
    final uri = _uri('/tutor/me/academic-context');

    try {
      final res = await http.get(uri, headers: headers).timeout(_timeout);
      if (!_isOk(res)) {
        _fail('fetchAcademicContext', res);
      }
      return (json.decode(res.body) as Map<String, dynamic>);
    } on SocketException catch (e) {
      throw Exception('fetchAcademicContext network error: $e (uri=$uri)');
    }
  }

  Future<List<dynamic>> fetchStudentSubjects() async {
    final headers = await _headers();
    final uri = _uri('/student/subjects');

    try {
      final res = await http.get(uri, headers: headers).timeout(_timeout);
      if (!_isOk(res)) {
        _fail('fetchStudentSubjects', res);
      }

      final jsonBody = json.decode(res.body) as Map<String, dynamic>;
      final effective = jsonBody['effective'];
      if (effective is List) {
        return effective.cast<dynamic>();
      }

      final subjects = jsonBody['subjects'];
      if (subjects is List) {
        return subjects.cast<dynamic>();
      }

      final v = jsonBody['data'] ?? jsonBody['items'] ?? jsonBody['result'];
      if (v is List) {
        return v.cast<dynamic>();
      }
      if (v is Map && v['subjects'] is List) {
        return (v['subjects'] as List).cast<dynamic>();
      }

      return <dynamic>[];
    } on SocketException catch (e) {
      throw Exception('fetchStudentSubjects network error: $e (uri=$uri)');
    }
  }

  Future<Map<String, dynamic>> createSession({
    String? characterId,
    String? subject,
    String? title,
    String? topic,
    String? initialMessage,
  }) async {
    final headers = await _headers();
    final uri = _uri('/tutor/sessions');

    final payload = <String, dynamic>{
      if (characterId != null && characterId.trim().isNotEmpty)
        'characterId': characterId,
      if (subject != null && subject.trim().isNotEmpty) 'subject': subject,
      if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
      if (topic != null && topic.trim().isNotEmpty) 'topic': topic.trim(),
      if (initialMessage != null && initialMessage.trim().isNotEmpty)
        'initialMessage': initialMessage.trim(),
    };

    try {
      final res = await http
          .post(uri, headers: headers, body: json.encode(payload))
          .timeout(_timeout);
      if (!_isOk(res)) {
        _fail('createSession', res);
      }
      return (json.decode(res.body) as Map<String, dynamic>);
    } on SocketException catch (e) {
      throw Exception('createSession network error: $e (uri=$uri)');
    }
  }

  Future<Map<String, dynamic>> postMessage({
    required String sessionId,
    required String text,
  }) async {
    final headers = await _headers();
    final uri = _uri('/tutor/sessions/$sessionId/messages');

    try {
      final res = await http
          .post(
            uri,
            headers: headers,
            body: json.encode(<String, dynamic>{
              'role': 'USER',
              'content': text,
            }),
          )
          .timeout(_timeout);

      if (!_isOk(res)) {
        _fail('postMessage', res);
      }
      return (json.decode(res.body) as Map<String, dynamic>);
    } on SocketException catch (e) {
      throw Exception('postMessage network error: $e (uri=$uri)');
    }
  }

  Future<Map<String, dynamic>> reply({required String sessionId}) async {
    final headers = await _headers();
    final uri = _uri('/tutor/sessions/$sessionId/reply');

    try {
      final res = await http
          .post(uri, headers: headers, body: json.encode(<String, dynamic>{}))
          .timeout(_timeout);

      if (!_isOk(res)) {
        _fail('reply', res);
      }
      return (json.decode(res.body) as Map<String, dynamic>);
    } on SocketException catch (e) {
      throw Exception('reply network error: $e (uri=$uri)');
    }
  }

  Stream<Map<String, dynamic>> replyStream({required String sessionId}) async* {
    final u = _uri('/tutor/sessions/$sessionId/reply/stream');

    await for (final ev in _sse.connect(
      u,
      getToken: () async => (await getToken()) ?? '',
    )) {
      yield ev;
    }
  }
}

extension TutorRepositoryCompat on TutorRepository {
  Future<Map<String, dynamic>> sendMessage({
    required String sessionId,
    required String text,
  }) {
    return postMessage(sessionId: sessionId, text: text);
  }

  Future<Map<String, dynamic>> sendImage({
    required String sessionId,
    required String path,
    String? text,
  }) async {
    final headers = await _headers();
    final uri = _uri('/tutor/sessions/$sessionId/upload');

    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(headers);
    req.fields['kind'] = 'IMAGE';
    if ((text ?? '').trim().isNotEmpty) {
      req.fields['text'] = text!.trim();
    }
    req.files.add(
      await http.MultipartFile.fromPath(
        'file',
        path,
        filename: path.split('/').last,
      ),
    );

    final streamed = await req.send().timeout(TutorRepository._timeout);
    final res = await http.Response.fromStream(streamed);
    if (!_isOk(res)) {
      _fail('sendImage', res);
    }
    return (json.decode(res.body) as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> sendFile({
    required String sessionId,
    required String path,
    String? text,
  }) async {
    final headers = await _headers();
    final uri = _uri('/tutor/sessions/$sessionId/upload');

    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(headers);
    req.fields['kind'] = 'FILE';
    if ((text ?? '').trim().isNotEmpty) {
      req.fields['text'] = text!.trim();
    }
    req.files.add(
      await http.MultipartFile.fromPath(
        'file',
        path,
        filename: path.split('/').last,
      ),
    );

    final streamed = await req.send().timeout(TutorRepository._timeout);
    final res = await http.Response.fromStream(streamed);
    if (!_isOk(res)) {
      _fail('sendFile', res);
    }
    return (json.decode(res.body) as Map<String, dynamic>);
  }

  Future<String> transcribeAudio({
    required String path,
  }) async {
    final headers = await _headers();
    final uri = _uri('/tutor/transcribe');

    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(headers);
    req.files.add(
      await http.MultipartFile.fromPath(
        'file',
        path,
        filename: path.split('/').last,
      ),
    );

    final streamed = await req.send().timeout(TutorRepository._timeout);
    final res = await http.Response.fromStream(streamed);
    if (!_isOk(res)) {
      _fail('transcribeAudio', res);
    }

    if (res.body.trim().isEmpty) return '';
    final body = json.decode(res.body);
    if (body is Map<String, dynamic>) {
      final text = body['text'] ?? body['transcript'] ?? body['content'];
      return text?.toString().trim() ?? '';
    }
    return '';
  }
}
