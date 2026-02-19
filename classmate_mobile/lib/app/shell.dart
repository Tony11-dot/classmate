import 'package:classmate_mobile/ui/nav/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_controller.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  int _indexFor(String loc) {
    if (loc.startsWith('/classrooms')) return 1;
    if (loc.startsWith('/solutions')) return 2;
    if (loc.startsWith('/insights')) return 3;
    if (loc.startsWith('/tutor')) return 4;
    return 0; // schedule
  }

  String _locFor(int index) {
    return switch (index) {
      0 => '/app',
      1 => '/classrooms',
      2 => '/solutions',
      3 => '/insights',
      4 => '/tutor',
      _ => '/app',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).uri.toString();
    final idx = _indexFor(loc);

    final auth = ref.watch(authProvider);
    final errorBanner = auth.error;

    return Scaffold(
      appBar: _TopBar(title: _titleFor(loc)),
      drawer: const MainDrawer(),
      body: Column(
        children: [
          if (errorBanner != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: Text(
                'API auth failed (demo still works): ',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          Expanded(child: child),
        ],
      ),
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

String _titleFor(String loc) {
  if (loc.startsWith('/classrooms')) return 'Classrooms';
  if (loc.startsWith('/solutions')) return 'Solutions';
  if (loc.startsWith('/insights')) return 'Insights';
  if (loc.startsWith('/tutor')) return 'AI Tutor';
  if (loc.startsWith('/attendance')) return 'Attendance';
  if (loc.startsWith('/grades')) return 'Grades';
  if (loc.startsWith('/assignments')) return 'Assignments';
  if (loc.startsWith('/announcements')) return 'Announcements';
  if (loc.startsWith('/profile')) return 'Profile';
  if (loc.startsWith('/settings')) return 'Settings';
  return 'Schedule';
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
