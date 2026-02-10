import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../demo/demo_data.dart';

class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final user = DemoStore.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Classmate'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${user.points}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
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
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexForLocation(
          GoRouterState.of(context).uri.toString(),
        ),
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/classrooms');
              break;
            case 1:
              context.go('/assignments');
              break;
            case 2:
              context.go('/leaderboard');
              break;
            default:
              context.go('/classrooms');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            label: 'Classes',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            label: 'Rank',
          ),
        ],
      ),
    );
  }

  int _indexForLocation(String loc) {
    if (loc.startsWith('/assignments')) return 1;
    if (loc.startsWith('/leaderboard')) return 2;
    return 0;
  }
}
