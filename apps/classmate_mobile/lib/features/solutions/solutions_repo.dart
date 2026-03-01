import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/http/cm_api.dart';
import 'solution_model.dart';
import 'solutions_filters.dart';

final solutionsRepoProvider = Provider<SolutionsRepo>((ref) {
  final session = ref.watch(authSessionProvider);
  return SolutionsRepo(token: session.token);
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
    if (cursor != null && cursor.trim().isNotEmpty) q['cursor'] = cursor.trim();
    final j = await _api().getJson('/api/solutions', query: q);
    return SolutionsPage.fromJson(Map<String, dynamic>.from(j as Map));
  }

  Future<Map<String, dynamic>> like(String solutionId) async {
    final j = await _api().postJson('/api/solutions/$solutionId/like');
    return Map<String, dynamic>.from(j as Map);
  }

  Future<Map<String, dynamic>> unlike(String solutionId) async {
    final j = await _api().deleteJson('/api/solutions/$solutionId/like');
    return Map<String, dynamic>.from(j as Map);
  }

  Future<SolutionCommentsPage> getComments(
    String solutionId, {
    int limit = 20,
    String? cursor,
  }) async {
    final q = <String, String>{
      'limit': '$limit',
      if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor.trim(),
    };
    final j = await _api().getJson(
      '/api/solutions/$solutionId/comments',
      query: q,
    );
    return SolutionCommentsPage.fromJson(Map<String, dynamic>.from(j as Map));
  }

  Future<SolutionComment> addComment(String solutionId, String body) async {
    final j = await _api().postJson(
      '/api/solutions/$solutionId/comments',
      body: <String, dynamic>{'body': body},
    );
    final m = Map<String, dynamic>.from(j as Map);
    final c = Map<String, dynamic>.from((m['comment'] as Map?) ?? const {});
    return SolutionComment.fromJson(c);
  }
}
