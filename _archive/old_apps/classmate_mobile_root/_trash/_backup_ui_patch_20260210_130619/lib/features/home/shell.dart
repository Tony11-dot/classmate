import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../demo/demo_store.dart';

class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  int _idxFromLoc(String loc) {
    if (loc == '/' || loc.startsWith('/schedule')) return 0;
    if (loc.startsWith('/classrooms')) return 1;
    if (loc.startsWith('/tutor')) return 2;
    if (loc.startsWith('/insights')) return 3;
    return 4;
  }

  void _goIdx(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go('/schedule');
        break;
      case 1:
        context.go('/classrooms');
        break;
      case 2:
        context.go('/tutor');
        break;
      case 3:
        context.go('/insights');
        break;
      default:
        context.go('/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = DemoStore.user;
    final loc = GoRouterState.of(context).uri.toString();
    final idx = _idxFromLoc(loc);

    return Scaffold(
      drawer: const _AppDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'ClassMate',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.2),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${u.points}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline_rounded),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => _goIdx(context, i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.class_outlined),
            label: 'Classrooms',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            label: 'Tutor',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_graph_outlined),
            label: 'Insights',
          ),
          NavigationDestination(icon: Icon(Icons.tune_rounded), label: 'More'),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 8, 10, 12),
              child: Text(
                'ClassMate',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: const Text(
                'Attendance',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/attendance');
              },
            ),
            ListTile(
              leading: const Icon(Icons.school_outlined),
              title: const Text(
                'Grades',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/grades');
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign_outlined),
              title: const Text(
                'Announcements',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/announcements');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: const Text(
                'Assignments',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/assignments');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cloud_sync_outlined),
              title: const Text(
                'Import (Google Classroom demo)',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/import');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}
