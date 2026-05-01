import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<TeacherAssessmentBundle> fetchAssessments() async {
    final raw = await _api.getJson('/teacher/grades/assessments');
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
  }) async {
    await _api.postJson(
      '/teacher/attendance/bulk',
      body: <String, dynamic>{
        'cohortId': cohortId,
        'date': date,
        'period': period,
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

  Future<List<TeacherAssessmentGrade>> fetchAssessmentGrades(String assessmentId) async {
    final raw = await _api.getJson('/teacher/assessments/$assessmentId/grades');
    final map = _asMap(raw);
    return _asList(map['grades'])
        .map((item) => TeacherAssessmentGrade.fromJson(_asMap(item)))
        .toList(growable: false);
  }

  Future<void> createAssessment({
    required String courseId,
    required String title,
    required String date,
    int? maxGrade,
  }) async {
    await _api.postJson(
      '/teacher/grades/assessment',
      body: <String, dynamic>{
        'courseId': courseId,
        'title': title.trim(),
        'date': date.trim().isEmpty ? null : date.trim(),
        'maxGrade': maxGrade,
      },
    );
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
          final cohortMap = _asMap(m['cohort']);
          return TeacherCourse(
            id: _asString(m['id']),
            name: _asString(m['name']),
            subject: _asString(m['subject']),
            cohortId: _asString(m['cohortId']),
            cohort: cohortMap.isEmpty ? null : TeacherCohort.fromJson(cohortMap),
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
  }) async {
    await _api.postJson(
      '/teacher/classrooms/$courseId/assignments',
      body: <String, dynamic>{
        'title': title.trim(),
        if ((body ?? '').trim().isNotEmpty) 'body': body!.trim(),
        if ((dueAt ?? '').trim().isNotEmpty) 'dueAt': dueAt!.trim(),
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
    final raw = await _api.getJson('/teacher/classrooms/$courseId/people');
    return _asMap(raw);
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
    String? targetRole,
    String? targetCohortId,
    bool pinned = false,
  }) async {
    await _api.postJson(
      '/announcements',
      body: <String, dynamic>{
        'title': title.trim(),
        'body': body.trim(),
        'pinned': pinned,
        if ((targetRole ?? '').isNotEmpty) 'targets': [<String, dynamic>{'role': targetRole}],
        if ((targetCohortId ?? '').isNotEmpty) 'targets': [<String, dynamic>{'cohortId': targetCohortId}],
      },
    );
  }

  Future<TeacherAttendanceSession> fetchAttendanceSessionForDate({
    required String cohortId,
    required String date,
    required int period,
  }) async {
    final raw = await _api.getJson(
      '/teacher/attendance/history',
      query: <String, String>{'cohortId': cohortId, 'date': date, 'period': '$period'},
    );
    final map = _asMap(raw);
    return TeacherAttendanceSession(
      cohort: TeacherCohort.fromJson(_asMap(map['cohort'])),
      date: _asString(map['date']),
      period: _asInt(map['period']),
      course: TeacherCourse.fromJson(_asMap(map['course'])),
      students: _asList(map['students'])
          .map((item) => TeacherAttendanceStudent.fromJson(_asMap(item)))
          .toList(growable: false),
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
    if (raw is Map && raw['responses'] is List) {
      return (raw['responses'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
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

  Future<void> deleteDiploma(String id) async {
    await _api.deleteJson('/teacher/diplomas/$id');
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
  });

  factory TeacherAssessment.fromJson(Map<String, dynamic> json) {
    return TeacherAssessment(
      id: _asString(json['id']),
      courseId: _asString(json['courseId']),
      title: _asString(json['title']),
      date: _asString(json['date']),
      maxGrade: json['maxGrade'] == null ? null : _asInt(json['maxGrade']),
    );
  }

  final String id;
  final String courseId;
  final String title;
  final String date;
  final int? maxGrade;
}

class TeacherAttendanceSession {
  const TeacherAttendanceSession({
    required this.cohort,
    required this.date,
    required this.period,
    required this.course,
    required this.students,
  });

  final TeacherCohort cohort;
  final String date;
  final int period;
  final TeacherCourse course;
  final List<TeacherAttendanceStudent> students;
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