import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/http/cm_api.dart';

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) {
  final session = ref.watch(authSessionProvider);
  final token = (session.token ?? '').trim();
  return InsightsRepository(token: token);
});

class InsightsRepository {
  InsightsRepository({required this.token});

  final String token;

  CMApi get _api => CMApi(token: token);

  Future<Map<String, dynamic>> _safeMap(String path, String listKey) async {
    try {
      final raw = await _api.getJson(path);
      if (raw is Map<String, dynamic>) return raw;
      if (raw is List) return <String, dynamic>{listKey: raw};
      return <String, dynamic>{listKey: <dynamic>[]};
    } catch (_) {
      return <String, dynamic>{listKey: <dynamic>[]};
    }
  }

  Future<Map<String, dynamic>> getInsightsSnapshot() async {
    final grades = await _safeMap('/student/grades', 'grades');
    final attendance = await _safeMap('/student/attendance', 'items');

    return <String, dynamic>{'grades': grades, 'attendance': attendance};
  }
}
