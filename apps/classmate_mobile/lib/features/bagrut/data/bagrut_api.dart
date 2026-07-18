import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/config/env.dart';
import '../../../core/http/cm_api.dart';
import '../domain/bagrut_models.dart';

final bagrutApiProvider = Provider<BagrutApi>((ref) {
  final session = ref.watch(authSessionProvider);
  return BagrutApi(
    baseUrl: Env.apiBaseUrl,
    tokenGetter: () => (session.token ?? '').trim(),
  );
});

class BagrutApi {
  const BagrutApi({required this.baseUrl, required String Function() tokenGetter})
      : _getToken = tokenGetter;

  final String baseUrl;
  final String Function() _getToken;

  String get token => _getToken();
  CMApi get _api => CMApi(token: token);

  String _normalizedBaseUrl() =>
      baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

  Uri _uri(String path) => Uri.parse('${_normalizedBaseUrl()}$path');

  /// Turns a relative `/uploads/...` URL into an absolute one.
  String resolveUrl(String url) {
    final u = url.trim();
    if (u.isEmpty) return u;
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    return '${_normalizedBaseUrl()}${u.startsWith('/') ? '' : '/'}$u';
  }

  /// Inverse of [resolveUrl] — strips our API origin so files are persisted as
  /// relative `/uploads/...` paths (portable if the API host ever changes).
  String relativizeUrl(String url) {
    final base = _normalizedBaseUrl();
    return url.startsWith(base) ? url.substring(base.length) : url;
  }

  Map<String, String> _headers() {
    final trimmed = token.trim();
    final looksJwt = trimmed.split('.').length >= 3;
    final looksEmailish = trimmed.contains('@') && trimmed.contains('.');
    final isDevToken = trimmed.startsWith('dev-token-');
    final hasToken = trimmed.isNotEmpty && ((looksJwt && !looksEmailish) || isDevToken);
    return <String, String>{ if (hasToken) 'Authorization': 'Bearer $trimmed' };
  }

  // ── Browse ────────────────────────────────────────────────────────────────
  Future<List<BagrutExam>> fetchExams(String subject) async {
    final raw = await _api.getJson('/bagrut/exams', query: {'subject': subject});
    final list = raw is List ? raw : (raw is Map && raw['exams'] is List ? raw['exams'] as List : const []);
    return list
        .whereType<Map>()
        .map((e) => BagrutExam.fromJson(Map<String, dynamic>.from(e), resolveUrl))
        .toList();
  }

  Future<BagrutExam?> fetchExam(String id) async {
    final raw = await _api.getJson('/bagrut/exams/$id');
    if (raw is Map) return BagrutExam.fromJson(Map<String, dynamic>.from(raw), resolveUrl);
    return null;
  }

  // ── Manage (manager) ────────────────────────────────────────────────────────

  /// Uploads one file (bytes → cross-platform incl. web) and returns its
  /// `{url, fileName, mimeType, fileSize, kind}`.
  Future<Map<String, dynamic>> uploadFileBytes(List<int> bytes, String filename) async {
    final req = http.MultipartRequest('POST', _uri('/uploads/bagrut-file'));
    req.headers.addAll(_headers());
    final detectedMime = lookupMimeType(filename) ?? 'application/octet-stream';
    req.files.add(http.MultipartFile.fromBytes('file', bytes,
        filename: filename, contentType: MediaType.parse(detectedMime)));
    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      // Sanitized toString — never leak the raw response body to the UI.
      throw CMApiException(statusCode: streamed.statusCode, uri: _uri('/uploads/bagrut-file'), body: body);
    }
    final decoded = jsonDecode(body);
    if (decoded is Map && decoded['file'] is Map) {
      return Map<String, dynamic>.from(decoded['file'] as Map);
    }
    throw Exception('upload returned no file');
  }

  Future<Map<String, dynamic>> createExam({
    required String subject,
    required int year,
    required String term,
    required String title,
    required List<Map<String, dynamic>> files,
  }) async {
    final raw = await _api.postJson('/bagrut/exams', body: {
      'subject': subject,
      'year': year,
      'term': term,
      'title': title,
      'files': files,
    });
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateExam({
    required String id,
    String? subject,
    int? year,
    String? term,
    String? title,
    List<Map<String, dynamic>>? files,
  }) async {
    final raw = await _api.patchJson('/bagrut/exams/$id', body: {
      if (subject != null) 'subject': subject,
      if (year != null) 'year': year,
      if (term != null) 'term': term,
      if (title != null) 'title': title,
      if (files != null) 'files': files,
    });
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<void> deleteExam(String id) async {
    await _api.deleteJson('/bagrut/exams/$id');
  }
}
