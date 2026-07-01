import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/http/cm_api.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class CertCohort {
  const CertCohort({required this.id, required this.name, this.grade});
  final String id;
  final String name;
  final int? grade;
  factory CertCohort.fromJson(Map<String, dynamic> j) => CertCohort(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        grade: j['grade'] is int ? j['grade'] as int : int.tryParse('${j['grade']}'),
      );
}

class CertStudent {
  const CertStudent({required this.id, required this.name});
  final String id;
  final String name;
  factory CertStudent.fromJson(Map<String, dynamic> j) =>
      CertStudent(id: (j['id'] ?? '').toString(), name: (j['name'] ?? '').toString());
}

class CertSubjectRow {
  const CertSubjectRow({
    required this.subject,
    required this.i18n,
    required this.units,
    required this.semesters,
    required this.finalAvg,
    this.teachers = const [],
  });
  final String subject;
  final Map<String, dynamic>? i18n;
  final int units;
  final List<int?> semesters; // per-semester average (null = none)
  final int? finalAvg;
  final List<String> teachers; // subject teacher(s), from the schedule

  /// Localized display name for [lang] ('en','ar','he','fr','ru','ps'), falling
  /// back through English then the raw subject string.
  String display(String lang) {
    final m = i18n;
    if (m != null) {
      final key = {
            'en': 'nameEn',
            'ar': 'nameAr',
            'he': 'nameHe',
            'fr': 'nameFr',
            'ru': 'nameRu',
            'ps': 'nameAr', // Pashto uses Arabic-script names when present
          }[lang] ??
          'nameEn';
      final v = (m[key] ?? m['nameEn'])?.toString();
      if (v != null && v.trim().isNotEmpty) return v;
    }
    return subject;
  }

  factory CertSubjectRow.fromJson(Map<String, dynamic> j) => CertSubjectRow(
        subject: (j['subject'] ?? '').toString(),
        i18n: j['i18n'] is Map ? Map<String, dynamic>.from(j['i18n'] as Map) : null,
        units: j['units'] is int ? j['units'] as int : int.tryParse('${j['units']}') ?? 0,
        semesters: (j['semesters'] as List? ?? [])
            .map((e) => e == null ? null : (e is int ? e : int.tryParse('$e')))
            .toList(),
        finalAvg: j['final'] == null ? null : (j['final'] is int ? j['final'] as int : int.tryParse('${j['final']}')),
        teachers: (j['teachers'] as List? ?? []).map((e) => '$e').where((s) => s.isNotEmpty).toList(),
      );
}

class CertPrefill {
  CertPrefill({
    required this.schoolName,
    required this.schoolLogoUrl,
    required this.schoolYear,
    required this.semesterCount,
    required this.semesterWeights,
    required this.defaultHomeroomTeacher,
    required this.defaultPrincipalName,
    required this.cohorts,
    required this.teacherNames,
    required this.principalNames,
    required this.student,
    required this.studentNationalId,
    required this.subjects,
    required this.overall,
    required this.absences,
    required this.lates,
  });
  final String schoolName;
  final String? schoolLogoUrl;
  final String schoolYear;
  final int semesterCount;
  final List<int> semesterWeights;
  final String defaultHomeroomTeacher;
  final String defaultPrincipalName;
  final List<CertCohort> cohorts;
  final List<String> teacherNames;
  final List<String> principalNames;
  final CertStudent? student;
  final String? studentNationalId;
  final List<CertSubjectRow> subjects;
  final int? overall;
  final int absences;
  final int lates;

  factory CertPrefill.fromJson(Map<String, dynamic> j) {
    final student = j['student'] is Map ? Map<String, dynamic>.from(j['student'] as Map) : null;
    final att = j['attendance'] is Map ? Map<String, dynamic>.from(j['attendance'] as Map) : const {};
    return CertPrefill(
      schoolName: (j['schoolName'] ?? '').toString(),
      schoolLogoUrl: j['schoolLogoUrl']?.toString(),
      schoolYear: (j['schoolYear'] ?? '').toString(),
      semesterCount: j['semesterCount'] is int ? j['semesterCount'] as int : int.tryParse('${j['semesterCount']}') ?? 2,
      semesterWeights: (j['semesterWeights'] as List? ?? [])
          .map((e) => e is int ? e : int.tryParse('$e') ?? 0)
          .toList(),
      defaultHomeroomTeacher: (j['defaultHomeroomTeacher'] ?? '').toString(),
      defaultPrincipalName: (j['defaultPrincipalName'] ?? '').toString(),
      cohorts: (j['cohorts'] as List? ?? [])
          .map((e) => CertCohort.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      teacherNames: (j['teacherNames'] as List? ?? []).map((e) => '$e').toList(),
      principalNames: (j['principalNames'] as List? ?? []).map((e) => '$e').toList(),
      student: student == null ? null : CertStudent.fromJson(student),
      studentNationalId: student?['nationalId']?.toString(),
      subjects: (j['subjects'] as List? ?? [])
          .map((e) => CertSubjectRow.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      overall: j['overall'] == null ? null : (j['overall'] is int ? j['overall'] as int : int.tryParse('${j['overall']}')),
      absences: att['absences'] is int ? att['absences'] as int : int.tryParse('${att['absences']}') ?? 0,
      lates: att['lates'] is int ? att['lates'] as int : int.tryParse('${att['lates']}') ?? 0,
    );
  }
}

// ── Repository ────────────────────────────────────────────────────────────────

final certificatesRepositoryProvider = Provider<CertificatesRepository>((ref) {
  final token = (ref.watch(authSessionProvider).token ?? '').trim();
  return CertificatesRepository(token: token);
});

class CertificatesRepository {
  CertificatesRepository({required this.token});
  final String token;
  CMApi get _api => CMApi(token: token);

  Map<String, dynamic> _m(dynamic raw) => raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  List<dynamic> _l(dynamic raw) => raw is List ? raw : const [];

  Future<List<CertCohort>> cohorts() async {
    final raw = await _api.getJson('/certificates/cohorts');
    return _l(_m(raw)['cohorts']).map((e) => CertCohort.fromJson(_m(e))).toList();
  }

  Future<List<CertStudent>> students(String cohortId) async {
    final raw = await _api.getJson('/certificates/students', query: {'cohortId': cohortId});
    return _l(_m(raw)['students']).map((e) => CertStudent.fromJson(_m(e))).toList();
  }

  Future<CertPrefill> prefill(String cohortId, {String? studentId, List<int>? semesterWeights}) async {
    final raw = await _api.getJson('/certificates/prefill', query: {
      'cohortId': cohortId,
      'studentId': ?studentId,
      if (semesterWeights != null && semesterWeights.isNotEmpty) 'semesterWeights': semesterWeights.join(','),
    });
    return CertPrefill.fromJson(_m(raw));
  }

  Future<void> create(Map<String, dynamic> body) async {
    await _api.postJson('/certificates', body: body);
  }

  Future<List<Map<String, dynamic>>> list({String? cohortId}) async {
    final raw = await _api.getJson('/certificates', query: {'cohortId': ?cohortId});
    return _l(_m(raw)['certificates']).map((e) => _m(e)).toList();
  }
}
