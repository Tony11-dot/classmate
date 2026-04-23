import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';
import '../insights/domain/insights_models.dart';
import '../insights/providers/insights_providers.dart';

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  static const String _allSubjects = '__all_subjects__';

  String _selectedSubject = _allSubjects;
  _GradesRangeFilter _selectedRange = _GradesRangeFilter.all;

  DateTime? _parseDate(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return null;

    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;

    final slash = RegExp(r'^(\d{1,2})\/(\d{1,2})\/(\d{2,4})$').firstMatch(value);
    if (slash != null) {
      final first = int.tryParse(slash.group(1)!);
      final second = int.tryParse(slash.group(2)!);
      final yearRaw = int.tryParse(slash.group(3)!);
      if (first != null && second != null && yearRaw != null) {
        final year = yearRaw < 100 ? 2000 + yearRaw : yearRaw;
        if (second > 12) {
          return DateTime.tryParse(
            '$year-${first.toString().padLeft(2, '0')}-${second.toString().padLeft(2, '0')}',
          );
        }
        return DateTime.tryParse(
          '$year-${second.toString().padLeft(2, '0')}-${first.toString().padLeft(2, '0')}',
        );
      }
    }

    final dash = RegExp(r'^(\d{1,2})-(\d{1,2})-(\d{2,4})$').firstMatch(value);
    if (dash != null) {
      final first = int.tryParse(dash.group(1)!);
      final second = int.tryParse(dash.group(2)!);
      final yearRaw = int.tryParse(dash.group(3)!);
      if (first != null && second != null && yearRaw != null) {
        final year = yearRaw < 100 ? 2000 + yearRaw : yearRaw;
        if (first > 12) {
          return DateTime.tryParse(
            '$year-${second.toString().padLeft(2, '0')}-${first.toString().padLeft(2, '0')}',
          );
        }
        return DateTime.tryParse(
          '$year-${first.toString().padLeft(2, '0')}-${second.toString().padLeft(2, '0')}',
        );
      }
    }

    return null;
  }

  String _friendlyDate(BuildContext context, String? raw) {
    final parsed = _parseDate(raw);
    if (parsed == null) {
      final fallback = (raw ?? '').trim();
      return fallback.isEmpty ? AppLocalizations.of(context)!.attendanceUndated : fallback;
    }

    return MaterialLocalizations.of(context).formatMediumDate(parsed);
  }

  String _friendlyError(BuildContext context, Object error) {
    final l = AppLocalizations.of(context)!;
    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    if (raw.isEmpty) {
      return l.gradesLoadError;
    }
    final lowered = raw.toLowerCase();
    if (lowered.contains('timeout')) {
      return l.gradesLoadTimeout;
    }
    if (lowered.contains('socket') || lowered.contains('network')) {
      return l.gradesLoadNetwork;
    }
    return raw;
  }

  String _subjectLabel(BuildContext context, UnifiedGradeInsight item) {
    final subject = item.subject.trim();
    if (subject.isNotEmpty) return subject;
    final courseName = item.courseName.trim();
    if (courseName.isNotEmpty) return courseName;
    return AppLocalizations.of(context)!.gradesGeneralSubject;
  }

  DateTime? _cutoffDate() {
    final days = _selectedRange.days;
    if (days == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
  }

  List<UnifiedGradeInsight> _sortedItems(List<UnifiedGradeInsight> items) {
    final sorted = [...items];
    sorted.sort((a, b) {
      final aDate = _parseDate(a.date);
      final bDate = _parseDate(b.date);
      if (aDate != null && bDate != null) {
        final byDate = bDate.compareTo(aDate);
        if (byDate != 0) return byDate;
      } else if (aDate != null) {
        return -1;
      } else if (bDate != null) {
        return 1;
      }

      final bySubject = _subjectLabel(context, a).compareTo(_subjectLabel(context, b));
      if (bySubject != 0) return bySubject;

      final byTitle = a.assessmentTitle.trim().compareTo(b.assessmentTitle.trim());
      if (byTitle != 0) return byTitle;

      return b.grade.compareTo(a.grade);
    });
    return sorted;
  }

  List<UnifiedGradeInsight> _filteredItems(List<UnifiedGradeInsight> items) {
    final cutoff = _cutoffDate();
    return _sortedItems(items).where((item) {
      final matchesSubject =
          _selectedSubject == _allSubjects || _subjectLabel(context, item) == _selectedSubject;
      if (!matchesSubject) return false;
      if (cutoff == null) return true;
      final parsed = _parseDate(item.date);
      if (parsed == null) return false;
      final normalized = DateTime(parsed.year, parsed.month, parsed.day);
      return !normalized.isBefore(cutoff);
    }).toList(growable: false);
  }

  double? _subjectAverage(List<UnifiedGradeInsight> items) {
    if (items.isEmpty) return null;
    final total = items.fold<double>(0, (sum, item) => sum + item.grade);
    return total / items.length;
  }

  String _gradeBand(BuildContext context, double? value) {
    final l = AppLocalizations.of(context)!;
    if (value == null) return l.gradesBandBuilding;
    if (value >= 90) return l.gradesBandExcellent;
    if (value >= 80) return l.gradesBandStrong;
    if (value >= 70) return l.gradesBandOkay;
    if (value >= 60) return l.gradesBandNeedsAttention;
    return l.gradesBandRisk;
  }

  String _trendLabel(BuildContext context, List<UnifiedGradeInsight> items) {
    final l = AppLocalizations.of(context)!;
    if (items.length < 2) return l.gradesBandBuilding;
    final sorted = _sortedItems(items);
    final delta = sorted.first.grade - sorted[1].grade;
    if (delta >= 5) return l.gradesTrendRising;
    if (delta <= -5) return l.gradesTrendDropping;
    return l.gradesTrendStable;
  }

  _DerivedGradesSummary _deriveSummary(List<UnifiedGradeInsight> items) {
    final sorted = _sortedItems(items);
    final average = _subjectAverage(sorted);
    final bySubject = <String, List<UnifiedGradeInsight>>{};
    for (final item in sorted) {
      bySubject.putIfAbsent(_subjectLabel(context, item), () => <UnifiedGradeInsight>[]).add(item);
    }

    String? bestSubject;
    String? weakestSubject;
    double? bestAverage;
    double? weakestAverage;

    for (final entry in bySubject.entries) {
      final subjectAverage = _subjectAverage(entry.value);
      if (subjectAverage == null) continue;
      if (bestAverage == null || subjectAverage > bestAverage) {
        bestAverage = subjectAverage;
        bestSubject = entry.key;
      }
      if (weakestAverage == null || subjectAverage < weakestAverage) {
        weakestAverage = subjectAverage;
        weakestSubject = entry.key;
      }
    }

    return _DerivedGradesSummary(
      count: sorted.length,
      average: average,
      bestSubject: bestSubject,
      weakestSubject: weakestSubject,
      latest: sorted.isEmpty ? null : sorted.first,
      bySubject: bySubject,
    );
  }

  Color _scoreTone(BuildContext context, double score) {
    final cs = Theme.of(context).colorScheme;
    if (score >= 85) return cs.secondaryContainer;
    if (score >= 70) return cs.tertiaryContainer;
    return cs.errorContainer;
  }

  String _filterSummaryLabel(BuildContext context, int filteredCount, int totalCount) {
    final l = AppLocalizations.of(context)!;
    final subjectLabel =
        _selectedSubject == _allSubjects ? l.attendanceAllSubjectsLowercase : _selectedSubject;
    final rangeLabel = _selectedRange.shortLabel(context).toLowerCase();
    return l.gradesShowingSummary(filteredCount, totalCount, subjectLabel, rangeLabel);
  }

  void _clearFilters() {
    setState(() {
      _selectedSubject = _allSubjects;
      _selectedRange = _GradesRangeFilter.all;
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(unifiedStudentInsightsProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: async.when(
        skipLoadingOnRefresh: true,
        loading: () => _LoadingBody(
          title: l.navGrades,
          subtitle: l.gradesLoadingSubtitle,
        ),
        error: (error, stackTrace) => _ErrorBody(
          title: l.gradesUnavailableTitle,
          subtitle: _friendlyError(context, error),
          onRetry: () => ref.invalidate(unifiedStudentInsightsProvider),
        ),
        data: (data) {
          final grades = data?.grades;
          final items = _sortedItems(grades?.latest ?? const <UnifiedGradeInsight>[]);
          final subjects = items
              .map((item) => _subjectLabel(context, item))
              .where((value) => value.trim().isNotEmpty)
              .toSet()
              .toList()
            ..sort();
          final safeSubject = subjects.contains(_selectedSubject)
              ? _selectedSubject
              : _allSubjects;
          if (safeSubject != _selectedSubject) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _selectedSubject = safeSubject);
            });
          }

          final filteredItems = _filteredItems(items);
          final filteredSummary = _deriveSummary(filteredItems);
          final hasActiveFilters =
              safeSubject != _allSubjects || _selectedRange != _GradesRangeFilter.all;
          final latestOverall = items.isEmpty ? null : items.first;
          final hasOverallSummary = (grades?.count ?? 0) > 0 || grades?.average != null;

          final subjectCards = filteredSummary.bySubject.entries.toList()
            ..sort((a, b) {
              final aAvg = _subjectAverage(a.value) ?? -1;
              final bAvg = _subjectAverage(b.value) ?? -1;
              return aAvg.compareTo(bAvg);
            });

          return RefreshIndicator(
            onRefresh: () => ref.refresh(unifiedStudentInsightsProvider.future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _HeroCard(
                  title: l.navGrades,
                  subtitle: l.gradesHeroSubtitle,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.grade_rounded,
                              label: l.gradesMetricAverage,
                              value: grades?.average == null
                                  ? '—'
                                  : grades!.average!.toStringAsFixed(1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.library_books_rounded,
                              label: l.gradesMetricRecorded,
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
                              label: l.gradesMetricBestSubject,
                              value: (grades?.bestSubject ?? '').trim().isEmpty
                                  ? '—'
                                  : grades!.bestSubject!,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.flag_rounded,
                              label: l.gradesMetricNeedsWork,
                              value: (grades?.weakestSubject ?? '').trim().isEmpty
                                  ? '—'
                                  : grades!.weakestSubject!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _SignalBanner(
                        icon: Icons.bolt_rounded,
                        title: _gradeBand(context, grades?.average),
                        body: latestOverall != null
                            ? l.gradesLatestSignalBody(
                                latestOverall.assessmentTitle,
                                _subjectLabel(context, latestOverall),
                                latestOverall.grade.toStringAsFixed(0),
                                _gradeBand(context, latestOverall.grade),
                              )
                            : hasOverallSummary
                            ? l.gradesSummaryAvailableNoRecent
                            : l.gradesEmptySubtitle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  _EmptyStateCard(
                    title: l.gradesEmptyTitle,
                    subtitle: l.gradesEmptySubtitle,
                    hint: l.assignmentsPullToCheckAgain,
                  )
                else ...[
                  _SectionCard(
                    title: l.filters,
                    subtitle: l.gradesFiltersSubtitle,
                    child: Column(
                      children: [
                        LiquidGlassDropdown<String>(
                          label: l.assignmentsSubjectLabel,
                          value: safeSubject,
                          items: [
                            LiquidGlassDropdownItem(
                              value: _allSubjects,
                              label: l.assignmentsAllSubjects,
                              icon: Icons.grid_view_rounded,
                            ),
                            ...subjects.map(
                              (subject) => LiquidGlassDropdownItem(
                                value: subject,
                                label: subject,
                                icon: Icons.menu_book_rounded,
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedSubject = value);
                          },
                          searchHint: l.assignmentsSearchSubjects,
                        ),
                        const SizedBox(height: 10),
                        LiquidGlassDropdown<_GradesRangeFilter>(
                          label: l.attendanceTimeRangeLabel,
                          value: _selectedRange,
                          items: _GradesRangeFilter.values
                              .map(
                                (range) => LiquidGlassDropdownItem(
                                  value: range,
                                  label: range.label(context),
                                  icon: range.icon,
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setState(() => _selectedRange = value);
                          },
                          searchHint: l.attendanceSearchRanges,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                _filterSummaryLabel(context, filteredItems.length, items.length),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            if (hasActiveFilters) ...[
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: _clearFilters,
                                child: Text(l.clear),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filteredItems.isEmpty)
                    _EmptyStateCard(
                      title: l.gradesNoFilteredTitle,
                      subtitle: l.gradesNoFilteredSubtitle,
                      hint: hasActiveFilters
                          ? l.assignmentsClearFiltersHint
                          : l.assignmentsPullToCheckAgain,
                    )
                  else ...[
                    _SectionCard(
                      title: l.gradesQuickReadTitle,
                      subtitle: hasActiveFilters
                          ? l.gradesQuickReadSubtitleFiltered
                          : l.gradesQuickReadSubtitleAll,
                      child: Column(
                        children: [
                          _InsightRow(
                            icon: Icons.flag_rounded,
                            label: l.gradesWeakSpotLabel,
                            value: (filteredSummary.weakestSubject ?? '').trim().isEmpty
                                ? l.gradesNoWeakSignal
                                : l.gradesWeakSpotValue(filteredSummary.weakestSubject!),
                          ),
                          const SizedBox(height: 10),
                          _InsightRow(
                            icon: Icons.workspace_premium_rounded,
                            label: l.gradesStrengthLabel,
                            value: (filteredSummary.bestSubject ?? '').trim().isEmpty
                                ? l.gradesNoStrengthSignal
                                : l.gradesStrengthValue(filteredSummary.bestSubject!),
                          ),
                          const SizedBox(height: 10),
                          _InsightRow(
                            icon: Icons.insights_rounded,
                            label: l.gradesBandLabel,
                            value: _gradeBand(context, filteredSummary.average),
                          ),
                          const SizedBox(height: 10),
                          _InsightRow(
                            icon: Icons.filter_alt_rounded,
                            label: l.gradesInViewLabel,
                            value: filteredSummary.average == null
                                ? l.gradesInViewCount(filteredSummary.count)
                                : l.gradesInViewAverage(
                                    filteredSummary.count,
                                    filteredSummary.average!.toStringAsFixed(1),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: l.gradesLatestAssessmentsTitle,
                      subtitle: hasActiveFilters
                          ? l.gradesLatestAssessmentsSubtitleFiltered
                          : l.gradesLatestAssessmentsSubtitleAll,
                      child: Column(
                        children: filteredItems
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _GradeTile(
                                  item: item,
                                  formattedDate: _friendlyDate(context, item.date),
                                  tone: _scoreTone(context, item.grade),
                                  subjectLabel: _subjectLabel(context, item),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: l.gradesSubjectDrilldownTitle,
                      subtitle: hasActiveFilters
                          ? l.gradesSubjectDrilldownSubtitleFiltered
                          : l.gradesSubjectDrilldownSubtitleAll,
                      child: Column(
                        children: subjectCards
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _SubjectGroup(
                                  subject: entry.key,
                                  items: _sortedItems(entry.value),
                                  average: _subjectAverage(entry.value),
                                  trendLabel: _trendLabel(context, entry.value),
                                  isBest: filteredSummary.bestSubject == entry.key,
                                  isWeak: filteredSummary.weakestSubject == entry.key,
                                  friendlyDate: (ctx, raw) => _friendlyDate(ctx, raw),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
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
  const _GradeTile({
    required this.item,
    required this.formattedDate,
    required this.tone,
    required this.subjectLabel,
  });

  final UnifiedGradeInsight item;
  final String formattedDate;
  final Color tone;
  final String subjectLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(20),
      blurSigma: 10,
      color: cs.surface.withValues(alpha: 0.82),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: tone.withValues(alpha: 0.88),
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
                  item.assessmentTitle.trim().isEmpty
                      ? AppLocalizations.of(context)!.gradesAssessmentFallback
                      : item.assessmentTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Chip(
                      label: subjectLabel,
                      backgroundColor: cs.surface.withValues(alpha: 0.7),
                      foregroundColor: cs.onSurface,
                    ),
                    if (item.courseName.trim().isNotEmpty)
                      _Chip(
                        label: item.courseName,
                        backgroundColor: cs.surface.withValues(alpha: 0.52),
                        foregroundColor: cs.onSurfaceVariant,
                      ),
                    _Chip(
                      label: formattedDate,
                      backgroundColor: cs.surface.withValues(alpha: 0.52),
                      foregroundColor: cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
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
    required this.friendlyDate,
  });

  final String subject;
  final List<UnifiedGradeInsight> items;
  final double? average;
  final String trendLabel;
  final bool isBest;
  final bool isWeak;
  final String Function(BuildContext context, String? raw) friendlyDate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(22),
      blurSigma: 12,
      color: cs.surface.withValues(alpha: 0.82),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
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
              if (isBest) _Chip(label: AppLocalizations.of(context)!.gradesChipBest),
              if (isWeak) _Chip(label: AppLocalizations.of(context)!.gradesMetricNeedsWork),
              _Chip(label: trendLabel),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            average == null
                ? AppLocalizations.of(context)!.gradesNoAverageYet
                : AppLocalizations.of(context)!
                    .gradesRecentAverage(average!.toStringAsFixed(1)),
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.assessmentTitle.trim().isEmpty
                          ? AppLocalizations.of(context)!.gradesAssessmentFallback
                          : item.assessmentTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: cs.onSurface),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.grade.toStringAsFixed(0),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    friendlyDate(context, item.date),
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
          child: const Column(
            children: [
              Row(
                children: [
                  Expanded(child: _LoadingTile()),
                  SizedBox(width: 10),
                  Expanded(child: _LoadingTile()),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _LoadingTile()),
                  SizedBox(width: 10),
                  Expanded(child: _LoadingTile()),
                ],
              ),
              SizedBox(height: 14),
              _LoadingBanner(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _LoadingSectionCard(),
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
    final l = AppLocalizations.of(context)!;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _HeroCard(
          title: title,
          subtitle: subtitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.assignmentsPullToRefreshRetry,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l.retry),
              ),
            ],
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
    return LiquidGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(26),
      blurSigma: 18,
      gradient: LinearGradient(
        colors: [
          cs.primaryContainer.withValues(alpha: 0.95),
          cs.surfaceContainerHigh.withValues(alpha: 0.95),
        ],
      ),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
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
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      blurSigma: 14,
      color: cs.surfaceContainerLow.withValues(alpha: 0.78),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.24)),
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
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(18),
      blurSigma: 10,
      color: cs.surface.withValues(alpha: 0.78),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(20),
      blurSigma: 10,
      color: cs.surface.withValues(alpha: 0.82),
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

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
    required this.hint,
  });

  final String title;
  final String subtitle;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      blurSigma: 12,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
          ),
          const SizedBox(height: 12),
          _Chip(
            label: hint,
            backgroundColor: cs.surface.withValues(alpha: 0.72),
            foregroundColor: cs.onSurface,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (backgroundColor ?? cs.surfaceContainerHighest).withValues(alpha: 0.94),
            cs.surface.withValues(alpha: 0.52),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foregroundColor ?? cs.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

class _LoadingBanner extends StatelessWidget {
  const _LoadingBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(minHeight: 4),
          SizedBox(height: 12),
          _LoadingLine(widthFactor: 0.7),
          SizedBox(height: 8),
          _LoadingLine(widthFactor: 0.95),
        ],
      ),
    );
  }
}

class _LoadingSectionCard extends StatelessWidget {
  const _LoadingSectionCard();

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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LoadingLine(widthFactor: 0.3),
          SizedBox(height: 10),
          _LoadingLine(widthFactor: 0.85),
          SizedBox(height: 16),
          _LoadingTile(),
          SizedBox(height: 10),
          _LoadingTile(),
        ],
      ),
    );
  }
}

class _LoadingLine extends StatelessWidget {
  const _LoadingLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _DerivedGradesSummary {
  const _DerivedGradesSummary({
    required this.count,
    required this.average,
    required this.bestSubject,
    required this.weakestSubject,
    required this.latest,
    required this.bySubject,
  });

  final int count;
  final double? average;
  final String? bestSubject;
  final String? weakestSubject;
  final UnifiedGradeInsight? latest;
  final Map<String, List<UnifiedGradeInsight>> bySubject;
}

enum _GradesRangeFilter {
  all(null, Icons.all_inclusive_rounded),
  last7Days(7, Icons.view_week_rounded),
  last30Days(30, Icons.calendar_view_month_rounded),
  last90Days(90, Icons.date_range_rounded);

  const _GradesRangeFilter(this.days, this.icon);

  final int? days;
  final IconData icon;

  String label(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (this) {
      case _GradesRangeFilter.all:
        return l.attendanceRangeAll;
      case _GradesRangeFilter.last7Days:
        return l.attendanceRange7;
      case _GradesRangeFilter.last30Days:
        return l.attendanceRange30;
      case _GradesRangeFilter.last90Days:
        return l.attendanceRange90;
    }
  }

  String shortLabel(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (this) {
      case _GradesRangeFilter.all:
        return l.attendanceRangeAllShort;
      case _GradesRangeFilter.last7Days:
        return l.attendanceRange7Short;
      case _GradesRangeFilter.last30Days:
        return l.attendanceRange30Short;
      case _GradesRangeFilter.last90Days:
        return l.attendanceRange90Short;
    }
  }
}
