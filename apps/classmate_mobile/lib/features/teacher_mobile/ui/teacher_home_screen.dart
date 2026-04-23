import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/http/cm_api.dart';
import '../../schedule/schedule_empty_state_copy.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;
    final bundle = _bundle;
    final today = _today;
    final scheduledSlots = today?.slots
            .where((slot) => slot.course != null && slot.cohort != null)
            .toList(growable: false) ??
        const <TeacherTodaySlot>[];
    final upcoming = (bundle?.assessments ?? const <TeacherAssessment>[]).take(4).toList(growable: false);
    final teachingGroups = (bundle?.courses.map((c) => c.cohortId).where((id) => id.isNotEmpty).toSet().length) ?? 0;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Text(
            l.navTeacherWorkspace,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            l.teacherWorkspaceSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(label: l.teacherMetricSessionsToday, value: '${scheduledSlots.length}', accent: cs.primaryContainer),
              _MetricCard(label: l.teacherMetricTeachingGroups, value: '$teachingGroups', accent: cs.secondaryContainer),
              _MetricCard(label: l.teacherMetricAssessments, value: '${bundle?.assessments.length ?? 0}', accent: cs.tertiaryContainer),
            ],
          ),
          const SizedBox(height: 18),
          LiquidGlassCard(
            color: cs.surface.withValues(alpha: 0.74),
            gradient: LinearGradient(
              colors: [
                cs.primaryContainer.withValues(alpha: 0.26),
                cs.surface.withValues(alpha: 0.78),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.teacherQuickActions, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ActionChip(icon: Icons.fact_check_rounded, label: l.navAttendance, onTap: () => context.go('/teacher/attendance')),
                    _ActionChip(icon: Icons.groups_rounded, label: l.navClassrooms, onTap: () => context.go('/teacher/classrooms')),
                    _ActionChip(icon: Icons.assignment_turned_in_rounded, label: l.navTeacherAssessments, onTap: () => context.go('/teacher/grades')),
                    _ActionChip(icon: Icons.quiz_rounded, label: l.navExams, onTap: () => context.go('/exams')),
                    _ActionChip(icon: Icons.article_rounded, label: l.navForms, onTap: () => context.go('/forms')),
                    _ActionChip(icon: Icons.chat_bubble_rounded, label: l.navMessages, onTap: () => context.go('/messages')),
                    _ActionChip(icon: Icons.psychology_rounded, label: l.navNova, onTap: () => context.go('/tutor')),
                    _ActionChip(icon: Icons.campaign_rounded, label: l.navAnnouncements, onTap: () => context.go('/announcements')),
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
            _SectionCard(
              title: l.today,
              subtitle: today?.date.isNotEmpty == true ? today!.date : l.teacherNoDateAvailable,
              child: scheduledSlots.isEmpty
                  ? Text(ScheduleEmptyStateCopy.subtitle(l, l.today))
                  : Column(
                      children: scheduledSlots
                          .map(
                            (slot) => _AgendaRow(
                              title: slot.course?.name ?? l.teacherUnassignedSlot,
                              subtitle: '${slot.cohort?.name ?? l.teacherNoCohort} • ${l.teacherPeriod(slot.period.toString())}',
                              trailing: slot.course?.subject ?? slot.source,
                            ),
                          )
                          .toList(growable: false),
                    ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: l.teacherUpcomingAssessments,
              subtitle: l.teacherUpcomingAssessmentsSubtitle,
              child: upcoming.isEmpty
                ? Text(l.teacherNoAssessmentsYet)
                  : Column(
                      children: upcoming
                          .map(
                            (assessment) => _AgendaRow(
                              title: assessment.title,
                              subtitle: (bundle?.courses.firstWhere(
                                        (course) => course.id == assessment.courseId,
                                        orElse: () => TeacherCourse(id: '', name: l.teacherCourseFallback, subject: '', cohortId: ''),
                                      ).name ??
                                      l.teacherCourseFallback),
                              trailing: assessment.date.split('T').first,
                            ),
                          )
                          .toList(growable: false),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.accent});

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 56) / 2;
    return SizedBox(
      width: width < 140 ? double.infinity : width,
      child: LiquidGlassCard(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.45), Colors.white.withValues(alpha: 0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      color: cs.surface.withValues(alpha: 0.76),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cs.surface.withValues(alpha: 0.82),
          cs.surfaceContainerHigh.withValues(alpha: 0.66),
        ],
      ),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.title, required this.subtitle, required this.trailing});

  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(18),
        blurSigma: 10,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface.withValues(alpha: 0.78),
            cs.surfaceContainerHighest.withValues(alpha: 0.58),
          ],
        ),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.16)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(trailing, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w700)),
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