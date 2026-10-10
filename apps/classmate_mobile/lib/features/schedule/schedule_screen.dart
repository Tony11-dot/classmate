import 'package:classmate_mobile/core/theme/cm_tokens.dart';
import 'package:classmate_mobile/ui/widgets/cm_press.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'providers/schedule_providers.dart';
import 'schedule_empty_state_copy.dart';
import '../../core/http/cm_api.dart';
import '../../core/util/friendly_date.dart';
import '../../core/util/bidi.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/cm_loading.dart';
import '../class_materials/ui/class_materials_section.dart';
import '../lifedoc/data/exams_repository.dart';
import '../lifedoc/domain/exam_models.dart';
import '../../ui/widgets/cm_refresh_indicator.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Attendance helpers shared across the schedule tile and detail sheet
// ─────────────────────────────────────────────────────────────────────────────

Color _attendanceColor(BuildContext context, String status) {
  final cs = Theme.of(context).colorScheme;
  switch (status.toUpperCase()) {
    case 'PRESENT': return CmTokens.of(context).goodContainer;
    case 'ABSENT': return cs.errorContainer;
    case 'LATE': return CmTokens.of(context).warnContainer;
    case 'EXCUSED':
    case 'JUSTIFIED': return cs.primaryContainer;
    default: return cs.surfaceContainerHighest;
  }
}

Color _attendanceFg(BuildContext context, String status) {
  final cs = Theme.of(context).colorScheme;
  switch (status.toUpperCase()) {
    case 'PRESENT': return CmTokens.of(context).onGoodContainer;
    case 'ABSENT': return cs.onErrorContainer;
    case 'LATE': return CmTokens.of(context).onWarnContainer;
    case 'EXCUSED':
    case 'JUSTIFIED': return cs.onPrimaryContainer;
    default: return cs.onSurfaceVariant;
  }
}

String _attendanceLabel(BuildContext context, String status) {
  final l = AppLocalizations.of(context)!;
  switch (status.toUpperCase()) {
    case 'PRESENT': return l.attendanceStatusPresent;
    case 'ABSENT': return l.attendanceStatusAbsent;
    case 'LATE': return l.attendanceStatusLate;
    case 'EXCUSED':
    case 'JUSTIFIED': return l.attendanceStatusExcused;
    default: return status;
  }
}

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late DateTime _selectedDate;

  String _friendlyScheduleError(AppLocalizations l, Object error) {
    if (error is CMApiException) {
      if (error.statusCode == 429) return l.scheduleRefreshTooFast;
      if (error.statusCode == 401) return l.scheduleSessionExpired;
      final body = error.body.toLowerCase();
      if (body.contains('not onboarded') || body.contains('not assigned')) {
        return l.scheduleNotOnboarded;
      }
      return l.scheduleLoadError;
    }
    final raw = error.toString().toLowerCase();
    if (raw.contains('too many requests')) return l.scheduleRefreshTooFast;
    if (raw.contains('not onboarded') || raw.contains('not assigned')) return l.scheduleNotOnboarded;
    return l.scheduleLoadError;
  }

  Future<void> _retryWeek(String weekOf) async {
    ref.invalidate(weekScheduleProvider(weekOf));
    await ref.read(weekScheduleProvider(weekOf).future);
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
    // Invalidate on every open so stale cached data never gets stuck.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weekOf = _weekStartYmd(_selectedDate);
      ref.invalidate(weekScheduleProvider(weekOf));
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekOf = _weekStartYmd(_selectedDate);
    final weekAsync = ref.watch(weekScheduleProvider(weekOf));
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;

    return CmRefreshIndicator(
      onRefresh: () => _retryWeek(weekOf),
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v < -50) {
            _shiftDay(1);
          } else if (v > 50) {
            _shiftDay(-1);
          }
        },
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(),
          // Bottom padding accounts for the shell's bottom nav bar +
          // iPhone home indicator so the last period tile isn't clipped.
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            weekAsync.when(
              data: (data) => _heroCard(context, data),
              loading: () => _heroLoadingCard(context),
              error: (error, _) =>
                  _heroErrorCard(context, _friendlyScheduleError(l, error), () {
                    _retryWeek(weekOf);
                  }),
            ),
            const SizedBox(height: 16),
            // Week strip: the 7 days of the selected week, tap to jump. The
            // ‹ › arrows still step one day and the date opens the picker.
            Container(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(CmTokens.radiusXl),
                boxShadow: CmTokens.of(context).shadowSm,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _navBtn(
                        context,
                        icon: Icons.chevron_left_rounded,
                        tooltip: AppLocalizations.of(context)!.a11yPrevious,
                        onTap: () => _shiftDay(-1),
                      ),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _pickDate(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_month_rounded,
                                    size: 18, color: cs.primary),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '${_friendlyDate(context, _selectedDate)} · ${_weekdayLong(context, _selectedDate)}',
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _navBtn(
                        context,
                        icon: Icons.chevron_right_rounded,
                        tooltip: AppLocalizations.of(context)!.a11yNext,
                        onTap: () => _shiftDay(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _weekStrip(context, weekAsync.asData?.value),
                ],
              ),
            ),
            const SizedBox(height: 16),
            weekAsync.when(
              data: (data) => _daySection(context, data),
              loading: () => const _LoadingState(),
              error: (error, _) => _ErrorState(
                message: _friendlyScheduleError(l, error),
                onRetry: () {
                  _retryWeek(weekOf);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(BuildContext context, Map<String, dynamic> data) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;
    final days = _weekDays(data);
    final selectedItems = _itemsForSelectedDate(data);
    final next = selectedItems.isNotEmpty ? selectedItems.first : null;
    final upcomingExam = _nextUpcomingExam();

    final weekTotal = days.fold<int>(
      0,
      (sum, day) => sum + (((day['items'] as List?)?.length) ?? 0),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer,
            Color.alphaBlend(
                cs.primary.withValues(alpha: 0.16), cs.primaryContainer),
          ],
        ),
        borderRadius: BorderRadius.circular(CmTokens.radiusXl),
        boxShadow: CmTokens.of(context).shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.onPrimaryContainer.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.event_note_rounded,
                    color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.titleSchedule,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Counts side by side; "Next up" and the exam get full rows so
          // the class name and exam date are never cut off on a phone.
          LayoutBuilder(builder: (context, c) {
            final w = (c.maxWidth - 10) / 2;
            final full = c.maxWidth;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // The two counts stay the same height when a longer label
                // (French, Russian, large text) wraps to a second line.
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: w,
                        child: _statPill(
                          context,
                          icon: Icons.today_rounded,
                          label: l.scheduleSelectedDay,
                          value: l.scheduleClassCount(selectedItems.length),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: w,
                        child: _statPill(
                          context,
                          icon: Icons.calendar_view_week_rounded,
                          label: l.thisWeek,
                          value: l.scheduleClassCount(weekTotal),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: full,
                  child: _statPill(
                    context,
                    icon: Icons.schedule_rounded,
                    label: l.scheduleNextUp,
                    value: next == null
                        ? l.scheduleNoMoreClasses
                        : '${_timeLabel(next)} • ${_titleOf(context, next)}',
                  ),
                ),
                // Tappable — jumps to the Exams tab (top pill switches to
                // Exams, drawer highlights Exams, bottom nav hides — all
                // driven by the /exams route in the shell).
                SizedBox(
                  width: full,
                  child: _statPill(
                    context,
                    icon: Icons.quiz_rounded,
                    label: l.scheduleUpcomingExam,
                    value: upcomingExam == null
                        ? l.scheduleNoUpcomingExams
                        : '${FriendlyDate.date(upcomingExam.dateLabel, Localizations.localeOf(context).toString())} • ${upcomingExam.title}',
                    onTap: () => context.go('/exams'),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Sun–Sat strip of the selected week. A dot per class (max 3) under each
  /// day; today gets a ring, the selected day is filled.
  Widget _weekStrip(BuildContext context, Map<String, dynamic>? data) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final start = DateTime.parse(_weekStartYmd(_selectedDate));
    final today = _dateOnly(DateTime.now());
    final counts = <String, int>{
      for (final d in _weekDays(data))
        (d['date'] ?? '').toString(): ((d['items'] as List?)?.length ?? 0),
    };
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Builder(builder: (context) {
            final day = _dateOnly(start.add(Duration(days: i)));
            final selected = _ymd(day) == _ymd(_selectedDate);
            final isToday = _ymd(day) == _ymd(today);
            final n = counts[_ymd(day)] ?? 0;
            String wd;
            try {
              wd = DateFormat.E(locale).format(day);
            } catch (_) {
              wd = DateFormat.E().format(day);
            }
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: CmPress(
                  onTap: () => setState(() => _selectedDate = day),
                  child: AnimatedContainer(
                    duration: CmTokens.medium,
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? cs.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isToday && !selected
                            ? cs.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          wd,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: selected
                                ? cs.onPrimary.withValues(alpha: 0.85)
                                : cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: selected ? cs.onPrimary : cs.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var k = 0; k < (n > 3 ? 3 : n); k++)
                                Container(
                                  width: 5,
                                  height: 5,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: selected
                                        ? cs.onPrimary
                                        : cs.primary.withValues(alpha: 0.6),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _heroLoadingCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      height: 120,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Center(child: CmLoading()),
    );
  }

  Widget _heroErrorCard(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.titleSchedule,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28, color: cs.onErrorContainer),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: cs.onErrorContainer),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l.retry),
          ),
        ],
      ),
    );
  }

  Widget _navBtn(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: cs.surfaceContainerHigh,
        fixedSize: const Size(44, 44),
      ),
      icon: Icon(icon),
    );
  }

  Widget _daySection(BuildContext context, Map<String, dynamic> data) {
    final l = AppLocalizations.of(context)!;
    final items = _itemsForSelectedDate(data);

    if (items.isEmpty) {
      return _EmptyState(
        icon: Icons.free_breakfast_rounded,
        title: ScheduleEmptyStateCopy.title(l),
        subtitle: ScheduleEmptyStateCopy.subtitle(
          l,
          _weekdayLong(context, _selectedDate),
        ),
      );
    }

    final sorted = [...items]
      ..sort((a, b) {
        final ap = (a['period'] as num?)?.toInt() ?? 999;
        final bp = (b['period'] as num?)?.toInt() ?? 999;
        if (ap != bp) return ap.compareTo(bp);
        return _startsAt(a).compareTo(_startsAt(b));
      });

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Attendance map for today — silently empty on error.
    final isToday = _ymd(_selectedDate) == _ymd(_dateOnly(DateTime.now()));
    final attendanceAsync = ref.watch(todayAttendanceProvider);
    final attendanceMap = isToday
        ? (attendanceAsync.asData?.value ?? const <String, String>{})
        : const <String, String>{};

    // Current time in HH:mm for "NOW" indicator
    final nowMinutes = isToday ? _nowMinutes() : -1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _weekdayLong(context, _selectedDate),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _friendlyDate(context, _selectedDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  AppLocalizations.of(context)!.scheduleClassCount(sorted.length),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...sorted.map(
          (item) {
            final period = (item['period'] as num?)?.toInt() ?? 0;
            final subject = (item['subject'] ?? '').toString().trim().toLowerCase();
            final courseId = (item['courseId'] ?? '').toString().trim();
            final inlineStatus = (item['attendanceStatus'] ??
                item['status'] ??
                item['attendance'] ?? '').toString().trim().toUpperCase();
            String status = inlineStatus;
            if (status.isEmpty) {
              status = attendanceMap['$period:$subject'] ??
                  attendanceMap['course:$courseId'] ??
                  attendanceMap['period:$period'] ??
                  '';
            }
            final isCurrent = nowMinutes >= 0 &&
                _isCurrentPeriod(item, nowMinutes);
            return _ScheduleTile(
              item: item,
              attendanceStatus: status,
              isCurrent: isCurrent,
              isLast: identical(item, sorted.last),
            );
          },
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() => _selectedDate = _dateOnly(picked));
  }

  void _shiftDay(int delta) {
    setState(() {
      _selectedDate = _dateOnly(_selectedDate.add(Duration(days: delta)));
    });
  }

  List<Map<String, dynamic>> _weekDays(Map<String, dynamic>? data) {
    final raw = ((data ?? const {})['days']) as List?;
    return raw
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _itemsForSelectedDate(Map<String, dynamic>? data) {
    final date = _ymd(_selectedDate);
    final days = _weekDays(data);
    final match = days.cast<Map<String, dynamic>?>().firstWhere(
      (d) => (d?['date']?.toString() ?? '') == date,
      orElse: () => null,
    );

    if (match == null) return <Map<String, dynamic>>[];

    final raw = (match['items'] as List?) ?? const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Soonest exam that is today or later, from the live exams feed. Returns
  /// null while loading, on error, or when there are no upcoming exams.
  StudentExamItem? _nextUpcomingExam() {
    final exams = ref.watch(examsLiveProvider).asData?.value;
    if (exams == null || exams.isEmpty) return null;
    final todayStart = _dateOnly(DateTime.now());
    StudentExamItem? best;
    DateTime? bestWhen;
    for (final e in exams) {
      final when = DateTime.tryParse(e.dateLabel);
      if (when == null) continue;
      if (_dateOnly(when).isBefore(todayStart)) continue;
      if (bestWhen == null || when.isBefore(bestWhen)) {
        best = e;
        bestWhen = when;
      }
    }
    return best;
  }

  int _nowMinutes() {
    final now = DateTime.now();
    return now.hour * 60 + now.minute;
  }

  int _timeToMinutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return -1;
    final h = int.tryParse(parts[0]) ?? -1;
    final m = int.tryParse(parts[1]) ?? -1;
    if (h < 0 || m < 0) return -1;
    return h * 60 + m;
  }

  bool _isCurrentPeriod(Map<String, dynamic> item, int nowMins) {
    final start = _timeToMinutes((item['startsAt'] ?? '').toString());
    final end = _timeToMinutes((item['endsAt'] ?? '').toString());
    if (start < 0 || end < 0) return false;
    return nowMins >= start && nowMins < end;
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _ymd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String _weekStartYmd(DateTime d) {
    final local = _dateOnly(d);
    final sundayBased = local.weekday % 7;
    final start = local.subtract(Duration(days: sundayBased));
    return _ymd(start);
  }

  String _friendlyDate(BuildContext context, DateTime date) {
    try {
      return MaterialLocalizations.of(context).formatMediumDate(date);
    } catch (_) {
      return _ymd(date);
    }
  }

  String _weekdayLong(BuildContext context, DateTime date) {
    // Just the weekday ("vendredi", "пятница"). Cutting the full date at its
    // first comma doesn't work in French, which has none.
    try {
      return DateFormat.EEEE(Localizations.localeOf(context).toString()).format(date);
    } catch (_) {}
    try {
      final fullDate = MaterialLocalizations.of(context).formatFullDate(date);
      final parts = fullDate.split(RegExp(r'[,،]'));
      return parts.first.trim().isEmpty ? fullDate : parts.first.trim();
    } catch (_) {
      return _ymd(date);
    }
  }

  String _startsAt(Map<String, dynamic> item) => '${item['startsAt'] ?? ''}';
  String _timeLabel(Map<String, dynamic> item) =>
      ltrIsolate('${item['startsAt'] ?? '--:--'}–${item['endsAt'] ?? '--:--'}');
  String _titleOf(BuildContext context, Map<String, dynamic> item) =>
      '${item['title'] ?? AppLocalizations.of(context)!.scheduleClassFallback}';
}

Widget _statPill(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String value,
  VoidCallback? onTap,
}) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;

  final content = Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: cs.surface.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: cs.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
        ],
      ],
    ),
  );

  return onTap == null ? content : CmPress(onTap: onTap, child: content);
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.item,
    this.attendanceStatus = '',
    this.isCurrent = false,
    this.isLast = false,
  });

  final Map<String, dynamic> item;
  final String attendanceStatus;
  final bool isCurrent;
  final bool isLast;

  void _openDetail(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final title = '${item['title'] ?? l.scheduleClassFallback}';
    final subject = (item['subject'] ?? '').toString().trim();
    final caption = (item['caption'] ?? '').toString().trim();
    final location = (item['location'] ?? '').toString().trim();
    final teacherName = (item['teacherName'] ?? '').toString().trim();
    final startsAt = '${item['startsAt'] ?? '--:--'}';
    final endsAt = '${item['endsAt'] ?? '--:--'}';
    final notes = (item['notes'] ?? item['note'] ?? item['classNote'] ??
        item['teacherNote'] ?? item['description'] ?? '').toString().trim();
    final period = (item['period'] as num?)?.toInt();
    final slotId = (item['id'] ?? item['slotId'] ?? '').toString().trim();
    final hasStatus = attendanceStatus.isNotEmpty;
    // Date label — derived from item.date (server YMD) when present so
    // the sheet shows "Monday · May 24" even if the user is browsing a
    // past/future week.
    final dateStr = (item['date'] ?? '').toString().trim();
    String? dayLabel;
    if (dateStr.isNotEmpty) {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) {
        final locale = Localizations.localeOf(context).toString();
        dayLabel = '${DateFormat.EEEE(locale).format(parsed)} · ${DateFormat.MMM(locale).format(parsed)} ${parsed.day}';
      }
    }
    final attachments = (item['attachments'] is List)
        ? (item['attachments'] as List).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList()
        : const <Map<String, dynamic>>[];

    // useRootNavigator pushes the sheet onto the root navigator stack
    // — that's the only level above the StatefulShellRoute bottom nav,
    // so the sheet no longer renders beneath it.
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (caption.isNotEmpty) ...[
                          Text(caption,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 2),
                        ],
                        Text(title,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        // Only show the subject when it adds information — when
                        // it's identical to the title it just read as the same
                        // name printed twice (QA #73).
                        if (subject.isNotEmpty &&
                            subject.toLowerCase() != title.trim().toLowerCase()) ...[
                          const SizedBox(height: 2),
                          Text(subject,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                  ),
                  if (hasStatus) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _attendanceColor(ctx, attendanceStatus),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _attendanceLabel(ctx, attendanceStatus),
                        style: TextStyle(
                          color: _attendanceFg(ctx, attendanceStatus),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              // Info pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (dayLabel != null)
                    _InfoPill(
                      icon: Icons.calendar_today_rounded,
                      label: dayLabel,
                      cs: cs,
                      theme: theme,
                    ),
                  _InfoPill(
                    icon: Icons.access_time_rounded,
                    label: '$startsAt – $endsAt',
                    cs: cs,
                    theme: theme,
                  ),
                  if (period != null)
                    _InfoPill(
                      icon: Icons.tag_rounded,
                      label: l.teacherPeriod(period),
                      cs: cs,
                      theme: theme,
                    ),
                  if (teacherName.isNotEmpty)
                    _InfoPill(
                      icon: Icons.person_rounded,
                      label: teacherName,
                      cs: cs,
                      theme: theme,
                    ),
                  if (location.isNotEmpty)
                    _InfoPill(
                      icon: Icons.room_rounded,
                      label: location,
                      cs: cs,
                      theme: theme,
                    ),
                ],
              ),
              // Notes
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.50),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notes_rounded, size: 16, color: cs.primary),
                          const SizedBox(width: 6),
                          Text(
                            l.scheduleScreenNotes,
                            style: theme.textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.w800, color: cs.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(notes,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
              // (Go-to-classroom dropped — classrooms are independent of
              // periods now; the schedule grid is the source of truth for
              // what's happening when.)

              // Materials — the period's materials (teacher- and student-added)
              // shown as tappable pills, with a "+" to add your own. Subject +
              // audience are inherited from the period; you only give a title +
              // files. Same single Materials system as the drawer tab.
              if (slotId.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 14),
                ClassMaterialsSection(
                  slotId: slotId,
                  date: dateStr,
                  initial: attachments.map((m) {
                    final mTitle = (m['title'] ?? m['name'] ?? l.scheduleScreenMaterialFallback).toString();
                    final mUrl = (m['url'] ?? '').toString();
                    final mMime = (m['mime'] ?? '').toString().toLowerCase();
                    final lowerUrl = mUrl.toLowerCase();
                    String type = 'file';
                    if (mMime.contains('pdf') || lowerUrl.endsWith('.pdf')) {
                      type = 'pdf';
                    } else if (mMime.contains('image') ||
                        lowerUrl.endsWith('.jpg') ||
                        lowerUrl.endsWith('.jpeg') ||
                        lowerUrl.endsWith('.png') ||
                        lowerUrl.endsWith('.webp')) {
                      type = 'image';
                    } else if (mUrl.startsWith('http')) {
                      type = 'link';
                    }
                    return <String, dynamic>{'url': mUrl, 'name': mTitle, 'type': type};
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;

    // Tile prints just "subject - teacher" (with an optional caption
    // floating above). Location/period chip dropped — admins didn't want
    // any of the secondary metadata in the grid.
    final subject = (item['subject'] ?? '').toString().trim();
    final rawTitle = '${item['title'] ?? ''}'.trim();
    final title = subject.isNotEmpty
        ? subject
        : (rawTitle.isNotEmpty ? rawTitle : l.scheduleClassFallback);
    final caption = (item['caption'] ?? '').toString().trim();
    final teacherName = (item['teacherName'] ?? '').toString().trim();
    final startsAt = '${item['startsAt'] ?? '--:--'}';
    final endsAt = '${item['endsAt'] ?? '--:--'}';
    final courseId = (item['courseId'] ?? '').toString().trim();
    final period = (item['period'] as num?)?.toInt();
    final attachmentCount = (item['attachments'] is List)
        ? (item['attachments'] as List).length
        : 0;
    final hasStatus = attendanceStatus.isNotEmpty;

    // Subtitle: just the teacher's name. Subject is already in the title
    // (or just above as caption); location intentionally dropped.
    final subtitle = teacherName;

    // Timeline row:  time rail │ node │ card. The current class gets a
    // filled node + primary card; attended classes tint their edge.
    final edgeColor = hasStatus
        ? _attendanceFg(context, attendanceStatus).withValues(alpha: 0.35)
        : cs.outlineVariant.withValues(alpha: 0.3);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            // Grows with large text so "08:00" never breaks in two.
            width: MediaQuery.textScalerOf(context).scale(50).clamp(50.0, 110.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(startsAt,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isCurrent ? cs.primary : cs.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      )),
                  Text(endsAt,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      )),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Container(
                  width: isCurrent ? 14 : 10,
                  height: isCurrent ? 14 : 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent ? cs.primary : cs.surface,
                    border: Border.all(color: cs.primary, width: 2.5),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 4),
                      color: cs.primary.withValues(alpha: 0.18),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CmPress(
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: isCurrent ? cs.primaryContainer : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(CmTokens.radiusLg),
          border: Border.all(
            color: isCurrent ? cs.primary.withValues(alpha: 0.5) : edgeColor,
            width: isCurrent || hasStatus ? 1.2 : 0.8,
          ),
          boxShadow: isCurrent
              ? CmTokens.of(context).shadowMd
              : CmTokens.of(context).shadowSm,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 8, 12),
          child: Row(
            children: [
              if (isCurrent) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l.scheduleScreenNow,
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header line: caption (if any) + period badge.
                    // Layout below: subject - teacher (big).
                    if (caption.isNotEmpty || period != null) ...[
                      Row(
                        children: [
                          if (period != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                l.teacherPeriod(period),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            if (caption.isNotEmpty) const SizedBox(width: 6),
                          ],
                          if (caption.isNotEmpty)
                            Expanded(
                              child: Text(
                                caption,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: isCurrent ? cs.onPrimaryContainer : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (attachmentCount > 0) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.attach_file_rounded,
                                  size: 12, color: cs.onSecondaryContainer),
                              const SizedBox(width: 4),
                              Text(
                                l.scheduleScreenMaterialCount(attachmentCount),
                                style: TextStyle(
                                  color: cs.onSecondaryContainer,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (hasStatus) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _attendanceColor(
                                context, attendanceStatus),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _attendanceLabel(context, attendanceStatus),
                            style: TextStyle(
                              color: _attendanceFg(
                                  context, attendanceStatus),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                courseId.isEmpty
                    ? Icons.info_outline_rounded
                    : Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label, required this.cs, required this.theme});
  final IconData icon;
  final String label;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.primary),
          const SizedBox(width: 5),
          Text(label,
              style: theme.textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CmLoading()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 34, color: cs.onErrorContainer),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.scheduleLoadError,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: cs.onErrorContainer),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: cs.onErrorContainer),
          ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                      color: cs.primaryContainer, shape: BoxShape.circle),
                  child: Icon(icon, size: 30, color: cs.onPrimaryContainer),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
