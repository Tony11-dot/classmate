import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/session.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _indexForLocation(String location) {
    if (location.startsWith('/schedule')) return 0;
    if (location.startsWith('/classrooms')) return 1;
    if (location.startsWith('/tutor')) return 2;
    if (location.startsWith('/notifications')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  String _locationForIndex(int index) {
    switch (index) {
      case 0:
        return '/schedule';
      case 1:
        return '/classrooms';
      case 2:
        return '/tutor';
      case 3:
        return '/notifications';
      case 4:
        return '/profile';
      default:
        return '/schedule';
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final idx = _indexForLocation(loc);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ClassMate'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Schedule'),
                onTap: () => context.go('/schedule'),
              ),
              ListTile(
                leading: const Icon(Icons.grade),
                title: const Text('Grades'),
                onTap: () => context.go('/grades'),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Attendance'),
                onTap: () => context.go('/attendance'),
              ),
              ListTile(
                leading: const Icon(Icons.campaign),
                title: const Text('Announcements'),
                onTap: () => context.go('/announcements'),
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Assignments'),
                onTap: () => context.go('/assignments'),
              ),
              ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('Solutions'),
                onTap: () => context.go('/solutions'),
              ),
              ListTile(
                leading: const Icon(Icons.insights),
                title: const Text('AI Insights'),
                onTap: () => context.go('/insights'),
              ),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Import / Admin ops'),
                onTap: () => context.go('/import'),
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () => context.go('/settings'),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await Session.clear();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_locationForIndex(i)),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          NavigationDestination(icon: Icon(Icons.class_), label: 'Classrooms'),
          NavigationDestination(icon: Icon(Icons.smart_toy), label: 'Tutor'),
          NavigationDestination(
            icon: Icon(Icons.notifications),
            label: 'Notifs',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
