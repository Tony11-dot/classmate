import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';
import 'grades_api.dart';
import 'grades_models.dart';

final gradeSubjectsSummaryProvider = FutureProvider<List<GradeSubjectSummary>>((
  ref,
) async {
  final api = GradesApi(ApiClient.instance);
  return api.subjectSummary();
});

final gradesBySubjectProvider = FutureProvider.family<List<GradeRow>, String>((
  ref,
  subjectId,
) async {
  final api = GradesApi(ApiClient.instance);
  return api.list(subjectId: subjectId);
});
