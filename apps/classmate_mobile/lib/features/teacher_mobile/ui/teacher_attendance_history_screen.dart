import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/util/friendly_date.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/cm_tokens.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../core/semester/school_semester.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/semester_filter_bar.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

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

    return CmRefreshIndicator(
      onRefresh: _load,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          // ── Filter bar ──────────────────────────────────────────────────
          CmCard(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                const CmIconTile(icon: Icons.event_note_rounded, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.teacherAttendanceFrom(fromLabel),
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _pickFrom,
                  icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                  label: Text(l.teacherAttendanceChangeDate),
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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(CmTokens.radiusMd),
              ),
              child: Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onErrorContainer)),
            )
          else if (visible.isEmpty)
            CmEmptyState(icon: Icons.fact_check_outlined, title: l.teacherAttendanceNoSessions)
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
    final dayLabel = dateObj != null ? DateFormat('EEEE, MMM d', DateFormat.localeExists(Localizations.localeOf(context).languageCode) ? Localizations.localeOf(context).languageCode : 'en').format(dateObj) : session.date;
    // Localized ("Period 1"), not the English "1st period" in every language.
    final periodLabel = AppLocalizations.of(context)!.teacherPeriod(session.period);
    final gradeLabel = session.grade != null
        ? '${AppLocalizations.of(context)!.adminCohortGradeFormat(session.grade!)} · '
        : '';
    final total = session.totalStudents;
    // Late students attended — count them as present in the rate (matches the
    // session-detail screen + admin dashboard; only Absent lowers it).
    final attendancePct = total > 0 ? (session.presentCount + session.lateCount) / total : 0.0;

    final tokens = CmTokens.of(context);
    final rateColor = attendancePct >= 0.85
        ? tokens.good
        : attendancePct >= 0.7
            ? tokens.warn
            : cs.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CmCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CmDateStub(date: dateObj, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.courseName,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      CmPill(label: periodLabel, color: color),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$dayLabel  ·  $gradeLabel${session.cohortName}',
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  if (total > 0) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _StatChip(label: '${session.presentCount}', icon: Icons.check_circle_rounded, color: tokens.good),
                              _StatChip(label: '${session.absentCount}', icon: Icons.cancel_rounded, color: cs.error),
                              if (session.lateCount > 0)
                                _StatChip(label: '${session.lateCount}', icon: Icons.schedule_rounded, color: tokens.warn),
                            ],
                          ),
                        ),
                        _RateRing(value: attendancePct, color: rateColor),
                      ],
                    ),
                  ],
                  if ((session.classNote ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: cs.brightness == Brightness.dark ? cs.surfaceContainerHigh : cs.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.notes_rounded, size: 14, color: cs.onSurfaceVariant),
                          const SizedBox(width: 6),
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
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4, top: 2),
              child: Icon(Icons.chevron_right_rounded, size: 20, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Attendance rate as a small ring with the percentage inside.
class _RateRing extends StatelessWidget {
  const _RateRing({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 4,
              strokeCap: StrokeCap.round,
              backgroundColor: cs.outlineVariant.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            '${(value * 100).round()}%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                  fontSize: 10,
                ),
          ),
        ],
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
  Widget build(BuildContext context) => CmPill(label: label, icon: icon, color: color);
}
