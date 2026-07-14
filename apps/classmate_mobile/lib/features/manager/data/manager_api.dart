import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/config/env.dart';
import '../../../core/http/cm_api.dart';

final managerApiProvider = Provider<ManagerApi>((ref) {
  final session = ref.watch(authSessionProvider);
  return ManagerApi(
    baseUrl: Env.apiBaseUrl,
    tokenGetter: () => (session.token ?? '').trim(),
  );
});

class ManagerApi {
  const ManagerApi({required this.baseUrl, required String Function() tokenGetter})
      : _getToken = tokenGetter;

  final String baseUrl;
  final String Function() _getToken;

  String get token => _getToken();
  CMApi get _api => CMApi(token: token);

  String _normalizedBaseUrl() =>
      baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

  Uri _uri(String path) => Uri.parse('${_normalizedBaseUrl()}$path');

  String resolveUrl(String url) {
    final u = url.trim();
    if (u.isEmpty) return u;
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    return '${_normalizedBaseUrl()}${u.startsWith('/') ? '' : '/'}$u';
  }

  Map<String, String> _headers() {
    final trimmed = token.trim();
    final looksJwt = trimmed.split('.').length >= 3;
    final looksEmailish = trimmed.contains('@') && trimmed.contains('.');
    final isDevToken = trimmed.startsWith('dev-token-');
    final hasToken = trimmed.isNotEmpty && ((looksJwt && !looksEmailish) || isDevToken);
    return <String, String>{ if (hasToken) 'Authorization': 'Bearer $trimmed' };
  }

  // ── Schools ────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listSchools() async {
    final raw = await _api.getJson('/manager/schools');
    final list = raw is Map && raw['schools'] is List ? raw['schools'] as List : const [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> getSchool(String id) async {
    final raw = await _api.getJson('/manager/schools/$id');
    if (raw is Map && raw['school'] is Map) return Map<String, dynamic>.from(raw['school'] as Map);
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> createSchool(Map<String, dynamic> body) async {
    final raw = await _api.postJson('/manager/schools', body: body);
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateSchool(String id, Map<String, dynamic> body) async {
    final raw = await _api.patchJson('/manager/schools/$id', body: body);
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<void> deleteSchool(String id) async {
    await _api.deleteJson('/manager/schools/$id');
  }

  /// Uploads a school logo image (bytes → cross-platform incl. web), returns
  /// its `/uploads/...` url.
  Future<String> uploadLogoBytes(List<int> bytes, String filename) async {
    final req = http.MultipartRequest('POST', _uri('/uploads/manager-logo'));
    req.headers.addAll(_headers());
    final detectedMime = lookupMimeType(filename) ?? 'image/png';
    req.files.add(http.MultipartFile.fromBytes('file', bytes,
        filename: filename, contentType: MediaType.parse(detectedMime)));
    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception('logo upload failed (${streamed.statusCode}): $body');
    }
    final decoded = jsonDecode(body);
    if (decoded is Map && decoded['url'] is String) return decoded['url'] as String;
    throw Exception('logo upload returned no url');
  }

  // ── Managers ───────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listManagers() async {
    final raw = await _api.getJson('/manager/managers');
    final list = raw is Map && raw['managers'] is List ? raw['managers'] as List : const [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> addManager({
    String? name,
    String? email,
    String? username,
    String? password,
  }) async {
    final raw = await _api.postJson('/manager/managers', body: {
      if ((name ?? '').trim().isNotEmpty) 'name': name!.trim(),
      if ((email ?? '').trim().isNotEmpty) 'email': email!.trim(),
      if ((username ?? '').trim().isNotEmpty) 'username': username!.trim(),
      if ((password ?? '').trim().isNotEmpty) 'password': password!.trim(),
    });
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<void> revokeManager(String userId) async {
    await _api.deleteJson('/manager/managers/$userId');
  }
}
