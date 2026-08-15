import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/http/cm_api.dart';
import '../../../core/realtime/realtime_listener.dart';
import '../../schedule/schedule_empty_state_copy.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

Future<void> _showSlotActionSheet(
  BuildContext context,
  TeacherTodaySlot slot,
  String date,
) async {
  final course = slot.course;
  final cohort = slot.cohort;
  if (course == null || cohort == null) return;

  final l = AppLocalizations.of(context)!;

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
                Container(width: 36, height: 4,
                    decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.name.isNotEmpty ? course.name : course.subject,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                      Text('${cohort.name} · ${l.teacherPeriod(slot.period)}',
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
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
                    context.push('/teacher/classroom/${course.id}', extra: <String, dynamic>{
                      'name': course.name,
                      'subject': course.subject,
                      'cohortName': cohort.name,
                      'grade': cohort.grade,
                    });
                  },
                ),
                _SheetAction(
                  icon: Icons.fact_check_rounded,
                  label: l.teacherMarkAttendance,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    context.push('/teacher/attendance/mark', extra: <String, dynamic>{
                      'cohortId': cohort.id,
                      'period': slot.period,
                      'date': date,
                      'courseId': course.id,
                    });
                  },
                ),
                _SheetAction(
                  icon: Icons.assignment_rounded,
                  label: l.teacherPostAssignment,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    context.push('/teacher/classroom/${course.id}', extra: <String, dynamic>{
                      'name': course.name,
                      'subject': course.subject,
                      'cohortName': cohort.name,
                      'grade': cohort.grade,
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
              width: 36, height: 36,
              decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(10)),
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

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  TeacherTodaySchedule? _today;
  TeacherAssessmentBundle? _bundle;
  List<Map<String, dynamic>> _assignments = const [];
  int _examsCount = 0;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final values = await Future.wait<dynamic>([
        repo.fetchTodaySchedule(),
        repo.fetchAssessments(),
        repo.listTeacherAssignments().catchError((_) => <Map<String, dynamic>>[]),
        repo.listTeacherExams().catchError((_) => <Map<String, dynamic>>[]),
      ]);
      if (!mounted) return;
      setState(() {
        _today = values[0] as TeacherTodaySchedule;
        _bundle = values[1] as TeacherAssessmentBundle;
        _assignments = (values[2] as List).cast<Map<String, dynamic>>();
        _examsCount = (values[3] as List).length;
        _loading = false;
      });
    } on CMApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        await ref.read(authSessionProvider).logout();
        if (!mounted) return;
        context.go('/login');
        return;
      }
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  /// Upcoming = exams + assignments THIS teacher posted that are still
  /// ahead in time (not yet due/sat), merged and sorted soonest-first.
  List<({DateTime when, String title, String subtitle, bool isExam})> _buildUpcoming() {
    final bundle = _bundle;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final items = <({DateTime when, String title, String subtitle, bool isExam})>[];

    for (final a in bundle?.assessments ?? const <TeacherAssessment>[]) {
      final dt = DateTime.tryParse(a.date);
      if (dt == null || dt.isBefore(todayStart)) continue;
      final courseName = bundle == null
          ? ''
          : bundle.courses
              .firstWhere((c) => c.id == a.courseId,
                  orElse: () => TeacherCourse(id: '', name: '', subject: '', cohortId: ''))
              .name;
      items.add((when: dt, title: a.title, subtitle: courseName, isExam: true));
    }

    for (final m in _assignments) {
      final dt = DateTime.tryParse((m['dueAt'] ?? m['date'] ?? '').toString());
      if (dt == null || dt.isBefore(todayStart)) continue;
      items.add((
        when: dt,
        title: (m['title'] ?? '').toString(),
        subtitle: (m['subject'] ?? m['courseName'] ?? '').toString(),
        isExam: false,
      ));
    }

    items.sort((a, b) => a.when.compareTo(b.when));
    return items.take(5).toList(growable: false);
  }

  String _greeting(AppLocalizations l) {
    final h = DateTime.now().hour;
    if (h < 12) return l.teacherGreetingMorning;
    if (h < 17) return l.teacherGreetingAfternoon;
    return l.teacherGreetingEvening;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;
    final session = ref.read(authSessionProvider);
    final bundle = _bundle;
    final today = _today;
    // A teacher slot is renderable as long as it has a period number —
    // course / cohort are now optional (slot may target by-grade or
    // by-student audience and have no cohort attached at all).
    final scheduledSlots = today?.slots
            .where((slot) => slot.period > 0)
            .toList(growable: false) ??
        const <TeacherTodaySlot>[];
    final upcoming = _buildUpcoming();
    final teachingGroups = (bundle?.courses.map((c) => c.cohortId).where((id) => id.isNotEmpty).toSet().length) ?? 0;
    final teacherName = session.displayName.trim().split(' ').first;
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = '${DateFormat.EEEE(locale).format(now)}, ${DateFormat.MMM(locale).format(now)} ${now.day}';

    // Refresh workspace when real-time events arrive (new grades, submissions, meetings)
    ref.listen(realtimeEventProvider, (_, event) {
      if (event != null &&
          (event.type == 'grade_updated' ||
           event.type == 'assignment_created' ||
           event.type == 'meeting_created')) {
        _load();
      }
    });

    return CmRefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // ── Hero Banner ──────────────────────────────────────────────────
          LiquidGlassCard(
            borderRadius: BorderRadius.circular(28),
            color: cs.primaryContainer,
            border: Border.all(color: cs.outlineVariant),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacherName.isNotEmpty ? '${_greeting(l)}, $teacherName' : _greeting(l),
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1, color: cs.onPrimaryContainer),
                          ),
                          const SizedBox(height: 4),
                          Text(dateLabel, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onPrimaryContainer)),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.school_rounded, size: 26, color: cs.onPrimaryContainer),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Stat pills
                Row(
                  children: [
                    _StatPill(
                      icon: Icons.today_rounded,
                      value: '${scheduledSlots.length}',
                      label: l.today,
                      color: cs.primaryContainer,
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      icon: Icons.groups_rounded,
                      value: '$teachingGroups',
                      label: l.teacherGroupsLabel,
                      color: cs.secondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      icon: Icons.grade_rounded,
                      // Count the teacher's exams (which exist before grading);
                      // fall back to graded assessments if no exams created.
                      value: '${_examsCount > 0 ? _examsCount : (bundle?.assessments.length ?? 0)}',
                      label: l.teacherTestsLabel,
                      color: cs.tertiaryContainer,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── Quick Actions ───────────────────────────────────────────────
          LiquidGlassCard(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cs.outlineVariant),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.teacherQuickActions, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurfaceVariant)),
                const SizedBox(height: 14),
                // Row 1 — daily actions
                Row(
                  children: [
                    Expanded(child: _BigActionButton(icon: Icons.fact_check_rounded, label: l.navAttendance, color: cs.primary, onTap: () => context.go('/teacher/attendance'))),
                    const SizedBox(width: 10),
                    Expanded(child: _BigActionButton(icon: Icons.grade_rounded, label: l.navGrades, color: cs.secondary, onTap: () => context.go('/teacher/grades'))),
                    const SizedBox(width: 10),
                    Expanded(child: _BigActionButton(icon: Icons.groups_rounded, label: l.navClassrooms, color: cs.tertiary, onTap: () => context.go('/teacher/classrooms'))),
                  ],
                ),
                const SizedBox(height: 10),
                // Row 2 — communication
                Row(
                  children: [
                    Expanded(child: _BigActionButton(icon: Icons.chat_bubble_rounded, label: l.navMessages, color: cs.primary, onTap: () => context.go('/messages'))),
                    const SizedBox(width: 10),
                    Expanded(child: _BigActionButton(icon: Icons.campaign_rounded, label: l.teacherAnnounceLabel, color: cs.secondary, onTap: () => context.push('/teacher/announcements/new'))),
                    const SizedBox(width: 10),
                    Expanded(child: _BigActionButton(icon: Icons.quiz_rounded, label: l.navExams, color: cs.tertiary, onTap: () => context.go('/teacher/exams'))),
                  ],
                ),
                const SizedBox(height: 10),
                // Row 3 — more
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ActionChip(icon: Icons.article_rounded, label: l.navForms, onTap: () => context.go('/teacher/forms')),
                    _ActionChip(icon: Icons.notifications_rounded, label: l.navNotifications, onTap: () => context.go('/notifications')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CmLoading()))
          else if (_error != null)
            _ErrorCard(message: _error!, onRetry: _load)
          else ...[
            // ── Today's Classes ────────────────────────────────────────────
            _SectionHeader(title: l.teacherTodaysClasses, subtitle: today?.date.isNotEmpty == true ? today!.date : l.teacherNoDate),
            const SizedBox(height: 10),
            scheduledSlots.isEmpty
                ? _EmptySlotCard(l: l)
                : Column(
                    children: scheduledSlots.asMap().entries.map((entry) {
                      final slot = entry.value;
                      final subject = slot.course?.subject ?? '';
                      final color = _subjectColor(subject, cs);
                      // The action sheet needs both a course and a cohort. When
                      // a slot is missing either, don't show the "⋯" affordance
                      // or make the row tappable — otherwise the tap silently
                      // does nothing (reported as "3-dot menu doesn't open").
                      final actionable = slot.course != null && slot.cohort != null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: actionable
                              ? () => _showSlotActionSheet(context, slot, today?.date ?? '')
                              : null,
                          borderRadius: BorderRadius.circular(20),
                          child: LiquidGlassCard(
                            padding: const EdgeInsets.all(14),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color),
                            child: Row(
                              children: [
                                // Period badge
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('P${slot.period}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: cs.onPrimaryContainer)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subject.isNotEmpty ? subject : (slot.course?.name ?? l.teacherUnassignedSlot),
                                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${slot.cohort?.name ?? ''} · ${l.gradeLevelLabel(slot.cohort?.grade ?? '')}',
                                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(8)),
                                      child: Text(subject.isNotEmpty ? subject : l.scheduleClassFallback, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cs.onPrimaryContainer)),
                                    ),
                                    const SizedBox(height: 4),
                                    if (actionable)
                                      Icon(Icons.more_horiz_rounded, size: 16, color: cs.onSurfaceVariant),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 18),

            // ── Upcoming Assessments ───────────────────────────────────────
            _SectionHeader(title: l.teacherUpcomingAssessments, subtitle: l.teacherUpcomingTestsSubtitle),
            const SizedBox(height: 10),
            upcoming.isEmpty
                ? LiquidGlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(16),
                    color: cs.surfaceContainerLow,
                    border: Border.all(color: cs.outlineVariant),
                    child: Row(children: [
                      Icon(Icons.event_busy_rounded, color: cs.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Text(l.teacherNoAssessmentsYet, style: TextStyle(color: cs.onSurfaceVariant)),
                    ]),
                  )
                : Column(
                    children: upcoming.map((item) {
                      final dateLabel2 = '${DateFormat.MMM(locale).format(item.when)} ${item.when.day}';
                      final tag = item.isExam ? l.navExams : l.navAssignments;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => context.go(item.isExam ? '/teacher/exams' : '/teacher/assignments'),
                          borderRadius: BorderRadius.circular(18),
                          child: LiquidGlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            borderRadius: BorderRadius.circular(18),
                            color: cs.surfaceContainerLow,
                            border: Border.all(color: cs.outlineVariant),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: item.isExam ? cs.tertiaryContainer : cs.secondaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    item.isExam ? Icons.quiz_rounded : Icons.assignment_rounded,
                                    size: 20,
                                    color: item.isExam ? cs.onTertiaryContainer : cs.onSecondaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                                      Text(
                                        item.subtitle.isNotEmpty ? '$tag · ${item.subtitle}' : tag,
                                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(dateLabel2, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: cs.tertiary)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.value, required this.label, required this.color});
  final IconData icon;
  final String value;
  final String label;
  /// Pass a container color (e.g. cs.primaryContainer). The on-color is
  /// derived automatically from the theme.
  final Color color;

  Color _onColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (color == cs.primaryContainer) return cs.onPrimaryContainer;
    if (color == cs.secondaryContainer) return cs.onSecondaryContainer;
    if (color == cs.tertiaryContainer) return cs.onTertiaryContainer;
    return cs.onPrimaryContainer;
  }

  @override
  Widget build(BuildContext context) {
    final onColor = _onColor(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: onColor),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: onColor, height: 1)),
            Text(label, style: TextStyle(fontSize: 10, color: onColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _BigActionButton extends StatelessWidget {
  const _BigActionButton({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  // color is kept for API compatibility but visual style uses theme colors.
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: cs.onSurface),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.onSurface), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

class _EmptySlotCard extends StatelessWidget {
  const _EmptySlotCard({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Row(children: [
        Icon(Icons.event_available_rounded, color: cs.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(ScheduleEmptyStateCopy.subtitle(l, l.today), style: TextStyle(color: cs.onSurfaceVariant)),
      ]),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: cs.onSurface),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      color: cs.errorContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.teacherLoadErrorTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onErrorContainer)),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: cs.onErrorContainer)),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.retry)),
        ],
      ),
    );
  }
}