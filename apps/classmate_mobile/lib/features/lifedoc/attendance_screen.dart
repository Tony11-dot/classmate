import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../insights/domain/insights_models.dart';
import '../insights/providers/insights_providers.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(unifiedStudentInsightsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: async.when(
        loading: () => const _LoadingBody(
          title: 'Attendance',
          subtitle: 'Building your attendance view.',
        ),
        error: (error, stackTrace) => _ErrorBody(
          title: 'Attendance unavailable',
          subtitle: error.toString(),
          onRetry: () => ref.invalidate(unifiedStudentInsightsProvider),
        ),
        data: (data) {
          final attendance = data?.attendance;
          final items =
              attendance?.latest ?? const <UnifiedAttendanceInsight>[];

          final grouped = <String, List<UnifiedAttendanceInsight>>{};
          for (final item in items) {
            grouped
                .putIfAbsent(item.date, () => <UnifiedAttendanceInsight>[])
                .add(item);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(unifiedStudentInsightsProvider);
              await ref.read(unifiedStudentInsightsProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _HeroCard(
                  title: 'Attendance',
                  subtitle:
                      'Your recent school presence, grouped by day and kept simple.',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.event_available_rounded,
                              label: 'Rate',
                              value: attendance?.attendanceRate == null
                                  ? '—'
                                  : '${attendance!.attendanceRate!.toStringAsFixed(1)}%',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.fact_check_rounded,
                              label: 'Present',
                              value: '${attendance?.present ?? 0}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.warning_amber_rounded,
                              label: 'Late',
                              value: '${attendance?.late ?? 0}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.cancel_outlined,
                              label: 'Absent',
                              value: '${attendance?.absent ?? 0}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  const _EmptyStateCard(
                    title: 'No attendance records yet',
                    subtitle:
                        'When your school starts sending attendance data, your recent days and lesson status will show up here.',
                  )
                else ...[
                  _SectionCard(
                    title: 'Recent days',
                    subtitle:
                        'Each day groups the lessons we currently have for you, so you can spot absence patterns fast.',
                    child: Column(
                      children: grouped.entries.map((entry) {
                        final dayItems = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _AttendanceDayGroup(
                            date: entry.key,
                            items: dayItems,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Quick read',
                    subtitle:
                        'A tiny summary based on the latest records currently available.',
                    child: _SummaryPills(
                      pills: [
                        _SummaryPillData(
                          label: 'Strongest signal',
                          value: (attendance?.attendanceRate ?? 0) >= 95
                              ? 'Excellent consistency'
                              : (attendance?.attendanceRate ?? 0) >= 85
                              ? 'Mostly steady'
                              : 'Needs tightening',
                        ),
                        _SummaryPillData(
                          label: 'Watch for',
                          value: (attendance?.late ?? 0) > 0
                              ? 'Repeated lateness'
                              : (attendance?.absent ?? 0) > 0
                              ? 'Recent absences'
                              : 'No major flags',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AttendanceDayGroup extends StatelessWidget {
  const _AttendanceDayGroup({required this.date, required this.items});

  final String date;
  final List<UnifiedAttendanceInsight> items;

  Color _tone(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    final normalized = status.trim().toUpperCase();
    if (normalized == 'PRESENT') return cs.secondaryContainer;
    if (normalized == 'LATE') return cs.tertiaryContainer;
    if (normalized == 'ABSENT') return cs.errorContainer;
    return cs.surfaceContainerHighest;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _tone(context, item.status).withValues(alpha: 0.74),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: cs.surface.withValues(alpha: 0.9),
                      child: Text(
                        '${item.period}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.courseName ?? item.subject ?? 'Lesson',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.subject ?? 'School'} • ${item.status}',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _HeroCard(
          title: title,
          subtitle: subtitle,
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _HeroCard(
          title: title,
          subtitle: subtitle,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer.withValues(alpha: 0.9),
            cs.secondaryContainer.withValues(alpha: 0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.3),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      subtitle: subtitle,
      child: const SizedBox.shrink(),
    );
  }
}

class _SummaryPillData {
  const _SummaryPillData({required this.label, required this.value});

  final String label;
  final String value;
}

class _SummaryPills extends StatelessWidget {
  const _SummaryPills({required this.pills});

  final List<_SummaryPillData> pills;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: pills
          .map(
            (pill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('${pill.label}: ${pill.value}'),
            ),
          )
          .toList(),
    );
  }
}
