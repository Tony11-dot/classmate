import 'package:flutter/material.dart';
import 'package:classmate_mobile/ui/widgets/classmate_refresh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/realtime/realtime_listener.dart';
import '../../core/util/friendly_date.dart';
import '../../l10n/app_localizations.dart';
import '../insights/domain/insights_models.dart';
import '../insights/providers/insights_providers.dart';
import '../../core/semester/school_semester.dart';
import '../../ui/widgets/cm_loading.dart';
import '../../ui/widgets/semester_filter_bar.dart';

/// Subject average from grades: a plain mean by default, or — when the teacher
/// set weight %'s — a %-weighted mean, computed under every "format" with the
/// BEST result kept (mirrors the certificate + server logic).
double? bestFormatAverage(List<UnifiedGradeInsight> items) {
  if (items.isEmpty) return null;
  final formatCount = items.fold<int>(0, (m, it) => it.weightPercents.length > m ? it.weightPercents.length : m);
  if (formatCount == 0) {
    return items.fold<double>(0, (s, i) => s + i.percent) / items.length;
  }
  double? best;
  for (int f = 0; f < formatCount; f++) {
    double num = 0;
    double den = 0;
    for (final it in items) {
      final w = it.weightPercents.isEmpty
          ? 0
          : (f < it.weightPercents.length ? it.weightPercents[f] : it.weightPercents.last);
      if (w <= 0) continue;
      num += it.percent * w;
      den += w;
    }
    if (den == 0) continue;
    final avg = num / den;
    if (best == null || avg > best) best = avg;
  }
  return best ?? (items.fold<double>(0, (s, i) => s + i.percent) / items.length);
}

/// Center popup showing how a subject average was reached — each grade, its
/// weight %, and the score the student got.
Future<void> showSubjectBreakdown(BuildContext context, String subject, List<UnifiedGradeInsight> items) {
  final l = AppLocalizations.of(context)!;
  final cs = Theme.of(context).colorScheme;
  final avg = bestFormatAverage(items);
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(subject),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (avg != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text('${l.gradesBreakdownAverage}: ${avg.round()}',
                    style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary)),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final it in items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              it.assessmentTitle.isNotEmpty ? it.assessmentTitle : subject,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (it.weightPercents.isNotEmpty) ...[
                            Text(it.weightPercents.map((w) => '$w%').join('/'),
                                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                            const SizedBox(width: 10),
                          ],
                          Text(it.label ?? '${it.grade.round()} / ${it.maxGrade ?? 100}',
                              style: const TextStyle(fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.commonClose))],
    ),
  );
}

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  final Set<String> _expanded = {};
  bool _showingPrevious = false;
  SemesterWindow? _selectedPast;
  // Last successfully-loaded insights. A refresh that transiently returns
  // null/empty (network blip, slow endpoint) must NOT blank out grades the
  // student already saw — we fall back to this instead of flashing empty.
  UnifiedStudentInsights? _lastGood;

  DateTime? _parseDate(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return null;
    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;
    final slash = RegExp(r'^(\d{1,2})\/(\d{1,2})\/(\d{2,4})$').firstMatch(value);
    if (slash != null) {
      final a = int.tryParse(slash.group(1)!);
      final b = int.tryParse(slash.group(2)!);
      final y = int.tryParse(slash.group(3)!);
      if (a != null && b != null && y != null) {
        final year = y < 100 ? 2000 + y : y;
        if (b > 12) {
          return DateTime.tryParse('$year-${a.toString().padLeft(2, '0')}-${b.toString().padLeft(2, '0')}');
        }
        return DateTime.tryParse('$year-${b.toString().padLeft(2, '0')}-${a.toString().padLeft(2, '0')}');
      }
    }
    return null;
  }

  String _friendlyDate(BuildContext context, String? raw) {
    if ((raw ?? '').trim().isEmpty) {
      return AppLocalizations.of(context)!.attendanceUndated;
    }
    return FriendlyDate.date(raw);
  }

  String _friendlyError(BuildContext context, Object error) {
    final l = AppLocalizations.of(context)!;
    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    if (raw.isEmpty) return l.gradesScreenCouldNotLoad;
    if (raw.toLowerCase().contains('timeout')) return l.gradesScreenTimeout;
    if (raw.toLowerCase().contains('socket') || raw.toLowerCase().contains('network')) {
      return l.gradesScreenNoConnection;
    }
    return raw;
  }

  String _subjectLabel(BuildContext context, UnifiedGradeInsight item) {
    final s = item.subject.trim();
    if (s.isNotEmpty) return s;
    final c = item.courseName.trim();
    if (c.isNotEmpty) return c;
    return AppLocalizations.of(context)!.gradesGeneralSubject;
  }

  List<UnifiedGradeInsight> _sorted(List<UnifiedGradeInsight> items) {
    final out = [...items];
    out.sort((a, b) {
      final aDate = _parseDate(a.date);
      final bDate = _parseDate(b.date);
      if (aDate != null && bDate != null) {
        final d = bDate.compareTo(aDate);
        if (d != 0) return d;
      } else if (aDate != null) {
        return -1;
      } else if (bDate != null) {
        return 1;
      }
      return b.grade.compareTo(a.grade);
    });
    return out;
  }

  Color _scoreColor(BuildContext context, double score) {
    final cs = Theme.of(context).colorScheme;
    if (score >= 85) return cs.secondaryContainer;
    if (score >= 70) return cs.tertiaryContainer;
    return cs.errorContainer;
  }

  Color _scoreOnColor(BuildContext context, double score) {
    final cs = Theme.of(context).colorScheme;
    if (score >= 85) return cs.onSecondaryContainer;
    if (score >= 70) return cs.onTertiaryContainer;
    return cs.onErrorContainer;
  }

  double? _average(List<UnifiedGradeInsight> items) => bestFormatAverage(items);

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(unifiedStudentInsightsProvider);
    final l = AppLocalizations.of(context)!;

    // Refresh grades when teacher posts grades in real-time
    ref.listen(realtimeEventProvider, (_, event) {
      if (event?.type == 'grade_updated') ref.invalidate(unifiedStudentInsightsProvider);
    });
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: async.when(
        skipLoadingOnRefresh: true,
        loading: () => _buildLoading(context),
        error: (err, _) => ClassMateRefreshIndicator(
          onRefresh: () => ref.refresh(unifiedStudentInsightsProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [_buildHero(context, null, null, null), const SizedBox(height: 20),
              _ErrorCard(message: _friendlyError(context, err), onRetry: () => ref.invalidate(unifiedStudentInsightsProvider)),
            ],
          ),
        ),
        data: (data) {
          if (data != null && data.grades.latest.isNotEmpty) _lastGood = data;
          final source = (data != null && data.grades.latest.isNotEmpty)
              ? data
              : (data ?? _lastGood);
          final raw = source?.grades.latest ?? const <UnifiedGradeInsight>[];
          final all = _sorted(raw);
          // Semester split (by grade date) — pills only show when the school
          // configured semesters.
          final semWindow = ref.watch(currentSemesterWindowProvider);
          final visible = visibleForSemester<UnifiedGradeInsight>(all, (g) => _parseDate(g.date), semWindow, _showingPrevious, _selectedPast);

          final bySubject = <String, List<UnifiedGradeInsight>>{};
          for (final item in visible) {
            bySubject.putIfAbsent(_subjectLabel(context, item), () => []).add(item);
          }

          final subjects = bySubject.keys.toList()..sort();
          final overallAvg = _average(visible);

          String? bestSubject;
          String? weakestSubject;
          double? bestAvg;
          double? weakAvg;
          for (final e in bySubject.entries) {
            final avg = _average(e.value) ?? 0;
            if (bestAvg == null || avg > bestAvg) { bestAvg = avg; bestSubject = e.key; }
            if (weakAvg == null || avg < weakAvg) { weakAvg = avg; weakestSubject = e.key; }
          }

          return ClassMateRefreshIndicator(
            onRefresh: () => ref.refresh(unifiedStudentInsightsProvider.future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _buildHero(context, overallAvg, bestSubject, weakestSubject),
                const SizedBox(height: 12),
                SemesterFilterBar(
                  visible: semWindow != null,
                  showingPrevious: _showingPrevious,
                  onChanged: (v) => setState(() { _showingPrevious = v; if (!v) _selectedPast = null; }),
                  selectedPast: _selectedPast,
                  onPastChanged: (w) => setState(() => _selectedPast = w),
                ),
                if (visible.isEmpty)
                  _EmptyCard(title: l.gradesEmptyTitle, subtitle: l.gradesEmptySubtitle)
                else
                  ...subjects.map((subject) {
                    final items = bySubject[subject]!;
                    final avg = _average(items);
                    final isExpanded = _expanded.contains(subject);
                    // Always show 3 as preview; expand to all regardless of count
                    final preview = isExpanded ? items : items.take(3).toList();
                    final remaining = items.length - 3; // can be <=0, handled in _SubjectCard

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SubjectCard(
                        subject: subject,
                        average: avg,
                        items: preview,
                        onAverageTap: () => showSubjectBreakdown(context, subject, items),
                        totalCount: items.length,
                        remainingCount: remaining,
                        isExpanded: isExpanded,
                        scoreColor: avg == null ? cs.surfaceContainerHighest : _scoreColor(context, avg),
                        scoreOnColor: avg == null ? cs.onSurfaceVariant : _scoreOnColor(context, avg),
                        isBest: bestSubject == subject && subjects.length > 1,
                        isWeak: weakestSubject == subject && subjects.length > 1,
                        friendlyDate: (raw) => _friendlyDate(context, raw),
                        gradeDotColor: (score) => _scoreColor(context, score),
                        onToggle: () => setState(() {
                          if (isExpanded) {
                            _expanded.remove(subject);
                          } else {
                            _expanded.add(subject);
                          }
                        }),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHero(BuildContext context, double? avg, String? best, String? weak) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.navGrades,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onPrimaryContainer,
                letterSpacing: -0.4,
              )),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                avg == null ? '—' : avg.toStringAsFixed(1),
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onPrimaryContainer,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              if (avg != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    l.gradesScreenOutOf100,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (best != null)
                _HeroPill(
                  icon: Icons.workspace_premium_rounded,
                  label: best,
                  // White translucent bg on primaryContainer → text contrasts.
                  color: Colors.white.withValues(alpha: 0.25),
                  textColor: cs.onPrimaryContainer,
                ),
              if (weak != null && weak != best)
                _HeroPill(
                  icon: Icons.flag_rounded,
                  label: weak,
                  color: cs.error.withValues(alpha: 0.30),
                  textColor: cs.onPrimaryContainer,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(child: CmLoading()),
        ),
        const SizedBox(height: 12),
        ...List.generate(3, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 130,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        )),
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.subject,
    required this.average,
    required this.items,
    required this.totalCount,
    required this.remainingCount,
    required this.isExpanded,
    required this.scoreColor,
    required this.scoreOnColor,
    required this.isBest,
    required this.isWeak,
    required this.friendlyDate,
    required this.gradeDotColor,
    required this.onToggle,
    this.onAverageTap,
  });

  final String subject;
  final double? average;
  final VoidCallback? onAverageTap;
  final List<UnifiedGradeInsight> items;
  final int totalCount;
  final int remainingCount;
  final bool isExpanded;
  final Color scoreColor;
  final Color scoreOnColor;
  final bool isBest;
  final bool isWeak;
  final String Function(String? raw) friendlyDate;
  final Color Function(double score) gradeDotColor;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: totalCount > 0 ? onToggle : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (isBest || isWeak) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (isBest) _SmallBadge(label: l.savedQuestionsTopSubjectMetric, color: cs.secondaryContainer, textColor: cs.onSecondaryContainer),
                              if (isBest && isWeak) const SizedBox(width: 6),
                              if (isWeak) _SmallBadge(label: l.gradesMetricNeedsWork, color: cs.errorContainer, textColor: cs.onErrorContainer),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (average != null)
                    InkWell(
                      onTap: onAverageTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: scoreColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              average!.toStringAsFixed(1),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scoreOnColor,
                              ),
                            ),
                            if (onAverageTap != null) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.info_outline_rounded, size: 14, color: scoreOnColor),
                            ],
                          ],
                        ),
                      ),
                    ),
                  if (totalCount > 0) ...[
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(height: 1, color: cs.outlineVariant),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              children: [
                ...items.map((item) => _GradeRow(
                  item: item,
                  date: friendlyDate(item.date),
                  dotColor: gradeDotColor(item.grade),
                )),
                if (!isExpanded && remainingCount > 0) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onToggle,
                    child: Row(
                      children: [
                        Icon(Icons.expand_more_rounded, size: 16, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(
                          l.gradesScreenShowMore(remainingCount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isExpanded && totalCount > 0) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onToggle,
                    child: Row(
                      children: [
                        Icon(Icons.expand_less_rounded, size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          l.gradesScreenShowLess,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeRow extends StatelessWidget {
  const _GradeRow({required this.item, required this.date, required this.dotColor});

  final UnifiedGradeInsight item;
  final String date;
  final Color dotColor;

  Color _gradeColor(BuildContext context, double score) {
    final cs = Theme.of(context).colorScheme;
    if (score >= 80) return cs.secondaryContainer;
    if (score >= 60) return const Color(0xFFF59E0B); // amber
    return cs.errorContainer;
  }

  Color _gradeOnColor(BuildContext context, double score) {
    final cs = Theme.of(context).colorScheme;
    if (score >= 80) return cs.onSecondaryContainer;
    if (score >= 60) return Colors.white;
    return cs.onErrorContainer;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final title = item.assessmentTitle.trim().isEmpty
        ? AppLocalizations.of(context)!.gradesAssessmentFallback
        : item.assessmentTitle;

    final score = item.grade;
    final gradeText = score % 1 == 0
        ? score.toStringAsFixed(0)
        : score.toStringAsFixed(1);
    final chipBg = _gradeColor(context, score);
    final chipFg = _gradeOnColor(context, score);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                if (date.isNotEmpty)
                  Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Colored grade chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              // Custom-scale grades show the label (e.g. "A+"); otherwise show
              // the teacher's max for this assessment (e.g. 15/20), not a
              // hardcoded /100. Falls back to /100 only when no max was set.
              item.label ?? '$gradeText / ${item.maxGrade ?? 100}',
              style: TextStyle(
                color: chipFg,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label, required this.color, required this.textColor});

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.school_rounded, size: 32, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, height: 1.4)),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message,
              style: TextStyle(color: cs.onErrorContainer, height: 1.4, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}
