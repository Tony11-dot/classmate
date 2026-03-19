import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/nav/main_drawer.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  int _indexFor(String loc) {
    if (loc.startsWith('/classrooms')) return 1;
    if (loc.startsWith('/practice')) return 2;
    if (loc.startsWith('/nova')) return 2;
    if (loc.startsWith('/insights')) return 3;
    if (loc.startsWith('/tutor')) return 4;
    return 0;
  }

  String _locFor(int index) => switch (index) {
    0 => '/schedule',
    1 => '/classrooms',
    2 => '/practice',
    3 => '/insights',
    4 => '/tutor',
    _ => '/schedule',
  };

  String _pageTitle(String loc) {
    if (loc.startsWith('/classrooms')) return 'Classes';
    if (loc.startsWith('/dms')) return 'Messages';
    if (loc.startsWith('/exams')) return 'Exams';
    if (loc.startsWith('/practice')) return 'Practice';
    if (loc.startsWith('/nova')) return 'NOVA';
    if (loc.startsWith('/insights')) return 'Insights';
    if (loc.startsWith('/tutor')) return 'NOVA';

    if (loc.startsWith('/attendance')) return 'Attendance';
    if (loc.startsWith('/grades')) return 'Grades';
    if (loc.startsWith('/assignments')) return 'Assignments';
    if (loc.startsWith('/meetings')) return 'Meetings';
    if (loc.startsWith('/announcements')) return 'Announcements';
    if (loc.startsWith('/notifications')) return 'Notifications';
    if (loc.startsWith('/announcements')) return 'Announcements';

    if (loc.startsWith('/profile')) return 'Profile';
    if (loc.startsWith('/settings')) return 'Settings';

    return 'Schedule';
  }

  bool _hideBottomNav(String loc) {
    if (loc.startsWith('/practice/session')) return true;
    if (loc.startsWith('/practice')) return false;
    if (loc.startsWith('/classrooms/')) return true;
    if (loc.startsWith('/tutor?')) return true;
    if (loc.startsWith('/tutor/')) return true;
    if (loc.contains('/chat')) return true;
    return false;
  }

  bool _hideTopBar(String loc) {
    if (loc.startsWith('/practice/session')) return true;
    if (loc.startsWith('/practice')) return false;
    if (loc.startsWith('/classrooms/')) return true;
    if (loc.startsWith('/tutor?')) return true;
    if (loc.startsWith('/tutor/')) return true;
    if (loc.contains('/chat')) return true;
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).uri.toString();
    final idx = _indexFor(loc);
    final hideBottomNav = _hideBottomNav(loc);
    final hideTopBar = _hideTopBar(loc);

    return Scaffold(
      drawerEnableOpenDragGesture: true,
      drawer: hideTopBar ? null : const MainDrawer(),
      appBar: hideTopBar ? null : _TopBar(title: _pageTitle(loc)),
      body: child,
      bottomNavigationBar: hideBottomNav
          ? null
          : NavigationBar(
              animationDuration: const Duration(milliseconds: 90),
              selectedIndex: idx,
              onDestinationSelected: (i) {
                final next = _locFor(i);
                if (next == loc) return;
                context.go(next);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.event_note_outlined),
                  selectedIcon: Icon(Icons.event_note),
                  label: 'Schedule',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  selectedIcon: Icon(Icons.groups),
                  label: 'Classes',
                ),
                NavigationDestination(
                  icon: Icon(Icons.smart_display_outlined),
                  selectedIcon: Icon(Icons.smart_display),
                  label: 'Practice',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights),
                  label: 'Insights',
                ),
                NavigationDestination(
                  icon: Icon(Icons.psychology_outlined),
                  selectedIcon: Icon(Icons.psychology),
                  label: 'NOVA',
                ),
              ],
            ),
    );
  }
}

class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopBar({required this.title});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      centerTitle: true,
      title: const Text(
        'ClassMate',
        style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.2),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Center(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
