// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';

// ── providers ──────────────────────────────────────────────────────────────

final _teacherWeekProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, weekOf) => ref.read(teacherMobileRepositoryProvider).fetchWeekSchedule(weekOf: weekOf),
);

// ── helpers ────────────────────────────────────────────────────────────────

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String _ymd(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _weekStartYmd(DateTime d) {
  // Israeli school weeks start on Sunday. Computing Monday-of-week here
  // meant a Sunday view sent the *previous* Monday's weekOf, which made
  // the server emit a 7-day range that didn't include the selected day —
  // hero counted the week's slots but the day list was empty because no
  // day matched. Mirror the student resolver (Sun=0 .. Sat=6) so the
  // selected date is always inside the fetched week.
  final sundayBased = d.weekday % 7;
  final sunday = d.subtract(Duration(days: sundayBased));
  return _ymd(sunday);
}

Color _subjectColor(String subject, ColorScheme cs) {
  final s = subject.toLowerCase();
  if (s.contains('math')) return cs.primary;
  if (s.contains('phys') || s.contains('science')) return const Color(0xFF60A5FA);
  if (s.contains('english') || s.contains('lit')) return const Color(0xFF34D399);
  if (s.contains('arabic') || s.contains('hebrew')) return const Color(0xFFF59E0B);
  if (s.contains('hist') || s.contains('geo')) return const Color(0xFFA78BFA);
  if (s.contains('bio') || s.contains('chem')) return const Color(0xFF22D3EE);
  if (s.contains('cs') || s.contains('comp')) return const Color(0xFFF472B6);
  return cs.secondary;
}

class TeacherScheduleScreen extends ConsumerStatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  ConsumerState<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends ConsumerState<TeacherScheduleScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
  }

  void _shiftDay(int days) =>
      setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = _dateOnly(picked));
  }

  Future<void> _refresh(String weekOf) async {
    ref.invalidate(_teacherWeekProvider(weekOf));
    await ref.read(_teacherWeekProvider(weekOf).future);
  }

  @override
  Widget build(BuildContext context) {
    final weekOf = _weekStartYmd(_selectedDate);
    final weekAsync = ref.watch(_teacherWeekProvider(weekOf));
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return RefreshIndicator(
      onRefresh: () => _refresh(weekOf),
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            // ── Hero card ──────────────────────────────────────────────────
            weekAsync.when(
              data: (data) => _buildHeroCard(context, data, locale),
              loading: () => _buildHeroLoading(context),
              error: (e, _) => _buildHeroError(context, e.toString(), () => _refresh(weekOf)),
            ),
            const SizedBox(height: 16),

            // ── Day picker ─────────────────────────────────────────────────
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
                  _navBtn(context, icon: Icons.chevron_left_rounded, onTap: () => _shiftDay(-1)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _pickDate(context),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
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
                                _friendlyDate(context, _selectedDate, locale),
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
                  _navBtn(context, icon: Icons.chevron_right_rounded, onTap: () => _shiftDay(1)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Day slots ──────────────────────────────────────────────────
            weekAsync.when(
              data: (data) => _buildDaySlots(context, data, l, locale),
              loading: () => const Center(
                child: Padding(padding: EdgeInsets.all(32), child: CmLoading()),
              ),
              error: (e, _) => _buildDayError(context, e.toString(), () => _refresh(weekOf), l),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero card ─────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _slotsForDay(Map<String, dynamic> data, String ymd) {
    final days = data['days'] is List ? data['days'] as List : <dynamic>[];
    final dayData = days.firstWhere(
      (d) => d is Map && (d['date'] ?? '').toString() == ymd,
      orElse: () => null,
    );
    if (dayData is! Map || dayData['slots'] is! List) return [];
    return (dayData['slots'] as List)
        .whereType<Map>()
        .map((s) => Map<String, dynamic>.from(s))
        .toList();
  }

  Map<String, dynamic>? _nextUpSlot(List<Map<String, dynamic>> todaySlots) {
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;
    for (final s in todaySlots) {
      final start = _parseTimeMins((s['startTime'] ?? '').toString());
      if (start >= 0 && start > nowMins) return s;
      // also show if currently running
      final end = _parseTimeMins((s['endTime'] ?? '').toString());
      if (start >= 0 && end >= 0 && nowMins >= start && nowMins < end) return s;
    }
    return null;
  }

  int _parseTimeMins(String hhmm) {
    final p = hhmm.split(':');
    if (p.length != 2) return -1;
    final h = int.tryParse(p[0]) ?? -1;
    final m = int.tryParse(p[1]) ?? -1;
    if (h < 0 || m < 0) return -1;
    return h * 60 + m;
  }

  Widget _buildHeroCard(BuildContext context, Map<String, dynamic> data, String locale) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;
    final days = data['days'] is List ? data['days'] as List : <dynamic>[];
    final selectedYmd = _ymd(_selectedDate);
    final todayYmd = _ymd(_dateOnly(DateTime.now()));
    final isToday = selectedYmd == todayYmd;

    final selectedSlots = _slotsForDay(data, selectedYmd);
    final totalThisWeek = days.fold<int>(0, (sum, d) {
      if (d is Map && d['slots'] is List) return sum + (d['slots'] as List).length;
      return sum;
    });

    final nextUp = isToday ? _nextUpSlot(selectedSlots) : null;

    return LiquidGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(26),
      color: cs.primaryContainer,
      border: Border.all(color: cs.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.navSchedule,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _statPill(
                  context,
                  icon: Icons.today_rounded,
                  label: l.scheduleSelectedDay,
                  value: '${selectedSlots.length}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statPill(
                  context,
                  icon: Icons.date_range_rounded,
                  label: l.teacherWeekScheduleTitle,
                  value: '$totalThisWeek',
                ),
              ),
            ],
          ),
          if (nextUp != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_forward_rounded, size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next up',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          [
                            nextUp['subject']?.toString() ?? 'Period ${nextUp['period']}',
                            if ((nextUp['cohort'] as Map?)?['name'] != null)
                              (nextUp['cohort'] as Map)['name'].toString(),
                            if ((nextUp['startTime'] ?? '').toString().isNotEmpty)
                              '${nextUp['startTime']} – ${nextUp['endTime'] ?? ''}',
                          ].where((s) => s.isNotEmpty).join('  ·  '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onPrimaryContainer,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroLoading(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(26),
      color: cs.surfaceContainerHigh,
      border: Border.all(color: cs.outlineVariant),
      child: const Center(child: Padding(padding: EdgeInsets.all(16), child: CmLoading())),
    );
  }

  Widget _buildHeroError(BuildContext context, String message, VoidCallback onRetry) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(26),
      color: cs.errorContainer,
      border: Border.all(color: cs.error),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.teacherCouldNotLoad, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          FilledButton(onPressed: onRetry, child: Text(l.retry)),
        ],
      ),
    );
  }

  Widget _statPill(BuildContext context, {required IconData icon, required String label, required String value}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.onPrimaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: cs.onPrimaryContainer, fontWeight: FontWeight.w600)),
                Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: cs.onPrimaryContainer, height: 1.1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Day slots ─────────────────────────────────────────────────────────────

  Widget _buildDaySlots(
    BuildContext context,
    Map<String, dynamic> data,
    AppLocalizations l,
    String locale,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final days = data['days'] is List ? data['days'] as List : <dynamic>[];
    final selectedYmd = _ymd(_selectedDate);
    final dayData = days.firstWhere(
      (d) => d is Map && (d['date'] ?? '').toString() == selectedYmd,
      orElse: () => null,
    );

    final slots = dayData is Map && dayData['slots'] is List
        ? (dayData['slots'] as List)
            // Server always emits `period` on every slot (the `course` key
            // was an older shape that's no longer sent); just keep the
            // shape check so a malformed row doesn't crash the list.
            .where((s) => s is Map && s['period'] != null)
            .toList()
        : <dynamic>[];

    if (slots.isEmpty) {
      return LiquidGlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(20),
        color: cs.surfaceContainerLow,
        border: Border.all(color: cs.outlineVariant),
        child: Column(
          children: [
            Icon(Icons.event_available_rounded, size: 40, color: cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              l.scheduleNoClassesTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              l.scheduleNoClassesSubtitle(l.today),
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: slots.map((slot) {
        final s = slot is Map ? Map<String, dynamic>.from(slot) : <String, dynamic>{};
        final period = (s['period'] ?? 0) is int ? s['period'] as int : int.tryParse('${s['period']}') ?? 0;
        final cohortMap = s['cohort'] is Map ? Map<String, dynamic>.from(s['cohort'] as Map<Object?, Object?>) : <String, dynamic>{};
        final subject = (s['subject'] ?? '').toString();
        final caption = (s['caption'] ?? '').toString().trim();
        final cohortName = (cohortMap['name'] ?? '').toString().trim();
        final audienceGrade = (s['audienceGrade'] as num?)?.toInt();
        final studentNames = (s['studentNames'] is List)
            ? (s['studentNames'] as List).map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
            : const <String>[];
        // Resolve the audience line shown alongside / below the subject.
        // Cohort name wins; then "Grade N" when by-grade; otherwise a
        // collapsed list of student names. No times, no period number —
        // those live in the period badge.
        String audienceLine = '';
        if (cohortName.isNotEmpty) {
          audienceLine = cohortName;
        } else if (audienceGrade != null && audienceGrade > 0) {
          audienceLine = 'Grade $audienceGrade';
        } else if (studentNames.isNotEmpty) {
          audienceLine = studentNames.length <= 3
              ? studentNames.join(', ')
              : '${studentNames.take(3).join(', ')} +${studentNames.length - 3}';
        } else {
          audienceLine = l.teacherNoCohort;
        }
        final startTime = (s['startTime'] ?? '').toString();
        final color = _subjectColor(subject, cs);
        final subjectLabel = subject.isNotEmpty ? subject : l.teacherUnassignedSlot;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => _showSlotSheet(context, slot, l),
            borderRadius: BorderRadius.circular(20),
            child: LiquidGlassCard(
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color),
              child: Row(
                children: [
                  // Period badge
                  Container(
                    width: 56,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('P$period', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: cs.onPrimaryContainer)),
                        if (startTime.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(startTime, style: TextStyle(fontSize: 10, color: cs.onPrimaryContainer.withValues(alpha: 0.75))),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: caption.isNotEmpty
                          ? [
                              // With caption: caption above, subject - audience below.
                              Text(
                                caption,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$subjectLabel - $audienceLine',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ]
                          : [
                              Text(
                                subjectLabel,
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                audienceLine,
                                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 16, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayError(BuildContext context, String message, VoidCallback onRetry, AppLocalizations l) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(20),
      color: cs.errorContainer,
      border: Border.all(color: cs.error),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.teacherCouldNotLoad, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          FilledButton(onPressed: onRetry, child: Text(l.retry)),
        ],
      ),
    );
  }

  // ── Slot action sheet ─────────────────────────────────────────────────────

  Future<void> _showSlotSheet(BuildContext context, dynamic slot, AppLocalizations l) async {
    final s = slot is Map ? Map<String, dynamic>.from(slot) : <String, dynamic>{};
    final cohortMap = s['cohort'] is Map ? Map<String, dynamic>.from(s['cohort'] as Map<Object?, Object?>) : <String, dynamic>{};
    final subject = (s['subject'] ?? '').toString();
    final classroomId = (s['classroomId'] ?? '').toString();
    final classroomName = (s['classroomName'] ?? '').toString();
    final cohortName = (cohortMap['name'] ?? '').toString();
    final cohortId = (cohortMap['id'] ?? '').toString();
    final grade = cohortMap['grade'] is int ? cohortMap['grade'] as int : int.tryParse('${cohortMap['grade']}') ?? 0;
    final period = (s['period'] ?? 0) is int ? s['period'] as int : int.tryParse('${s['period']}') ?? 0;
    final slotId = (s['slotId'] ?? '').toString();
    final dateYmd = _ymd(_selectedDate);

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: LiquidGlassCard(
              borderRadius: BorderRadius.circular(24),
              color: cs.surfaceContainerLow,
              border: Border.all(color: cs.outlineVariant),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.isNotEmpty ? subject : l.teacherUnassignedSlot,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                        ),
                        Text(
                          [if (cohortName.isNotEmpty) cohortName, l.teacherPeriod(period)].join(' · '),
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  if (classroomId.isNotEmpty)
                    _SheetAction(
                      icon: Icons.class_rounded,
                      label: l.teacherGoToClassroom,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        context.push('/teacher/classroom/$classroomId', extra: <String, dynamic>{
                          'name': classroomName,
                          'subject': subject,
                          'cohortName': cohortName,
                          'grade': grade,
                        });
                      },
                    ),
                  _SheetAction(
                    icon: Icons.fact_check_rounded,
                    label: l.teacherMarkAttendance,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.push('/teacher/attendance/mark', extra: <String, dynamic>{
                        'cohortId': cohortId,
                        'period': period,
                        'date': dateYmd,
                        'courseId': cohortId,
                        if (slotId.isNotEmpty) 'slotId': slotId,
                      });
                    },
                  ),
                  _SheetAction(
                    icon: Icons.notes_rounded,
                    label: 'Add Class Notes',
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.push('/teacher/attendance/mark', extra: <String, dynamic>{
                        'cohortId': cohortId,
                        'period': period,
                        'date': dateYmd,
                        'courseId': cohortId,
                        if (slotId.isNotEmpty) 'slotId': slotId,
                        'focusNotes': true,
                      });
                    },
                  ),
                  if (slotId.isNotEmpty)
                    _SheetAction(
                      icon: Icons.attach_file_rounded,
                      label: 'Attachments',
                      onTap: () {
                        Navigator.of(ctx).pop();
                        // Pass the period's audience hints so the
                        // "Create new material" shortcut inside the
                        // attachments screen prefills the audience +
                        // subject to match this period.
                        context.push('/teacher/slot/$slotId/attachments', extra: <String, dynamic>{
                          'title': subject.isNotEmpty ? subject : l.teacherUnassignedSlot,
                          if (subject.isNotEmpty) 'subject': subject,
                          if (cohortId.isNotEmpty) 'cohortIds': <String>[cohortId],
                        });
                      },
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Nav button ──────────────────────────────────────────────────────────────

Widget _navBtn(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
  final cs = Theme.of(context).colorScheme;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Icon(icon, size: 20, color: cs.onSurface),
    ),
  );
}

// ── Friendly date ────────────────────────────────────────────────────────────

String _friendlyDate(BuildContext context, DateTime d, String locale) {
  try {
    final weekday = DateFormat.EEEE(locale).format(d);
    return '${MaterialLocalizations.of(context).formatMediumDate(d)} · $weekday';
  } catch (_) {
    return _ymd(d);
  }
}

// ── Sheet action ─────────────────────────────────────────────────────────────

class _SheetAction extends StatelessWidget {
  const _SheetAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
