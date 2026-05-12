import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:classmate_mobile/core/auth/auth_controller.dart';
import 'package:classmate_mobile/l10n/app_localizations.dart';
import 'package:classmate_mobile/ui/widgets/classmate_logo.dart';

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
                      ],
                    ),
                  ),
                  // Logo close button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: schoolLogoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.network(
                                schoolLogoUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const ClassMateIcon(size: 22),
                              ),
                            )
                          : const ClassMateIcon(size: 22),
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
                  sectionHeader(l.sectionCore),
                  if (isSecretary) ...[
                    // Secretary: focused on announcements, students, messaging
                    navItem(icon: Icons.campaign_rounded, label: l.navAnnouncements, route: '/announcements'),
                    navItem(icon: Icons.school_rounded, label: l.adminStudents, route: '/secretary/students'),
                    navItem(icon: Icons.chat_bubble_rounded, label: l.navMessages, route: '/messages'),
                    navItem(icon: Icons.psychology_rounded, label: l.navNova, route: '/tutor'),
                  ] else if (isPureAdmin) ...[
                    navItem(icon: Icons.dashboard_rounded, label: l.navDashboard, route: '/admin/dashboard'),
                    navItem(icon: Icons.people_rounded, label: l.navPeople, route: '/admin/people'),
                    navItem(icon: Icons.groups_rounded, label: l.navCohorts, route: '/admin/cohorts'),
                    navItem(icon: Icons.manage_history_rounded, label: l.adminScheduleTitle, route: '/admin/schedule'),
                    navItem(icon: Icons.chat_bubble_rounded, label: l.navMessages, route: '/messages'),
                    navItem(icon: Icons.psychology_rounded, label: l.navNova, route: '/tutor'),
                  ] else if (isTeacherLike) ...[
                    navItem(
                      icon: Icons.event_note_rounded,
                      label: l.navSchedule,
                      route: '/teacher/schedule',
                    ),
                    navItem(
                      icon: Icons.groups_rounded,
                      label: l.navClassrooms,
                      route: '/teacher/classrooms',
                    ),
                    navItem(
                      icon: Icons.psychology_rounded,
                      label: l.navNova,
                      route: '/tutor',
                    ),
                    navItem(
                      icon: Icons.insights_rounded,
                      label: l.navInsights,
                      route: '/teacher/insights',
                    ),
                    navItem(
                      icon: Icons.chat_bubble_rounded,
                      label: l.navMessages,
                      route: '/messages',
                    ),
                  ] else ...[
                    navItem(
                      icon: Icons.calendar_month_rounded,
                      label: l.navSchedule,
                      route: '/schedule',
                    ),
                    navItem(
                      icon: Icons.groups_rounded,
                      label: l.navClassrooms,
                      route: '/classrooms',
                    ),
                    navItem(
                      icon: Icons.auto_awesome_rounded,
                      label: l.navPractice,
                      route: '/practice',
                    ),
                    navItem(
                      icon: Icons.insights_rounded,
                      label: l.navInsights,
                      route: '/insights',
                    ),
                    navItem(
                      icon: Icons.psychology_rounded,
                      label: l.navNova,
                      route: '/tutor',
                    ),
                  ],

                  sectionHeader(l.sectionSchoolTools),
                  if (isSecretary) ...[
                    navItem(icon: Icons.notifications_rounded, label: l.navNotifications, route: '/notifications'),
                    navItem(icon: Icons.settings_rounded, label: l.navSettings, route: '/settings'),
                  ] else if (isPureAdmin) ...[
                    navItem(icon: Icons.school_rounded, label: l.adminSchoolSettingsTitle, route: '/admin/school'),
                    navItem(icon: Icons.settings_rounded, label: l.adminSettingsTitle, route: '/admin/settings'),
                    navItem(icon: Icons.campaign_rounded, label: l.navAnnouncements, route: '/announcements'),
                    navItem(icon: Icons.notifications_rounded, label: l.navNotifications, route: '/notifications'),
                    navItem(icon: Icons.lightbulb_rounded, label: l.navSolutions, route: '/solutions'),
                  ] else if (isTeacherLike) ...[
                    navItem(
                      icon: Icons.dashboard_rounded,
                      label: l.navTeacherWorkspace,
                      route: '/teacher/home',
                    ),
                    navItem(
                      icon: Icons.fact_check_rounded,
                      label: l.navAttendance,
                      route: '/teacher/attendance',
                    ),
                    navItem(
                      icon: Icons.grade_rounded,
                      label: l.navGrades,
                      route: '/teacher/grades',
                    ),
                    navItem(
                      icon: Icons.campaign_rounded,
                      label: l.navAnnouncements,
                      route: '/announcements',
                    ),
                    navItem(
                      icon: Icons.notifications_rounded,
                      label: l.navNotifications,
                      route: '/notifications',
                    ),
                    navItem(
                      icon: Icons.assignment_rounded,
                      label: l.navAssignments,
                      route: '/teacher/assignments',
                    ),
                    navItem(
                      icon: Icons.folder_shared_rounded,
                      label: 'Materials',
                      route: '/teacher/materials',
                    ),
                    navItem(
                      icon: Icons.video_call_rounded,
                      label: l.navMeetings,
                      route: '/teacher/meetings',
                    ),
                    navItem(
                      icon: Icons.people_rounded,
                      label: l.teacherStudentsLabel,
                      route: '/teacher/students',
                    ),
                    navItem(
                      icon: Icons.quiz_rounded,
                      label: l.navExams,
                      route: '/teacher/exams',
                    ),
                    navItem(
                      icon: Icons.assignment_turned_in_rounded,
                      label: l.navForms,
                      route: '/teacher/forms',
                    ),
                    navItem(
                      icon: Icons.workspace_premium_rounded,
                      label: l.navDiplomas,
                      route: '/diplomas',
                    ),
                    navItem(
                      icon: Icons.lightbulb_rounded,
                      label: l.navSolutions,
                      route: '/solutions',
                    ),
                  ] else ...[
                    navItem(
                      icon: Icons.chat_bubble_rounded,
                      label: l.navMessages,
                      route: '/messages',
                    ),
                    navItem(
                      icon: Icons.how_to_reg_rounded,
                      label: l.navAttendance,
                      route: '/attendance',
                    ),
                    navItem(
                      icon: Icons.grade_rounded,
                      label: l.navGrades,
                      route: '/grades',
                    ),
                    navItem(
                      icon: Icons.assignment_rounded,
                      label: l.navAssignments,
                      route: '/assignments',
                    ),
                    navItem(
                      icon: Icons.folder_rounded,
                      label: 'Materials',
                      route: '/materials',
                    ),
                    navItem(
                      icon: Icons.video_call_rounded,
                      label: l.navMeetings,
                      route: '/meetings',
                    ),
                    navItem(
                      icon: Icons.campaign_rounded,
                      label: l.navAnnouncements,
                      route: '/announcements',
                    ),
                    navItem(
                      icon: Icons.notifications_rounded,
                      label: l.navNotifications,
                      route: '/notifications',
                    ),
                    navItem(
                      icon: Icons.lightbulb_rounded,
                      label: l.navSolutions,
                      route: '/solutions',
                    ),
                    navItem(
                      icon: Icons.quiz_rounded,
                      label: l.navExams,
                      route: '/exams',
                    ),
                    navItem(
                      icon: Icons.assignment_turned_in_rounded,
                      label: l.navForms,
                      route: '/forms',
                    ),
                    navItem(
                      icon: Icons.bookmark_rounded,
                      label: l.navSavedQuestions,
                      route: '/saved-questions',
                    ),
                    navItem(
                      icon: Icons.workspace_premium_rounded,
                      label: l.navDiplomas,
                      route: '/diplomas',
                    ),
                  ],

                  sectionHeader(l.sectionAccount),
                  navItem(
                    icon: Icons.person_rounded,
                    label: l.navProfile,
                    route: '/profile',
                  ),
                  navItem(
                    icon: Icons.settings_rounded,
                    label: l.navSettings,
                    route: '/settings',
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

