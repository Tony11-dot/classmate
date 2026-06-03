import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/http/cm_api.dart';
import 'parent_models.dart';

/// Wraps the `/parent/*` endpoints. All methods take the studentId of
/// the currently-selected child (except `children()` which returns the
/// list of children to choose from).
class ParentRepository {
  ParentRepository(this._token);
  final String? _token;

  Future<List<ParentChild>> children() async {
    final api = CMApi(token: _token);
    try {
      final raw = await api.getJson('/parent/children');
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((m) => ParentChild.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } finally {
      api.dispose();
    }
  }

  Future<List<ParentGrade>> grades(String studentId, {int take = 30}) async {
    final api = CMApi(token: _token);
    try {
      final raw = await api.getJson('/parent/grades', query: {
        'studentId': studentId,
        'take': '$take',
      });
      final list = raw is List
          ? raw
          : raw is Map && raw['items'] is List
              ? raw['items'] as List
              : const [];
      return list
          .whereType<Map>()
          .map((m) => ParentGrade.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } finally {
      api.dispose();
    }
  }

  Future<List<ParentScheduleSlot>> scheduleWeek(String studentId, {String? weekOf}) async {
    final api = CMApi(token: _token);
    try {
      final raw = await api.getJson('/parent/schedule/week', query: {
        'studentId': studentId,
        if (weekOf != null && weekOf.isNotEmpty) 'weekOf': weekOf,
      });
      final list = raw is List
          ? raw
          : raw is Map && raw['slots'] is List
              ? raw['slots'] as List
              : const [];
      return list
          .whereType<Map>()
          .map((m) => ParentScheduleSlot.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } finally {
      api.dispose();
    }
  }

  Future<List<ParentAttendance>> attendanceWeek(String studentId, {String? weekOf}) async {
    final api = CMApi(token: _token);
    try {
      final raw = await api.getJson('/parent/attendance/week', query: {
        'studentId': studentId,
        if (weekOf != null && weekOf.isNotEmpty) 'weekOf': weekOf,
      });
      final list = raw is List
          ? raw
          : raw is Map && raw['items'] is List
              ? raw['items'] as List
              : const [];
      return list
          .whereType<Map>()
          .map((m) => ParentAttendance.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } finally {
      api.dispose();
    }
  }

  /// Generic GET wrapper for the child-scoped feeds (exams, assignments,
  /// diplomas, meetings, materials, insights). Returns the raw JSON so
  /// callers can hand it straight to whatever parser the equivalent
  /// student screen already uses.
  Future<dynamic> getChildFeed(String path, String studentId, {Map<String, String>? extraQuery}) async {
    final api = CMApi(token: _token);
    try {
      return await api.getJson(path, query: {
        'studentId': studentId,
        ...?extraQuery,
      });
    } finally {
      api.dispose();
    }
  }

  Future<Map<String, dynamic>> dashboard() async {
    final api = CMApi(token: _token);
    try {
      final raw = await api.getJson('/parent/dashboard');
      return raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    } finally {
      api.dispose();
    }
  }

  Future<List<ParentNotification>> notifications({int take = 30}) async {
    final api = CMApi(token: _token);
    try {
      final raw = await api.getJson('/parent/notifications', query: {
        'take': '$take',
      });
      // Server returns { ok, notifications: [...] } — accept that key first
      // (the old 'items'-only read always fell through to [] → empty inbox).
      final list = raw is List
          ? raw
          : raw is Map && raw['notifications'] is List
              ? raw['notifications'] as List
              : raw is Map && raw['items'] is List
                  ? raw['items'] as List
                  : const [];
      return list
          .whereType<Map>()
          .map((m) => ParentNotification.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } finally {
      api.dispose();
    }
  }
}

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  final session = ref.watch(authSessionProvider);
  return ParentRepository(session.token);
});

final parentChildrenProvider = FutureProvider<List<ParentChild>>((ref) async {
  return ref.read(parentRepositoryProvider).children();
});

/// The id of the child currently being viewed across all parent screens.
/// Persisted in SharedPreferences so the parent doesn't re-pick every
/// time they switch tabs.
class SelectedChildController extends Notifier<String?> {
  static const _kPrefKey = 'parent_selected_student_id_v1';

  @override
  String? build() {
    // Fire-and-forget restore from prefs — state starts null and
    // upgrades to the stored value once SharedPreferences resolves.
    Future<void>.microtask(_restore);
    return null;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString(_kPrefKey);
      if (v != null && v.isNotEmpty) state = v;
    } catch (e) {
      debugPrint('[parent] restore selected child failed: $e');
    }
  }

  Future<void> select(String studentId) async {
    state = studentId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefKey, studentId);
    } catch (_) {}
  }
}

final selectedChildProvider =
    NotifierProvider<SelectedChildController, String?>(SelectedChildController.new);

final parentGradesProvider =
    FutureProvider.family<List<ParentGrade>, String>((ref, studentId) async {
  return ref.read(parentRepositoryProvider).grades(studentId);
});

final parentScheduleWeekProvider =
    FutureProvider.family<List<ParentScheduleSlot>, String>((ref, studentId) async {
  return ref.read(parentRepositoryProvider).scheduleWeek(studentId);
});

final parentAttendanceWeekProvider =
    FutureProvider.family<List<ParentAttendance>, String>((ref, studentId) async {
  return ref.read(parentRepositoryProvider).attendanceWeek(studentId);
});

final parentNotificationsProvider =
    FutureProvider<List<ParentNotification>>((ref) async {
  return ref.read(parentRepositoryProvider).notifications();
});
