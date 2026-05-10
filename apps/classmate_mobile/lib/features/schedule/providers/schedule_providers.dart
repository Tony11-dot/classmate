import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/cm_api.dart';
import '../data/schedule_repository.dart';

// autoDispose so each week key is independent; keepAlive is NOT used so
// ref.invalidate() always works and stale results never get stuck.
final weekScheduleProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, weekOf) async {
      final repo = ref.watch(scheduleRepositoryProvider);
      try {
        return await repo.getWeek(DateTime.parse(weekOf));
      } on CMApiException catch (e) {
        if (e.statusCode == 401) return <String, dynamic>{'items': []};
        throw Exception(e.friendlyMessage);
      }
    });

/// Fetches today's attendance records keyed by "${period}:${subject}".
/// Falls back to an empty map so the schedule renders normally if this fails.
final todayAttendanceProvider =
    FutureProvider.autoDispose<Map<String, String>>((ref) async {
      final repo = ref.watch(scheduleRepositoryProvider);
      return repo.getTodayAttendance();
    });
