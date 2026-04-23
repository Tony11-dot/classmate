import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../insights/domain/insights_models.dart';
import '../insights/providers/insights_providers.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  static const String _allSubjects = '__all_subjects__';

  String _selectedSubject = _allSubjects;
  _AttendanceRangeFilter _selectedRange = _AttendanceRangeFilter.all;

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

  String _normalizedStatus(String? status) {
    final normalized = (status ?? '').trim().toUpperCase();
    if (normalized.isEmpty) return 'UNKNOWN';
    if (normalized == 'JUSTIFIED' || normalized == 'EXCUSED') return 'EXCUSED';
    return normalized;
  }

  String _friendlyError(BuildContext context, Object error) {
    final l = AppLocalizations.of(context)!;
    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    if (raw.isEmpty) {
      return l.attendanceLoadError;
    }
    final lowered = raw.toLowerCase();
    if (lowered.contains('timeout')) {
      return l.attendanceLoadTimeout;
    }
    if (lowered.contains('socket') || lowered.contains('network')) {
      return l.attendanceLoadNetwork;
    }
    return raw;
  }

  String _subjectLabel(BuildContext context, UnifiedAttendanceInsight item) {
    final subject = (item.subject ?? '').trim();
    if (subject.isNotEmpty) return subject;
    final courseName = (item.courseName ?? '').trim();
    if (courseName.isNotEmpty) return courseName;
    return AppLocalizations.of(context)!.editProfileSchool;
  }

  DateTime? _cutoffDate() {
    final days = _selectedRange.days;
    if (days == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
  }

  List<UnifiedAttendanceInsight> _filteredItems(
    List<UnifiedAttendanceInsight> items,
  ) {
    final cutoff = _cutoffDate();
    return items.where((item) {
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

  _AttendanceDerivedSummary _deriveSummary(List<UnifiedAttendanceInsight> items) {
    var present = 0;
    var late = 0;
    var absent = 0;
    var excused = 0;

    for (final item in items) {
      switch (_normalizedStatus(item.status)) {
        case 'PRESENT':
          present += 1;
          break;
        case 'LATE':
          late += 1;
          break;
        case 'ABSENT':
          absent += 1;
          break;
        case 'EXCUSED':
          excused += 1;
          break;
      }
    }

    final total = items.length;
    final attended = present + late + excused;
    final rate = total == 0 ? null : (attended / total) * 100.0;

    return _AttendanceDerivedSummary(
      total: total,
      present: present,
      late: late,
      absent: absent,
      excused: excused,
      attendanceRate: rate,
    );
  }

  String _consistencyLabelFromRate(BuildContext context, double? rate) {
    final l = AppLocalizations.of(context)!;
    if (rate == null) return l.attendanceConsistencyBuilding;
    if (rate >= 95) return l.attendanceConsistencyExcellent;
    if (rate >= 88) return l.attendanceConsistencySteady;
    if (rate >= 80) return l.attendanceConsistencyNeedsAttention;
    return l.attendanceConsistencyRisk;
  }

  String _watchForFromSummary(BuildContext context, _AttendanceDerivedSummary summary) {
    final l = AppLocalizations.of(context)!;
    if (summary.absent > 0) return l.attendanceWatchRecentAbsences;
    if (summary.late > 0) return l.attendanceWatchRepeatedLateness;
    if (summary.excused > 0) return l.attendanceWatchExcusedAddingUp;
    return l.attendanceWatchNoFlags;
  }

  String _filterSummaryLabel(BuildContext context, int filteredCount, int totalCount) {
    final l = AppLocalizations.of(context)!;
    final subjectLabel =
        _selectedSubject == _allSubjects ? l.attendanceAllSubjectsLowercase : _selectedSubject;
    final rangeLabel = _selectedRange.shortLabel(context).toLowerCase();
    return l.attendanceShowingSummary(filteredCount, totalCount, subjectLabel, rangeLabel);
  }

  void _clearFilters() {
    setState(() {
      _selectedSubject = _allSubjects;
      _selectedRange = _AttendanceRangeFilter.all;
    });
  }

  String _consistencyLabel(BuildContext context, UnifiedAttendanceSummary? attendance) {
    final rate = attendance?.attendanceRate;
    return _consistencyLabelFromRate(context, rate);
  }

  String _watchFor(BuildContext context, UnifiedAttendanceSummary? attendance) {
    final l = AppLocalizations.of(context)!;
    if ((attendance?.absent ?? 0) > 0) return l.attendanceWatchRecentAbsences;
    if ((attendance?.late ?? 0) > 0) return l.attendanceWatchRepeatedLateness;
    if ((attendance?.justified ?? 0) > 0) return l.attendanceWatchExcusedAddingUp;
    return l.attendanceWatchNoFlags;
  }

  String _dayTone(BuildContext context, List<UnifiedAttendanceInsight> items) {
    final l = AppLocalizations.of(context)!;
    final hasAbsent = items.any((e) => _normalizedStatus(e.status) == 'ABSENT');
    final hasLate = items.any((e) => _normalizedStatus(e.status) == 'LATE');
    final hasExcused = items.any((e) => _normalizedStatus(e.status) == 'EXCUSED');
    if (hasAbsent) return l.attendanceDayToneAbsent;
    if (hasLate) return l.attendanceDayToneLate;
    if (hasExcused) return l.attendanceDayToneExcused;
    return l.attendanceDayToneClean;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(unifiedStudentInsightsProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: async.when(
        skipLoadingOnRefresh: true,
        loading: () => _LoadingBody(
          title: l.navAttendance,
          subtitle: l.attendanceLoadingSubtitle,
        ),
        error: (error, stackTrace) => _ErrorBody(
          title: l.attendanceUnavailableTitle,
          subtitle: _friendlyError(context, error),
          onRetry: () => ref.invalidate(unifiedStudentInsightsProvider),
        ),
        data: (data) {
          final attendance = data?.attendance;
          final items = attendance?.latest ?? const <UnifiedAttendanceInsight>[];
          final trackedTotal = attendance?.total ?? items.length;
          final hasSummary = trackedTotal > 0 || attendance?.attendanceRate != null;
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
              safeSubject != _allSubjects || _selectedRange != _AttendanceRangeFilter.all;

          final grouped = <String, List<UnifiedAttendanceInsight>>{};
          for (final item in filteredItems) {
            final key = item.date.trim().isEmpty ? l.attendanceUndated : item.date.trim();
            grouped.putIfAbsent(key, () => <UnifiedAttendanceInsight>[]).add(item);
          }

          final groupedEntries = grouped.entries
              .map(
                (entry) => _AttendanceGroupData(
                  rawDate: entry.key,
                  formattedDate: _friendlyDate(context, entry.key),
                  sortDate: _parseDate(entry.key),
                  items: [...entry.value]
                    ..sort((a, b) {
                      final aPeriod = a.period <= 0 ? 999 : a.period;
                      final bPeriod = b.period <= 0 ? 999 : b.period;
                      return aPeriod.compareTo(bPeriod);
                    }),
                ),
              )
              .toList()
            ..sort((a, b) {
              final aDate = a.sortDate;
              final bDate = b.sortDate;
              if (aDate != null && bDate != null) return bDate.compareTo(aDate);
              if (aDate != null) return -1;
              if (bDate != null) return 1;
              return b.rawDate.compareTo(a.rawDate);
            });

          return RefreshIndicator(
            onRefresh: () => ref.refresh(unifiedStudentInsightsProvider.future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _HeroCard(
                  title: l.navAttendance,
                  subtitle: l.attendanceHeroSubtitle,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.event_available_rounded,
                              label: l.attendanceMetricRate,
                              value: attendance?.attendanceRate == null
                                  ? '—'
                                  : '${attendance!.attendanceRate!.toStringAsFixed(1)}%',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.fact_check_rounded,
                              label: l.attendanceMetricPresent,
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
                              label: l.attendanceMetricLate,
                              value: '${attendance?.late ?? 0}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.cancel_outlined,
                              label: l.attendanceMetricAbsent,
                              value: '${attendance?.absent ?? 0}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _SignalBanner(
                        icon: Icons.shield_moon_rounded,
                        title: _consistencyLabel(context, attendance),
                        body: hasSummary
                            ? l.attendanceHeroSignalBody(_watchFor(context, attendance))
                            : l.attendanceNoSummary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  _EmptyStateCard(
                    title: l.attendanceEmptyTitle,
                    subtitle: l.attendanceEmptySubtitle,
                    hint: l.assignmentsPullToCheckAgain,
                  )
                else ...[
                  _SectionCard(
                    title: l.filters,
                    subtitle: l.attendanceFiltersSubtitle,
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
                        LiquidGlassDropdown<_AttendanceRangeFilter>(
                          label: l.attendanceTimeRangeLabel,
                          value: _selectedRange,
                          items: _AttendanceRangeFilter.values
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
                      title: l.attendanceNoFilteredMarksTitle,
                      subtitle: l.attendanceNoFilteredMarksSubtitle,
                      hint: hasActiveFilters
                          ? l.assignmentsClearFiltersHint
                          : l.assignmentsPullToCheckAgain,
                    )
                  else ...[
                  _SectionCard(
                    title: l.attendanceQuickReadTitle,
                    subtitle:
                        hasActiveFilters
                            ? l.attendanceQuickReadSubtitleFiltered
                            : l.attendanceQuickReadSubtitleAll,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _SummaryPill(
                          label: l.attendanceSummaryConsistency,
                          value: _consistencyLabelFromRate(context, filteredSummary.attendanceRate),
                        ),
                        _SummaryPill(
                          label: l.attendanceSummaryWatchFor,
                          value: _watchForFromSummary(context, filteredSummary),
                        ),
                        _SummaryPill(
                          label: l.attendanceSummaryExcused,
                          value: '${filteredSummary.excused}',
                        ),
                        _SummaryPill(
                          label: l.attendanceSummaryMarksInView,
                          value: '${filteredSummary.total}',
                        ),
                        _SummaryPill(
                          label: l.attendanceSummaryRateInView,
                          value: filteredSummary.attendanceRate == null
                              ? '—'
                              : '${filteredSummary.attendanceRate!.toStringAsFixed(1)}%',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: l.attendanceRecentDaysTitle,
                    subtitle:
                        hasActiveFilters
                            ? l.attendanceRecentDaysSubtitleFiltered
                            : l.attendanceRecentDaysSubtitleAll,
                    child: Column(
                      children: groupedEntries.map((entry) {
                        final dayItems = entry.items;
                        final dayStatuses = dayItems
                            .map((item) => _normalizedStatus(item.status))
                            .toSet();
                        final statusForTone = dayStatuses.contains('ABSENT')
                            ? 'ABSENT'
                            : dayStatuses.contains('LATE')
                            ? 'LATE'
                            : dayStatuses.contains('EXCUSED')
                            ? 'EXCUSED'
                            : dayItems.first.status;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _AttendanceDayGroup(
                            date: entry.formattedDate,
                            items: dayItems,
                            headline: _dayTone(context, dayItems),
                            statusLabel: dayItems.length == 1
                                ? l.attendanceLessonCountSingle
                                : l.attendanceLessonCount(dayItems.length),
                            statusForTone: statusForTone,
                          ),
                        );
                      }).toList(),
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

class _AttendanceDayGroup extends StatelessWidget {
  const _AttendanceDayGroup({
    required this.date,
    required this.items,
    required this.headline,
    required this.statusLabel,
    required this.statusForTone,
  });

  final String date;
  final List<UnifiedAttendanceInsight> items;
  final String headline;
  final String statusLabel;
  final String statusForTone;

  String _normalizedStatus(String? status) {
    final normalized = (status ?? '').trim().toUpperCase();
    if (normalized == 'JUSTIFIED' || normalized == 'EXCUSED') return 'EXCUSED';
    return normalized;
  }

  String _statusLabel(BuildContext context, String? status) {
    final l = AppLocalizations.of(context)!;
    switch (_normalizedStatus(status)) {
      case 'PRESENT':
        return l.attendanceStatusPresent;
      case 'LATE':
        return l.attendanceStatusLate;
      case 'ABSENT':
        return l.attendanceStatusAbsent;
      case 'EXCUSED':
        return l.attendanceStatusExcused;
      default:
        return l.attendanceStatusRecorded;
    }
  }

  Color _tone(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    final normalized = _normalizedStatus(status);
    if (normalized == 'PRESENT') return cs.secondaryContainer;
    if (normalized == 'LATE') return cs.tertiaryContainer;
    if (normalized == 'ABSENT') return cs.errorContainer;
    if (normalized == 'EXCUSED') return cs.primaryContainer;
    return cs.surfaceContainerHighest;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(22),
      blurSigma: 14,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cs.surface.withValues(alpha: 0.84),
          cs.surfaceContainerHigh.withValues(alpha: 0.68),
        ],
      ),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(headline, style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusChip(
                label: statusLabel,
                backgroundColor: _tone(context, statusForTone).withValues(alpha: 0.86),
                foregroundColor: cs.onSurface,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LiquidGlassCard(
                padding: const EdgeInsets.all(12),
                borderRadius: BorderRadius.circular(18),
                blurSigma: 10,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _tone(context, item.status).withValues(alpha: 0.84),
                    cs.surface.withValues(alpha: 0.58),
                  ],
                ),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: cs.surface.withValues(alpha: 0.9),
                      child: Text(
                        item.period <= 0 ? '—' : '${item.period}',
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
                            item.courseName ??
                                item.subject ??
                                AppLocalizations.of(context)!.attendanceLessonFallback,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _StatusChip(
                                label: _statusLabel(context, item.status),
                                backgroundColor: cs.surface.withValues(alpha: 0.72),
                                foregroundColor: cs.onSurface,
                              ),
                              _StatusChip(
                                label: (item.subject ?? '').trim().isEmpty
                                    ? AppLocalizations.of(context)!.editProfileSchool
                                    : item.subject!.trim(),
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
      color: cs.surfaceContainerLow.withValues(alpha: 0.8),
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
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.14)),
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
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(20),
      blurSigma: 10,
      color: cs.surface.withValues(alpha: 0.82),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.14)),
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

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(18),
        blurSigma: 10,
        color: cs.surface.withValues(alpha: 0.82),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
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
      blurSigma: 10,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.16)),
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
          _StatusChip(
            label: hint,
            backgroundColor: cs.surface.withValues(alpha: 0.72),
            foregroundColor: cs.onSurface,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      borderRadius: BorderRadius.circular(999),
      blurSigma: 8,
      color: backgroundColor,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.14)),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
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
    return SizedBox(
      height: 92,
      child: LiquidGlassCard(
        borderRadius: BorderRadius.circular(18),
        blurSigma: 8,
        color: cs.surface.withValues(alpha: 0.7),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _LoadingBanner extends StatelessWidget {
  const _LoadingBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      blurSigma: 10,
      color: cs.surface.withValues(alpha: 0.74),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.14)),
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
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      blurSigma: 12,
      color: cs.surfaceContainerLow.withValues(alpha: 0.8),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.24)),
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

class _AttendanceGroupData {
  const _AttendanceGroupData({
    required this.rawDate,
    required this.formattedDate,
    required this.sortDate,
    required this.items,
  });

  final String rawDate;
  final String formattedDate;
  final DateTime? sortDate;
  final List<UnifiedAttendanceInsight> items;
}

class _AttendanceDerivedSummary {
  const _AttendanceDerivedSummary({
    required this.total,
    required this.present,
    required this.late,
    required this.absent,
    required this.excused,
    required this.attendanceRate,
  });

  final int total;
  final int present;
  final int late;
  final int absent;
  final int excused;
  final double? attendanceRate;
}

enum _AttendanceRangeFilter {
  all(null, Icons.all_inclusive_rounded),
  last7Days(7, Icons.view_week_rounded),
  last30Days(30, Icons.calendar_view_month_rounded),
  last90Days(90, Icons.date_range_rounded);

  const _AttendanceRangeFilter(this.days, this.icon);

  final int? days;
  final IconData icon;

  String label(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (this) {
      case _AttendanceRangeFilter.all:
        return l.attendanceRangeAll;
      case _AttendanceRangeFilter.last7Days:
        return l.attendanceRange7;
      case _AttendanceRangeFilter.last30Days:
        return l.attendanceRange30;
      case _AttendanceRangeFilter.last90Days:
        return l.attendanceRange90;
    }
  }

  String shortLabel(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (this) {
      case _AttendanceRangeFilter.all:
        return l.attendanceRangeAllShort;
      case _AttendanceRangeFilter.last7Days:
        return l.attendanceRange7Short;
      case _AttendanceRangeFilter.last30Days:
        return l.attendanceRange30Short;
      case _AttendanceRangeFilter.last90Days:
        return l.attendanceRange90Short;
    }
  }
}
