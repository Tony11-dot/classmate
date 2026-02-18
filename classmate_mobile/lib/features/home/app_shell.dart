import 'package:classmate_mobile/ui/nav/main_drawer.dart';
import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

import 'package:go_router/go_router.dart';

import "../notifications/unread_provider.dart";

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  bool _showTitle(String loc) {
    return loc.startsWith('/schedule') ||
        loc.startsWith('/classrooms') ||
        loc.startsWith('/insights') ||
        loc.startsWith('/tutor');
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();

    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: _showTitle(loc)
            ? const Text(
                'ClassMate',
                style: TextStyle(fontWeight: FontWeight.w900),
              )
            : null,
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx(loc),
        onDestinationSelected: (i) => _go(context, i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          NavigationDestination(icon: Icon(Icons.class_), label: 'Classrooms'),
          NavigationDestination(icon: Icon(Icons.smart_toy), label: 'Tutor'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }

  int _idx(String loc) {
    if (loc.startsWith('/schedule')) return 0;
    if (loc.startsWith('/classrooms')) return 1;
    if (loc.startsWith('/tutor')) return 2;
    if (loc.startsWith('/insights')) return 3;
    return 4;
  }

  void _go(BuildContext c, int i) {
    switch (i) {
      case 0:
        c.go('/schedule');
        break;
      case 1:
        c.go('/classrooms');
        break;
      case 2:
        c.go('/tutor');
        break;
      case 3:
        c.go('/insights');
        break;
      default:
        c.go('/settings');
    }
  }
}

class _MainDrawer extends StatelessWidget {
  const _MainDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'ClassMate',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const Divider(),
          _item(context, 'Attendance', '/attendance'),
          _item(context, 'Grades', '/grades'),
          _item(context, 'Announcements', '/announcements'),
          _item(context, 'Notifications', '/notifications'),
          _item(context, 'Assignments', '/assignments'),
          const Divider(),
          _item(context, 'Settings', '/settings'),
        ],
      ),
    );
  }

  Widget _item(BuildContext c, String t, String r) {
    return ListTile(
      title: Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
      trailing: t == 'Notifications'
          ? Consumer(
              builder: (context, ref, _) {
                final u = ref.watch(unreadCountProvider);
                return u.when(
                  data: (n) => n > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0x22000000)),
                          ),
                          child: Text(
                            '$n',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            )
          : null,
      onTap: () {
        Navigator.pop(c);
        c.go(r);
      },
    );
  }
}
