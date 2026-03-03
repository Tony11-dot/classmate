import 'dart:convert';
import 'dart:io';

import 'sse_client.dart';
import 'package:http/http.dart' as http;

class TutorRepository {
  final SseClient _sse = SseClient();

  TutorRepository(this.baseUrl, this.getToken);

  final String baseUrl;
  final Future<String?> Function() getToken;

  static const _timeout = Duration(seconds: 20);

  String _apiBase() {
    final b = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$b/api';
  }

  Uri _uri(String path, {Map<String, String>? q}) {
    final base = _apiBase();
    final u = Uri.parse('$base$path');
    return (q == null || q.isEmpty) ? u : u.replace(queryParameters: q);
  }

  Future<Map<String, String>> _headers() async {
    final t0 = ((await getToken()) ?? '').trim();
    final t = (t0 == 'SIM_TOKEN') ? '' : t0;
    final isJwtish = t.split('.').length >= 3;
    final hasToken = t.isNotEmpty && isJwtish;
    // ignore: avoid_print
    print('[TUTOR_HEADERS] hasToken=$hasToken tokenLen=${t.length} t="$t"');
    return <String, String>{
      'Content-Type': 'application/json',
      if (hasToken) 'Authorization': 'Bearer $t',
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
    final snippet = body.length > 400 ? '${body.substring(0, 400)}…' : body;
    throw Exception(
      '$label failed: ${res.statusCode} ${res.reasonPhrase} body=$snippet',
    );
  }

  Future<List<dynamic>> fetchCharacters({String? subject}) async {
    final headers = await _headers();
    // ignore: avoid_print
    print('[TUTOR_REPO] headers=$headers');
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

  Future<List<dynamic>> fetchStudentSubjects() async {
    final headers = await _headers();
    final uri = _uri('/student/subjects');

    try {
      final res = await http.get(uri, headers: headers).timeout(_timeout);
      if (!_isOk(res)) {
        _fail('fetchStudentSubjects', res);
      }

      final jsonBody = json.decode(res.body) as Map<String, dynamic>;

      // preferred: { ok, ..., effective: [] }
      final effective = jsonBody['effective'];
      if (effective is List) {
        return effective.cast<dynamic>();
      }

      // fallback shapes
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
  }) async {
    final headers = await _headers();
    final uri = _uri('/tutor/sessions');

    final payload = <String, dynamic>{
      ...?(characterId == null ? null : {'characterId': characterId}),
      ...?(subject == null ? null : {'subject': subject}),
    };

    try {
      final res = await http
          .post(uri, headers: headers, body: json.encode(payload))
          .timeout(_timeout);
      if (!_isOk(res)) {
        _fail('createSession', res);
      }
      return json.decode(res.body) as Map<String, dynamic>;
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
            body: json.encode({'role': 'USER', 'content': text}),
          )
          .timeout(_timeout);
      if (!_isOk(res)) {
        _fail('postMessage', res);
      }
      return json.decode(res.body) as Map<String, dynamic>;
    } on SocketException catch (e) {
      throw Exception('postMessage network error: $e (uri=$uri)');
    }
  }

  Future<Map<String, dynamic>> reply({required String sessionId}) async {
    final headers = await _headers();
    final uri = _uri('/tutor/sessions/$sessionId/reply');

    try {
      final res = await http
          .post(uri, headers: headers, body: json.encode({}))
          .timeout(_timeout);
      if (!_isOk(res)) {
        _fail('reply', res);
      }
      return json.decode(res.body) as Map<String, dynamic>;
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
      // ignore: avoid_print
      print('[SSE] $ev');
      yield ev;
    }
  }
}
