import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            const _Header(),
            const SizedBox(height: 8),

            const _SectionTitle('Core'),
            _NavTile(
              icon: Icons.calendar_today,
              title: 'Schedule',
              route: '/app',
            ),
            _NavTile(
              icon: Icons.class_,
              title: 'Classrooms',
              route: '/classrooms',
            ),
            _NavTile(icon: Icons.smart_toy, title: 'AI Tutor', route: '/tutor'),
            _NavTile(
              icon: Icons.insights,
              title: 'Insights',
              route: '/insights',
            ),
            _NavTile(
              icon: Icons.lightbulb,
              title: 'Solutions',
              route: '/solutions',
            ),

            const Divider(height: 24),

            const _SectionTitle('LifeDoc'),
            _NavTile(
              icon: Icons.check_circle,
              title: 'Attendance',
              route: '/attendance',
            ),
            _NavTile(icon: Icons.grade, title: 'Grades', route: '/grades'),
            _NavTile(
              icon: Icons.notifications,
              title: 'Notifications',
              route: '/notifications',
            ),
            _NavTile(
              icon: Icons.announcement,
              title: 'Announcements',
              route: '/announcements',
            ),
            _NavTile(
              icon: Icons.assignment,
              title: 'Assignments',
              route: '/assignments',
            ),

            const Divider(height: 24),

            const _SectionTitle('Account'),
            _NavTile(icon: Icons.person, title: 'Profile', route: '/profile'),
            _NavTile(
              icon: Icons.settings,
              title: 'Settings',
              route: '/settings',
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // TODO: wire real logout (auth controller)
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'ClassMate',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text('Navigation', style: TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.route,
  });
  final IconData icon;
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }
}
