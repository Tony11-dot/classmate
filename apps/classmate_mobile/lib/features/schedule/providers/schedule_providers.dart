import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/http/cm_api.dart';
import '../data/schedule_repository.dart';

// autoDispose so each week key is independent; keepAlive is NOT used so
// ref.invalidate() always works and stale results never get stuck.
final weekScheduleProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, weekOf) async {
      // Watch the session token directly. On app launch the auth session
      // hydrates async — if the schedule screen mounts before that
      // hydration completes, the repo provider returns an instance with
      // an empty token, the fetch silently 401s, the catch-block hands
      // back {items:[]}, and Riverpod doesn't reliably re-execute this
      // future once the session populates. Watching the token via
      // .select forces a re-run the moment it changes from empty to
      // populated — without it, the user sees an empty schedule until
      // they manually logout+login.
      final token = ref.watch(
        authSessionProvider.select((s) => (s.token ?? '').trim()),
      );
      if (token.isEmpty) {
        return <String, dynamic>{'items': []};
      }
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
