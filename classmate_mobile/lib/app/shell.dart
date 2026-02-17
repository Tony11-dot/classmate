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
      appBar: AppBar(title: const Text('ClassMate')),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              const ListTile(
                title: Text(
                  'ClassMate',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('Pilot build'),
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.event_note),
                title: const Text('Schedule'),
                onTap: () => context.go('/app'),
              ),
              ListTile(
                leading: const Icon(Icons.groups),
                title: const Text('Classrooms'),
                onTap: () => context.go('/classrooms'),
              ),
              ListTile(
                leading: const Icon(Icons.smart_display),
                title: const Text('Solutions'),
                onTap: () => context.go('/solutions'),
              ),
              ListTile(
                leading: const Icon(Icons.insights),
                title: const Text('Insights'),
                onTap: () => context.go('/insights'),
              ),
              ListTile(
                leading: const Icon(Icons.psychology),
                title: const Text('AI Tutor'),
                onTap: () => context.go('/tutor'),
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.how_to_reg),
                title: const Text('Attendance'),
                onTap: () => context.go('/attendance'),
              ),
              ListTile(
                leading: const Icon(Icons.grade),
                title: const Text('Grades'),
                onTap: () => context.go('/grades'),
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Assignments'),
                onTap: () => context.go('/assignments'),
              ),
              ListTile(
                leading: const Icon(Icons.campaign),
                title: const Text('Announcements'),
                onTap: () => context.go('/announcements'),
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () => context.go('/profile'),
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Settings'),
                onTap: () => context.go('/settings'),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Reset pilot user'),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/app');
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (errorBanner != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: Text(
                'API auth failed (demo still works): $errorBanner',
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
