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
                  data: (o) {
                    final isEmpty = o.students == 0 && o.teachers == 0 && o.cohorts == 0;
                    return Column(
                      children: [
                        _StatsGrid(overview: o),
                        if (isEmpty) ...[
                          const SizedBox(height: 20),
                          _SetupGuide(isAdmin: isAdmin),
                        ],
                      ],
                    );
                  },
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

class _SetupGuide extends StatelessWidget {
  const _SetupGuide({required this.isAdmin});
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final steps = [
      _SetupStep(
        icon: Icons.school_rounded,
        title: 'Set school name & logo',
        subtitle: "Personalise the app with your school's identity",
        route: '/admin/school',
        done: false,
      ),
      _SetupStep(
        icon: Icons.schedule_rounded,
        title: 'Set bell schedule',
        subtitle: 'Define start/end times for each period (P1–P9)',
        route: '/admin/bell-schedule',
        done: false,
      ),
      _SetupStep(
        icon: Icons.menu_book_rounded,
        title: 'Set subjects per grade',
        subtitle: 'Configure which subjects each grade studies',
        route: '/admin/school',
        done: false,
      ),
      if (isAdmin)
        _SetupStep(
          icon: Icons.co_present_rounded,
          title: 'Add teachers',
          subtitle: 'Create teacher accounts with temporary passwords',
          route: '/admin/people',
          done: false,
        ),
      _SetupStep(
        icon: Icons.groups_rounded,
        title: 'Create cohorts',
        subtitle: 'Set up your class groups (e.g. 10th-1, 11th-2)',
        route: '/admin/cohorts',
        done: false,
      ),
      _SetupStep(
        icon: Icons.person_add_rounded,
        title: 'Add students',
        subtitle: 'Create accounts or generate join codes for self-enrolment',
        route: '/admin/cohorts',
        done: false,
      ),
      if (isAdmin)
        _SetupStep(
          icon: Icons.manage_history_rounded,
          title: 'Build the weekly schedule',
          subtitle: 'Assign teachers and cohorts to time slots',
          route: '/admin/schedule',
          done: false,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'School Setup',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${steps.length} steps',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Your school isn\'t set up yet. Complete these steps to get started.',
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

    return GestureDetector(
      onTap: () => context.push(step.route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
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
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
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
            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
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
