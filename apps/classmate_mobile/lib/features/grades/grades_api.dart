import '../../api/api_client.dart';
import 'grades_models.dart';

class GradesApi {
  final ApiClient _c;
  const GradesApi(this._c);

  /// ONE call for "subjects list" data for student sorting.
  Future<List<GradeSubjectSummary>> subjectSummary() async {
    final res = await _c.get('/grades/subjects/summary');
    final rows = (res.data as List).cast<dynamic>();
    return rows
        .map((e) => GradeSubjectSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Subject grades list (newest first server-side)
  Future<List<GradeRow>> list({required String subjectId}) async {
    final res = await _c.get(
      '/grades',
      queryParameters: {'subjectId': subjectId},
    );
    final rows = (res.data as List).cast<dynamic>();
    return rows
        .map((e) => GradeRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
