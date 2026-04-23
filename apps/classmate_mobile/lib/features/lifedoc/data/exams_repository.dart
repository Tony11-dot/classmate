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

// ── Live provider (hits /student/assessments) ────────────────────────────────

final examsLiveProvider = FutureProvider<List<StudentExamItem>>((
  ref,
) async {
  final now = DateTime.now();
  final cachedAt = _examsCachedAt;
  final cachedItems = _examsCachedItems;
  if (cachedAt != null &&
      cachedItems != null &&
      now.difference(cachedAt) < _examsCacheTtl) {
    return cachedItems;
  }

  final inflight = _examsInflight;
  if (inflight != null) {
    return inflight;
  }

  final repo = ref.read(classroomsRepoProvider);
  final future = repo.studentAssessments().then((raw) {
    final mapped = raw.map(_mapToExamItem).toList(growable: false);
    _examsCachedItems = mapped;
    _examsCachedAt = DateTime.now();
    return mapped;
  }).onError((err, st) {
    // If the endpoint is unavailable, return empty list gracefully
    _examsCachedItems = const <StudentExamItem>[];
    _examsCachedAt = DateTime.now();
    return const <StudentExamItem>[];
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

  final rawMaterials = j['materials'];
  final materials = rawMaterials is List
      ? rawMaterials
            .whereType<Map>()
            .map((m) {
              final mi = m.map((k, v) => MapEntry(k.toString(), v));
              return ExamMaterialItem(
                id: str(['id'], 'mat-${mi.hashCode}'),
                name: str(['name', 'title', 'filename'], 'Material'),
                kind: str(['kind', 'type', 'mimeType'], 'File'),
                url: opt(['url', 'fileUrl', 'link']),
              );
            })
            .toList(growable: false)
      : const <ExamMaterialItem>[];

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
  );
}

// ─────────────────────────────────────────────────────────────────────────────


class StudentExamsRepository {
  const StudentExamsRepository();

  List<StudentExamItem> list() => const <StudentExamItem>[];

  StudentExamItem? byId(String id) => null;
}
