import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/http/cm_api.dart';

final studentsHubApiProvider = Provider<StudentsHubApi>((ref) {
  final session = ref.watch(authSessionProvider);
  return StudentsHubApi(token: (session.token ?? '').trim());
});

final hubStudentsProvider =
    FutureProvider.autoDispose<List<HubStudent>>((ref) {
  return ref.watch(studentsHubApiProvider).fetchStudents();
});

final hubInsightsProvider = FutureProvider.autoDispose
    .family<HubInsights, String>((ref, id) {
  return ref.watch(studentsHubApiProvider).fetchInsights(id);
});

final hubGradesProvider = FutureProvider.autoDispose
    .family<List<HubSubjectGrades>, String>((ref, id) {
  return ref.watch(studentsHubApiProvider).fetchGrades(id);
});

final hubProfileProvider = FutureProvider.autoDispose
    .family<HubProfile, String>((ref, id) {
  return ref.watch(studentsHubApiProvider).fetchProfile(id);
});

class HubStudent {
  const HubStudent({
    required this.studentId,
    required this.name,
    this.grade,
    this.cohortName,
  });
  final String studentId;
  final String name;
  final int? grade;
  final String? cohortName;
}

class HubInsights {
  const HubInsights({
    this.gradeAverage,
    this.gradeCount = 0,
    this.bestSubject,
    this.weakestSubject,
    this.attendanceRate,
    this.present = 0,
    this.absent = 0,
    this.late = 0,
    this.practiceAccuracy,
    this.practiceAttempts = 0,
    this.weakTopics = const [],
    this.strongTopics = const [],
  });

  final num? gradeAverage;
  final int gradeCount;
  final String? bestSubject;
  final String? weakestSubject;
  final num? attendanceRate;
  final int present;
  final int absent;
  final int late;
  final num? practiceAccuracy;
  final int practiceAttempts;
  final List<String> weakTopics;
  final List<String> strongTopics;
}

class HubGradeRow {
  const HubGradeRow({
    required this.title,
    required this.grade,
    required this.maxGrade,
    required this.published,
    this.date,
    this.comment,
  });
  final String title;
  final num grade;
  final num maxGrade;
  final bool published;
  final DateTime? date;
  final String? comment;
}

class HubSubjectGrades {
  const HubSubjectGrades({
    required this.subject,
    this.average,
    this.grades = const [],
  });
  final String subject;
  final num? average;
  final List<HubGradeRow> grades;
}

class HubParent {
  const HubParent({required this.name, this.email, this.phone});
  final String name;
  final String? email;
  final String? phone;
}

class HubProfile {
  const HubProfile({
    required this.name,
    this.email,
    this.gradeAverage,
    this.attendanceRate,
    this.parents = const [],
  });
  final String name;
  final String? email;
  final num? gradeAverage;
  final num? attendanceRate;
  final List<HubParent> parents;
}

class StudentsHubApi {
  const StudentsHubApi({this.token = ''});

  final String token;

  CMApi get _api => CMApi(token: token);

  Future<List<HubStudent>> fetchStudents() async {
    final raw = await _api.getJson('/teacher/school-students');
    final list = (raw is Map ? raw['students'] : null) as List? ?? const [];
    return list
        .whereType<Map>()
        .map((s) => HubStudent(
              studentId: '${s['studentId'] ?? ''}',
              name: '${s['name'] ?? ''}',
              grade: (s['grade'] as num?)?.toInt(),
              cohortName: s['cohortName'] as String?,
            ))
        .toList();
  }

  Future<HubInsights> fetchInsights(String studentId) async {
    final raw = await _api.getJson('/teacher/students/$studentId/insights');
    final m = raw is Map ? raw : const {};
    final grades = m['grades'] is Map ? m['grades'] as Map : const {};
    final att = m['attendance'] is Map ? m['attendance'] as Map : const {};
    final pr = m['practice'] is Map ? m['practice'] as Map : const {};
    List<String> topics(dynamic v) => (v as List? ?? const [])
        .map((e) => e is Map ? '${e['topic'] ?? e['name'] ?? ''}' : '$e')
        .where((e) => e.isNotEmpty)
        .cast<String>()
        .toList();
    return HubInsights(
      gradeAverage: grades['average'] as num?,
      gradeCount: (grades['count'] as num?)?.toInt() ?? 0,
      bestSubject: grades['bestSubject'] is Map
          ? '${(grades['bestSubject'] as Map)['subject'] ?? ''}'
          : grades['bestSubject'] as String?,
      weakestSubject: grades['weakestSubject'] is Map
          ? '${(grades['weakestSubject'] as Map)['subject'] ?? ''}'
          : grades['weakestSubject'] as String?,
      attendanceRate: att['attendanceRate'] as num?,
      present: (att['present'] as num?)?.toInt() ?? 0,
      absent: (att['absent'] as num?)?.toInt() ?? 0,
      late: (att['late'] as num?)?.toInt() ?? 0,
      practiceAccuracy: pr['overallAccuracy'] as num?,
      practiceAttempts: (pr['totalAttempts'] as num?)?.toInt() ?? 0,
      weakTopics: topics(pr['weakTopics']),
      strongTopics: topics(pr['strongestTopics']),
    );
  }

  Future<List<HubSubjectGrades>> fetchGrades(String studentId) async {
    final raw = await _api.getJson('/teacher/students/$studentId/grades');
    final list = (raw is Map ? raw['subjects'] : null) as List? ?? const [];
    return list
        .whereType<Map>()
        .map((s) => HubSubjectGrades(
              subject: '${s['subject'] ?? ''}',
              average: s['average'] as num?,
              grades: (s['grades'] as List? ?? const [])
                  .whereType<Map>()
                  .map((g) => HubGradeRow(
                        title: '${g['title'] ?? ''}',
                        grade: (g['grade'] as num?) ?? 0,
                        maxGrade: (g['maxGrade'] as num?) ?? 100,
                        published: g['published'] != false,
                        date: DateTime.tryParse('${g['date'] ?? ''}'),
                        comment: g['comment'] as String?,
                      ))
                  .toList(),
            ))
        .toList();
  }

  Future<HubProfile> fetchProfile(String studentId) async {
    final results = await Future.wait([
      _api.getJson('/teacher/student/$studentId/profile'),
      _api.getJson('/teacher/students/$studentId/parents'),
    ]);
    final prof = results[0] is Map ? results[0] as Map : const {};
    final par = results[1] is Map ? results[1] as Map : const {};
    final student = prof['student'] is Map ? prof['student'] as Map : const {};
    return HubProfile(
      name: '${student['name'] ?? ''}',
      email: student['email'] as String?,
      gradeAverage: prof['gradeAverage'] as num?,
      attendanceRate: prof['attendanceRate'] as num?,
      parents: (par['parents'] as List? ?? const [])
          .whereType<Map>()
          .map((p) => HubParent(
                name: '${p['name'] ?? ''}',
                email: p['email'] as String?,
                phone: p['phone'] as String?,
              ))
          .toList(),
    );
  }
}
