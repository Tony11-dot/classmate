import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../parent/data/viewed_student_context.dart';
import '../data/student_insights_api.dart';
import '../domain/insights_models.dart';

final unifiedStudentInsightsProvider = FutureProvider<UnifiedStudentInsights?>((
  ref,
) async {
  final api = ref.watch(studentInsightsApiProvider);
  final viewedStudentId = ref.watch(viewedStudentIdProvider);
  return api.fetchUnifiedInsights(overrideStudentId: viewedStudentId);
});
