import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../classrooms/providers/classrooms_repo_provider.dart';
import '../domain/exam_models.dart';

const _examsCacheTtl = Duration(minutes: 2);
DateTime? _examsCachedAt;
List<StudentExamItem>? _examsCachedItems;
Future<List<StudentExamItem>>? _examsInflight;

final examsRepositoryProvider = Provider<StudentExamsRepository>((ref) {
  return const StudentExamsRepository();
});

// ── Live provider — merges /student/exams (new) with /student/assessments ────

final examsLiveProvider = FutureProvider<List<StudentExamItem>>((ref) async {
  final now = DateTime.now();
  if (_examsCachedAt != null &&
      _examsCachedItems != null &&
      now.difference(_examsCachedAt!) < _examsCacheTtl) {
    return _examsCachedItems!;
  }

  if (_examsInflight != null) return _examsInflight!;

  final repo = ref.read(classroomsRepoProvider);

  final future = Future.wait<List<StudentExamItem>>([
    // The canonical endpoint — only published TeacherExam records that target
    // this student. Ghost exams (deleted or unpublished) never appear here.
    repo.studentTeacherExams().then((raw) => raw.map(_mapToExamItem).toList()).catchError((_) => <StudentExamItem>[]),
  ]).then((lists) {
    // Merge and deduplicate by id.
    final seen = <String>{};
    final merged = <StudentExamItem>[];
    for (final list in lists) {
      for (final item in list) {
        if (seen.add(item.id)) merged.add(item);
      }
    }
    // Sort: today first, then upcoming, then past
    merged.sort((a, b) {
      final da = DateTime.tryParse(a.dateLabel);
      final db = DateTime.tryParse(b.dateLabel);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });
    _examsCachedItems = merged;
    _examsCachedAt = DateTime.now();
    return merged;
  });

  _examsInflight = future;
  try {
    return await future;
  } finally {
    _examsInflight = null;
  }
});

StudentExamItem _mapToExamItem(Map<String, dynamic> j) {
  String str(List<String> keys, [String fallback = '']) {
    for (final k in keys) {
      final v = (j[k]?.toString() ?? '').trim();
      if (v.isNotEmpty) return v;
    }
    return fallback;
  }

  String? opt(List<String> keys) {
    for (final k in keys) {
      final v = (j[k]?.toString() ?? '').trim();
      if (v.isNotEmpty) return v;
    }
    return null;
  }

  int? intOpt(List<String> keys) {
    for (final k in keys) {
      final v = j[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      final parsed = int.tryParse((v ?? '').toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  // Backend returns 'attachments' (TeacherExam.attachments JSON); some legacy
  // exam shapes also used 'materials'. Check both so neither source is dropped.
  final rawMaterials = (j['attachments'] is List && (j['attachments'] as List).isNotEmpty)
      ? j['attachments'] as List
      : (j['materials'] is List ? j['materials'] as List : const []);
  final materials = rawMaterials
        .whereType<Map>()
        .map((m) {
          final mi = m.map((k, v) => MapEntry(k.toString(), v));
          return ExamMaterialItem(
            id: (mi['id'] ?? 'mat-${mi.hashCode}').toString(),
            name: (mi['name'] ?? mi['title'] ?? mi['fileName'] ?? mi['filename'] ?? 'Attachment').toString(),
            kind: (mi['kind'] ?? mi['type'] ?? mi['mimeType'] ?? 'file').toString(),
            url: (mi['url'] ?? mi['fileUrl'] ?? mi['link'] ?? '').toString().trim().isNotEmpty
                ? (mi['url'] ?? mi['fileUrl'] ?? mi['link']).toString().trim()
                : null,
          );
        })
        .toList(growable: false);

  final audienceRaw = str(['audienceType']).toUpperCase();
  final audienceType = audienceRaw.contains('MAJOR')
      ? ExamAudienceType.majorGroup
      : audienceRaw.contains('GRADE')
      ? ExamAudienceType.gradeGroup
      : ExamAudienceType.classGroup;

  return StudentExamItem(
    id: str(['id'], 'exam-${j.hashCode}'),
    subject: str(['subject', 'courseName', 'courseSubject']),
    topic: opt(['topic', 'topicLabel', 'chapter']),
    title: str(['title', 'name', 'assessmentTitle'], 'Assessment'),
    caption: opt(['description', 'caption', 'body', 'notes']),
    dateLabel: str(['scheduledAt', 'date', 'dueAt', 'examDate']),
    hourLabel: opt(['hour', 'time', 'startTime']),
    periodLabel: opt(['period', 'periodLabel']),
    durationLabel: opt(['duration', 'durationLabel']),
    teacher: str(['teacher', 'teacherName', 'instructor']),
    audience: ExamAudience(
      type: audienceType,
      label: str(['audienceLabel', 'audience', 'audienceGroup'], 'Class'),
    ),
    materials: materials,
    grade: intOpt(['grade']),
    maxGrade: intOpt(['maxGrade']),
  );
}

// ─────────────────────────────────────────────────────────────────────────────


class StudentExamsRepository {
  const StudentExamsRepository();

  List<StudentExamItem> list() => const <StudentExamItem>[];

  StudentExamItem? byId(String id) => null;
}
