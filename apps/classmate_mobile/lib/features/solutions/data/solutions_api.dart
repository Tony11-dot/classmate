import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/auth/auth_controller.dart';
import '../../../core/config/env.dart';
import '../../../core/http/cm_api.dart';

const _devStudentToken = 'dev-token-student@classmate.local';

final solutionsApiProvider = Provider<SolutionsApi>((ref) {
  final session = ref.watch(authSessionProvider);
  final token = (session.token ?? '').trim();
  return SolutionsApi(
    baseUrl: Env.apiBaseUrl,
    token: token.isEmpty ? _devStudentToken : token,
  );
});

class SolutionsApi {
  const SolutionsApi({required this.baseUrl, this.token = _devStudentToken});

  final String baseUrl;
  final String token;

  CMApi get _api => CMApi(token: token);

  String _normalizedBaseUrl() {
    return baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  Uri _uri(String path) => Uri.parse('${_normalizedBaseUrl()}$path');

  Map<String, String> _headers() {
    final trimmed = token.trim();
    final isJwtish = trimmed.split('.').length >= 3;
    final isDevToken = trimmed.startsWith('dev-token-');
    final hasToken = trimmed.isNotEmpty && (isJwtish || isDevToken);

    return <String, String>{
      if (hasToken) 'Authorization': 'Bearer $trimmed',
      if (!hasToken) ...<String, String>{
        'x-dev-role': 'STUDENT',
        'x-dev-user-id': 'dev-student',
        'x-dev-grade': '10',
        'x-dev-school-id': 'test-school',
      },
    };
  }

  Future<Map<String, dynamic>> fetchSubjects() async {
    final raw = await _api.getJson('/solutions/subjects');
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> fetchBooks({String? subject}) async {
    final q = <String, String>{};
    if ((subject ?? '').trim().isNotEmpty) {
      q['subject'] = subject!.trim();
    }
    final raw = await _api.getJson('/solutions/books', query: q);
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> fetchSolutions({
    String? subject,
    String? bookTitle,
    int? pageNumber,
    String? questionNumber,
    int page = 1,
    int limit = 12,
  }) async {
    final q = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if ((subject ?? '').trim().isNotEmpty) 'subject': subject!.trim(),
      if ((bookTitle ?? '').trim().isNotEmpty) 'bookTitle': bookTitle!.trim(),
      if (pageNumber != null) 'pageNumber': '$pageNumber',
      if ((questionNumber ?? '').trim().isNotEmpty)
        'questionNumber': questionNumber!.trim(),
    };

    final raw = await _api.getJson('/solutions', query: q);
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> uploadFilesMultipart(
    List<String> paths,
  ) async {
    final out = <Map<String, dynamic>>[];

    for (final path in paths) {
      final req = http.MultipartRequest('POST', _uri('/uploads/solution-file'));
      req.headers.addAll(_headers());
      req.files.add(await http.MultipartFile.fromPath('file', path));

      final streamed = await req.send();
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        throw Exception('upload failed (${streamed.statusCode}): $body');
      }

      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['file'] is Map) {
        out.add(Map<String, dynamic>.from(decoded['file'] as Map));
      }
    }

    return out;
  }

  Future<Map<String, dynamic>> createSolution({
    required String subject,
    required String bookTitle,
    required int pageNumber,
    required String questionNumber,
    String? caption,
    String? uploaderName,
    String? uploaderInitials,
    required List<Map<String, dynamic>> files,
  }) async {
    final raw = await _api.postJson(
      '/solutions',
      body: <String, dynamic>{
        'subject': subject,
        'bookTitle': bookTitle,
        'pageNumber': pageNumber,
        'questionNumber': questionNumber,
        if ((caption ?? '').trim().isNotEmpty) 'caption': caption!.trim(),
        if ((uploaderName ?? '').trim().isNotEmpty)
          'uploaderName': uploaderName!.trim(),
        if ((uploaderInitials ?? '').trim().isNotEmpty)
          'uploaderInitials': uploaderInitials!.trim(),
        'files': files,
      },
    );
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }
}
