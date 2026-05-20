// ignore_for_file: use_null_aware_elements
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/auth/auth_session.dart';
import '../../../core/http/cm_api.dart';

final teacherMobileRepositoryProvider = Provider<TeacherMobileRepository>((ref) {
  final session = ref.watch(authSessionProvider);
  return TeacherMobileRepository(token: session.token ?? '');
});

class TeacherMobileRepository {
  TeacherMobileRepository({required this.token});

  final String token;

  CMApi get _api => CMApi(token: token);

  Future<TeacherTodaySchedule> fetchTodaySchedule() async {
    final raw = await _api.getJson('/teacher/schedule/today');
    final map = _asMap(raw);
    final slots = _asList(map['slots'])
        .map((item) => TeacherTodaySlot.fromJson(_asMap(item)))
        .toList(growable: false);
    return TeacherTodaySchedule(
      date: _asString(map['date']),
      dayOfWeek: _asInt(map['dayOfWeek']),
      slots: slots,
    );
  }

  Future<TeacherAssessmentBundle> fetchAssessments({bool standalone = false}) async {
    final raw = await _api.getJson(
      '/teacher/grades/assessments',
      query: standalone ? const <String, String>{'standalone': 'true'} : null,
    );
    final map = _asMap(raw);
    final courses = _asList(map['courses'])
        .map((item) => TeacherCourse.fromJson(_asMap(item)))
        .toList(growable: false);
    final assessments = _asList(map['assessments'])
        .map((item) => TeacherAssessment.fromJson(_asMap(item)))
        .toList(growable: false);
    return TeacherAssessmentBundle(courses: courses, assessments: assessments);
  }

  Future<TeacherAttendanceSession> fetchAttendanceSession({
    required String cohortId,
    required String date,
    required int period,
  }) async {
    final raw = await _api.getJson(
      '/teacher/attendance/session',
      query: <String, String>{
        'cohortId': cohortId,
        'date': date,
        'period': '$period',
      },
    );
    final map = _asMap(raw);
    return TeacherAttendanceSession(
      cohort: TeacherCohort.fromJson(_asMap(map['cohort'])),
      date: _asString(map['date']),
      period: _asInt(map['period']),
      classNote: _asString(map['classNote']),
      course: TeacherCourse.fromJson(_asMap(map['course'])),
      students: _asList(map['students'])
          .map((item) => TeacherAttendanceStudent.fromJson(_asMap(item)))
          .toList(growable: false),
    );
  }

  Future<void> saveBulkAttendance({
    required String cohortId,
    required String date,
    required int period,
    required List<TeacherAttendanceDraftRecord> records,
    String? classNote,
  }) async {
    await _api.postJson(
      '/teacher/attendance/bulk',
      body: <String, dynamic>{
        'cohortId': cohortId,
        'date': date,
        'period': period,
        if ((classNote ?? '').trim().isNotEmpty) 'classNote': classNote!.trim(),
        'records': records
            .map(
              (record) => <String, dynamic>{
                'studentId': record.studentId,
                'status': record.status,
                'note': record.note.trim().isEmpty ? null : record.note.trim(),
              },
            )
            .toList(growable: false),
      },
    );
  }

  Future<List<TeacherAttendanceSessionSummary>> fetchAttendanceSessions({
    String? from,
    String? to,
  }) async {
    final query = <String, String>{
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    };
    final raw = await _api.getJson('/teacher/attendance/sessions', query: query.isEmpty ? null : query);
    return _asList(raw)
        .map((item) => TeacherAttendanceSessionSummary.fromJson(_asMap(item)))
        .toList(growable: false);
  }

  Future<List<TeacherStudent>> fetchCohortStudents(String cohortId) async {
    final raw = await _api.getJson('/teacher/cohorts/$cohortId/students');
    final map = _asMap(raw);
    return _asList(map['students'])
        .map((item) => TeacherStudent.fromJson(_asMap(item)))
        .toList(growable: false);
  }

  Future<TeacherJoinCode> createJoinCode(String cohortId) async {
    final raw = await _api.postJson(
      '/teacher/cohorts/join-code',
      body: <String, dynamic>{
        'cohortId': cohortId,
        'expiresInHours': 24,
        'length': 6,
      },
    );
    return TeacherJoinCode.fromJson(_asMap(raw));
  }

  /// Returns the existing active permanent join code or creates a new one.
  Future<TeacherJoinCode> getOrCreateJoinCode(String cohortId) async {
    final raw = await _api.getJson('/teacher/cohorts/$cohortId/join-code');
    return TeacherJoinCode.fromJson(_asMap(raw));
  }

  /// Resets (replaces) the join code for the given cohort.
  Future<TeacherJoinCode> resetJoinCode(String cohortId) async {
    final raw = await _api.postJson(
      '/teacher/cohorts/$cohortId/reset-join-code',
      body: <String, dynamic>{},
    );
    return TeacherJoinCode.fromJson(_asMap(raw));
  }

  Future<Map<String, dynamic>> createClassroom({
    required String name,
    required String subject,
    List<String> studentIds = const [],
    List<String> cohortIds = const [],
  }) async {
    final raw = await _api.postJson(
      '/teacher/classrooms',
      body: <String, dynamic>{
        'name': name.trim(),
        'subject': subject.trim(),
        if (studentIds.isNotEmpty) 'studentIds': studentIds,
        if (cohortIds.isNotEmpty) 'cohortIds': cohortIds,
      },
    );
    return raw is Map ? Map<String, dynamic>.from(raw) : {};
  }

  /// All school cohorts — for audience pickers in add screens.
  Future<List<Map<String, dynamic>>> fetchCohortsForPicker() async {
    try {
      final raw = await _api.getJson('/teacher/school-cohorts');
      final list = raw is List ? raw : (raw is Map ? (raw['cohorts'] ?? raw['items'] ?? []) : []);
      return (list as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Only THIS teacher's cohorts (from their schedule slots) — for insights/schedule.
  Future<List<Map<String, dynamic>>> fetchTeacherCohorts() async {
    try {
      final raw = await _api.getJson('/teacher/cohorts');
      final list = raw is List ? raw : (raw is Map ? (raw['cohorts'] ?? raw['items'] ?? []) : []);
      return (list as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<TeacherAssessmentGrade>> fetchAssessmentGrades(String assessmentId) async {
    final raw = await _api.getJson('/teacher/assessments/$assessmentId/grades');
    final map = _asMap(raw);
    return _asList(map['grades'])
        .map((item) => TeacherAssessmentGrade.fromJson(_asMap(item)))
        .toList(growable: false);
  }

  /// Creates an Assessment. The server's Assessment model is keyed on cohort,
  /// not classroom — `cohortId` is required.  Returns the raw server payload
  /// (e.g. `{ ok: true, assessment: { id, ... } }`); the caller can pull
  /// `assessment.id` straight out instead of round-tripping a list query.
  Future<Map<String, dynamic>> createAssessment({
    required String cohortId,
    required String title,
    required String date,
    String? subject,
    int? maxGrade,
    bool published = false,
    List<Map<String, dynamic>>? attachments,
  }) async {
    final raw = await _api.postJson(
      '/teacher/grades/assessment',
      body: <String, dynamic>{
        'cohortId': cohortId,
        'title': title.trim(),
        if (subject != null && subject.trim().isNotEmpty) 'subject': subject.trim(),
        'date': date.trim().isEmpty ? null : date.trim(),
        'maxGrade': maxGrade,
        'published': published,
        if (attachments != null && attachments.isNotEmpty) 'attachments': attachments,
      },
    );
    return raw is Map ? Map<String, dynamic>.from(raw) : {};
  }

  Future<void> updateAssessment({
    required String assessmentId,
    required String title,
    required String date,
    int? maxGrade,
  }) async {
    await _api.patchJson(
      '/teacher/grades/assessment/$assessmentId',
      body: <String, dynamic>{
        'title': title.trim(),
        'date': date.trim().isEmpty ? null : date.trim(),
        'maxGrade': maxGrade,
      },
    );
  }

  Future<void> deleteAssessment(String assessmentId) async {
    await _api.deleteJson('/teacher/grades/assessment/$assessmentId');
  }

  Future<void> saveBulkGrades({
    required String assessmentId,
    required List<TeacherGradeDraftRecord> grades,
  }) async {
    await _api.postJson(
      '/teacher/grades/bulk',
      body: <String, dynamic>{
        'assessmentId': assessmentId,
        'grades': grades
            .map(
              (grade) => <String, dynamic>{
                'studentId': grade.studentId,
                'grade': grade.grade,
              },
            )
            .toList(growable: false),
      },
    );
  }

  // ── Classroom management ────────────────────────────────────────────────

  Future<List<TeacherCourse>> fetchClassrooms() async {
    final raw = await _api.getJson('/teacher/classrooms');
    final map = _asMap(raw);
    return _asList(map['classrooms'])
        .map((item) {
          final m = _asMap(item);
          return TeacherCourse(
            id: _asString(m['id']),
            name: _asString(m['name']),
            subject: _asString(m['subject']),
            cohortId: '',
            cohort: null, // no cohort — displayName will use name directly
          );
        })
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> fetchClassroomChat(
    String courseId, {
    int limit = 30,
    String? cursor,
  }) async {
    final q = <String, String>{'limit': '$limit'};
    if ((cursor ?? '').isNotEmpty) q['cursor'] = cursor!;
    final raw = await _api.getJson('/teacher/classrooms/$courseId/chat', query: q);
    final map = _asMap(raw);
    return _asList(map['items'])
        .map((item) => Map<String, dynamic>.from(_asMap(item)))
        .toList(growable: false);
  }

  Future<void> sendClassroomChat(String courseId, String text) async {
    await _api.postJson(
      '/teacher/classrooms/$courseId/chat',
      body: <String, dynamic>{'text': text.trim()},
    );
  }

  Future<List<Map<String, dynamic>>> fetchClassroomAssignments(String courseId) async {
    final raw = await _api.getJson('/teacher/classrooms/$courseId/assignments');
    final map = _asMap(raw);
    return _asList(map['items'])
        .map((item) => Map<String, dynamic>.from(_asMap(item)))
        .toList(growable: false);
  }

  Future<void> createClassroomAssignment({
    required String courseId,
    required String title,
    String? body,
    String? dueAt,
    List<Map<String, dynamic>> attachments = const [],
  }) async {
    await _api.postJson(
      '/teacher/classrooms/$courseId/assignments',
      body: <String, dynamic>{
        'title': title.trim(),
        if ((body ?? '').trim().isNotEmpty) 'body': body!.trim(),
        if ((dueAt ?? '').trim().isNotEmpty) 'dueAt': dueAt!.trim(),
        if (attachments.isNotEmpty) 'attachments': attachments,
      },
    );
  }

  Future<void> updateClassroomAssignment({
    required String courseId,
    required String id,
    String? title,
    String? body,
    String? dueAt,
  }) async {
    await _api.patchJson(
      '/teacher/classrooms/$courseId/assignments/$id',
      body: <String, dynamic>{
        if (title != null) 'title': title.trim(),
        if (body != null) 'body': body.trim(),
        if (dueAt != null) 'dueAt': dueAt.trim(),
      },
    );
  }

  Future<void> deleteClassroomAssignment(String courseId, String id) async {
    await _api.deleteJson('/teacher/classrooms/$courseId/assignments/$id');
  }

  Future<void> resetAssignmentSubmission(String assignmentId, String studentId) async {
    await _api.deleteJson('/teacher/assignments/$assignmentId/submissions/$studentId');
  }

  Future<List<Map<String, dynamic>>> fetchClassroomMaterials(String courseId) async {
    final raw = await _api.getJson('/teacher/classrooms/$courseId/materials');
    final map = _asMap(raw);
    return _asList(map['items'])
        .map((item) => Map<String, dynamic>.from(_asMap(item)))
        .toList(growable: false);
  }

  Future<void> createClassroomMaterial({
    required String courseId,
    required String title,
    required String url,
    String? description,
    String? mime,
  }) async {
    await _api.postJson(
      '/teacher/classrooms/$courseId/materials',
      body: <String, dynamic>{
        'title': title.trim(),
        'url': url.trim(),
        if ((description ?? '').trim().isNotEmpty) 'description': description!.trim(),
        if ((mime ?? '').trim().isNotEmpty) 'mime': mime!.trim(),
      },
    );
  }

  Future<void> deleteClassroomMaterial(String courseId, String id) async {
    await _api.deleteJson('/teacher/classrooms/$courseId/materials/$id');
  }

  Future<List<Map<String, dynamic>>> fetchClassroomMeetings(String courseId) async {
    final raw = await _api.getJson('/teacher/classrooms/$courseId/meetings');
    final map = _asMap(raw);
    return _asList(map['items'])
        .map((item) => Map<String, dynamic>.from(_asMap(item)))
        .toList(growable: false);
  }

  Future<void> createClassroomMeeting({
    required String courseId,
    required String title,
    required String link,
    required String startsAt,
    String? endsAt,
  }) async {
    await _api.postJson(
      '/teacher/classrooms/$courseId/meetings',
      body: <String, dynamic>{
        'title': title.trim(),
        'link': link.trim(),
        'startsAt': startsAt.trim(),
        if ((endsAt ?? '').trim().isNotEmpty) 'endsAt': endsAt!.trim(),
      },
    );
  }

  Future<void> deleteClassroomMeeting(String courseId, String id) async {
    await _api.deleteJson('/teacher/classrooms/$courseId/meetings/$id');
  }

  Future<Map<String, dynamic>> fetchClassroomPeople(String courseId) async {
    final raw = await _api.getJson('/teacher/classrooms/$courseId/members');
    final map = _asMap(raw);
    final members = _asList(map['members']);
    final teacher = map['teacher'] is Map ? map['teacher'] as Map : null;

    final students = members.map((m) {
      final mMap = _asMap(m);
      return <String, dynamic>{
        'id': (mMap['studentId'] ?? mMap['id'] ?? mMap['userId'] ?? '').toString(),
        'name': (mMap['name'] ?? mMap['displayName'] ?? mMap['studentName'] ?? '').toString(),
        'email': (mMap['email'] ?? '').toString(),
      };
    }).toList();
    final ids = students.map((s) => s['id'] as String).toList();

    // Build people list: teacher first, then students
    final people = <Map<String, dynamic>>[
      if (teacher != null) <String, dynamic>{
        'id': teacher['userId']?.toString() ?? '',
        'name': teacher['name']?.toString() ?? '',
        'role': 'TEACHER',
      },
      ...students.map((s) => {...s, 'role': 'STUDENT'}),
    ];

    return <String, dynamic>{
      'teacher': teacher,
      'items': <String, dynamic>{
        'students': students,
        'studentUserIds': ids,
        'people': people,
      },
    };
  }

  Future<Map<String, dynamic>> fetchClassroomAnalytics(String courseId) async {
    final raw = await _api.getJson('/teacher/classrooms/$courseId/analytics');
    return _asMap(raw);
  }

  Future<Map<String, dynamic>> fetchAssignmentSubmissions(String courseId, String assignmentId) async {
    final raw = await _api.getJson('/teacher/classrooms/$courseId/assignments/$assignmentId/submissions');
    return _asMap(raw);
  }

  Future<Map<String, dynamic>> fetchStudentProfile(String studentId) async {
    final raw = await _api.getJson('/teacher/student/$studentId/profile');
    return _asMap(raw);
  }

  Future<Map<String, dynamic>> fetchWeekSchedule({String? weekOf}) async {
    final q = <String, String>{};
    if ((weekOf ?? '').isNotEmpty) q['weekOf'] = weekOf!;
    final raw = await _api.getJson('/teacher/schedule/week', query: q);
    return _asMap(raw);
  }

  Future<void> addStudentToClassroom(String courseId, String emailOrId) async {
    final body = <String, dynamic>{};
    if (emailOrId.contains('@')) {
      body['email'] = emailOrId;
    } else {
      body['userId'] = emailOrId;
    }
    await _api.postJson('/teacher/classrooms/$courseId/students', body: body);
  }

  Future<void> removeStudentFromClassroom(String courseId, String studentId) async {
    await _api.deleteJson('/teacher/classrooms/$courseId/students/$studentId');
  }

  Future<void> createAnnouncement({
    required String title,
    required String body,
    List<Map<String, dynamic>> targets = const [],
    List<Map<String, dynamic>> attachments = const [],
  }) async {
    await _api.postJson(
      '/announcements',
      body: <String, dynamic>{
        'title': title.trim(),
        'body': body.trim(),
        if (targets.isNotEmpty) 'targets': targets,
        if (attachments.isNotEmpty) 'attachments': attachments,
      },
    );
  }

  Future<TeacherAttendanceSession> fetchAttendanceSessionForDate({
    required String cohortId,
    required String date,
    required int period,
    String? slotId,
  }) async {
    final raw = await _api.getJson(
      '/teacher/attendance/history',
      query: <String, String>{
        'cohortId': cohortId,
        'date': date,
        'period': '$period',
        if (slotId != null && slotId.isNotEmpty) 'slotId': slotId,
      },
    );
    final map = _asMap(raw);
    return TeacherAttendanceSession(
      cohort: TeacherCohort.fromJson(_asMap(map['cohort'])),
      date: _asString(map['date']),
      period: _asInt(map['period']),
      classNote: _asString(map['classNote']),
      course: TeacherCourse.fromJson(_asMap(map['course'])),
      students: _asList(map['students'])
          .map((item) => TeacherAttendanceStudent.fromJson(_asMap(item)))
          .toList(growable: false),
    );
  }

  // ── Teacher-wide assignments ───────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchTeacherAssignments() async {
    final courses = await fetchClassrooms();
    final results = await Future.wait(
      courses.map((course) async {
        try {
          final items = await fetchClassroomAssignments(course.id);
          return items.map((item) => <String, dynamic>{
            ...item,
            '_courseId': course.id,
            '_courseName': course.name,
            '_subject': course.subject,
          }).toList();
        } catch (_) {
          return <Map<String, dynamic>>[];
        }
      }),
    );
    final flat = results.expand((g) => g).toList();
    flat.sort((a, b) {
      final aDue = (a['dueAt'] ?? a['createdAt'] ?? '') as String;
      final bDue = (b['dueAt'] ?? b['createdAt'] ?? '') as String;
      return bDue.compareTo(aDue);
    });
    return flat;
  }

  Future<List<Map<String, dynamic>>> fetchTeacherMaterials() async {
    final courses = await fetchClassrooms();
    final results = await Future.wait(
      courses.map((course) async {
        try {
          final items = await fetchClassroomMaterials(course.id);
          return items.map((item) => <String, dynamic>{
            ...item,
            '_courseId': course.id,
            '_courseName': course.name,
            '_subject': course.subject,
          }).toList();
        } catch (_) {
          return <Map<String, dynamic>>[];
        }
      }),
    );
    return results.expand((g) => g).toList();
  }

  Future<void> createTeacherAssignment({
    required String courseId,
    required String title,
    String? body,
    String? dueAt,
    List<Map<String, dynamic>>? attachments,
  }) async {
    await _api.postJson(
      '/teacher/classrooms/$courseId/assignments',
      body: <String, dynamic>{
        'title': title.trim(),
        if ((body ?? '').trim().isNotEmpty) 'body': body!.trim(),
        if ((dueAt ?? '').trim().isNotEmpty) 'dueAt': dueAt!.trim(),
        if (attachments != null && attachments.isNotEmpty) 'attachments': attachments,
      },
    );
  }

  // ── Teacher-wide Assignments ───────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> listTeacherAssignments() async {
    final raw = await _api.getJson('/teacher/assignments');
    if (raw is Map && raw['assignments'] is List) {
      return (raw['assignments'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> createTeacherAssignmentV2({
    required String title,
    String? description,
    String? courseId,
    String? subject,
    String? dueAt,
    int? maxGrade,
    String targetType = 'EVERYONE',
    List<String> targetCohortIds = const [],
    List<String> targetStudentIds = const [],
    List<Map<String, dynamic>> attachments = const [],
    bool published = false,
  }) async {
    final raw = await _api.postJson(
      '/teacher/assignments',
      body: <String, dynamic>{
        'title': title.trim(),
        if ((description ?? '').isNotEmpty) 'description': description!.trim(),
        if ((courseId ?? '').isNotEmpty) 'courseId': courseId,
        if ((subject ?? '').isNotEmpty) 'subject': subject!.trim(),
        if ((dueAt ?? '').isNotEmpty) 'dueAt': dueAt,
        if (maxGrade != null) 'maxGrade': maxGrade,
        'targetType': targetType,
        'targetCohortIds': targetCohortIds,
        'targetStudentIds': targetStudentIds,
        if (attachments.isNotEmpty) 'attachments': attachments,
        'published': published,
      },
    );
    return raw is Map ? Map<String, dynamic>.from(raw) : {};
  }

  Future<void> updateTeacherAssignment(String id, Map<String, dynamic> body) async {
    await _api.patchJson('/teacher/assignments/$id', body: body);
  }

  Future<void> deleteTeacherAssignmentV2(String id) async {
    await _api.deleteJson('/teacher/assignments/$id');
  }

  Future<List<Map<String, dynamic>>> getTeacherAssignmentSubmissions(String assignmentId) async {
    final raw = await _api.getJson('/teacher/assignments/$assignmentId/submissions');
    if (raw is Map && raw['submissions'] is List) {
      return (raw['submissions'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  Future<void> gradeAssignmentSubmission({
    required String assignmentId,
    required String studentId,
    int? grade,
    String? feedback,
  }) async {
    await _api.patchJson(
      '/teacher/assignments/$assignmentId/submissions/$studentId/grade',
      body: <String, dynamic>{
        if (grade != null) 'grade': grade,
        if ((feedback ?? '').isNotEmpty) 'feedback': feedback,
      },
    );
  }

  // ── Teacher Materials (standalone) ────────────────────────────────────────

  Future<List<Map<String, dynamic>>> listTeacherMaterials() async {
    final raw = await _api.getJson('/teacher/materials');
    if (raw is Map && raw['materials'] is List) {
      return (raw['materials'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  // ── Slot attachments ─────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> listSlotMaterials(String slotId) async {
    final raw = await _api.getJson('/teacher/schedule-slots/$slotId/materials');
    if (raw is Map && raw['attachments'] is List) {
      return (raw['attachments'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  Future<void> attachSlotMaterial({
    required String slotId,
    required String teacherMaterialId,
  }) async {
    await _api.postJson(
      '/teacher/schedule-slots/$slotId/materials',
      body: <String, dynamic>{'teacherMaterialId': teacherMaterialId},
    );
  }

  Future<void> detachSlotMaterial({
    required String slotId,
    required String teacherMaterialId,
  }) async {
    await _api.deleteJson(
      '/teacher/schedule-slots/$slotId/materials/$teacherMaterialId',
    );
  }

  Future<Map<String, dynamic>> createTeacherMaterial({
    required String title,
    String? description,
    String? url,
    String? courseId,
    String? subject,
    String targetType = 'EVERYONE',
    List<String> targetCohortIds = const [],
    List<String> targetStudentIds = const [],
    List<Map<String, dynamic>> attachments = const [],
    bool published = true,
  }) async {
    final raw = await _api.postJson('/teacher/materials', body: <String, dynamic>{
      'title': title.trim(),
      if ((description ?? '').isNotEmpty) 'description': description,
      if ((url ?? '').isNotEmpty) 'url': url,
      if ((courseId ?? '').isNotEmpty) 'courseId': courseId,
      if ((subject ?? '').isNotEmpty) 'subject': subject,
      'targetType': targetType,
      'targetCohortIds': targetCohortIds,
      'targetStudentIds': targetStudentIds,
      if (attachments.isNotEmpty) 'attachments': attachments,
      'published': published,
    });
    // Server wraps as { ok: true, material: {...} }. Unwrap so callers
    // get a flat material map (with `id`, `title`, etc).
    if (raw is Map) {
      final inner = raw['material'];
      if (inner is Map) return Map<String, dynamic>.from(inner);
      return Map<String, dynamic>.from(raw);
    }
    return {};
  }

  Future<void> updateTeacherMaterial(String id, Map<String, dynamic> body) async {
    await _api.patchJson('/teacher/materials/$id', body: body);
  }

  Future<void> deleteTeacherMaterial(String id) async {
    await _api.deleteJson('/teacher/materials/$id');
  }

  // ── Teacher Meetings (standalone) ─────────────────────────────────────────

  Future<List<Map<String, dynamic>>> listTeacherMeetings() async {
    final raw = await _api.getJson('/teacher/meetings');
    if (raw is Map && raw['meetings'] is List) {
      return (raw['meetings'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> createTeacherMeeting({
    required String title,
    String? description,
    required String link,
    required String startsAt,
    String? endsAt,
    String? courseId,
    String? subject,
    String targetType = 'EVERYONE',
    List<String> targetCohortIds = const [],
    List<String> targetStudentIds = const [],
  }) async {
    final raw = await _api.postJson('/teacher/meetings', body: <String, dynamic>{
      'title': title.trim(),
      if ((description ?? '').isNotEmpty) 'description': description,
      'link': link.trim(),
      'startsAt': startsAt,
      if ((endsAt ?? '').isNotEmpty) 'endsAt': endsAt,
      if ((courseId ?? '').isNotEmpty) 'courseId': courseId,
      if ((subject ?? '').isNotEmpty) 'subject': subject,
      'targetType': targetType,
      'targetCohortIds': targetCohortIds,
      'targetStudentIds': targetStudentIds,
    });
    return raw is Map ? Map<String, dynamic>.from(raw) : {};
  }

  Future<void> updateTeacherMeeting(String id, Map<String, dynamic> body) async {
    await _api.patchJson('/teacher/meetings/$id', body: body);
  }

  Future<void> deleteTeacherMeeting(String id) async {
    await _api.deleteJson('/teacher/meetings/$id');
  }

  // ── Teacher Exams ──────────────────────────────────────────────────────────

  Future<List<String>> fetchSubjects() async {
    final raw = await _api.getJson('/teacher/subjects');
    if (raw is Map && raw['subjects'] is List) {
      return (raw['subjects'] as List).map((e) => e.toString()).toList(growable: false);
    }
    return const [];
  }

  Future<Map<String, dynamic>> fetchExamGrades(String examId) async {
    final raw = await _api.getJson('/teacher/exams/$examId/grades');
    return raw is Map ? Map<String, dynamic>.from(raw) : {};
  }

  Future<void> saveExamGrades({
    required String examId,
    required List<TeacherGradeDraftRecord> grades,
  }) async {
    await _api.postJson(
      '/teacher/exams/$examId/grades',
      body: <String, dynamic>{
        'grades': grades
            .map((g) => <String, dynamic>{'studentId': g.studentId, 'grade': g.grade})
            .toList(growable: false),
      },
    );
  }

  Future<List<Map<String, dynamic>>> listTeacherExams() async {
    final raw = await _api.getJson('/teacher/exams');
    // Handle multiple possible response shapes from the API
    List<dynamic> items = const [];
    if (raw is List) {
      items = raw;
    } else if (raw is Map) {
      items = (raw['exams'] ?? raw['items'] ?? raw['data'] ?? const []) as List? ?? const [];
    }
    return items.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> createTeacherExam({
    required String title,
    String? subject,
    String? courseId,
    required String date,
    int? maxGrade,
    bool published = false,
    String targetType = 'EVERYONE',
    List<String> targetCohortIds = const [],
    List<String> targetStudentIds = const [],
    List<Map<String, dynamic>> attachments = const [],
  }) async {
    final raw = await _api.postJson(
      '/teacher/exams',
      body: <String, dynamic>{
        'title': title.trim(),
        if ((subject ?? '').isNotEmpty) 'subject': subject!.trim(),
        if ((courseId ?? '').isNotEmpty) 'courseId': courseId,
        'date': date,
        if (maxGrade != null) 'maxGrade': maxGrade,
        'published': published,
        'targetType': targetType,
        'targetCohortIds': targetCohortIds,
        'targetStudentIds': targetStudentIds,
        if (attachments.isNotEmpty) 'attachments': attachments,
      },
    );
    return raw is Map ? Map<String, dynamic>.from(raw) : {};
  }

  Future<void> updateTeacherExam(String id, Map<String, dynamic> body) async {
    await _api.patchJson('/teacher/exams/$id', body: body);
  }

  /// Uploads a file to the general attachment endpoint and returns
  /// `{ url, fileName, mimeType }` with a server-hosted URL.
  Future<Map<String, dynamic>> uploadAttachmentFile(String filePath, String fileName) async {
    final baseUrl = _api.primaryBaseUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$baseUrl/uploads/attachment');
    final t = (token).trim();
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $t'
      ..files.add(await http.MultipartFile.fromPath('file', filePath, filename: fileName));
    final streamed = await req.send().timeout(const Duration(seconds: 60));
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode >= 400) throw Exception('Upload failed: ${streamed.statusCode}');
    final j = jsonDecode(body);
    if (j is! Map) throw Exception('Upload: unexpected response');
    final result = Map<String, dynamic>.from(j);
    // Convert relative URL to absolute so the app can open the file directly
    for (final key in ['url', 'fileUrl']) {
      final v = result[key]?.toString() ?? '';
      if (v.isNotEmpty && !v.startsWith('http')) result[key] = '$baseUrl$v';
    }
    return result;
  }

  Future<void> deleteTeacherExam(String id) async {
    await _api.deleteJson('/teacher/exams/$id');
  }

  // ── Student Assignments (student view) ────────────────────────────────────

  Future<List<Map<String, dynamic>>> listStudentAssignments() async {
    final raw = await _api.getJson('/student/assignments');
    if (raw is Map && raw['assignments'] is List) {
      return (raw['assignments'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  Future<void> submitStudentAssignment(String assignmentId, {String? note}) async {
    await _api.postJson(
      '/student/assignments/$assignmentId/submit',
      body: <String, dynamic>{
        if ((note ?? '').isNotEmpty) 'note': note,
      },
    );
  }

  // ── Forms ──────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> listForms() async {
    final raw = await _api.getJson('/teacher/forms');
    if (raw is Map && raw['forms'] is List) {
      return (raw['forms'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> createForm(Map<String, dynamic> body) async {
    final raw = await _api.postJson('/teacher/forms', body: body);
    return raw is Map ? Map<String, dynamic>.from(raw) : {};
  }

  Future<void> updateForm(String id, Map<String, dynamic> body) async {
    await _api.patchJson('/teacher/forms/$id', body: body);
  }

  Future<void> deleteForm(String id) async {
    await _api.deleteJson('/teacher/forms/$id');
  }

  Future<List<Map<String, dynamic>>> formResponses(String id) async {
    final raw = await _api.getJson('/teacher/forms/$id/responses');
    List<dynamic> items = const [];
    if (raw is List) {
      items = raw;
    } else if (raw is Map) {
      items = (raw['responses'] ?? raw['items'] ?? raw['data'] ?? const []) as List? ?? const [];
    }
    return items.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ── Diplomas ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> listDiplomas() async {
    final raw = await _api.getJson('/teacher/diplomas');
    if (raw is Map && raw['diplomas'] is List) {
      return (raw['diplomas'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> createDiploma(Map<String, dynamic> body) async {
    final raw = await _api.postJson('/teacher/diplomas', body: body);
    return raw is Map ? Map<String, dynamic>.from(raw) : {};
  }

  Future<void> updateDiploma(String id, Map<String, dynamic> body) async {
    await _api.patchJson('/teacher/diplomas/$id', body: body);
  }

  Future<void> deleteDiploma(String id) async {
    await _api.deleteJson('/teacher/diplomas/$id');
  }

  // Returns all students at the teacher's school.
  Future<List<TeacherStudentWithLevel>> fetchAllStudents() async {
    final byId = <String, TeacherStudentWithLevel>{};

    // Primary: school-wide student list
    try {
      final raw = await _api.getJson('/teacher/school-students');
      final list = raw is Map && raw['students'] is List
          ? (raw['students'] as List).whereType<Map>().toList()
          : <Map>[];
      for (final s in list) {
        final id = (s['studentId'] ?? '').toString();
        if (id.isEmpty) continue;
        final gradeVal = s['grade'];
        byId[id] = TeacherStudentWithLevel(
          studentId: id,
          name: (s['name'] ?? '').toString(),
          email: (s['email'] ?? '').toString(),
          gradeLevel: gradeVal is int ? gradeVal : int.tryParse('${gradeVal ?? ''}'),
          cohortId: (s['cohortId'] ?? '').toString(),
          cohortName: (s['cohortName'] ?? '').toString(),
          subjects: const [],
          coursesBySubject: const {},
        );
      }
    } catch (_) {}

    // Fallback: school-wide directory (works even when cohort linkage is missing)
    if (byId.isEmpty) {
      try {
        final raw = await _api.getJson('/messages/people/same-school');
        final items = raw is Map && raw['items'] is List ? raw['items'] as List : const <dynamic>[];
        for (final item in items) {
          if (item is! Map) continue;
          final role = (item['role'] ?? '').toString().toLowerCase();
          if (role != 'student') continue;
          final id = (item['userId'] ?? item['id'] ?? '').toString();
          if (id.isEmpty || byId.containsKey(id)) continue;
          byId[id] = TeacherStudentWithLevel(
            studentId: id,
            name: (item['displayName'] ?? item['name'] ?? '').toString(),
            email: '',
            gradeLevel: null,
            cohortId: '',
            cohortName: (item['gradeLabel'] ?? '').toString(),
            subjects: const [],
            coursesBySubject: const {},
          );
        }
      } catch (_) {}
    }

    final list = byId.values.toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) => value is List ? value : const <dynamic>[];

String _asString(dynamic value) => (value ?? '').toString().trim();

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse((value ?? '').toString()) ?? 0;
}

class TeacherTodaySchedule {
  const TeacherTodaySchedule({
    required this.date,
    required this.dayOfWeek,
    required this.slots,
  });

  final String date;
  final int dayOfWeek;
  final List<TeacherTodaySlot> slots;
}

class TeacherTodaySlot {
  const TeacherTodaySlot({
    required this.period,
    required this.source,
    required this.cohort,
    required this.course,
  });

  factory TeacherTodaySlot.fromJson(Map<String, dynamic> json) {
    final cohortMap = _asMap(json['cohort']);
    final courseMap = _asMap(json['course']);
    return TeacherTodaySlot(
      period: _asInt(json['period']),
      source: _asString(json['source']),
      cohort: cohortMap.isEmpty ? null : TeacherCohort.fromJson(cohortMap),
      course: courseMap.isEmpty ? null : TeacherCourse.fromJson(courseMap),
    );
  }

  final int period;
  final String source;
  final TeacherCohort? cohort;
  final TeacherCourse? course;
}

class TeacherCohort {
  const TeacherCohort({required this.id, required this.name, required this.grade});

  factory TeacherCohort.fromJson(Map<String, dynamic> json) {
    return TeacherCohort(
      id: _asString(json['id']),
      name: _asString(json['name']),
      grade: _asInt(json['grade']),
    );
  }

  final String id;
  final String name;
  final int grade;
}

class TeacherCourse {
  const TeacherCourse({
    required this.id,
    required this.name,
    required this.subject,
    required this.cohortId,
    this.cohort,
  });

  factory TeacherCourse.fromJson(Map<String, dynamic> json) {
    final cohortMap = _asMap(json['cohort']);
    return TeacherCourse(
      id: _asString(json['id']),
      name: _asString(json['name']),
      subject: _asString(json['subject']),
      cohortId: _asString(json['cohortId']),
      cohort: cohortMap.isEmpty ? null : TeacherCohort.fromJson(cohortMap),
    );
  }

  final String id;
  final String name;
  final String subject;
  final String cohortId;
  final TeacherCohort? cohort;

  String get displayName {
    final grade = cohort?.grade;
    final cohortName = cohort?.name ?? '';
    if (grade != null && grade > 0) return '$subject — Grade $grade ($cohortName)';
    if (cohortName.isNotEmpty) return '$subject — $cohortName';
    return name.isNotEmpty ? name : subject;
  }
}

class TeacherAssessmentBundle {
  const TeacherAssessmentBundle({required this.courses, required this.assessments});

  final List<TeacherCourse> courses;
  final List<TeacherAssessment> assessments;
}

class TeacherAssessment {
  const TeacherAssessment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.date,
    required this.maxGrade,
    this.published = false,
    this.attachments = const [],
  });

  factory TeacherAssessment.fromJson(Map<String, dynamic> json) {
    final rawAttachments = json['attachments'];
    return TeacherAssessment(
      id: _asString(json['id']),
      courseId: _asString(json['courseId']),
      title: _asString(json['title']),
      date: _asString(json['date']),
      maxGrade: json['maxGrade'] == null ? null : _asInt(json['maxGrade']),
      published: json['published'] == true,
      attachments: rawAttachments is List
          ? rawAttachments.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList()
          : const [],
    );
  }

  final String id;
  final String courseId;
  final String title;
  final String date;
  final int? maxGrade;
  final bool published;
  final List<Map<String, dynamic>> attachments;
}

class TeacherAttendanceSession {
  const TeacherAttendanceSession({
    required this.cohort,
    required this.date,
    required this.period,
    required this.course,
    required this.students,
    this.classNote = '',
  });

  final TeacherCohort cohort;
  final String date;
  final int period;
  final TeacherCourse course;
  final List<TeacherAttendanceStudent> students;
  final String classNote;
}

class TeacherAttendanceStudent {
  const TeacherAttendanceStudent({
    required this.studentId,
    required this.name,
    required this.status,
    required this.note,
  });

  factory TeacherAttendanceStudent.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceStudent(
      studentId: _asString(json['studentId']),
      name: _asString(json['name']),
      status: _asString(json['status']).isEmpty ? 'PRESENT' : _asString(json['status']),
      note: _asString(json['note']),
    );
  }

  final String studentId;
  final String name;
  final String status;
  final String note;
}

class TeacherAttendanceDraftRecord {
  const TeacherAttendanceDraftRecord({
    required this.studentId,
    required this.status,
    required this.note,
  });

  final String studentId;
  final String status;
  final String note;
}

class TeacherAttendanceSessionSummary {
  const TeacherAttendanceSessionSummary({
    required this.id,
    required this.date,
    required this.period,
    required this.courseName,
    required this.subject,
    required this.cohortId,
    required this.cohortName,
    required this.grade,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.excusedCount,
    this.classNote,
  });

  factory TeacherAttendanceSessionSummary.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceSessionSummary(
      id: _asString(json['id']),
      date: _asString(json['date']),
      period: _asInt(json['period']),
      courseName: _asString(json['courseName']),
      subject: _asString(json['subject']),
      cohortId: _asString(json['cohortId']),
      cohortName: _asString(json['cohortName']),
      grade: json['grade'] is num ? (json['grade'] as num).toInt() : null,
      totalStudents: _asInt(json['totalStudents']),
      presentCount: _asInt(json['presentCount']),
      absentCount: _asInt(json['absentCount']),
      lateCount: _asInt(json['lateCount']),
      excusedCount: _asInt(json['excusedCount']),
      classNote: json['classNote'] as String?,
    );
  }

  final String id;
  final String date;
  final int period;
  final String courseName;
  final String subject;
  final String cohortId;
  final String cohortName;
  final int? grade;
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final String? classNote;
}

class TeacherStudent {
  const TeacherStudent({required this.studentId, required this.name, required this.email});

  factory TeacherStudent.fromJson(Map<String, dynamic> json) {
    return TeacherStudent(
      studentId: _asString(json['studentId']),
      name: _asString(json['name']),
      email: _asString(json['email']),
    );
  }

  final String studentId;
  final String name;
  final String email;
}

class TeacherJoinCode {
  const TeacherJoinCode({required this.cohortId, required this.code, required this.expiresAt});

  factory TeacherJoinCode.fromJson(Map<String, dynamic> json) {
    return TeacherJoinCode(
      cohortId: _asString(json['cohortId']),
      code: _asString(json['code']),
      expiresAt: _asString(json['expiresAt']),
    );
  }

  final String cohortId;
  final String code;
  final String expiresAt;
}

class TeacherAssessmentGrade {
  const TeacherAssessmentGrade({required this.studentId, required this.grade});

  factory TeacherAssessmentGrade.fromJson(Map<String, dynamic> json) {
    return TeacherAssessmentGrade(
      studentId: _asString(json['studentId']),
      grade: json['grade'] == null ? null : _asInt(json['grade']),
    );
  }

  final String studentId;
  final int? grade;
}

class TeacherGradeDraftRecord {
  const TeacherGradeDraftRecord({required this.studentId, required this.grade});

  final String studentId;
  final int grade;
}

class TeacherStudentWithLevel {
  const TeacherStudentWithLevel({
    required this.studentId,
    required this.name,
    required this.email,
    required this.gradeLevel,
    required this.cohortId,
    required this.cohortName,
    required this.subjects,
    required this.coursesBySubject,
  });

  final String studentId;
  final String name;
  final String email;
  final int? gradeLevel;
  final String cohortId;
  final String cohortName;
  final List<String> subjects;
  final Map<String, String> coursesBySubject; // subject → courseId
}