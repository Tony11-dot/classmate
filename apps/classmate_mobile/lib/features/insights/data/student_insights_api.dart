import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/http/cm_api.dart';
import '../domain/insights_models.dart';

final studentInsightsApiProvider = Provider<StudentInsightsApi>((ref) {
  final session = ref.watch(authSessionProvider);
  final token = (session.token ?? '').trim();
  return StudentInsightsApi(token: token);
});

class StudentInsightsApi {
  const StudentInsightsApi({this.token = ''});

  final String token;

  CMApi get _api => CMApi(token: token);

  Future<UnifiedStudentInsights?> fetchUnifiedInsights() async {
    try {
      final raw = await _api.getJson('/student/insights');
      if (raw is! Map) return null;
      return UnifiedStudentInsights.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }
}
