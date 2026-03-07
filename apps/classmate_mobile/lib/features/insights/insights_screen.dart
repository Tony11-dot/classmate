import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/insights_providers.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(insightsSnapshotProvider);
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(insightsSnapshotProvider);
        await ref.read(insightsSnapshotProvider.future);
      },
      child: asyncValue.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: const [
            SizedBox(
              height: 140,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _StateCard(
              icon: Icons.insights_outlined,
              title: 'Could not load insights',
              subtitle: '$error',
              action: FilledButton.icon(
                onPressed: () => ref.invalidate(insightsSnapshotProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
        data: (data) {
          final gradesMap = _map(data['grades']);
          final attendanceMap = _map(data['attendance']);

          final grades = _list(gradesMap['grades']);
          final attendance = _list(attendanceMap['items']);

          final presentCount = attendance
              .where((e) => _statusOf(e) == 'PRESENT')
              .length;
          final absentCount = attendance
              .where((e) => _statusOf(e) == 'ABSENT')
              .length;
          final lateCount = attendance
              .where((e) => _statusOf(e) == 'LATE')
              .length;
          final excusedCount = attendance
              .where((e) => _statusOf(e) == 'EXCUSED')
              .length;

          final attendedBase =
              presentCount + absentCount + lateCount + excusedCount;
          final attendanceRate = attendedBase == 0
              ? null
              : ((presentCount + lateCount) / attendedBase) * 100.0;

          final numericGrades = grades
              .map((e) => _gradeValue(e))
              .whereType<double>()
              .toList(growable: false);

          final gradesAverage = numericGrades.isEmpty
              ? null
              : numericGrades.reduce((a, b) => a + b) / numericGrades.length;

          final recentGrades = [...grades]
            ..sort((a, b) {
              final ad =
                  DateTime.tryParse(_assessmentDate(a)) ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              final bd =
                  DateTime.tryParse(_assessmentDate(b)) ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              return bd.compareTo(ad);
            });

          final recentAttendance = [...attendance]
            ..sort((a, b) {
              final ad =
                  DateTime.tryParse(_attendanceDate(a)) ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              final bd =
                  DateTime.tryParse(_attendanceDate(b)) ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              return bd.compareTo(ad);
            });

          final emptyAll = grades.isEmpty && attendance.isEmpty;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primaryContainer.withValues(alpha: 0.95),
                      cs.surfaceContainerHigh.withValues(alpha: 0.95),
                    ],
                  ),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insights',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Attendance and grades overview from the last 30 days.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (emptyAll)
                _StateCard(
                  icon: Icons.insights_outlined,
                  title: 'No insights yet',
                  subtitle:
                      'Once attendance and grades start coming in, this screen will show your progress here.',
                  action: null,
                )
              else ...[
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.18,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _MetricCard(
                      icon: Icons.fact_check_rounded,
                      label: 'Attendance rate',
                      value: attendanceRate == null
                          ? '—'
                          : '${attendanceRate.toStringAsFixed(0)}%',
                      subtitle: attendedBase == 0
                          ? 'No attendance records'
                          : '$attendedBase records',
                    ),
                    _MetricCard(
                      icon: Icons.school_rounded,
                      label: 'Grades average',
                      value: gradesAverage == null
                          ? '—'
                          : gradesAverage.toStringAsFixed(1),
                      subtitle: grades.isEmpty
                          ? 'No grades yet'
                          : '${grades.length} grades',
                    ),
                    _MetricCard(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Present',
                      value: '$presentCount',
                      subtitle: lateCount > 0
                          ? '$lateCount late'
                          : 'On-time classes',
                    ),
                    _MetricCard(
                      icon: Icons.warning_amber_rounded,
                      label: 'Absent',
                      value: '$absentCount',
                      subtitle: excusedCount > 0
                          ? '$excusedCount excused'
                          : 'Missed classes',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  title: 'Recent grades',
                  icon: Icons.grade_rounded,
                  child: recentGrades.isEmpty
                      ? const _MiniEmpty(
                          title: 'No grades yet',
                          subtitle:
                              'Grades will appear here once teachers publish them.',
                        )
                      : Column(
                          children: [
                            for (final item in recentGrades.take(5)) ...[
                              _GradeRow(item: item),
                              if (item != recentGrades.take(5).last)
                                const Divider(height: 16),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Recent attendance',
                  icon: Icons.event_available_rounded,
                  child: recentAttendance.isEmpty
                      ? const _MiniEmpty(
                          title: 'No attendance yet',
                          subtitle:
                              'Attendance records will appear here once marked.',
                        )
                      : Column(
                          children: [
                            for (final item in recentAttendance.take(6)) ...[
                              _AttendanceRow(item: item),
                              if (item != recentAttendance.take(6).last)
                                const Divider(height: 16),
                            ],
                          ],
                        ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const Spacer(),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _GradeRow extends StatelessWidget {
  const _GradeRow({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final assessment = _map(item['assessment']);
    final course = _map(item['course']);
    final grade = _gradeValue(item);
    final title = (assessment['title'] ?? 'Assessment').toString();
    final subject = (course['subject'] ?? course['name'] ?? 'Course')
        .toString();
    final date = _friendlyDate(_assessmentDate(item));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            grade == null
                ? '—'
                : grade.toStringAsFixed(
                    grade.truncateToDouble() == grade ? 0 : 1,
                  ),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                '$subject · $date',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (((item['comment'] ?? '').toString().trim()).isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  (item['comment'] ?? '').toString().trim(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.25),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final course = _map(item['course']);
    final subject = (course['subject'] ?? course['name'] ?? 'Class').toString();
    final period = (item['period'] ?? '').toString();
    final status = _statusOf(item);
    final note = (item['note'] ?? '').toString().trim();
    final cs = Theme.of(context).colorScheme;

    final Color tone = switch (status) {
      'PRESENT' => cs.primary,
      'LATE' => Colors.orange,
      'ABSENT' => cs.error,
      'EXCUSED' => cs.secondary,
      _ => cs.onSurfaceVariant,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                '${_friendlyDate(_attendanceDate(item))} · Period $period · ${_prettyStatus(status)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (note.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  note,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.25),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniEmpty extends StatelessWidget {
  const _MiniEmpty({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 34, color: cs.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          if (action != null) ...[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) {
    return Map<String, dynamic>.from(value);
  }
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _list(dynamic value) {
  if (value is! List) {
    return <Map<String, dynamic>>[];
  }
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList(growable: false);
}

String _statusOf(Map<String, dynamic> item) {
  return (item['status'] ?? '').toString().trim().toUpperCase();
}

double? _gradeValue(Map<String, dynamic> item) {
  final raw = item['grade'];
  if (raw is num) {
    return raw.toDouble();
  }
  return double.tryParse((raw ?? '').toString());
}

String _assessmentDate(Map<String, dynamic> item) {
  final assessment = _map(item['assessment']);
  return (assessment['date'] ?? '').toString();
}

String _attendanceDate(Map<String, dynamic> item) {
  return (item['date'] ?? '').toString();
}

String _prettyStatus(String status) {
  switch (status) {
    case 'PRESENT':
      return 'Present';
    case 'ABSENT':
      return 'Absent';
    case 'LATE':
      return 'Late';
    case 'EXCUSED':
      return 'Excused';
    default:
      return status.isEmpty ? 'Unknown' : status;
  }
}

String _friendlyDate(String raw) {
  final dt = DateTime.tryParse(raw);
  if (dt == null) {
    return raw.isEmpty ? 'Unknown date' : raw;
  }
  final local = dt.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
