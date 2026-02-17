import '../../api/api_client.dart';
import 'solution_models.dart';

class SolutionsApi {
  final ApiClient client;
  const SolutionsApi(this.client);

  Future<List<SolutionItem>> feed({
    String? q,
    int? grade,
    String? subjectId,
  }) async {
    final qp = <String, dynamic>{};
    if (q != null && q.trim().isNotEmpty) {
      qp['q'] = q.trim();
    }
    if (grade != null) {
      qp['grade'] = grade;
    }
    if (subjectId != null && subjectId.trim().isNotEmpty) {
      qp['subjectId'] = subjectId;
    }
    final res = await client.get(
      '/solutions',
      queryParameters: qp.isEmpty ? null : qp,
    );
    final data = res.data;

    if (data is! List) {
      return const [];
    }
    return data.map((e) => SolutionItem.fromJson(e)).toList();
  }
}
