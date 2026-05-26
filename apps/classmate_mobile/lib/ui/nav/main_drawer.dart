import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:classmate_mobile/core/auth/auth_controller.dart';
import 'package:classmate_mobile/features/parent/data/parent_repository.dart';
import 'package:classmate_mobile/l10n/app_localizations.dart';
import 'package:classmate_mobile/ui/widgets/classmate_logo.dart';
import 'package:classmate_mobile/ui/widgets/liquid_glass_dropdown.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final isTeacherLike = session.isTeacherLike;
    final isSecretary = session.primaryRole == 'SECRETARY';
    final isPureAdmin = session.primaryRole == 'ADMIN';
    final isParent = session.primaryRole == 'PARENT';
    final displayName = session.displayName.trim();
    final initials = _initials(displayName);
    final schoolName = session.schoolName.trim();
    final schoolLogoUrl = session.schoolLogoUrl.trim();
    final loc = GoRouterState.of(context).matchedLocation;
    final roleLabel = switch (session.primaryRole) {
      'TEACHER' => l.roleTeacher,
      'ADMIN' => l.roleAdmin,
      'SECRETARY' => l.roleSecretary,
      'PARENT' => l.roleParent,
      _ => l.student,
    };

    // ── helpers ──────────────────────────────────────────────────────────

    Widget sectionHeader(String title) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 16, 6),
        child: Row(
          children: [
            Expanded(
              child: Divider(
                height: 1,
                color: cs.outlineVariant,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Divider(
                height: 1,
                color: cs.outlineVariant,
              ),
            ),
          ],
        ),
      );
    }

    Widget navItem({
      required IconData icon,
      required String label,
      required String route,
      bool danger = false,
    }) {
      final isActive = loc == route ||
          (route != '/schedule' && loc.startsWith(route));
      final tint = danger ? cs.error : cs.primary;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Material(
          color: isActive
              ? cs.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.of(context).pop();
              context.go(route);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isActive
                          ? tint
                          : cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isActive
                          ? (danger ? cs.onError : cs.onPrimary)
                          : cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? tint : (danger ? tint : cs.onSurface),
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: tint,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── build ─────────────────────────────────────────────────────────────

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── School branding ─────────────────────────────────────────
            if (schoolName.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  border: Border(
                    bottom: BorderSide(
                      color: cs.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // School logo or placeholder icon
                    if (schoolLogoUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          schoolLogoUrl,
                          width: 36,
                          height: 36,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, stack) => _schoolLogoPlaceholder(cs),
                        ),
                      )
                    else
                      _schoolLogoPlaceholder(cs),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        schoolName,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // ── User header ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
              ),
              child: Row(
                children: [
                  // Avatar circle with accent bg + proper initials
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName.isEmpty ? 'ClassMate' : displayName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          roleLabel,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                        ),
                        if (isParent) ...[
                          const SizedBox(height: 8),
                          const _ParentChildDropdown(),
                        ],
                      ],
                    ),
                  ),
                  // Close button — always shows the CM mark. The school logo
                  // already appears in the dedicated branding row above, so
                  // mirroring it here just doubled the visual noise.
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(child: ClassMateIcon(size: 32)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable nav list ──────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 12),
                children: [
                  // ── Admin/Secretary drawer: 3 focused categories ──────────
                  if (isParent) ...[
                    sectionHeader(l.sectionCore),
                    navItem(icon: Icons.dashboard_rounded, label: 'Home', route: '/parent/home'),
                    navItem(icon: Icons.event_note_rounded, label: l.navSchedule, route: '/parent/schedule'),
                    navItem(icon: Icons.insights_rounded, label: l.navInsights, route: '/parent/overview'),
                    navItem(icon: Icons.chat_bubble_rounded, label: l.navMessages, route: '/messages'),
                    navItem(icon: Icons.psychology_rounded, label: l.navNova, route: '/tutor'),
                    sectionHeader(l.sectionSchoolTools),
                    navItem(icon: Icons.how_to_reg_rounded, label: l.navAttendance, route: '/parent/attendance'),
                    navItem(icon: Icons.grade_rounded, label: l.navGrades, route: '/parent/grades'),
                    navItem(icon: Icons.quiz_rounded, label: l.navExams, route: '/parent/exams'),
                    navItem(icon: Icons.workspace_premium_rounded, label: l.navDiplomas, route: '/parent/certificates'),
                    navItem(icon: Icons.assignment_rounded, label: l.navAssignments, route: '/parent/assignments'),
                    navItem(icon: Icons.video_call_rounded, label: l.navMeetings, route: '/parent/meetings'),
                    navItem(icon: Icons.folder_rounded, label: l.navMaterials, route: '/parent/materials'),
                    navItem(icon: Icons.campaign_rounded, label: l.navAnnouncements, route: '/announcements'),
                    navItem(icon: Icons.notifications_rounded, label: l.navNotifications, route: '/parent/notifications'),
                    sectionHeader(l.sectionAccount),
                  ] else if (isSecretary) ...[
                    sectionHeader(l.sectionSecretaryTools),
                    navItem(icon: Icons.dashboard_rounded, label: l.navHome, route: '/secretary/home'),
                    navItem(icon: Icons.manage_history_rounded, label: l.adminScheduleTitle, route: '/secretary/schedule'),
                    navItem(icon: Icons.people_rounded, label: l.navPeople, route: '/secretary/people'),
                    navItem(icon: Icons.groups_rounded, label: l.navCohorts, route: '/secretary/cohorts'),
                    navItem(icon: Icons.campaign_rounded, label: l.navAnnouncements, route: '/announcements'),
                    navItem(icon: Icons.chat_bubble_rounded, label: l.navMessages, route: '/messages'),
                    navItem(icon: Icons.flag_outlined, label: l.navReports, route: '/secretary/reports'),
                    navItem(icon: Icons.download_rounded, label: l.navExportData, route: '/secretary/export'),
                    sectionHeader(l.sectionAccount),
                  ] else if (isPureAdmin) ...[
                    sectionHeader(l.sectionSchoolToolsLabel),
                    navItem(icon: Icons.chat_bubble_rounded, label: l.navMessages, route: '/messages'),
                    navItem(icon: Icons.campaign_rounded, label: l.navAnnouncements, route: '/announcements'),
                    navItem(icon: Icons.notifications_rounded, label: l.navNotifications, route: '/notifications'),
                    sectionHeader(l.sectionAdminTools),
                    navItem(icon: Icons.dashboard_rounded, label: l.navDashboard, route: '/admin/dashboard'),
                    navItem(icon: Icons.people_rounded, label: l.navPeople, route: '/admin/people'),
                    navItem(icon: Icons.groups_rounded, label: l.navCohorts, route: '/admin/cohorts'),
                    navItem(icon: Icons.manage_history_rounded, label: l.adminScheduleTitle, route: '/admin/schedule'),
                    navItem(icon: Icons.school_rounded, label: l.adminSchoolSettingsTitle, route: '/admin/school'),
                    navItem(icon: Icons.shield_outlined, label: l.navPasswordRequests, route: '/admin/password-requests'),
                    navItem(icon: Icons.flag_outlined, label: l.navReports, route: '/admin/reports'),
                    navItem(icon: Icons.download_rounded, label: l.navExportData, route: '/admin/export'),
                    sectionHeader(l.sectionAccount),
                  // ── Teacher drawer ────────────────────────────────────────
                  ] else if (isTeacherLike) ...[
                    sectionHeader(l.sectionCore),
                    navItem(icon: Icons.event_note_rounded, label: l.navSchedule, route: '/teacher/schedule'),
                    navItem(icon: Icons.groups_rounded, label: l.navClassrooms, route: '/teacher/classrooms'),
                    navItem(icon: Icons.psychology_rounded, label: l.navNova, route: '/tutor'),
                    navItem(icon: Icons.insights_rounded, label: l.navInsights, route: '/teacher/insights'),
                    navItem(icon: Icons.chat_bubble_rounded, label: l.navMessages, route: '/messages'),
                    sectionHeader(l.sectionSchoolTools),
                    navItem(icon: Icons.dashboard_rounded, label: l.navTeacherWorkspace, route: '/teacher/home'),
                    navItem(icon: Icons.fact_check_rounded, label: l.navAttendance, route: '/teacher/attendance'),
                    navItem(icon: Icons.grade_rounded, label: l.navGrades, route: '/teacher/grades'),
                    navItem(icon: Icons.campaign_rounded, label: l.navAnnouncements, route: '/announcements'),
                    navItem(icon: Icons.notifications_rounded, label: l.navNotifications, route: '/notifications'),
                    navItem(icon: Icons.assignment_rounded, label: l.navAssignments, route: '/teacher/assignments'),
                    navItem(icon: Icons.folder_shared_rounded, label: l.navMaterials, route: '/teacher/materials'),
                    navItem(icon: Icons.video_call_rounded, label: l.navMeetings, route: '/teacher/meetings'),
                    navItem(icon: Icons.people_rounded, label: l.teacherStudentsLabel, route: '/teacher/students'),
                    navItem(icon: Icons.quiz_rounded, label: l.navExams, route: '/teacher/exams'),
                    navItem(icon: Icons.assignment_turned_in_rounded, label: l.navForms, route: '/teacher/forms'),
                    navItem(icon: Icons.workspace_premium_rounded, label: l.navDiplomas, route: '/diplomas'),
                    sectionHeader(l.sectionAccount),
                  // ── Student drawer ────────────────────────────────────────
                  ] else ...[
                    sectionHeader(l.sectionCore),
                    navItem(icon: Icons.calendar_month_rounded, label: l.navSchedule, route: '/schedule'),
                    navItem(icon: Icons.groups_rounded, label: l.navClassrooms, route: '/classrooms'),
                    navItem(icon: Icons.auto_awesome_rounded, label: l.navPractice, route: '/practice'),
                    navItem(icon: Icons.insights_rounded, label: l.navInsights, route: '/insights'),
                    navItem(icon: Icons.psychology_rounded, label: l.navNova, route: '/tutor'),
                    sectionHeader(l.sectionSchoolTools),
                    navItem(icon: Icons.chat_bubble_rounded, label: l.navMessages, route: '/messages'),
                    navItem(icon: Icons.how_to_reg_rounded, label: l.navAttendance, route: '/attendance'),
                    navItem(icon: Icons.grade_rounded, label: l.navGrades, route: '/grades'),
                    navItem(icon: Icons.assignment_rounded, label: l.navAssignments, route: '/assignments'),
                    navItem(icon: Icons.folder_rounded, label: l.navMaterials, route: '/materials'),
                    navItem(icon: Icons.video_call_rounded, label: l.navMeetings, route: '/meetings'),
                    navItem(icon: Icons.campaign_rounded, label: l.navAnnouncements, route: '/announcements'),
                    navItem(icon: Icons.notifications_rounded, label: l.navNotifications, route: '/notifications'),
                    navItem(icon: Icons.quiz_rounded, label: l.navExams, route: '/exams'),
                    navItem(icon: Icons.assignment_turned_in_rounded, label: l.navForms, route: '/forms'),
                    navItem(icon: Icons.bookmark_rounded, label: l.navSavedQuestions, route: '/saved-questions'),
                    navItem(icon: Icons.workspace_premium_rounded, label: l.navDiplomas, route: '/diplomas'),
                    sectionHeader(l.sectionAccount),
                  ],

                  navItem(
                    icon: Icons.person_rounded,
                    label: l.navProfile,
                    route: '/profile',
                  ),
                  // NOVA Plans is offered to students, teachers, and parents
                  // (the roles that actually use the NOVA tutor). Admins and
                  // secretaries manage a school, not a tutor subscription.
                  if (!isPureAdmin && !isSecretary)
                    navItem(
                      icon: Icons.workspace_premium_rounded,
                      label: l.navPlans,
                      route: '/plans',
                    ),
                  navItem(
                    icon: Icons.settings_rounded,
                    label: l.navSettings,
                    route: '/settings',
                  ),
                  navItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Support',
                    route: '/support',
                  ),
                  navItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About',
                    route: '/about',
                  ),
                  // Logout (danger style, separate tap handler)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await ref.read(authControllerProvider).logout(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 11),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: cs.errorContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.logout_rounded,
                                  size: 18,
                                  color: cs.error,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l.navLogout,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: cs.error,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _initials(String name) {
  if (name.isEmpty) return 'CM';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  // Single word: use first two characters
  final word = parts[0];
  if (word.length >= 2) return '${word[0]}${word[1]}'.toUpperCase();
  return word[0].toUpperCase();
}

Widget _schoolLogoPlaceholder(ColorScheme cs) {
  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: cs.primaryContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(
      Icons.school_rounded,
      size: 20,
      color: cs.onPrimaryContainer,
    ),
  );
}

/// Liquid-glass-styled child selector under the parent's name in the
/// drawer header. Tap → opens the shared bottom-sheet picker; selecting
/// writes to [selectedChildProvider] so every parent-scoped data
/// provider re-fetches against the new child.
class _ParentChildDropdown extends ConsumerWidget {
  const _ParentChildDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final async = ref.watch(parentChildrenProvider);
    final selectedId = ref.watch(selectedChildProvider);

    return async.when(
      loading: () => _shell(cs, isDark,
          child: Text(AppLocalizations.of(context)!.drawerLoadingChildren,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant))),
      error: (err, _) => _shell(cs, isDark,
          child: Text(AppLocalizations.of(context)!.drawerCouldNotLoadChildren,
              style: TextStyle(fontSize: 12, color: cs.error))),
      data: (children) {
        if (children.isEmpty) {
          return _shell(cs, isDark,
              child: Text(AppLocalizations.of(context)!.drawerNoChildrenLinked,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)));
        }
        final selected = children.firstWhere(
          (c) => c.studentId == selectedId,
          orElse: () => children.first,
        );

        return InkWell(
          onTap: () async {
            final picked = await showLiquidGlassPicker<String>(
              context: context,
              title: AppLocalizations.of(context)!.drawerSwitchChild,
              currentValue: selected.studentId,
              items: [
                for (final c in children)
                  LiquidGlassDropdownItem(
                    value: c.studentId,
                    label: c.gradeLabel.isNotEmpty
                        ? '${c.name.isEmpty ? '—' : c.name} • ${c.gradeLabelLocalized(AppLocalizations.of(context)!)}'
                        : (c.name.isEmpty ? '—' : c.name),
                    icon: Icons.child_care_rounded,
                  ),
              ],
            );
            if (picked != null && picked != selected.studentId) {
              ref.read(selectedChildProvider.notifier).select(picked);
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: _shell(
            cs,
            isDark,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: cs.primary,
                  child: Text(
                    _initials(selected.name),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selected.name.isEmpty ? '—' : selected.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        );
      },
    );
  }

  /// The liquid-glass shell — same gradient + border style as
  /// [LiquidGlassDropdown] so the drawer trigger matches the rest of the
  /// app's pickers.
  Widget _shell(ColorScheme cs, bool isDark, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface.withValues(alpha: isDark ? 0.76 : 0.88),
            cs.surfaceContainerHigh.withValues(alpha: isDark ? 0.56 : 0.66),
          ],
        ),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: child,
    );
  }
}

