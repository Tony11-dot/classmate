import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/config/env.dart';
import '../../core/http/cm_api.dart';
import 'solution_model.dart';
import 'solutions_filters.dart';

const _devStudentToken = 'dev-token-student@classmate.local';
const _devAdminToken = 'dev-token-admin@classmate.local';

final solutionsRepoProvider = Provider<SolutionsRepo>((ref) {
  final session = ref.watch(authSessionProvider);
  final token = (session.token ?? '').trim();
  return SolutionsRepo(token: token.isEmpty ? _devStudentToken : token);
});

class SolutionsRepo {
  SolutionsRepo({required this.token});

  final String? token;

  CMApi _api() => CMApi(token: token);

  Future<SolutionsPage> list({
    required SolutionsFilters filters,
    required int limit,
    required String? cursor,
  }) async {
    final q = <String, String>{'limit': '$limit', ...filters.toQuery()};

    final trimmedCursor = cursor?.trim();
    if (trimmedCursor != null && trimmedCursor.isNotEmpty) {
      q['cursor'] = trimmedCursor;
    }

    final j = await _api().getJson('/solutions', query: q);
    return SolutionsPage.fromJson(Map<String, dynamic>.from(j as Map));
  }

  Future<Solution> create({
    required String subject,
    required String sourceType,
    String? sourceName,
    int? page,
    String? questionNumber,
    String? title,
    String? notes,
    String? body,
    bool forceStaffDevToken = false,
  }) async {
    final api = forceStaffDevToken ? CMApi(token: _devAdminToken) : _api();

    final sourceNameTrimmed = sourceName?.trim();
    final questionNumberTrimmed = questionNumber?.trim();
    final titleTrimmed = title?.trim();
    final notesTrimmed = notes?.trim();
    final bodyTrimmed = body?.trim();

    final payload = <String, dynamic>{
      'subject': subject,
      'sourceType': sourceType,
    };

    if (sourceNameTrimmed != null && sourceNameTrimmed.isNotEmpty) {
      payload['sourceName'] = sourceNameTrimmed;
    }
    if (page != null) {
      payload['page'] = page;
    }
    if (questionNumberTrimmed != null && questionNumberTrimmed.isNotEmpty) {
      payload['questionNumber'] = questionNumberTrimmed;
    }
    if (titleTrimmed != null && titleTrimmed.isNotEmpty) {
      payload['title'] = titleTrimmed;
    }
    if (notesTrimmed != null && notesTrimmed.isNotEmpty) {
      payload['notes'] = notesTrimmed;
    }
    if (bodyTrimmed != null && bodyTrimmed.isNotEmpty) {
      payload['body'] = bodyTrimmed;
    }

    final j = await api.postJson('/solutions', body: payload);
    return Solution.fromJson(Map<String, dynamic>.from(j as Map));
  }

  Future<Map<String, dynamic>> uploadImageFile(
    File file, {
    bool forceStaffDevToken = false,
  }) async {
    final authToken = forceStaffDevToken
        ? _devAdminToken
        : (token ?? _devStudentToken);

    final base = Uri.parse(Env.apiBaseUrl);
    final normalizedBasePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final uploadPath = '$normalizedBasePath/uploads/image';

    final uri = Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: uploadPath,
    );

    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final mediaType = MediaType.parse(mimeType);

    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $authToken'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: mediaType,
        ),
      );

    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception('upload failed (${streamed.statusCode}): $body');
    }

    return Map<String, dynamic>.from(jsonDecode(body) as Map);
  }

  Future<Map<String, dynamic>> attachImage(
    String solutionId, {
    required Map<String, dynamic> upload,
    bool forceStaffDevToken = false,
  }) async {
    final api = forceStaffDevToken ? CMApi(token: _devAdminToken) : _api();

    final payload = <String, dynamic>{
      'url': upload['url'],
      'storagePath': upload['storagePath'],
      'kind': upload['kind'] ?? 'image',
      'mime': upload['mime'],
      'sizeBytes': upload['sizeBytes'],
      if (upload['width'] != null) 'width': upload['width'],
      if (upload['height'] != null) 'height': upload['height'],
      if (upload['originalName'] != null)
        'originalName': upload['originalName'],
    };

    final j = await api.postJson(
      '/solutions/$solutionId/images',
      body: payload,
    );
    return Map<String, dynamic>.from(j as Map);
  }

  Future<Map<String, dynamic>> like(String solutionId) async {
    final j = await _api().postJson('/solutions/$solutionId/like');
    return Map<String, dynamic>.from(j as Map);
  }

  Future<Map<String, dynamic>> unlike(String solutionId) async {
    final j = await _api().deleteJson('/solutions/$solutionId/like');
    return Map<String, dynamic>.from(j as Map);
  }

  Future<SolutionCommentsPage> getComments(
    String solutionId, {
    int limit = 20,
    String? cursor,
  }) async {
    final q = <String, String>{'limit': '$limit'};

    final trimmedCursor = cursor?.trim();
    if (trimmedCursor != null && trimmedCursor.isNotEmpty) {
      q['cursor'] = trimmedCursor;
    }

    final j = await _api().getJson('/solutions/$solutionId/comments', query: q);
    return SolutionCommentsPage.fromJson(Map<String, dynamic>.from(j as Map));
  }

  Future<SolutionComment> addComment(String solutionId, String body) async {
    final j = await _api().postJson(
      '/solutions/$solutionId/comments',
      body: <String, dynamic>{'body': body},
    );
    final m = Map<String, dynamic>.from(j as Map);
    final c = Map<String, dynamic>.from((m['comment'] as Map?) ?? const {});
    return SolutionComment.fromJson(c);
  }

  Future<Map<String, dynamic>> repostSolution(String solutionId) async {
    final j = await _api().postJson('/solutions/$solutionId/repost');
    return Map<String, dynamic>.from(j as Map);
  }
}
