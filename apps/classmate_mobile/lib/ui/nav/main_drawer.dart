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
          children: const [
            _Header(),
            Divider(),
            _SectionTitle('Core'),
            _NavTile(
              icon: Icons.event_note,
              title: 'Schedule',
              route: '/schedule',
            ),
            _NavTile(
              icon: Icons.groups,
              title: 'Classrooms',
              route: '/classrooms',
            ),
            _NavTile(
              icon: Icons.psychology,
              title: 'AI Tutor',
              route: '/tutor',
            ),
            _NavTile(
              icon: Icons.insights,
              title: 'Insights',
              route: '/insights',
            ),
            _NavTile(
              icon: Icons.smart_display,
              title: 'Solutions',
              route: '/solutions',
            ),
            Divider(),
            _SectionTitle('LifeDoc'),
            _NavTile(
              icon: Icons.how_to_reg,
              title: 'Attendance',
              route: '/attendance',
            ),
            _NavTile(icon: Icons.grade, title: 'Grades', route: '/grades'),
            _NavTile(
              icon: Icons.assignment,
              title: 'Assignments',
              route: '/assignments',
            ),
            _NavTile(
              icon: Icons.campaign,
              title: 'Announcements',
              route: '/announcements',
            ),
            _NavTile(
              icon: Icons.notifications,
              title: 'Notifications',
              route: '/notifications',
            ),
            Divider(),
            _SectionTitle('Account'),
            _NavTile(icon: Icons.person, title: 'Profile', route: '/profile'),
            _NavTile(
              icon: Icons.settings,
              title: 'Settings',
              route: '/settings',
            ),
            _NavTile(
              icon: Icons.palette,
              title: 'Customization',
              route: '/customization',
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4),
          Text('Created by Tony Aboud', style: TextStyle(fontSize: 13)),
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
