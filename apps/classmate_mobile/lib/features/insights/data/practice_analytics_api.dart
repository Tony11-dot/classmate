import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/http/cm_api.dart';
import '../domain/insights_models.dart';

const _devStudentToken = 'dev-token-student@classmate.local';

final practiceAnalyticsApiProvider = Provider<PracticeAnalyticsApi>((ref) {
  final session = ref.watch(authSessionProvider);
  final token = (session.token ?? '').trim();
  return PracticeAnalyticsApi(token: token.isEmpty ? _devStudentToken : token);
});

class PracticeAnalyticsApi {
  const PracticeAnalyticsApi({this.token = _devStudentToken});

  final String token;

  CMApi get _api => CMApi(token: token);

  Future<InsightsServerSummary?> fetchProgressSummary() async {
    try {
      final raw = await _api.getJson('/practice/progress-summary');
      if (raw is! Map) return null;

      final decoded = Map<String, dynamic>.from(raw);
      return InsightsServerSummary.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
