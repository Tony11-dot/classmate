import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  const ApiClient(this.baseUrl);

  Future<Map<String, dynamic>> health() async {
    final uri = Uri.parse('$baseUrl/api/health');
    final res = await http.get(uri).timeout(const Duration(seconds: 6));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Health failed: ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
