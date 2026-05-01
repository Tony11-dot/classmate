// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';

// ── providers ──────────────────────────────────────────────────────────────

final _teacherWeekProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, weekOf) => ref.read(teacherMobileRepositoryProvider).fetchWeekSchedule(weekOf: weekOf),
);

// ── helpers ────────────────────────────────────────────────────────────────

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String _ymd(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _weekStartYmd(DateTime d) {
  final diff = (d.weekday - DateTime.monday) % 7;
  final monday = d.subtract(Duration(days: diff));
  return _ymd(monday);
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
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
                          color: cs.surface.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
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
                child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
              ),
              error: (e, _) => _buildDayError(context, e.toString(), () => _refresh(weekOf), l),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero card ─────────────────────────────────────────────────────────────

  Widget _buildHeroCard(BuildContext context, Map<String, dynamic> data, String locale) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;
    final days = data['days'] is List ? data['days'] as List : <dynamic>[];
    final selectedYmd = _ymd(_selectedDate);
    final dayData = days.firstWhere(
      (d) => (d is Map && (d['date'] ?? '').toString() == selectedYmd),
      orElse: () => null,
    );
    final slots = dayData is Map && dayData['slots'] is List
        ? (dayData['slots'] as List).where((s) => s is Map && (s['course'] is Map)).toList()
        : <dynamic>[];
    final totalThisWeek = days.fold<int>(0, (sum, d) {
      if (d is Map && d['slots'] is List) {
        return sum + (d['slots'] as List).where((s) => s is Map && (s['course'] is Map)).length;
      }
      return sum;
    });

    return LiquidGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(26),
      blurSigma: 18,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cs.primaryContainer.withValues(alpha: 0.95),
          cs.surfaceContainerHigh.withValues(alpha: 0.95),
        ],
      ),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.navSchedule,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statPill(
                  context,
                  icon: Icons.today_rounded,
                  label: l.scheduleSelectedDay,
                  value: '${slots.length}',
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
          const SizedBox(height: 12),
          // Week schedule shortcut
          InkWell(
            onTap: () => context.push('/teacher/schedule/week'),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_view_week_rounded, size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(l.teacherViewFullWeekSchedule,
                      style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary, fontSize: 13)),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, size: 16, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroLoading(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(26),
      blurSigma: 18,
      color: cs.surfaceContainerHigh.withValues(alpha: 0.6),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      child: const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
    );
  }

  Widget _buildHeroError(BuildContext context, String message, VoidCallback onRetry) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(26),
      blurSigma: 12,
      color: cs.errorContainer.withValues(alpha: 0.55),
      border: Border.all(color: cs.error.withValues(alpha: 0.25)),
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
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
                Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: cs.primary, height: 1.1)),
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
            .where((s) => s is Map && (s['course'] is Map || s['period'] != null))
            .toList()
        : <dynamic>[];

    if (slots.isEmpty) {
      return LiquidGlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(20),
        blurSigma: 10,
        color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
        child: Column(
          children: [
            Icon(Icons.event_available_rounded, size: 40, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
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
        final courseMap = s['course'] is Map ? Map<String, dynamic>.from(s['course'] as Map<Object?, Object?>) : <String, dynamic>{};
        final cohortMap = s['cohort'] is Map ? Map<String, dynamic>.from(s['cohort'] as Map<Object?, Object?>) : <String, dynamic>{};
        final courseName = (courseMap['name'] ?? '').toString();
        final subject = (courseMap['subject'] ?? '').toString();
        final cohortName = (cohortMap['name'] ?? '').toString();
        final grade = (cohortMap['grade'] ?? 0);
        final courseId = (courseMap['id'] ?? '').toString();
        final color = _subjectColor(subject, cs);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: courseId.isNotEmpty
                ? () => _showSlotSheet(context, slot, l)
                : null,
            borderRadius: BorderRadius.circular(20),
            child: LiquidGlassCard(
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(20),
              blurSigma: 10,
              gradient: LinearGradient(
                colors: [
                  cs.surface.withValues(alpha: 0.84),
                  cs.surfaceContainerHigh.withValues(alpha: 0.68),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: color.withValues(alpha: 0.22)),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 12, spreadRadius: -4)],
              child: Row(
                children: [
                  // Period badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'P$period',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.isNotEmpty ? subject : (courseName.isNotEmpty ? courseName : l.teacherUnassignedSlot),
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          cohortName.isNotEmpty
                              ? '$cohortName${grade is int && grade > 0 ? ' · Grade $grade' : ''}'
                              : l.teacherNoCohort,
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subject.isNotEmpty ? subject : l.teacherCourseFallback,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                    ),
                  ),
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
      blurSigma: 10,
      color: cs.errorContainer.withValues(alpha: 0.5),
      border: Border.all(color: cs.error.withValues(alpha: 0.22)),
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
    final courseMap = s['course'] is Map ? Map<String, dynamic>.from(s['course'] as Map<Object?, Object?>) : <String, dynamic>{};
    final cohortMap = s['cohort'] is Map ? Map<String, dynamic>.from(s['cohort'] as Map<Object?, Object?>) : <String, dynamic>{};
    final courseId = (courseMap['id'] ?? '').toString();
    final courseName = (courseMap['name'] ?? '').toString();
    final subject = (courseMap['subject'] ?? '').toString();
    final cohortName = (cohortMap['name'] ?? '').toString();
    final cohortId = (cohortMap['id'] ?? '').toString();
    final grade = cohortMap['grade'] is int ? cohortMap['grade'] as int : int.tryParse('${cohortMap['grade']}') ?? 0;
    final period = (s['period'] ?? 0) is int ? s['period'] as int : int.tryParse('${s['period']}') ?? 0;
    final dateYmd = _ymd(_selectedDate);

    if (courseId.isEmpty) return;

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
              blurSigma: 18,
              color: cs.surface.withValues(alpha: 0.96),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outlineVariant.withValues(alpha: 0.5),
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
                          subject.isNotEmpty ? subject : (courseName.isNotEmpty ? courseName : l.teacherUnassignedSlot),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                        ),
                        Text(
                          '$cohortName · ${l.teacherPeriod(period)}',
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  _SheetAction(
                    icon: Icons.class_rounded,
                    label: l.teacherGoToClassroom,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.push('/teacher/classroom/$courseId', extra: <String, dynamic>{
                        'name': courseName,
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
                      context.push('/teacher/attendance', extra: <String, dynamic>{
                        'cohortId': cohortId,
                        'period': period,
                        'date': dateYmd,
                        'courseId': courseId,
                      });
                    },
                  ),
                  _SheetAction(
                    icon: Icons.campaign_rounded,
                    label: l.teacherNewAnnouncementAction,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.push('/teacher/announcements/new');
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
        color: cs.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
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
                color: cs.primaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: cs.primary),
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
