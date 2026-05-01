import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/http/cm_api.dart';
import '../../schedule/schedule_empty_state_copy.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';

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
            blurSigma: 18,
            color: cs.surface.withValues(alpha: 0.96),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(width: 36, height: 4,
                    decoration: BoxDecoration(color: cs.outlineVariant.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.name.isNotEmpty ? course.name : course.subject,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                      Text('${cohort.name} · Period ${slot.period}',
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
                    context.push('/teacher/attendance', extra: <String, dynamic>{
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
              decoration: BoxDecoration(color: cs.primaryContainer.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(10)),
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

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  TeacherTodaySchedule? _today;
  TeacherAssessmentBundle? _bundle;
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
      ]);
      if (!mounted) return;
      setState(() {
        _today = values[0] as TeacherTodaySchedule;
        _bundle = values[1] as TeacherAssessmentBundle;
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

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
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
    final scheduledSlots = today?.slots
            .where((slot) => slot.course != null && slot.cohort != null)
            .toList(growable: false) ??
        const <TeacherTodaySlot>[];
    final upcoming = (bundle?.assessments ?? const <TeacherAssessment>[]).take(4).toList(growable: false);
    final teachingGroups = (bundle?.courses.map((c) => c.cohortId).where((id) => id.isNotEmpty).toSet().length) ?? 0;
    final teacherName = session.displayName.trim().split(' ').first;
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
    final dateLabel = '${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}';

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // ── Hero Banner ──────────────────────────────────────────────────
          LiquidGlassCard(
            borderRadius: BorderRadius.circular(28),
            blurSigma: 20,
            gradient: LinearGradient(
              colors: [
                cs.primaryContainer.withValues(alpha: 0.92),
                cs.tertiaryContainer.withValues(alpha: 0.72),
                cs.surfaceContainerHigh.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
            boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.14), blurRadius: 24, offset: const Offset(0, 10), spreadRadius: -6)],
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
                            teacherName.isNotEmpty ? '${_greeting()}, $teacherName' : _greeting(),
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1),
                          ),
                          const SizedBox(height: 4),
                          Text(dateLabel, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.school_rounded, size: 26, color: cs.primary),
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
                      color: cs.primary,
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      icon: Icons.groups_rounded,
                      value: '$teachingGroups',
                      label: l.teacherGroupsLabel,
                      color: cs.tertiary,
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      icon: Icons.grade_rounded,
                      value: '${bundle?.assessments.length ?? 0}',
                      label: l.teacherTestsLabel,
                      color: cs.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                        Text(l.teacherViewFullWeekSchedule, style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary, fontSize: 13)),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded, size: 16, color: cs.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── Quick Actions ───────────────────────────────────────────────
          LiquidGlassCard(
            borderRadius: BorderRadius.circular(24),
            blurSigma: 14,
            gradient: LinearGradient(
              colors: [cs.primaryContainer.withValues(alpha: 0.22), cs.surface.withValues(alpha: 0.76)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.24)),
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
                    Expanded(child: _BigActionButton(icon: Icons.psychology_rounded, label: l.navNova, color: cs.tertiary, onTap: () => context.go('/tutor'))),
                  ],
                ),
                const SizedBox(height: 10),
                // Row 3 — more
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ActionChip(icon: Icons.quiz_rounded, label: l.navExams, onTap: () => context.go('/exams')),
                    _ActionChip(icon: Icons.article_rounded, label: l.navForms, onTap: () => context.go('/forms')),
                    _ActionChip(icon: Icons.notifications_rounded, label: l.navNotifications, onTap: () => context.go('/notifications')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (_error != null)
            _ErrorCard(message: _error!, onRetry: _load)
          else ...[
            // ── Today's Classes ────────────────────────────────────────────
            _SectionHeader(title: "Today's Classes", subtitle: today?.date.isNotEmpty == true ? today!.date : 'No date'),
            const SizedBox(height: 10),
            scheduledSlots.isEmpty
                ? _EmptySlotCard(l: l)
                : Column(
                    children: scheduledSlots.asMap().entries.map((entry) {
                      final slot = entry.value;
                      final subject = slot.course?.subject ?? '';
                      final color = _subjectColor(subject, cs);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => _showSlotActionSheet(context, slot, today?.date ?? ''),
                          borderRadius: BorderRadius.circular(20),
                          child: LiquidGlassCard(
                            padding: const EdgeInsets.all(14),
                            borderRadius: BorderRadius.circular(20),
                            blurSigma: 10,
                            gradient: LinearGradient(
                              colors: [cs.surface.withValues(alpha: 0.84), cs.surfaceContainerHigh.withValues(alpha: 0.68)],
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: color.withValues(alpha: 0.18)),
                            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 12, spreadRadius: -4)],
                            child: Row(
                              children: [
                                // Period badge
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('P${slot.period}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
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
                                        '${slot.cohort?.name ?? ''} · Grade ${slot.cohort?.grade ?? ''}',
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
                                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                                      child: Text(subject.isNotEmpty ? subject : 'Class', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                                    ),
                                    const SizedBox(height: 4),
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
            _SectionHeader(title: 'Upcoming Assessments', subtitle: 'Next tests & quizzes'),
            const SizedBox(height: 10),
            upcoming.isEmpty
                ? LiquidGlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(16),
                    blurSigma: 8,
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
                    child: Row(children: [
                      Icon(Icons.event_busy_rounded, color: cs.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Text(l.teacherNoAssessmentsYet, style: TextStyle(color: cs.onSurfaceVariant)),
                    ]),
                  )
                : Column(
                    children: upcoming.map((assessment) {
                      final courseName = bundle?.courses.firstWhere(
                        (c) => c.id == assessment.courseId,
                        orElse: () => TeacherCourse(id: '', name: '', subject: '', cohortId: ''),
                      ).name ?? '';
                      final dateStr = assessment.date.split('T').first;
                      final dt = DateTime.tryParse(dateStr);
                      final months2 = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                      final dateLabel2 = dt != null ? '${months2[dt.month-1]} ${dt.day}' : dateStr;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => context.go('/teacher/grades'),
                          borderRadius: BorderRadius.circular(18),
                          child: LiquidGlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            borderRadius: BorderRadius.circular(18),
                            blurSigma: 10,
                            color: cs.surface.withValues(alpha: 0.82),
                            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(color: cs.tertiaryContainer.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(12)),
                                  child: Icon(Icons.quiz_rounded, size: 20, color: cs.tertiary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(assessment.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                                      if (courseName.isNotEmpty) Text(courseName, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
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
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: color, height: 1)),
            Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
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
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color), textAlign: TextAlign.center),
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
      blurSigma: 8,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primaryContainer.withValues(alpha: isDark ? 0.48 : 0.72),
              cs.surface.withValues(alpha: isDark ? 0.44 : 0.62),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.primary.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              spreadRadius: -10,
              offset: const Offset(0, 8),
              color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: cs.primary),
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
    return LiquidGlassCard(
      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.62),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.teacherLoadErrorTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.retry)),
        ],
      ),
    );
  }
}