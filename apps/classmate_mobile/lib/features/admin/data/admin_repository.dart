import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/http/cm_api.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final token = ref.watch(authSessionProvider).token ?? '';
  return AdminRepository(token: token);
});

class AdminRepository {
  AdminRepository({required this.token});

  final String token;

  CMApi get _api => CMApi(token: token);

  // ── Analytics ────────────────────────────────────────────────────────────────

  Future<AdminOverview> fetchOverview() async {
    final raw = await _api.getJson('/admin/analytics/overview');
    final m = _m(raw);
    return AdminOverview(
      students: _i(m['students']),
      teachers: _i(m['teachers']),
      cohorts: _i(m['cohorts']),
      classrooms: _i(m['classrooms']),
      todaySessions: _i(m['todaySessions']),
    );
  }

  Future<List<CohortAttendance>> fetchAttendanceAnalytics() async {
    final raw = await _api.getJson('/admin/analytics/attendance');
    final list = _l(_m(raw)['cohorts']);
    return list.map((e) => CohortAttendance.fromJson(_m(e))).toList();
  }

  Future<List<CohortGrades>> fetchGradesAnalytics() async {
    final raw = await _api.getJson('/admin/analytics/grades');
    final list = _l(_m(raw)['cohorts']);
    return list.map((e) => CohortGrades.fromJson(_m(e))).toList();
  }

  // ── Users ────────────────────────────────────────────────────────────────────

  Future<AdminUserList> listUsers({String? q, String? role, int page = 0}) async {
    final query = <String, String>{
      if (q != null && q.isNotEmpty) 'q': q,
      if (role != null && role.isNotEmpty) 'role': role,
      if (page > 0) 'page': '$page',
    };
    final raw = await _api.getJson('/admin/users', query: query.isEmpty ? null : query);
    final m = _m(raw);
    return AdminUserList(
      users: _l(m['users']).map((e) => AdminUser.fromJson(_m(e))).toList(),
      total: _i(m['total']),
    );
  }

  Future<AdminUserDetail> getUserDetail(String id) async {
    final raw = await _api.getJson('/admin/users/$id');
    return AdminUserDetail.fromJson(_m(_m(raw)['user']));
  }

  Future<AdminCreateResult> createUser({
    required String name,
    required String email,
    required String role,
  }) async {
    final raw = await _api.postJson('/admin/users', body: {
      'name': name,
      'email': email,
      'role': role,
    });
    final m = _m(raw);
    return AdminCreateResult(
      user: AdminUser.fromJson(_m(m['user'])),
      tempPassword: m['tempPassword']?.toString() ?? '',
    );
  }

  Future<void> updateUser(String id, {String? name, String? email, String? role}) async {
    await _api.patchJson('/admin/users/$id', body: {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
    });
  }

  Future<void> deleteUser(String id) async {
    await _api.deleteJson('/admin/users/$id');
  }

  Future<String> resetUserPassword(String id) async {
    final raw = await _api.postJson('/admin/users/$id/reset-password');
    return _m(raw)['tempPassword']?.toString() ?? '';
  }

  // ── Cohorts ──────────────────────────────────────────────────────────────────

  Future<List<AdminCohort>> listCohorts() async {
    final raw = await _api.getJson('/admin/cohorts');
    return _l(_m(raw)['cohorts']).map((e) => AdminCohort.fromJson(_m(e))).toList();
  }

  Future<void> createCohort({required String name, required int grade}) async {
    await _api.postJson('/admin/cohorts', body: {'name': name, 'grade': grade});
  }

  Future<void> updateCohort(String id, {String? name, int? grade}) async {
    await _api.patchJson('/admin/cohorts/$id', body: {
      if (name != null) 'name': name,
      if (grade != null) 'grade': grade,
    });
  }

  Future<void> deleteCohort(String id) async {
    await _api.deleteJson('/admin/cohorts/$id');
  }

  Future<List<AdminUser>> getCohortRoster(String cohortId) async {
    final raw = await _api.getJson('/admin/cohorts/$cohortId/roster');
    return _l(_m(raw)['students']).map((e) => AdminUser.fromJson(_m(e))).toList();
  }

  Future<void> addStudentsToCohort(String cohortId, List<String> studentIds) async {
    await _api.postJson('/admin/cohorts/$cohortId/students', body: {'studentIds': studentIds});
  }

  Future<void> removeStudentFromCohort(String cohortId, String studentId) async {
    await _api.deleteJson('/admin/cohorts/$cohortId/students/$studentId');
  }

  // ── School ───────────────────────────────────────────────────────────────────

  Future<AdminSchool?> getMySchool() async {
    final raw = await _api.getJson('/admin/school');
    final s = _m(raw)['school'];
    if (s == null) return null;
    return AdminSchool.fromJson(_m(s));
  }

  Future<AdminSchool> updateMySchool({String? name, String logoUrl = ''}) async {
    // Always include logoUrl so the server knows to clear it when empty.
    // Empty string → null (clear); non-empty → set.
    final raw = await _api.patchJson('/admin/school', body: {
      if (name != null) 'name': name,
      'logoUrl': logoUrl.trim().isEmpty ? null : logoUrl.trim(),
    });
    return AdminSchool.fromJson(_m(_m(raw)['school']));
  }

  // ── DDL helpers (reuse existing admin endpoints) ─────────────────────────────

  Future<List<Map<String, dynamic>>> getDdlStudents({String? q}) async {
    final raw = await _api.getJson('/admin/ddl/students',
        query: q != null && q.isNotEmpty ? {'q': q} : null);
    return _l(_m(raw)['students']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getDdlCohorts() async {
    final raw = await _api.getJson('/admin/ddl/cohorts');
    return _l(_m(raw)['cohorts']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getDdlTeachers() async {
    final raw = await _api.getJson('/admin/ddl/teachers');
    return _l(_m(raw)['teachers']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getPeriods() async {
    final raw = await _api.getJson('/admin/periods');
    return _l(_m(raw)['slots']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> createPeriod({
    required int dayOfWeek,
    required int period,
    String? teacherId,
    List<String>? cohortIds,
    List<String>? studentIds,
    String? subject,
    String? startTime,
    String? endTime,
    int frequencyWeeks = 1,
  }) async {
    await _api.postJson('/admin/periods', body: {
      'dayOfWeek': dayOfWeek,
      'period': period,
      if (teacherId != null && teacherId.isNotEmpty) 'teacherId': teacherId,
      if (cohortIds != null && cohortIds.isNotEmpty) 'cohortIds': cohortIds,
      if (studentIds != null && studentIds.isNotEmpty) 'studentIds': studentIds,
      if (subject != null && subject.isNotEmpty) 'subject': subject,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      'frequencyWeeks': frequencyWeeks,
    });
  }

  Future<void> deletePeriod(String id) async {
    await _api.deleteJson('/admin/periods/$id');
  }

  Future<List<Map<String, dynamic>>> getPeriodDefaults() async {
    final raw = await _api.getJson('/admin/period-defaults');
    return _l(_m(raw)['defaults']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> setPeriodDefaults(List<Map<String, dynamic>> defaults) async {
    await _api.postJson('/admin/period-defaults', body: {'defaults': defaults});
  }

  // ── Join codes ───────────────────────────────────────────────────────────────

  Future<String> generateJoinCode(String cohortId) async {
    final raw = await _api.postJson('/admin/cohorts/join-code', body: {
      'cohortId': cohortId,
      'expiresInHours': 168, // 1 week
    });
    return _m(raw)['code']?.toString() ?? '';
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static Map<String, dynamic> _m(dynamic v) =>
      v is Map<String, dynamic> ? v : (v is Map ? Map<String, dynamic>.from(v) : const {});

  static List _l(dynamic v) => v is List ? v : const [];

  static int _i(dynamic v) => (v is num) ? v.toInt() : 0;
}

// ── Models ────────────────────────────────────────────────────────────────────

class AdminOverview {
  const AdminOverview({
    required this.students,
    required this.teachers,
    required this.cohorts,
    required this.classrooms,
    required this.todaySessions,
  });

  final int students;
  final int teachers;
  final int cohorts;
  final int classrooms;
  final int todaySessions;
}

class CohortAttendance {
  const CohortAttendance({
    required this.cohortId,
    required this.cohortName,
    required this.grade,
    required this.rate,
    required this.total,
  });

  final String cohortId;
  final String cohortName;
  final int grade;
  final int? rate;
  final int total;

  factory CohortAttendance.fromJson(Map<String, dynamic> m) => CohortAttendance(
        cohortId: m['cohortId']?.toString() ?? '',
        cohortName: m['cohortName']?.toString() ?? '',
        grade: (m['grade'] as num?)?.toInt() ?? 0,
        rate: (m['rate'] as num?)?.toInt(),
        total: (m['total'] as num?)?.toInt() ?? 0,
      );
}

class CohortGrades {
  const CohortGrades({
    required this.cohortId,
    required this.cohortName,
    required this.grade,
    required this.avgGrade,
  });

  final String cohortId;
  final String cohortName;
  final int grade;
  final int? avgGrade;

  factory CohortGrades.fromJson(Map<String, dynamic> m) => CohortGrades(
        cohortId: m['cohortId']?.toString() ?? '',
        cohortName: m['cohortName']?.toString() ?? '',
        grade: (m['grade'] as num?)?.toInt() ?? 0,
        avgGrade: (m['avgGrade'] as num?)?.toInt(),
      );
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    this.status,
  });

  final String id;
  final String name;
  final String email;
  final List<String> roles;
  final String? status;

  String get primaryRole {
    const order = ['TEACHER', 'ADMIN', 'SECRETARY', 'PARENT', 'STUDENT'];
    for (final r in order) {
      if (roles.contains(r)) return r;
    }
    return roles.isNotEmpty ? roles.first : 'STUDENT';
  }

  factory AdminUser.fromJson(Map<String, dynamic> m) => AdminUser(
        id: m['id']?.toString() ?? '',
        name: m['name']?.toString() ?? '',
        email: m['email']?.toString() ?? '',
        roles: (m['roles'] as List?)?.map((r) => r.toString()).toList() ?? [],
        status: m['status']?.toString(),
      );
}

class AdminUserList {
  const AdminUserList({required this.users, required this.total});
  final List<AdminUser> users;
  final int total;
}

class AdminUserDetail extends AdminUser {
  const AdminUserDetail({
    required super.id,
    required super.name,
    required super.email,
    required super.roles,
    super.status,
    this.cohort,
    this.attendanceRate,
    this.gradeAvg,
  });

  final Map<String, dynamic>? cohort;
  final int? attendanceRate;
  final int? gradeAvg;

  factory AdminUserDetail.fromJson(Map<String, dynamic> m) => AdminUserDetail(
        id: m['id']?.toString() ?? '',
        name: m['name']?.toString() ?? '',
        email: m['email']?.toString() ?? '',
        roles: (m['roles'] as List?)?.map((r) => r.toString()).toList() ?? [],
        status: m['status']?.toString(),
        cohort: m['cohort'] is Map ? Map<String, dynamic>.from(m['cohort'] as Map) : null,
        attendanceRate: (m['attendanceRate'] as num?)?.toInt(),
        gradeAvg: (m['gradeAvg'] as num?)?.toInt(),
      );
}

class AdminCreateResult {
  const AdminCreateResult({required this.user, required this.tempPassword});
  final AdminUser user;
  final String tempPassword;
}

class AdminCohort {
  const AdminCohort({
    required this.id,
    required this.name,
    required this.grade,
    required this.studentCount,
  });

  final String id;
  final String name;
  final int grade;
  final int studentCount;

  factory AdminCohort.fromJson(Map<String, dynamic> m) => AdminCohort(
        id: m['id']?.toString() ?? '',
        name: m['name']?.toString() ?? '',
        grade: (m['grade'] as num?)?.toInt() ?? 0,
        studentCount: (m['studentCount'] as num?)?.toInt() ?? 0,
      );
}

class AdminSchool {
  const AdminSchool({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String? logoUrl;

  factory AdminSchool.fromJson(Map<String, dynamic> m) => AdminSchool(
        id: m['id']?.toString() ?? '',
        name: m['name']?.toString() ?? '',
        logoUrl: m['logoUrl']?.toString(),
      );
}
