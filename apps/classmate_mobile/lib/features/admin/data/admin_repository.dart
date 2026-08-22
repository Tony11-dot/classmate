import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/config/env.dart';
import '../../../core/contracts/school_subject.dart';
import '../../../core/contracts/grade_scale.dart';
import '../../../core/http/cm_api.dart';
import '../../../l10n/app_localizations.dart';

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
      schoolNameSet: m['schoolNameSet'] == true,
      schoolLogoSet: m['schoolLogoSet'] == true,
      subjectsConfigured: m['subjectsConfigured'] == true,
      bellScheduleConfigured: m['bellScheduleConfigured'] == true,
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

  /// Returns the full raw user map (with nameEn, nameAr, username, grade, etc.)
  Future<Map<String, dynamic>> getUserDetailRaw(String id) async {
    final raw = await _api.getJson('/admin/users/$id');
    return Map<String, dynamic>.from(_m(_m(raw)['user']));
  }

  Future<AdminCreateResult> createUser({
    required String name,
    String? email,
    String? username,
    String? phone,
    String? password,
    required String role,
    int? grade,
    String? nationalId,
    bool? isPrincipal,
    List<int>? principalGrades,
    // Optional homeroom class to assign a newly-created TEACHER to (makes
    // them that cohort's homeroom teacher). Ignored by the server for
    // non-teacher roles.
    String? homeroomCohortId,
  }) async {
    final raw = await _api.postJson('/admin/users', body: {
      'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
      if (username != null && username.isNotEmpty) 'username': username,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (password != null && password.isNotEmpty) 'password': password,
      'role': role,
      'grade': ?grade,
      if (nationalId != null && nationalId.isNotEmpty) 'nationalId': nationalId,
      'isPrincipal': ?isPrincipal,
      'principalGrades': ?principalGrades,
      if (homeroomCohortId != null && homeroomCohortId.isNotEmpty)
        'homeroomCohortId': homeroomCohortId,
    });
    final m = _m(raw);
    return AdminCreateResult(
      user: AdminUser.fromJson(_m(m['user'])),
      tempPassword: m['tempPassword']?.toString() ?? '',
      username: m['username']?.toString(),
    );
  }

  /// Classes in this school that don't yet have a homeroom teacher — used to
  /// populate the "assign homeroom class" dropdown on the create-teacher form.
  Future<List<AdminHomeroomCohort>> fetchUnassignedHomeroomCohorts() async {
    final raw = await _api.getJson('/admin/ddl/unassigned-homeroom-cohorts');
    return _l(_m(raw)['cohorts'])
        .map((e) => AdminHomeroomCohort.fromJson(_m(e)))
        .toList();
  }

  Future<void> updateUser(String id, {
    String? name,
    String? email,
    String? username,
    String? phone,
    String? role,
    int? grade,
    String? nationalId,
    bool? isPrincipal,
    List<int>? principalGrades,
  }) async {
    await _api.patchJson('/admin/users/$id', body: {
      'name': ?name,
      'email': ?email,
      'username': ?username,
      'phone': ?phone,
      'role': ?role,
      'grade': ?grade,
      'nationalId': ?nationalId,
      'isPrincipal': ?isPrincipal,
      'principalGrades': ?principalGrades,
    });
  }

  Future<List<Map<String, dynamic>>> getUserChildren(String userId) async {
    final raw = await _api.getJson('/admin/users/$userId/children');
    return _l(_m(raw)['children']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> linkParent({required String parentId, required String studentId}) async {
    await _api.postJson('/admin/parent-links', body: {'parentId': parentId, 'studentId': studentId});
  }

  Future<void> unlinkChild(String parentId, String childId) async {
    await _api.deleteJson('/admin/users/$parentId/children/$childId');
  }

  Future<void> deleteUser(String id) async {
    await _api.deleteJson('/admin/users/$id');
  }

  Future<void> setUserPassword(String id, String newPassword) async {
    await _api.postJson('/admin/users/$id/set-password', body: {'newPassword': newPassword});
  }

  // ── Message reports (Play policy queue) ─────────────────────────────────

  Future<List<Map<String, dynamic>>> listReports({String status = 'OPEN'}) async {
    final raw = await _api.getJson('/admin/reports', query: {'status': status});
    return _l(_m(raw)['items']).map(_m).toList();
  }

  Future<void> resolveReport(String id) async {
    await _api.postJson('/admin/reports/$id/resolve');
  }

  Future<void> dismissReport(String id) async {
    await _api.postJson('/admin/reports/$id/dismiss');
  }

  // ── Cohorts ──────────────────────────────────────────────────────────────────

  Future<List<AdminCohort>> listCohorts() async {
    final raw = await _api.getJson('/admin/cohorts');
    return _l(_m(raw)['cohorts']).map((e) => AdminCohort.fromJson(_m(e))).toList();
  }

  /// Creates a cohort and returns its new id so the caller can immediately add
  /// students to it. The backend returns the created Cohort row (id at top
  /// level, or nested under `cohort` on some builds) — tolerate both.
  Future<String?> createCohort({required String name, required List<int> grades, String? homeroomTeacherId}) async {
    final res = await _api.postJson('/admin/cohorts', body: {
      'name': name,
      'grades': grades,
      // Legacy single-grade field kept for older API builds and so existing
      // server-side validators that still look at `grade` keep working.
      'grade': grades.first,
      'homeroomTeacherId': ?homeroomTeacherId,
    });
    final map = res is Map ? Map<String, dynamic>.from(res) : const <String, dynamic>{};
    final nested = map['cohort'];
    final id = map['id'] ?? (nested is Map ? nested['id'] : null);
    return id == null ? null : '$id';
  }

  Future<void> updateCohort(String id, {String? name, List<int>? grades, String? homeroomTeacherId}) async {
    await _api.patchJson('/admin/cohorts/$id', body: {
      'name': ?name,
      'grades': ?grades,
      'grade': ?(grades?.first),
      'homeroomTeacherId': ?homeroomTeacherId,
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

  /// Partial update of the caller's school. Only fields that are actually
  /// passed get sent — omitted fields stay untouched on the server.
  /// `logoUrl == null` means "don't touch the logo"; pass an empty string
  /// to explicitly clear it.
  Future<AdminSchool> updateMySchool({String? name, String? logoUrl, int? minGrade, int? maxGrade, String? gradeRanges, String? semesters}) async {
    final body = <String, dynamic>{
      'name': ?name,
      'minGrade': ?minGrade,
      'maxGrade': ?maxGrade,
      'gradeRanges': ?gradeRanges,
      'semesters': ?semesters,
    };
    if (logoUrl != null) {
      // Caller explicitly asked to touch the logo. Empty string clears.
      final t = logoUrl.trim();
      body['logoUrl'] = t.isEmpty ? null : t;
    }
    final raw = await _api.patchJson('/admin/school', body: body);
    return AdminSchool.fromJson(_m(_m(raw)['school']));
  }

  // ── Custom grade scales ──────────────────────────────────────────────────────

  Future<List<CustomGradeScale>> listGradeScales() async {
    final raw = await _api.getJson('/admin/grade-scales');
    return _l(_m(raw)['scales']).map((e) => CustomGradeScale.fromJson(_m(e))).toList();
  }

  Future<CustomGradeScale> createGradeScale({
    required String name,
    required List<int> gradeLevels,
    required List<GradeScaleLabel> labels,
  }) async {
    final raw = await _api.postJson('/admin/grade-scales', body: {
      'name': name,
      'gradeLevels': gradeLevels,
      'labels': labels.map((e) => e.toJson()).toList(),
    });
    return CustomGradeScale.fromJson(_m(_m(raw)['scale']));
  }

  Future<CustomGradeScale> updateGradeScale(
    String id, {
    String? name,
    List<int>? gradeLevels,
    List<GradeScaleLabel>? labels,
  }) async {
    final raw = await _api.patchJson('/admin/grade-scales/$id', body: {
      'name': ?name,
      'gradeLevels': ?gradeLevels,
      if (labels != null) 'labels': labels.map((e) => e.toJson()).toList(),
    });
    return CustomGradeScale.fromJson(_m(_m(raw)['scale']));
  }

  Future<void> deleteGradeScale(String id) async {
    await _api.deleteJson('/admin/grade-scales/$id');
  }

  // ── DDL helpers (reuse existing admin endpoints) ─────────────────────────────

  Future<List<Map<String, dynamic>>> getDdlStudents({String? q}) async {
    final raw = await _api.getJson('/admin/ddl/students',
        query: q != null && q.isNotEmpty ? {'q': q} : null);
    return _l(_m(raw)['students']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Every grade for one student, grouped by subject with per-subject average —
  /// powers the admin Insights per-student view. Returns the raw payload
  /// `{ student: {...}, subjects: [{ subject, average, grades: [...] }] }`.
  Future<Map<String, dynamic>> getStudentGrades(String studentId) async {
    final raw = await _api.getJson('/admin/students/$studentId/grades');
    return _m(raw);
  }

  Future<List<Map<String, dynamic>>> getDdlCohorts() async {
    final raw = await _api.getJson('/admin/ddl/cohorts');
    return _l(_m(raw)['cohorts']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getDdlTeachers() async {
    final raw = await _api.getJson('/admin/ddl/teachers');
    return _l(_m(raw)['teachers']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Returns every user with `role` (one of STUDENT/TEACHER/PARENT/SECRETARY/ADMIN)
  /// in the calling admin's school. Drives the export filter sheet's
  /// per-role drill-down (Parents tab, Secretaries tab, etc.).
  Future<List<Map<String, dynamic>>> getDdlUsersByRole(String role) async {
    final raw = await _api.getJson('/admin/ddl/users-by-role', query: {'role': role});
    return _l(_m(raw)['users']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> exportStudents({
    String? cohortId,
    int? grade,
    bool generatePasswords = false,
    List<String>? studentIds,
  }) async {
    final q = <String, String>{};
    if (studentIds != null && studentIds.isNotEmpty) {
      q['studentIds'] = studentIds.join(',');
    } else {
      if (cohortId != null && cohortId.isNotEmpty) q['cohortId'] = cohortId;
      if (grade != null) q['grade'] = '$grade';
    }
    if (generatePasswords) q['generatePasswords'] = 'true';
    final raw = await _api.getJson('/admin/export/students', query: q.isEmpty ? null : q);
    return _l(_m(raw)['students']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Multi-filter user export. Server UNIONs across roles, cohortIds,
  /// gradeIds, and userIds — each adds rows. Used by the redesigned
  /// admin export screen where every filter is a removable pill.
  Future<List<Map<String, dynamic>>> exportUsers({
    List<String> roles = const [],
    List<String> cohortIds = const [],
    List<int> gradeIds = const [],
    List<String> userIds = const [],
    bool generatePasswords = false,
  }) async {
    final q = <String, String>{};
    if (roles.isNotEmpty) q['roles'] = roles.join(',');
    if (cohortIds.isNotEmpty) q['cohortIds'] = cohortIds.join(',');
    if (gradeIds.isNotEmpty) q['gradeIds'] = gradeIds.join(',');
    if (userIds.isNotEmpty) q['userIds'] = userIds.join(',');
    if (generatePasswords) q['generatePasswords'] = 'true';
    final raw = await _api.getJson('/admin/export/users', query: q.isEmpty ? null : q);
    return _l(_m(raw)['users']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> exportCohorts() async {
    final raw = await _api.getJson('/admin/export/cohorts');
    return _l(_m(raw)['cohorts']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getPeriods() async {
    final raw = await _api.getJson('/admin/periods');
    return _l(_m(raw)['slots']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Returns the newly-created slot's id when the server response includes
  /// one, otherwise an empty string. Callers that need to apply follow-up
  /// patches (e.g. setting skipForStudentIds after a "Keep current" choice
  /// in the conflict dialog) rely on this.
  Future<String> createPeriod({
    required int dayOfWeek,
    required int period,
    String? teacherId,
    List<String>? cohortIds,
    List<String>? studentIds,
    String? subject,
    String? caption,
    String? color,
    int? audienceGrade,
    String? startTime,
    String? endTime,
    int frequencyWeeks = 1,
    String? startDate,
  }) async {
    final raw = await _api.postJson('/admin/periods', body: {
      'dayOfWeek': dayOfWeek,
      'period': period,
      if (teacherId != null && teacherId.isNotEmpty) 'teacherId': teacherId,
      if (cohortIds != null && cohortIds.isNotEmpty) 'cohortIds': cohortIds,
      if (studentIds != null && studentIds.isNotEmpty) 'studentIds': studentIds,
      if (subject != null && subject.isNotEmpty) 'subject': subject,
      if (caption != null && caption.isNotEmpty) 'caption': caption,
      if (color != null && color.isNotEmpty) 'color': color,
      'audienceGrade': ?audienceGrade,
      'startTime': ?startTime,
      'endTime': ?endTime,
      'frequencyWeeks': frequencyWeeks,
      'startDate': ?startDate,
    });
    final m = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
    final slot = m['slot'];
    if (slot is Map) {
      final id = slot['id']?.toString().trim();
      if (id != null && id.isNotEmpty) return id;
    }
    final topId = m['id']?.toString().trim();
    return topId ?? '';
  }

  Future<void> deletePeriod(String id) async {
    await _api.deleteJson('/admin/periods/$id');
  }

  /// Updates an existing slot.  Pass only the fields you want to change —
  /// the server treats `'in body'` semantics for nullable fields, so omitted
  /// keys leave the existing value alone.  `cohortIds`/`studentIds` replace
  /// the full audience when present.
  Future<void> updatePeriod({
    required String id,
    int? dayOfWeek,
    int? period,
    String? teacherId,
    bool setTeacherId = false,
    String? subject,
    bool setSubject = false,
    String? caption,
    bool setCaption = false,
    String? color,
    bool setColor = false,
    int? audienceGrade,
    bool setAudienceGrade = false,
    List<String>? cohortIds,
    List<String>? studentIds,
    String? startTime,
    bool setStartTime = false,
    String? endTime,
    bool setEndTime = false,
    int? frequencyWeeks,
    String? startDate,
    bool setStartDate = false,
    List<String>? skipDates,
    List<String>? skipForStudentIds,
    List<String>? studentDateSkips,
  }) async {
    final body = <String, dynamic>{
      'dayOfWeek': ?dayOfWeek,
      'period': ?period,
      if (setTeacherId) 'teacherId': teacherId,
      if (setSubject) 'subject': subject,
      if (setCaption) 'caption': caption,
      if (setColor) 'color': color,
      if (setAudienceGrade) 'audienceGrade': audienceGrade,
      'cohortIds': ?cohortIds,
      'studentIds': ?studentIds,
      if (setStartTime) 'startTime': startTime,
      if (setEndTime) 'endTime': endTime,
      'frequencyWeeks': ?frequencyWeeks,
      if (setStartDate) 'startDate': startDate,
      'skipDates': ?skipDates,
      'skipForStudentIds': ?skipForStudentIds,
      'studentDateSkips': ?studentDateSkips,
    };
    await _api.patchJson('/admin/periods/$id', body: body);
  }

  /// All subjects defined for this school, deduplicated across grades.
  /// Feeds the Schedule "Add Period" subject picker.
  Future<List<SchoolSubject>> listAllSchoolSubjects() async {
    final raw = await _api.getJson('/admin/subjects/all');
    return _l(_m(raw)['subjects'])
        .map(SchoolSubject.fromJson)
        .where((s) => s.nameEn.isNotEmpty)
        .toList();
  }

  /// Persists a new 5-lang subject onto the SchoolGradeSubjectDefault rows
  /// for each grade in [grades]. Returns nothing — the schedule UI just
  /// proceeds with the subject's nameEn as the slot label.
  Future<void> addSubjectToGrades({
    required List<int> grades,
    required SchoolSubject subject,
  }) async {
    await _api.postJson('/admin/subjects/add-to-grades', body: {
      'grades': grades,
      'subject': subject.toJson(),
    });
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

  // ── Bulk import + danger-zone resets + grade promotion ─────────────────────

  /// Bulk-create users from the in-app grid. Returns the raw summary
  /// (createdCount, failedCount, created[], errors[], linksCreated, linkErrors[]).
  /// Each row may carry `ref` (stable client id), `parentId` (link to an
  /// existing parent), or `parentRef` (link to a parent row in this batch).
  Future<Map<String, dynamic>> bulkCreateUsers(List<Map<String, dynamic>> rows) async {
    return _m(await _api.postJson('/admin/users/bulk', body: {'rows': rows}));
  }

  /// Live username-availability check for the add-user forms.
  /// Returns (valid, available, suggestions) — valid=false means bad format;
  /// suggestions is a list of available alternative usernames (empty when the
  /// typed value is itself available). Passing [name] yields name-based ideas.
  Future<({bool valid, bool available, List<String> suggestions})> checkUsername(
    String username, {
    String? name,
  }) async {
    final raw = await _api.getJson('/admin/users/check-username', query: {
      'username': username,
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
    });
    final m = _m(raw);
    final sugg = (m['suggestions'] is List)
        ? (m['suggestions'] as List).whereType<String>().toList()
        : <String>[];
    return (
      valid: m['valid'] == true,
      available: m['available'] == true,
      suggestions: sugg,
    );
  }

  /// Upload a CSV file. dryRun → preview (detectedFields, rowCount, preview[]);
  /// otherwise commits and returns the create summary.
  Future<Map<String, dynamic>> importCsv(String filePath, {bool dryRun = false}) async {
    final base = Env.stripApiSuffix(Env.apiBaseUrl).replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base/admin/users/import-csv${dryRun ? '?dryRun=true' : ''}');
    return _api.multipartUpload(uri, filePath, mimeType: 'text/csv');
  }

  Future<Map<String, dynamic>> resetSchedule() async => _m(await _api.postJson('/admin/schedule/reset'));
  Future<Map<String, dynamic>> resetCohorts() async => _m(await _api.postJson('/admin/cohorts/reset'));
  Future<Map<String, dynamic>> promoteAllGrades() async => _m(await _api.postJson('/admin/grades/promote-all'));

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
    this.schoolNameSet = false,
    this.schoolLogoSet = false,
    this.subjectsConfigured = false,
    this.bellScheduleConfigured = false,
  });

  final int students;
  final int teachers;
  final int cohorts;
  final int classrooms;
  final int todaySessions;

  /// Setup-progress signals — drive the dashboard School Setup widget.
  final bool schoolNameSet;
  final bool schoolLogoSet;
  final bool subjectsConfigured;
  final bool bellScheduleConfigured;
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
  const AdminCreateResult({required this.user, required this.tempPassword, this.username});
  final AdminUser user;
  final String tempPassword;
  final String? username; // auto-generated or provided username
}

/// A class/cohort with no homeroom teacher yet — an option in the
/// create-teacher "assign homeroom class" dropdown.
class AdminHomeroomCohort {
  const AdminHomeroomCohort({required this.id, required this.name, required this.grade});
  final String id;
  final String name;
  final int grade;

  factory AdminHomeroomCohort.fromJson(Map<String, dynamic> m) => AdminHomeroomCohort(
        id: m['id']?.toString() ?? '',
        name: m['name']?.toString() ?? '',
        grade: m['grade'] is int
            ? m['grade'] as int
            : int.tryParse('${m['grade'] ?? ''}') ?? 0,
      );
}

class AdminCohort {
  const AdminCohort({
    required this.id,
    required this.name,
    required this.grade,
    required this.grades,
    required this.studentCount,
  });

  final String id;
  final String name;
  /// Primary/representative grade (== grades.first). Kept for backward
  /// compatibility with code that wasn't ported to multi-grade yet.
  final int grade;
  /// All grades this cohort spans. Length 1 for single-grade cohorts.
  final List<int> grades;
  final int studentCount;

  /// Human-readable grade label: "Grade 7", "Grade 7-9" (contiguous range),
  /// or "Grades 7, 9, 11" (non-contiguous list). English-only — prefer
  /// [gradeLabelLocalized] for any UI render path.
  String get gradeLabel {
    if (grades.isEmpty) return 'Grade $grade';
    if (grades.length == 1) return 'Grade ${grades.first}';
    final sorted = [...grades]..sort();
    final isRange = sorted.last - sorted.first == sorted.length - 1;
    return isRange ? 'Grade ${sorted.first}-${sorted.last}' : 'Grades ${sorted.join(', ')}';
  }

  /// Localized variant of [gradeLabel] for UI rendering.
  String gradeLabelLocalized(AppLocalizations l) {
    if (grades.isEmpty) return l.adminCohortGradeFormat(grade.toString());
    if (grades.length == 1) {
      return l.adminCohortGradeFormat(grades.first.toString());
    }
    final sorted = [...grades]..sort();
    final isRange = sorted.last - sorted.first == sorted.length - 1;
    return isRange
        ? l.adminCohortGradeRange(sorted.first, sorted.last)
        : l.adminCohortGradesList(sorted.join(', '));
  }

  /// Compact label for tight chips: "G7", "G7-9", "G7,9,11".
  String get gradeChip {
    if (grades.isEmpty) return 'G$grade';
    if (grades.length == 1) return 'G${grades.first}';
    final sorted = [...grades]..sort();
    final isRange = sorted.last - sorted.first == sorted.length - 1;
    return isRange ? 'G${sorted.first}-${sorted.last}' : 'G${sorted.join(',')}';
  }

  factory AdminCohort.fromJson(Map<String, dynamic> m) {
    final grade = (m['grade'] as num?)?.toInt() ?? 0;
    final rawGrades = m['grades'];
    final grades = rawGrades is List
        ? rawGrades.map((e) => (e as num).toInt()).toList()
        : <int>[grade];
    return AdminCohort(
      id: m['id']?.toString() ?? '',
      name: m['name']?.toString() ?? '',
      grade: grade,
      grades: grades.isEmpty ? [grade] : grades,
      studentCount: (m['studentCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminSchool {
  const AdminSchool({
    required this.id,
    required this.name,
    this.logoUrl,
    this.minGrade = 5,
    this.maxGrade = 12,
    this.gradeRanges = '',
    this.semesters = '',
  });

  final String id;
  final String name;
  final String? logoUrl;
  final int minGrade;
  final int maxGrade;
  /// Multi-range string e.g. "4-6,9-12"; empty = single minGrade..maxGrade.
  final String gradeRanges;
  /// Semester month-ranges e.g. "9-1,2-6"; empty = no semester split.
  final String semesters;

  factory AdminSchool.fromJson(Map<String, dynamic> m) => AdminSchool(
        id: m['id']?.toString() ?? '',
        name: m['name']?.toString() ?? '',
        logoUrl: m['logoUrl']?.toString(),
        minGrade: (m['minGrade'] as num?)?.toInt() ?? 5,
        maxGrade: (m['maxGrade'] as num?)?.toInt() ?? 12,
        gradeRanges: m['gradeRanges']?.toString() ?? '',
        semesters: m['semesters']?.toString() ?? '',
      );
}

