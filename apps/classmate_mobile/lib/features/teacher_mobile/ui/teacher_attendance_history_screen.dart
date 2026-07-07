import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/util/friendly_date.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../core/semester/school_semester.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/semester_filter_bar.dart';

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

String _ordinalPeriod(int period) {
  switch (period) {
    case 1: return '1st';
    case 2: return '2nd';
    case 3: return '3rd';
    default: return '${period}th';
  }
}

String _ymd(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class TeacherAttendanceHistoryScreen extends ConsumerStatefulWidget {
  const TeacherAttendanceHistoryScreen({super.key});

  @override
  ConsumerState<TeacherAttendanceHistoryScreen> createState() =>
      _TeacherAttendanceHistoryScreenState();
}

class _TeacherAttendanceHistoryScreenState
    extends ConsumerState<TeacherAttendanceHistoryScreen> {
  bool _loading = false;
  String? _error;
  bool _showingPrevious = false;
  SemesterWindow? _selectedPast;
  List<TeacherAttendanceSessionSummary> _sessions = const [];

  // Default: last 30 days
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final sessions = await ref
          .read(teacherMobileRepositoryProvider)
          .fetchAttendanceSessions(from: _ymd(_from));
      if (!mounted) return;
      setState(() => _sessions = sessions);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _from,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _from) {
      setState(() => _from = picked);
      await _load();
    }
  }

  void _openSession(TeacherAttendanceSessionSummary s) {
    context.push('/teacher/attendance/mark', extra: <String, dynamic>{
      'cohortId': s.cohortId,
      if ((s.slotId ?? '').isNotEmpty) 'slotId': s.slotId,
      'period': s.period,
      'date': s.date,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fromLabel = FriendlyDate.date(_from);

    // Semester split (by session date) — pills only show when the school
    // configured semesters.
    final semWindow = ref.watch(currentSemesterWindowProvider);
    final visible = visibleForSemester<TeacherAttendanceSessionSummary>(
      _sessions,
      (s) => DateTime.tryParse(s.date),
      semWindow,
      _showingPrevious,
      _selectedPast,
    );

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(16, 12 + MediaQuery.paddingOf(context).top, 16, 28),
        children: [
          // ── Filter bar ──────────────────────────────────────────────────
          LiquidGlassCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Icon(Icons.filter_list_rounded, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.teacherAttendanceFrom(fromLabel),
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                FilledButton.tonal(
                  onPressed: _pickFrom,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  child: Text(l.teacherAttendanceChangeDate),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (semWindow != null) ...[
            SemesterFilterBar(
              showingPrevious: _showingPrevious,
              selectedPast: _selectedPast,
              onPastChanged: (w) => setState(() => _selectedPast = w),
              onChanged: (v) => setState(() { _showingPrevious = v; if (!v) _selectedPast = null; }),
            ),
            const SizedBox(height: 4),
          ],

          // ── Content ─────────────────────────────────────────────────────
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CmLoading()))
          else if (_error != null)
            LiquidGlassCard(
              color: cs.errorContainer,
              child: Text(_error!, style: theme.textTheme.bodyMedium),
            )
          else if (visible.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fact_check_outlined, size: 52, color: cs.outlineVariant),
                    const SizedBox(height: 14),
                    Text(
                      l.teacherAttendanceNoSessions,
                      style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...visible.map((s) => _SessionCard(
              session: s,
              onTap: () => _openSession(s),
            )),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final TeacherAttendanceSessionSummary session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = _subjectColor(session.subject, cs);
    final dateObj = DateTime.tryParse(session.date);
    final dayLabel = dateObj != null ? DateFormat('EEEE, MMM d').format(dateObj) : session.date;
    final periodLabel = '${_ordinalPeriod(session.period)} period';
    final gradeLabel = session.grade != null ? 'Grade ${session.grade} · ' : '';
    final total = session.totalStudents;
    // Late students attended — count them as present in the rate (matches the
    // session-detail screen + admin dashboard; only Absent lowers it).
    final attendancePct = total > 0 ? (session.presentCount + session.lateCount) / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: LiquidGlassCard(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(18),
          child: IntrinsicHeight(
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Color stripe
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              session.courseName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              periodLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dayLabel  ·  $gradeLabel${session.cohortName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (total > 0) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _StatChip(
                              label: '${session.presentCount}',
                              icon: Icons.check_circle_rounded,
                              color: const Color(0xFF22C55E),
                            ),
                            const SizedBox(width: 6),
                            _StatChip(
                              label: '${session.absentCount}',
                              icon: Icons.cancel_rounded,
                              color: cs.error,
                            ),
                            if (session.lateCount > 0) ...[
                              const SizedBox(width: 6),
                              _StatChip(
                                label: '${session.lateCount}',
                                icon: Icons.schedule_rounded,
                                color: const Color(0xFFF59E0B),
                              ),
                            ],
                            const Spacer(),
                            // Attendance rate bar
                            SizedBox(
                              width: 56,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${(attendancePct * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: attendancePct >= 0.85
                                          ? const Color(0xFF22C55E)
                                          : attendancePct >= 0.7
                                              ? const Color(0xFFF59E0B)
                                              : cs.error,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: attendancePct,
                                      minHeight: 5,
                                      backgroundColor: cs.outlineVariant,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        attendancePct >= 0.85
                                            ? const Color(0xFF22C55E)
                                            : attendancePct >= 0.7
                                                ? const Color(0xFFF59E0B)
                                                : cs.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      if ((session.classNote ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.notes_rounded, size: 12, color: cs.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                session.classNote!.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsetsDirectional.only(end: 12),
                child: Icon(Icons.chevron_right_rounded, size: 20),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}
