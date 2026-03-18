import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../insights/domain/insights_models.dart';
import '../insights/providers/insights_providers.dart';

class GradesScreen extends ConsumerWidget {
  const GradesScreen({super.key});

  double? _subjectAverage(List<UnifiedGradeInsight> items) {
    if (items.isEmpty) return null;
    final total = items.fold<double>(0, (sum, item) => sum + item.grade);
    return total / items.length;
  }

  String _gradeBand(double? value) {
    if (value == null) return 'No signal yet';
    if (value >= 90) return 'Excellent';
    if (value >= 80) return 'Strong';
    if (value >= 70) return 'Okay';
    if (value >= 60) return 'Shaky';
    return 'At risk';
  }

  String _trendLabel(List<UnifiedGradeInsight> items) {
    if (items.length < 2) return 'Not enough data';
    final sorted = [...items]
      ..sort((a, b) => (b.date ?? '').compareTo(a.date ?? ''));
    final delta = sorted.first.grade - sorted[1].grade;
    if (delta >= 5) return 'Rising';
    if (delta <= -5) return 'Dropping';
    return 'Stable';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(unifiedStudentInsightsProvider);

    return Scaffold(
      body: async.when(
        loading: () => const _LoadingBody(
          title: 'Grades',
          subtitle: 'Loading the latest academic results.',
        ),
        error: (error, stackTrace) => _ErrorBody(
          title: 'Grades unavailable',
          subtitle: error.toString(),
          onRetry: () => ref.invalidate(unifiedStudentInsightsProvider),
        ),
        data: (data) {
          final grades = data?.grades;
          final items = grades?.latest ?? const <UnifiedGradeInsight>[];

          final bySubject = <String, List<UnifiedGradeInsight>>{};
          for (final item in items) {
            bySubject
                .putIfAbsent(item.subject, () => <UnifiedGradeInsight>[])
                .add(item);
          }

          final subjectCards = bySubject.entries.toList()
            ..sort((a, b) {
              final aAvg = _subjectAverage(a.value) ?? -1;
              final bAvg = _subjectAverage(b.value) ?? -1;
              return aAvg.compareTo(bAvg);
            });

          final latest = items.isEmpty ? null : items.first;

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
                  title: 'Grades',
                  subtitle:
                      'A sharper read on your recent assessments, subject pressure points, and score momentum.',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.grade_rounded,
                              label: 'Average',
                              value: grades?.average == null
                                  ? '—'
                                  : grades!.average!.toStringAsFixed(1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.library_books_rounded,
                              label: 'Recorded',
                              value: '${grades?.count ?? 0}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.workspace_premium_rounded,
                              label: 'Best subject',
                              value: (grades?.bestSubject ?? '').trim().isEmpty
                                  ? '—'
                                  : grades!.bestSubject!,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.flag_rounded,
                              label: 'Needs work',
                              value:
                                  (grades?.weakestSubject ?? '').trim().isEmpty
                                  ? '—'
                                  : grades!.weakestSubject!,
                            ),
                          ),
                        ],
                      ),
                      if (latest != null) ...[
                        const SizedBox(height: 14),
                        _SignalBanner(
                          icon: Icons.bolt_rounded,
                          title: 'Latest signal',
                          body:
                              '${latest.assessmentTitle} in ${latest.subject} landed at ${latest.grade.toStringAsFixed(0)}. ${_gradeBand(latest.grade)} right now.',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  const _EmptyStateCard(
                    title: 'No grades yet',
                    subtitle:
                        'Once assessments arrive from school, your latest results and subject breakdown will appear here.',
                  )
                else ...[
                  _SectionCard(
                    title: 'Pressure points',
                    subtitle:
                        'The fastest read on what to protect and what to recover.',
                    child: Column(
                      children: [
                        _InsightRow(
                          icon: Icons.flag_rounded,
                          label: 'Current weak spot',
                          value: (grades?.weakestSubject ?? '').trim().isEmpty
                              ? 'No weakest subject signal yet'
                              : '${grades!.weakestSubject} needs the first recovery block.',
                        ),
                        const SizedBox(height: 10),
                        _InsightRow(
                          icon: Icons.workspace_premium_rounded,
                          label: 'Current strength',
                          value: (grades?.bestSubject ?? '').trim().isEmpty
                              ? 'No best subject signal yet'
                              : '${grades!.bestSubject} is your confidence anchor right now.',
                        ),
                        const SizedBox(height: 10),
                        _InsightRow(
                          icon: Icons.insights_rounded,
                          label: 'Band',
                          value: _gradeBand(grades?.average),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Latest assessments',
                    subtitle:
                        'Most recent recorded grades in chronological order.',
                    child: Column(
                      children: items
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _GradeTile(item: item),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Subject drilldown',
                    subtitle:
                        'Grouped by subject so trend and pressure stand out faster.',
                    child: Column(
                      children: subjectCards
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _SubjectGroup(
                                subject: entry.key,
                                items: entry.value,
                                average: _subjectAverage(entry.value),
                                trendLabel: _trendLabel(entry.value),
                                isBest: grades?.bestSubject == entry.key,
                                isWeak: grades?.weakestSubject == entry.key,
                              ),
                            ),
                          )
                          .toList(),
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

class _GradeTile extends StatelessWidget {
  const _GradeTile({required this.item});

  final UnifiedGradeInsight item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final score = item.grade;
    final tone = score >= 85
        ? cs.secondaryContainer
        : score >= 70
        ? cs.tertiaryContainer
        : cs.errorContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: tone.withValues(alpha: 0.85),
            child: Text(
              item.grade.toStringAsFixed(0),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.assessmentTitle,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.subject} • ${item.courseName}',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if ((item.date ?? '').trim().isNotEmpty)
            Text(
              item.date!,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _SubjectGroup extends StatelessWidget {
  const _SubjectGroup({
    required this.subject,
    required this.items,
    required this.average,
    required this.trendLabel,
    required this.isBest,
    required this.isWeak,
  });

  final String subject;
  final List<UnifiedGradeInsight> items;
  final double? average;
  final String trendLabel;
  final bool isBest;
  final bool isWeak;

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                subject,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              if (isBest) const _Pill(label: 'Best'),
              if (isWeak) const _Pill(label: 'Needs work'),
              _Pill(label: trendLabel),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            average == null
                ? 'No average yet'
                : 'Recent average: ${average!.toStringAsFixed(1)}',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '• ${item.assessmentTitle} — ${item.grade.toStringAsFixed(0)}',
                style: TextStyle(color: cs.onSurface),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer.withValues(alpha: 0.95),
            cs.surfaceContainerHigh.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
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
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
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
        color: cs.surface.withValues(alpha: 0.78),
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
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _SignalBanner extends StatelessWidget {
  const _SignalBanner({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
          ),
        ],
      ),
    );
  }
}
