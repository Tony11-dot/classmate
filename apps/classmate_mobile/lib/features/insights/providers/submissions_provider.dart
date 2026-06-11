import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../classrooms/providers/classrooms_repo_provider.dart';

/// On-time submission performance, computed from the student's teacher-wide
/// assignments (`/student/assignments`). This is intentionally derived on the
/// client from data we already fetch elsewhere, so no new endpoint is needed.
class SubmissionStats {
  const SubmissionStats({
    required this.total,
    required this.submitted,
    required this.onTime,
    required this.late,
    required this.pending,
    required this.missed,
  });

  /// Assignments that have a due date (the ones we can judge timeliness on).
  final int total;
  final int submitted;
  final int onTime;
  final int late;

  /// Not handed in yet, due date still in the future.
  final int pending;

  /// Not handed in and the due date has passed.
  final int missed;

  /// Of everything handed in, the share that was on time (0–100).
  double? get onTimeRate =>
      submitted == 0 ? null : (onTime / submitted) * 100.0;

  /// Of everything assigned, the share handed in on time (0–100).
  double? get reliabilityRate =>
      total == 0 ? null : (onTime / total) * 100.0;

  static const empty = SubmissionStats(
    total: 0,
    submitted: 0,
    onTime: 0,
    late: 0,
    pending: 0,
    missed: 0,
  );
}

final submissionStatsProvider = FutureProvider<SubmissionStats>((ref) async {
  final repo = ref.watch(classroomsRepoProvider);

  List<Map<String, dynamic>> items;
  try {
    items = await repo.allStudentAssignments();
  } catch (_) {
    return SubmissionStats.empty;
  }

  DateTime? parseDate(Object? v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString())?.toLocal();
  }

  final now = DateTime.now();
  var total = 0;
  var submitted = 0;
  var onTime = 0;
  var late = 0;
  var pending = 0;
  var missed = 0;

  for (final item in items) {
    final due = parseDate(item['dueAt']);
    // Only assignments with a due date can be judged for timeliness.
    if (due == null) continue;
    total += 1;

    final isSubmitted = item['submitted'] == true ||
        (item['submittedAt'] != null &&
            (item['status']?.toString().toUpperCase() != 'RETURNED'));
    final submittedAt = parseDate(item['submittedAt']);

    if (isSubmitted) {
      submitted += 1;
      if (submittedAt == null || !submittedAt.isAfter(due)) {
        onTime += 1;
      } else {
        late += 1;
      }
    } else {
      if (due.isAfter(now)) {
        pending += 1;
      } else {
        missed += 1;
      }
    }
  }

  return SubmissionStats(
    total: total,
    submitted: submitted,
    onTime: onTime,
    late: late,
    pending: pending,
    missed: missed,
  );
});
