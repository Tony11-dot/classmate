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
  });

  factory TeacherCourse.fromJson(Map<String, dynamic> json) {
    return TeacherCourse(
      id: _asString(json['id']),
      name: _asString(json['name']),
      subject: _asString(json['subject']),
      cohortId: _asString(json['cohortId']),
    );
  }

  final String id;
  final String name;
  final String subject;
  final String cohortId;
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