import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/nav/main_drawer.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  int _indexFor(String loc) {
    if (loc.startsWith('/classrooms')) return 1;
    if (loc.startsWith('/solutions')) return 2; // swapped
    if (loc.startsWith('/insights')) return 3;
    if (loc.startsWith('/tutor')) return 4; // swapped
    return 0;
  }

  String _locFor(int index) => switch (index) {
    0 => '/schedule',
    1 => '/classrooms',
    2 => '/solutions', // swapped
    3 => '/insights',
    4 => '/tutor', // swapped
    _ => '/schedule',
  };

  String _pageTitle(String loc) {
    if (loc.startsWith('/classrooms')) return 'Classrooms';
    if (loc.startsWith('/solutions')) return 'Solutions';
    if (loc.startsWith('/insights')) return 'Insights';
    if (loc.startsWith('/tutor')) return 'AI Tutor';

    if (loc.startsWith('/attendance')) return 'Attendance';
    if (loc.startsWith('/grades')) return 'Grades';
    if (loc.startsWith('/assignments')) return 'Assignments';
    if (loc.startsWith('/announcements')) return 'Announcements';
    if (loc.startsWith('/notifications')) return 'Notifications';

    if (loc.startsWith('/profile')) return 'Profile';
    if (loc.startsWith('/settings')) return 'Settings';

    return 'Schedule';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).uri.toString();
    final idx = _indexFor(loc);

    return Scaffold(
      appBar: _TopBar(title: _pageTitle(loc)),
      drawer: const MainDrawer(),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_locFor(i)),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Classrooms',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_display_outlined),
            selectedIcon: Icon(Icons.smart_display),
            label: 'Solutions',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: 'Tutor',
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      centerTitle: true,
      title: const Text(
        'ClassMate',
        style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.2),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
        ),
      ],
    );
  }
}
