import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:classmate_mobile/core/auth/auth_controller.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    Widget section(String title) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 0.3,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    ListTile item({
      required IconData icon,
      required String title,
      required VoidCallback onTap,
    }) {
      return ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        onTap: () {
          Navigator.of(context).pop();
          onTap();
        },
      );
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: cs.primaryContainer.withValues(alpha: 0.75),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ClassMate',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Menu',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.4)),
            section('Core'),
            item(
              icon: Icons.calendar_month_rounded,
              title: 'Schedule',
              onTap: () => context.go('/schedule'),
            ),
            item(
              icon: Icons.groups_rounded,
              title: 'Classrooms',
              onTap: () => context.go('/classrooms'),
            ),
            item(
              icon: Icons.auto_awesome_rounded,
              title: 'Practice',
              onTap: () => context.go('/practice'),
            ),
            item(
              icon: Icons.insights_rounded,
              title: 'Insights',
              onTap: () => context.go('/insights'),
            ),
            item(
              icon: Icons.psychology_rounded,
              title: 'NOVA',
              onTap: () => context.go('/tutor'),
            ),
            section('School tools'),
            item(
              icon: Icons.how_to_reg_rounded,
              title: 'Attendance',
              onTap: () => context.go('/attendance'),
            ),
            item(
              icon: Icons.grade_rounded,
              title: 'Grades',
              onTap: () => context.go('/grades'),
            ),
            item(
              icon: Icons.campaign_rounded,
              title: 'Announcements',
              onTap: () => context.go('/announcements'),
            ),
            item(
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              onTap: () => context.go('/notifications'),
            ),
            item(
              icon: Icons.forum_rounded,
              title: 'DMs',
              onTap: () => context.go('/dms'),
            ),
            item(
              icon: Icons.bookmark_rounded,
              title: 'Saved questions',
              onTap: () => context.go('/saved-questions'),
            ),
            section('Profile'),
            item(
              icon: Icons.person_rounded,
              title: 'Profile',
              onTap: () => context.go('/profile'),
            ),
            item(
              icon: Icons.settings_rounded,
              title: 'Settings',
              onTap: () => context.go('/settings'),
            ),
            item(
              icon: Icons.logout_rounded,
              title: 'Logout',
              onTap: () async {
                await ref.read(authControllerProvider).logout(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
