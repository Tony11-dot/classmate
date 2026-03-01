import 'dart:convert';
import 'package:http/http.dart' as http;

class TutorRepository {
  TutorRepository(this.baseUrl, this.getToken);

  final String baseUrl;
  final Future<String?> Function() getToken;

  Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> fetchCharacters({String? subject}) async {
    final headers = await _headers();
    final uri = Uri.parse(
      subject == null
          ? '$baseUrl/tutor/characters'
          : '$baseUrl/tutor/characters?subject=$subject',
    );

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to load characters');
    }

    final jsonBody = json.decode(res.body);
    return jsonBody['characters'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> createSession({
    String? characterId,
    String? subject,
  }) async {
    final headers = await _headers();

    final res = await http.post(
      Uri.parse('$baseUrl/tutor/sessions'),
      headers: headers,
      body: json.encode({
        ...? (characterId == null ? null : {'characterId': characterId}),
        ...? (subject == null ? null : {'subject': subject}),
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to create session');
    }

    return json.decode(res.body);
  }
}
