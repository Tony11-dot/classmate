import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/http/cm_api.dart';

const _devStudentToken = 'dev-token-student@classmate.local';

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) {
  final session = ref.watch(authSessionProvider);
  final token = (session.token ?? '').trim();
  return InsightsRepository(token: token.isEmpty ? _devStudentToken : token);
});

class InsightsRepository {
  InsightsRepository({required this.token});

  final String token;

  CMApi get _api => CMApi(token: token);

  Future<Map<String, dynamic>> getGrades() async {
    final raw = await _api.getJson('/student/grades');
    if (raw is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{'ok': true, 'grades': <dynamic>[]};
  }

  Future<Map<String, dynamic>> getAttendance({
    String? from,
    String? to,
  }) async {
    final query = <String, String>{};
    if ((from ?? '').trim().isNotEmpty) {
      query['from'] = from!.trim();
    }
    if ((to ?? '').trim().isNotEmpty) {
      query['to'] = to!.trim();
    }

    final raw = await _api.getJson('/student/attendance', query: query);
    if (raw is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{'ok': true, 'items': <dynamic>[]};
  }

  Future<Map<String, dynamic>> getInsightsSnapshot() async {
    final now = DateTime.now();
    final to = _ymd(now);
    final from = _ymd(now.subtract(const Duration(days: 29)));

    final results = await Future.wait<dynamic>([
      getGrades(),
      getAttendance(from: from, to: to),
    ]);

    return <String, dynamic>{
      'ok': true,
      'from': from,
      'to': to,
      'grades': Map<String, dynamic>.from(results[0] as Map),
      'attendance': Map<String, dynamic>.from(results[1] as Map),
    };
  }

  String _ymd(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
