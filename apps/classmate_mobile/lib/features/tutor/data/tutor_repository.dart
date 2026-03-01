import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class TutorRepository {
  TutorRepository(this.baseUrl, this.getToken);

  final String baseUrl;
  final Future<String?> Function() getToken;

  static const _timeout = Duration(seconds: 20);

  String _apiBase() {
    final b = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return '$b/api';
  }

  Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.trim().isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Never _fail(String label, http.Response res) {
    final body = res.body;
    final snippet = body.length > 400 ? '${body.substring(0, 400)}…' : body;
    throw Exception('$label failed: ${res.statusCode} ${res.reasonPhrase} body=$snippet');
  }

  Future<List<dynamic>> fetchCharacters({String? subject}) async {
    final headers = await _headers();
    final base = _apiBase();
    final uri = Uri.parse(
      subject == null ? '$base/tutor/characters' : '$base/tutor/characters?subject=$subject',
    );

    try {
      final res = await http.get(uri, headers: headers).timeout(_timeout);
      if (res.statusCode != 200) _fail('fetchCharacters', res);
      final jsonBody = json.decode(res.body) as Map<String, dynamic>;
      return (jsonBody['characters'] as List<dynamic>?) ?? <dynamic>[];
    } on SocketException catch (e) {
      throw Exception('fetchCharacters network error: $e (uri=$uri)');
    }
  }

  Future<Map<String, dynamic>> createSession({
    String? characterId,
    String? subject,
  }) async {
    final headers = await _headers();
    final base = _apiBase();
    final uri = Uri.parse('$base/tutor/sessions');

    final payload = <String, dynamic>{
      ...? (characterId == null ? null : {'characterId': characterId}),
      ...? (subject == null ? null : {'subject': subject}),
    };

    try {
      final res = await http
          .post(uri, headers: headers, body: json.encode(payload))
          .timeout(_timeout);

      if (res.statusCode != 200) _fail('createSession', res);
      return json.decode(res.body) as Map<String, dynamic>;
    } on SocketException catch (e) {
      throw Exception('createSession network error: $e (uri=$uri)');
    }
  }
}
