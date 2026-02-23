import 'package:flutter/material.dart';

import '../../features/parent/parent_dashboard_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const ParentDashboardScreen(),
      const _Stub(title: 'Classrooms'),
      const _Stub(title: 'AI Tutor'),
      const _Stub(title: 'Insights'),
      const _Stub(title: 'Solutions'),
    ];

    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (v) => setState(() => idx = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Classrooms'),
          NavigationDestination(
            icon: Icon(Icons.psychology),
            label: 'AI Tutor',
          ),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Insights'),
          NavigationDestination(
            icon: Icon(Icons.smart_display),
            label: 'Solutions',
          ),
        ],
      ),
    );
  }
}

class _Stub extends StatelessWidget {
  const _Stub({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Coming soon')),
    );
  }
}
