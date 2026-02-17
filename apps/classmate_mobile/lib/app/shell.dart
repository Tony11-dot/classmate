import 'package:flutter/material.dart';
import '../auth/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/notifications/unread_count_provider.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static const _mainTabs = <_NavItem>[
    _NavItem('Schedule', Icons.calendar_month, '/app'),
    _NavItem('Classrooms', Icons.class_, '/classrooms'),
    _NavItem('Solutions', Icons.auto_awesome_mosaic, '/solutions'),
    _NavItem('Insights', Icons.insights, '/insights'),
    _NavItem('Tutor', Icons.smart_toy, '/tutor'),
  ];

  static const _schoolTabs = <_NavItem>[
    _NavItem('Attendance', Icons.check_circle, '/attendance'),
    _NavItem('Grades', Icons.grade, '/grades'),
    _NavItem('Assignments', Icons.assignment, '/assignments'),
    _NavItem('Announcements', Icons.campaign, '/announcements'),
    _NavItem('Notifications', Icons.notifications, '/notifications'),
    _NavItem('Alerts', Icons.notifications, '/alerts'),
  ];

  static const _accountTabs = <_NavItem>[
    _NavItem('Profile', Icons.person, '/profile'),
    _NavItem('Settings', Icons.settings, '/settings'),
  ];

  String _titleFor(String loc) {
    for (final x in [..._mainTabs, ..._schoolTabs, ..._accountTabs]) {
      if (loc == x.loc) return x.label;
    }
    if (loc.startsWith('/classrooms/')) return 'Classroom';
    return 'ClassMate';
  }

  int _mainIndexFor(String loc) {
    for (var i = 0; i < _mainTabs.length; i++) {
      if (loc == _mainTabs[i].loc) return i;
    }
    if (loc.startsWith('/classrooms/')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).uri.toString();
    final title = _titleFor(loc);
    final idx = _mainIndexFor(loc);

    return Scaffold(
      // ✅ Fix drawer not opening (and enable swipe)
      drawerEnableOpenDragGesture: true,
      drawer: _Drawer(
        onGo: (path) {
          Navigator.pop(context);
          context.go(path);
        },
      ),

      appBar: AppBar(
        // left: hamburger. title centered. right: "ClassMate" logo text.
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        centerTitle: true,
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Text(
                'ClassMate',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),

      body: child,

      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_mainTabs[i].loc),
        destinations: [
          for (final t in _mainTabs)
            NavigationDestination(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }
}

class _Drawer extends ConsumerWidget {
  const _Drawer({required this.onGo});
  final void Function(String) onGo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget section(String label, List<_NavItem> items) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ...items.map(
            (x) => ListTile(
              leading: Icon(x.icon),
              title: x.loc == '/notifications'
                  ? _NotifTitle(
                      label: x.label,
                      countAsync: ref.watch(notificationsUnreadCountProvider),
                    )
                  : Text(x.label),
              onTap: () => onGo(x.loc),
            ),
          ),
        ],
      );
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'ClassMate',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
            const Divider(),
            section('Main', AppShell._mainTabs),
            const Divider(),
            section('School', AppShell._schoolTabs),
            const Divider(),
            section('Account', AppShell._accountTabs),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (!context.mounted) return;
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifTitle extends StatelessWidget {
  final String label;
  final AsyncValue<int> countAsync;
  const _NotifTitle({required this.label, required this.countAsync});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        countAsync.when(
          data: (c) {
            if (c <= 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$c',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.loc);
  final String label;
  final IconData icon;
  final String loc;
}
