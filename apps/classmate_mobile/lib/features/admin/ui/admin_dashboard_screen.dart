// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/auth/auth_controller.dart';
import '../data/admin_repository.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _overviewProvider = FutureProvider.autoDispose<AdminOverview>((ref) {
  return ref.watch(adminRepositoryProvider).fetchOverview();
});

final _attendanceProvider = FutureProvider.autoDispose<List<CohortAttendance>>((ref) {
  return ref.watch(adminRepositoryProvider).fetchAttendanceAnalytics();
});

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final session = ref.watch(authSessionProvider);
    final isAdmin = session.primaryRole == 'ADMIN';
    final overviewAsync = ref.watch(_overviewProvider);
    final attendanceAsync = ref.watch(_attendanceProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_overviewProvider);
          ref.invalidate(_attendanceProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  l.adminDashboardTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),

            // ── Stats grid ───────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: overviewAsync.when(
                  loading: () => const _StatsGridSkeleton(),
                  error: (e, _) => _ErrorCard(message: e.toString()),
                  data: (o) => Column(
                    children: [
                      _StatsGrid(overview: o),
                      const SizedBox(height: 20),
                      // Always shown — collapses to a compact "all done" pill
                      // once everything is ticked, so admins can still spot-
                      // check at a glance after first-time setup.
                      _SetupGuide(isAdmin: isAdmin, overview: o),
                    ],
                  ),
                ),
              ),
            ),

            // ── Quick actions ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.adminQuickActions,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _QuickAction(
                          icon: Icons.person_add_rounded,
                          label: l.adminAddUser,
                          color: cs.primary,
                          onTap: () => context.push('/admin/people'),
                        ),
                        _QuickAction(
                          icon: Icons.group_add_rounded,
                          label: l.navCohorts,
                          color: cs.secondary,
                          onTap: () => context.push('/admin/cohorts'),
                        ),
                        if (isAdmin)
                          _QuickAction(
                            icon: Icons.manage_history_rounded,
                            label: l.adminScheduleTitle,
                            color: cs.tertiary,
                            onTap: () => context.push('/admin/schedule'),
                          ),
                        _QuickAction(
                          icon: Icons.school_rounded,
                          label: l.navSchool,
                          color: cs.onSurfaceVariant,
                          onTap: () => context.push('/admin/school'),
                        ),
                        if (isAdmin)
                          _QuickAction(
                            icon: Icons.shield_outlined,
                            label: 'Password requests',
                            color: cs.error,
                            onTap: () => context.push('/admin/password-requests'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Attendance by cohort ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  l.adminAttendanceLast30,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
              sliver: attendanceAsync.when(
                loading: () => const SliverToBoxAdapter(child: _AttendanceSkeleton()),
                error: (e, _) => SliverToBoxAdapter(child: _ErrorCard(message: e.toString())),
                data: (cohorts) {
                  final withData = cohorts.where((c) => c.total > 0).toList();
                  if (withData.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _EmptyHint(
                        icon: Icons.how_to_reg_outlined,
                        message: AppLocalizations.of(context)!.adminNoAttendanceData,
                      ),
                    );
                  }
                  return SliverList.separated(
                    itemCount: withData.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) => _AttendanceTile(item: withData[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── First-time setup guide ─────────────────────────────────────────────────────

class _SetupGuide extends StatefulWidget {
  const _SetupGuide({required this.isAdmin, required this.overview});
  final bool isAdmin;
  final AdminOverview overview;

  @override
  State<_SetupGuide> createState() => _SetupGuideState();
}

class _SetupGuideState extends State<_SetupGuide> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final o = widget.overview;

    final steps = <_SetupStep>[
      _SetupStep(
        icon: Icons.image_rounded,
        title: 'Upload school logo',
        subtitle: 'Appears in headers and the drawer',
        route: '/admin/school',
        done: o.schoolLogoSet,
      ),
      _SetupStep(
        icon: Icons.drive_file_rename_outline_rounded,
        title: 'Set school name',
        subtitle: "Shown to students, teachers, and parents",
        route: '/admin/school',
        done: o.schoolNameSet,
      ),
      _SetupStep(
        icon: Icons.menu_book_rounded,
        title: 'Define subjects',
        subtitle: 'At least one grade with subjects configured',
        route: '/admin/school',
        done: o.subjectsConfigured,
      ),
      _SetupStep(
        icon: Icons.schedule_rounded,
        title: 'Set bell schedule',
        subtitle: 'Start/end times for each period',
        route: '/admin/school',
        done: o.bellScheduleConfigured,
      ),
      _SetupStep(
        icon: Icons.groups_rounded,
        title: 'Create cohorts',
        subtitle: 'Set up your class groups',
        route: '/admin/cohorts',
        done: o.cohorts > 0,
      ),
      _SetupStep(
        icon: Icons.person_add_rounded,
        title: 'Add students',
        subtitle: 'Create accounts or generate join codes',
        route: '/admin/people',
        done: o.students > 0,
      ),
      _SetupStep(
        icon: Icons.co_present_rounded,
        title: 'Add teachers',
        subtitle: 'Create teacher accounts',
        route: '/admin/people',
        done: o.teachers > 0,
      ),
    ];

    final doneCount = steps.where((s) => s.done).length;
    final total = steps.length;
    final allDone = doneCount == total;
    final progress = total == 0 ? 0.0 : doneCount / total;

    // Once every setup item is complete the guide has nothing left to nudge
    // toward — hide it entirely so the dashboard isn't permanently topped by
    // a "great job, you finished" card.
    if (allDone) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: allDone
            ? cs.tertiaryContainer.withValues(alpha: 0.25)
            : cs.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (allDone ? cs.tertiary : cs.primary).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    allDone ? Icons.verified_rounded : Icons.checklist_rounded,
                    color: allDone ? cs.tertiary : cs.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'School Setup',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: allDone ? cs.tertiary : cs.primary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: allDone ? cs.tertiary : cs.primary,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '$doneCount/$total',
                      style: TextStyle(
                        color: allDone ? cs.onTertiary : cs.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(allDone ? cs.tertiary : cs.primary),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            Text(
              allDone
                  ? "You're all set. Tap any item to revisit or refine it."
                  : 'Complete these steps to fully set up your school.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            ...steps.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SetupStepTile(step: e.value, number: e.key + 1),
            )),
          ],
        ],
      ),
    );
  }
}

class _SetupStep {
  const _SetupStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.done,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final bool done;
}

class _SetupStepTile extends StatelessWidget {
  const _SetupStepTile({required this.step, required this.number});
  final _SetupStep step;
  final int number;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final done = step.done;

    return GestureDetector(
      onTap: () => context.push(step.route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: done
              ? cs.tertiaryContainer.withValues(alpha: 0.35)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: done
                ? cs.tertiary.withValues(alpha: 0.4)
                : cs.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: done ? cs.tertiary : cs.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: done
                    ? Icon(Icons.check_rounded, color: cs.onTertiary, size: 18)
                    : Text(
                        '$number',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: cs.onSurfaceVariant,
                      color: done ? cs.onSurfaceVariant : cs.onSurface,
                    ),
                  ),
                  Text(
                    step.subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ── Stats grid ─────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.overview});
  final AdminOverview overview;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: [
        _StatCard(
          label: l.adminStudents,
          value: '${overview.students}',
          icon: Icons.school_rounded,
          color: cs.primary,
        ),
        _StatCard(
          label: l.adminTeachers,
          value: '${overview.teachers}',
          icon: Icons.co_present_rounded,
          color: cs.secondary,
        ),
        _StatCard(
          label: l.navCohorts,
          value: '${overview.cohorts}',
          icon: Icons.groups_rounded,
          color: cs.tertiary,
        ),
        _StatCard(
          label: l.navClassrooms,
          value: '${overview.classrooms}',
          icon: Icons.meeting_room_rounded,
          color: cs.error,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGridSkeleton extends StatelessWidget {
  const _StatsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: List.generate(
        4,
        (_) => Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

// ── Quick actions ──────────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Attendance tile ────────────────────────────────────────────────────────────

class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({required this.item});
  final CohortAttendance item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final rate = item.rate;
    final rateColor = rate == null
        ? cs.onSurfaceVariant
        : rate >= 90
            ? Colors.green
            : rate >= 75
                ? Colors.orange
                : cs.error;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'G${item.grade}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.cohortName,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${item.total} records',
                  style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            rate != null ? '$rate%' : '—',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: rateColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceSkeleton extends StatelessWidget {
  const _AttendanceSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 64,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message, style: TextStyle(color: cs.error)),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: cs.outlineVariant),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
