import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../../ui/widgets/cm_loading.dart';
import 'providers/insights_providers.dart';
import 'providers/submissions_provider.dart';

/// The student performance dashboard: grades, attendance and on-time work for
/// the semester at a glance. Designed for the least reading and the most
/// signal — big colour-coded numbers, tight supporting detail, one action.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  // ── number/format helpers ──────────────────────────────────────────────────

  String _fmtPercent(double? value) =>
      value == null ? '—' : '${value.round()}%';

  String _fmtNum(num? value) {
    if (value == null) return '—';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  /// Green / amber / red for a 0–100 metric against good/ok thresholds.
  Color _tone(BuildContext context, double? value, double good, double ok) {
    final cs = Theme.of(context).colorScheme;
    if (value == null) return cs.onSurfaceVariant;
    if (value >= good) return const Color(0xFF2E7D32);
    if (value >= ok) return const Color(0xFFE08600);
    return cs.error;
  }

  void _ask(BuildContext context, String prompt, {String? title}) {
    context.go(
      Uri(
        path: '/tutor',
        queryParameters: {
          if (prompt.trim().isNotEmpty) 'prompt': prompt.trim(),
          if ((title ?? '').trim().isNotEmpty) 'title': title!.trim(),
        },
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unifiedAsync = ref.watch(unifiedStudentInsightsProvider);
    final submissionsAsync = ref.watch(submissionStatsProvider);
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(unifiedStudentInsightsProvider);
        ref.invalidate(submissionStatsProvider);
        await ref.read(unifiedStudentInsightsProvider.future);
      },
      child: unifiedAsync.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 160),
          children: const [
            SizedBox(height: 120, child: Center(child: CmLoading())),
          ],
        ),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 160),
          children: [
            _Card(
              title: l.insightsNotReadyTitle,
              child: Text(
                error.toString(),
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
        data: (unified) {
          if (unified == null) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 160),
              children: [
                _Card(
                  title: l.insightsEmptyTitle,
                  child: Text(
                    l.insightsEmptySubtitle,
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            );
          }

          final gradeAvg = unified.grades.average;
          final attendance = unified.attendance.attendanceRate;
          final submissions = submissionsAsync.asData?.value;
          final onTimeRate = submissions?.onTimeRate;
          final accuracy = unified.practice.overallAccuracy * 100;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
            children: [
              // ── Hero: three headline numbers ─────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.titleInsights,
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      l.insightsSemesterTitle,
                      style: text.titleSmall?.copyWith(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _Metric(
                            label: l.insightsGradeAverage,
                            value: _fmtNum(gradeAvg),
                            icon: Icons.grade_rounded,
                            color: _tone(context, gradeAvg, 85, 70),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Metric(
                            label: l.navAttendance,
                            value: _fmtPercent(attendance),
                            icon: Icons.how_to_reg_rounded,
                            color: _tone(context, attendance, 90, 80),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Metric(
                            label: l.insightsOnTimeSubmissions,
                            value: _fmtPercent(onTimeRate),
                            icon: Icons.task_alt_rounded,
                            color: _tone(context, onTimeRate, 85, 70),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Submissions ──────────────────────────────────────────────
              if (submissions != null && submissions.total > 0) ...[
                _Card(
                  title: l.insightsSubmissionsTitle,
                  trailing: Text(
                    '${submissions.submitted}/${submissions.total} ${l.insightsHandedInLabel}',
                    style: text.labelLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Pill(
                        label: l.insightsOnTime,
                        count: submissions.onTime,
                        color: const Color(0xFF2E7D32),
                      ),
                      _Pill(
                        label: l.insightsLate,
                        count: submissions.late,
                        color: const Color(0xFFE08600),
                      ),
                      _Pill(
                        label: l.insightsMissing,
                        count: submissions.missed,
                        color: cs.error,
                      ),
                      _Pill(
                        label: l.insightsPending,
                        count: submissions.pending,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ── Grades ───────────────────────────────────────────────────
              _Card(
                title: l.navGrades,
                onTap: () => context.go('/grades'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            label: l.gradesMetricBestSubject,
                            value: (unified.grades.bestSubject ?? '').trim().isEmpty
                                ? '—'
                                : unified.grades.bestSubject!.trim(),
                            color: const Color(0xFF2E7D32),
                            icon: Icons.trending_up_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MiniStat(
                            label: l.gradesMetricNeedsWork,
                            value: (unified.grades.weakestSubject ?? '').trim().isEmpty
                                ? '—'
                                : unified.grades.weakestSubject!.trim(),
                            color: const Color(0xFFE08600),
                            icon: Icons.trending_down_rounded,
                          ),
                        ),
                      ],
                    ),
                    if (unified.grades.latest.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        l.insightsLatestGrades,
                        style: text.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...unified.grades.latest.take(4).map(
                            (g) => _GradeRow(
                              subject: g.subject.trim().isEmpty
                                  ? g.assessmentTitle
                                  : g.subject,
                              detail: g.assessmentTitle,
                              grade: g.grade,
                              color: _tone(context, g.grade, 85, 70),
                            ),
                          ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Attendance ───────────────────────────────────────────────
              _Card(
                title: l.navAttendance,
                onTap: () => context.go('/attendance'),
                trailing: Text(
                  _fmtPercent(attendance),
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: _tone(context, attendance, 90, 80),
                  ),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(
                      label: l.attendanceMetricPresent,
                      count: unified.attendance.present,
                      color: const Color(0xFF2E7D32),
                    ),
                    _Pill(
                      label: l.attendanceMetricLate,
                      count: unified.attendance.late,
                      color: const Color(0xFFE08600),
                    ),
                    _Pill(
                      label: l.attendanceMetricAbsent,
                      count: unified.attendance.absent,
                      color: cs.error,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Practice ─────────────────────────────────────────────────
              _Card(
                title: l.insightsPracticeTitle,
                onTap: () => context.go('/practice'),
                trailing: Text(
                  _fmtPercent(
                    unified.practice.totalAttempts == 0 ? null : accuracy,
                  ),
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: _tone(
                      context,
                      unified.practice.totalAttempts == 0 ? null : accuracy,
                      75,
                      50,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        unified.practice.weakTopics.isNotEmpty
                            ? '${l.gradesMetricNeedsWork}: ${unified.practice.weakTopics.first.topicLabel}'
                            : l.insightsPracticeNow,
                        style: TextStyle(color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () => context.go('/practice'),
                      child: Text(l.insightsPracticeNow),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── One action ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _ask(
                    context,
                    l.insightsReviewWithNovaPrompt,
                    title: l.insightsReviewWithNova,
                  ),
                  icon: const Icon(Icons.psychology_alt_rounded),
                  label: Text(l.insightsReviewWithNova),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── building blocks ───────────────────────────────────────────────────────────

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -0.5,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.child,
    this.trailing,
    this.onTap,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(22),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  ?trailing,
                  if (onTap != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _GradeRow extends StatelessWidget {
  const _GradeRow({
    required this.subject,
    required this.detail,
    required this.grade,
    required this.color,
  });

  final String subject;
  final String detail;
  final double grade;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (detail.trim().isNotEmpty)
                  Text(
                    detail,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            grade % 1 == 0 ? grade.toInt().toString() : grade.toStringAsFixed(1),
            style: TextStyle(fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }
}
