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

  Future<SolutionsPage> list({
    required SolutionsFilters filters,
    required int limit,
    required String? cursor,
  }) async {
    final api = CMApi(token: token);
    final q = <String, String>{
      'limit': limit.toString(),
      ...filters.toQuery(),
    };
    if (cursor != null && cursor.trim().isNotEmpty) q['cursor'] = cursor.trim();

    final j = await api.getJson('/api/solutions', query: q);
    return SolutionsPage.fromJson(j);
  }
}
