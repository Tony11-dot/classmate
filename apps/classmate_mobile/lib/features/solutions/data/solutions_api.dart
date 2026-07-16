import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/config/env.dart';
import '../../../core/http/cm_api.dart';

final solutionsApiProvider = Provider<SolutionsApi>((ref) {
  // Capture the session object — not the token string — so every API call
  // reads the token lazily (correct even if the provider was built before
  // AuthSession._init() completed).
  final session = ref.watch(authSessionProvider);
  return SolutionsApi(
    baseUrl: Env.apiBaseUrl,
    tokenGetter: () {
      final t = (session.token ?? '').trim();
      return t;
    },
  );
});

class SolutionsApi {
  const SolutionsApi({required this.baseUrl, required String Function() tokenGetter})
      : _getToken = tokenGetter;

  final String baseUrl;
  final String Function() _getToken;

  String get token => _getToken();

  CMApi get _api => CMApi(token: token);

  String _normalizedBaseUrl() {
    return baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  Uri _uri(String path) => Uri.parse('${_normalizedBaseUrl()}$path');

  Map<String, String> _headers() {
    final trimmed = token.trim();
    final looksJwt = trimmed.split('.').length >= 3;
    final looksEmailish = trimmed.contains('@') && trimmed.contains('.');
    // dev-token-* are accepted by the backend when ALLOW_DEV_TOKEN=1.
    final isDevToken = trimmed.startsWith('dev-token-');
    final hasToken = trimmed.isNotEmpty && ((looksJwt && !looksEmailish) || isDevToken);

    return <String, String>{
      if (hasToken) 'Authorization': 'Bearer $trimmed',
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

      // Explicitly detect MIME type so the backend file-filter accepts the file.
      final detectedMime =
          lookupMimeType(path) ?? 'application/octet-stream';
      final mediaType = MediaType.parse(detectedMime);

      req.files.add(
        await http.MultipartFile.fromPath(
          'file',
          path,
          contentType: mediaType,
        ),
      );

      final streamed = await req.send();
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        // Sanitized toString — never leak the raw response body to the UI.
        throw CMApiException(statusCode: streamed.statusCode, uri: _uri('/uploads/solution-file'), body: body);
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

  // ── Book management (teachers + admins) ─────────────────────────────────

  Future<Map<String, dynamic>> createBook({
    required String subject,
    required String title,
    required int pages,
    String? coverUrl,
    bool confirmDuplicate = false,
  }) async {
    final raw = await _api.postJson(
      '/solutions/books',
      body: <String, dynamic>{
        'subject': subject,
        'title': title,
        'pages': pages,
        if ((coverUrl ?? '').trim().isNotEmpty) 'coverUrl': coverUrl!.trim(),
        if (confirmDuplicate) 'confirmDuplicate': true,
      },
    );
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateBook({
    required String id,
    String? title,
    int? pages,
    String? coverUrl,
  }) async {
    final raw = await _api.patchJson(
      '/solutions/books/$id',
      body: <String, dynamic>{
        if ((title ?? '').trim().isNotEmpty) 'title': title!.trim(),
        'pages': ?pages,
        if ((coverUrl ?? '').trim().isNotEmpty) 'coverUrl': coverUrl!.trim(),
      },
    );
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> deleteBook(String id) async {
    final raw = await _api.deleteJson('/solutions/books/$id');
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  // ── Reporting ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> reportSolution({
    required String uploadId,
    String? reason,
  }) async {
    final raw = await _api.postJson(
      '/solutions/$uploadId/report',
      body: <String, dynamic>{
        if ((reason ?? '').trim().isNotEmpty) 'reason': reason!.trim(),
      },
    );
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> fetchReports() async {
    final raw = await _api.getJson('/solutions/reports');
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> resolveReport({
    required String id,
    required String action, // 'approve' | 'remove'
  }) async {
    final raw = await _api.patchJson(
      '/solutions/reports/$id',
      body: <String, dynamic>{'action': action},
    );
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }
}
