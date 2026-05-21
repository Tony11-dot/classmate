import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'providers/schedule_providers.dart';
import 'schedule_empty_state_copy.dart';
import '../../core/http/cm_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/cm_loading.dart';
import '../../ui/widgets/attachment_pill.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Attendance helpers shared across the schedule tile and detail sheet
// ─────────────────────────────────────────────────────────────────────────────

Color _attendanceColor(BuildContext context, String status) {
  final cs = Theme.of(context).colorScheme;
  switch (status.toUpperCase()) {
    case 'PRESENT': return cs.secondaryContainer;
    case 'ABSENT': return cs.errorContainer;
    case 'LATE': return cs.tertiaryContainer;
    case 'EXCUSED':
    case 'JUSTIFIED': return cs.primaryContainer;
    default: return cs.surfaceContainerHighest;
  }
}

Color _attendanceFg(BuildContext context, String status) {
  final cs = Theme.of(context).colorScheme;
  switch (status.toUpperCase()) {
    case 'PRESENT': return cs.onSecondaryContainer;
    case 'ABSENT': return cs.onErrorContainer;
    case 'LATE': return cs.onTertiaryContainer;
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

    return RefreshIndicator(
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  _navBtn(
                    context,
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _shiftDay(-1),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _pickDate(context),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 18),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '${_friendlyDate(context, _selectedDate)} · ${_weekdayLong(context, _selectedDate)}',
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _navBtn(
                    context,
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _shiftDay(1),
                  ),
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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.titleSchedule,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _statPill(
                context,
                icon: Icons.today_rounded,
                label: l.scheduleSelectedDay,
                value: l.scheduleClassCount(selectedItems.length),
              ),
              _statPill(
                context,
                icon: Icons.calendar_view_week_rounded,
                label: l.thisWeek,
                value: l.scheduleClassCount(
                  days.fold<int>(
                    0,
                    (sum, day) => sum + (((day['items'] as List?)?.length) ?? 0),
                  ),
                ),
              ),
              _statPill(
                context,
                icon: Icons.schedule_rounded,
                label: l.scheduleNextUp,
                value: next == null
                    ? l.scheduleNoMoreClasses
                    : '${_timeLabel(next)} • ${_titleOf(context, next)}',
              ),
            ],
          ),
        ],
      ),
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
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Icon(icon),
      ),
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
        Text(
          _weekdayLong(context, _selectedDate),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _friendlyDate(context, _selectedDate),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
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
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ScheduleTile(
                item: item,
                attendanceStatus: status,
                isCurrent: isCurrent,
              ),
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
      '${item['startsAt'] ?? '--:--'}–${item['endsAt'] ?? '--:--'}';
  String _titleOf(BuildContext context, Map<String, dynamic> item) =>
      '${item['title'] ?? AppLocalizations.of(context)!.scheduleClassFallback}';
}

Widget _statPill(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String value,
}) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;

  return ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 150),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.item,
    this.attendanceStatus = '',
    this.isCurrent = false,
  });

  final Map<String, dynamic> item;
  final String attendanceStatus;
  final bool isCurrent;

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
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
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
                        if (subject.isNotEmpty) ...[
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
              // Attachments — tappable material pills. Wired to
              // item['attachments'] (the server attaches the resolved
              // material list per slot). Quietly empty when nothing's
              // attached.
              if (attachments.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.attach_file_rounded, size: 16, color: cs.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Attachments',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Material pills — title is the pill text, tapping opens
                // PDFs/images in-app via the shared AttachmentPill widget.
                AttachmentPills(
                  attachments: attachments.map((m) {
                    final mTitle = (m['title'] ?? m['name'] ?? 'Material').toString();
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
              // Notes
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.50),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notes_rounded, size: 16, color: cs.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Notes',
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
            ],
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

    final borderColor = isCurrent
        ? cs.primary
        : hasStatus
            ? _attendanceColor(context, attendanceStatus).withValues(alpha: 0.60)
            : cs.outlineVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: isCurrent
              ? cs.primaryContainer.withValues(alpha: 0.18)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor,
            width: isCurrent ? 2 : (hasStatus ? 1.5 : 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Time block
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: 68,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isCurrent ? cs.primary : cs.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Text(startsAt,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isCurrent ? cs.onPrimary : null,
                            )),
                        const SizedBox(height: 2),
                        Text(endsAt,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isCurrent
                                  ? cs.onPrimary.withValues(alpha: 0.75)
                                  : cs.onSurfaceVariant,
                            )),
                      ],
                    ),
                  ),
                  if (isCurrent)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: cs.surface, width: 1.5),
                        ),
                        child: Text(
                          'NOW',
                          style: TextStyle(
                            color: cs.onPrimary,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
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
                                borderRadius: BorderRadius.circular(6),
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
                        alignment: Alignment.centerLeft,
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
                                attachmentCount == 1
                                    ? '1 material'
                                    : '$attachmentCount materials',
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
                        alignment: Alignment.centerLeft,
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
        border: Border.all(color: cs.outlineVariant),
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
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 36, color: cs.onSurfaceVariant),
                const SizedBox(height: 12),
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
