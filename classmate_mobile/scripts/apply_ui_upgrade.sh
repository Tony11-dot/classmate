#!/usr/bin/env bash
set -euo pipefail

echo "==> Upgrading UI: App title, Schedule day pager, Drawer, Classrooms tab, Classroom detail (chat/assignments/meetings/solutions)..."

mkdir -p lib/features/{classrooms,attendance,grades,announcements,assignments}

# 1) Fix the Insights crash: use go_router instead of pushNamed
perl -i -pe 's/Navigator\.of\(context\)\.pushNamed\(\'\/solutions\'\)/context.push(\'\/solutions\')/g' \
  lib/features/insights/insights_screen.dart || true

# Ensure Insights has go_router import (safe if already there)
perl -0777 -i -pe 'if($_ !~ /package:go_router\/go_router\.dart/){ s/import\s+\'package:flutter\/material\.dart\';/import \'package:flutter\/material\.dart\';\nimport \'package:go_router\/go_router.dart\';/ } $_' \
  lib/features/insights/insights_screen.dart || true


# 2) Home shell: centered "ClassMate", Drawer, bottom nav includes Classrooms
cat > lib/features/home/shell.dart <<'DART'
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
    return 4; // settings/more
  }

  void _goIdx(BuildContext context, int i) {
    switch (i) {
      case 0: context.go('/schedule'); break;
      case 1: context.go('/classrooms'); break;
      case 2: context.go('/tutor'); break;
      case 3: context.go('/insights'); break;
      case 4: context.go('/settings'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = DemoStore.user;
    final loc = GoRouterState.of(context).uri.toString();
    final idx = _idxFromLoc(loc);

    return Scaffold(
      drawer: _AppDrawer(),
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
              child: Row(children: [
                const Icon(Icons.stars_rounded, size: 18),
                const SizedBox(width: 6),
                Text('${u.points}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ]),
            ),
          ),
          IconButton(onPressed: () => context.push('/notifications'), icon: const Icon(Icons.notifications_outlined)),
          IconButton(onPressed: () => context.push('/profile'), icon: const Icon(Icons.person_outline_rounded)),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => _goIdx(context, i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.class_outlined), label: 'Classrooms'),
          NavigationDestination(icon: Icon(Icons.smart_toy_outlined), label: 'Tutor'),
          NavigationDestination(icon: Icon(Icons.auto_graph_outlined), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.tune_rounded), label: 'More'),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 8, 10, 12),
              child: Text('ClassMate', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: const Text('Attendance', style: TextStyle(fontWeight: FontWeight.w800)),
              onTap: () { Navigator.pop(context); context.push('/attendance'); },
            ),
            ListTile(
              leading: const Icon(Icons.school_outlined),
              title: const Text('Grades', style: TextStyle(fontWeight: FontWeight.w800)),
              onTap: () { Navigator.pop(context); context.push('/grades'); },
            ),
            ListTile(
              leading: const Icon(Icons.campaign_outlined),
              title: const Text('Announcements', style: TextStyle(fontWeight: FontWeight.w800)),
              onTap: () { Navigator.pop(context); context.push('/announcements'); },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: const Text('Assignments', style: TextStyle(fontWeight: FontWeight.w800)),
              onTap: () { Navigator.pop(context); context.push('/assignments'); },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cloud_sync_outlined),
              title: const Text('Import (Google Classroom demo)', style: TextStyle(fontWeight: FontWeight.w800)),
              onTap: () { Navigator.pop(context); context.push('/import'); },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w800)),
              onTap: () { Navigator.pop(context); context.push('/settings'); },
            ),
          ],
        ),
      ),
    );
  }
}
DART


# 3) Schedule: Day header "Monday - 21/1/2026" with < > to navigate days, list schedule for that day
cat > lib/features/schedule/schedule_screen.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../demo/demo_store.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime selected = DateTime.now();

  String _dayKey(DateTime d) {
    // Demo data uses Sun..Thu
    final wd = d.weekday; // Mon=1..Sun=7
    switch (wd) {
      case DateTime.sunday: return 'Sun';
      case DateTime.monday: return 'Mon';
      case DateTime.tuesday: return 'Tue';
      case DateTime.wednesday: return 'Wed';
      case DateTime.thursday: return 'Thu';
      case DateTime.friday: return 'Fri';
      case DateTime.saturday: return 'Sat';
      default: return 'Mon';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayKey = _dayKey(selected);
    final fmt = DateFormat("EEEE - d/M/yyyy");
    final title = fmt.format(selected);

    final todays = DemoStore.schedule.where((s) => s.day == dayKey).toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => setState(() => selected = selected.subtract(const Duration(days: 1))),
            ),
            Expanded(
              child: Center(
                child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () => setState(() => selected = selected.add(const Duration(days: 1))),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (todays.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text('No items for this day.'),
            ),
          ),

        for (final x in todays)
          Card(
            child: ListTile(
              leading: _icon(x.type),
              title: Text(x.title, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('${x.time} • ${x.room}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                // If this looks like a classroom, navigate
                final match = DemoStore.classrooms.firstWhere(
                  (c) => x.title.toLowerCase().contains(c.name.toLowerCase().split(' ').first),
                  orElse: () => DemoStore.classrooms.first,
                );
                context.push('/classrooms/${match.id}');
              },
            ),
          ),

        const SizedBox(height: 8),
        const Text('Your classes', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        for (final c in DemoStore.classrooms)
          Card(
            child: ListTile(
              leading: const Icon(Icons.class_outlined),
              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('${c.teacher} • ${c.room}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/classrooms/${c.id}'),
            ),
          ),
      ],
    );
  }

  static Widget _icon(String t) {
    switch (t) {
      case 'exam': return const Icon(Icons.assignment_turned_in_outlined);
      case 'event': return const Icon(Icons.event_outlined);
      default: return const Icon(Icons.school_outlined);
    }
  }
}
DART


# 4) Classrooms list + details (chat + assignments + meetings + solutions)
cat > lib/features/classrooms/classrooms_screen.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../demo/demo_store.dart';

class ClassroomsScreen extends StatelessWidget {
  const ClassroomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('Classrooms', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        for (final c in DemoStore.classrooms)
          Card(
            child: ListTile(
              leading: const Icon(Icons.class_outlined),
              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('${c.teacher} • ${c.room}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/classrooms/${c.id}'),
            ),
          ),
      ],
    );
  }
}
DART

cat > lib/features/classrooms/classroom_detail_screen.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../demo/demo_store.dart';

class ClassroomDetailScreen extends StatefulWidget {
  final String id;
  const ClassroomDetailScreen({super.key, required this.id});

  @override
  State<ClassroomDetailScreen> createState() => _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState extends State<ClassroomDetailScreen> {
  final msgCtrl = TextEditingController();
  final messages = <(bool me, String text)>[
    (false, 'Welcome! This is your class chat.'),
    (false, 'Teacher: Please submit the next assignment by tomorrow.'),
  ];

  void send() {
    final t = msgCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      messages.add((true, t));
      messages.add((false, '👍 Got it. I’ll reply in the meeting notes.'));
      msgCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = DemoStore.classrooms.firstWhere((x) => x.id == widget.id);
    final assigns = DemoStore.assignments.where((a) => a.classroomId == c.id).toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w900)),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chat'),
              Tab(icon: Icon(Icons.assignment_outlined), text: 'Assignments'),
              Tab(icon: Icon(Icons.video_call_outlined), text: 'Meetings'),
              Tab(icon: Icon(Icons.hub_outlined), text: 'Solutions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Chat
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final m = messages[i];
                      final align = m.$1 ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                      final bg = m.$1
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest;
                      return Column(
                        crossAxisAlignment: align,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 340),
                            child: Card(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: bg,
                                ),
                                child: Text(m.$2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo sending: demo')),
                        ),
                        icon: const Icon(Icons.photo_outlined),
                      ),
                      IconButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Voice message: demo')),
                        ),
                        icon: const Icon(Icons.mic_none_outlined),
                      ),
                      Expanded(
                        child: TextField(
                          controller: msgCtrl,
                          onSubmitted: (_) => send(),
                          decoration: const InputDecoration(hintText: 'Message…'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(onPressed: send, child: const Text('Send')),
                    ],
                  ),
                ),
              ],
            ),

            // Assignments
            ListView(
              padding: const EdgeInsets.all(14),
              children: [
                for (final a in assigns)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.assignment_outlined),
                      title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Text('Due: ${a.due} • Reward: +${a.reward}'),
                      trailing: a.submitted ? const Icon(Icons.check_circle_rounded) : null,
                      onTap: () {
                        setState(() => a.submitted = true);
                        DemoStore.user.points += a.reward;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Submitted. +${a.reward} points')),
                        );
                      },
                    ),
                  ),
              ],
            ),

            // Meetings
            ListView(
              padding: const EdgeInsets.all(14),
              children: const [
                Card(
                  child: ListTile(
                    leading: Icon(Icons.video_call_outlined),
                    title: Text('Weekly lesson review', style: TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text('Thu 18:00 • Online (demo)'),
                    trailing: Icon(Icons.chevron_right_rounded),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.video_call_outlined),
                    title: Text('Exam prep session', style: TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text('Sun 20:00 • Online (demo)'),
                    trailing: Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ],
            ),

            // Solutions network (demo)
            ListView(
              padding: const EdgeInsets.all(14),
              children: [
                const Text('Solutions Network', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.group_outlined),
                    title: const Text('Ask classmates', style: TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: const Text('Post a question and get step-by-step help (demo).'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Posting: demo')),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.auto_fix_high_outlined),
                    title: const Text('AI-guided solution', style: TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: const Text('Tutor generates a path + quick quiz (demo).'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/solutions'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
DART


# 5) Drawer placeholder screens (Attendance/Grades/Announcements/Assignments)
cat > lib/features/attendance/attendance_screen.dart <<'DART'
import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance', style: TextStyle(fontWeight: FontWeight.w900))),
      body: const Padding(
        padding: EdgeInsets.all(14),
        child: Card(child: Padding(padding: EdgeInsets.all(14), child: Text('Attendance dashboard (demo).'))),
      ),
    );
  }
}
DART

cat > lib/features/grades/grades_screen.dart <<'DART'
import 'package:flutter/material.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grades', style: TextStyle(fontWeight: FontWeight.w900))),
      body: const Padding(
        padding: EdgeInsets.all(14),
        child: Card(child: Padding(padding: EdgeInsets.all(14), child: Text('Grades dashboard (demo).'))),
      ),
    );
  }
}
DART

cat > lib/features/announcements/announcements_screen.dart <<'DART'
import 'package:flutter/material.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: const [
          Card(child: ListTile(title: Text('School event (demo)', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('Tomorrow 10:00 in the hall.'))),
          Card(child: ListTile(title: Text('Reminder (demo)', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('Bring lab notebook to Physics.'))),
        ],
      ),
    );
  }
}
DART

cat > lib/features/assignments/assignments_screen.dart <<'DART'
import 'package:flutter/material.dart';
import '../../demo/demo_store.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final list = DemoStore.assignments;
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          for (final a in list)
            Card(
              child: ListTile(
                leading: const Icon(Icons.assignment_outlined),
                title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('Due: ${a.due} • Reward: +${a.reward}'),
                trailing: a.submitted ? const Icon(Icons.check_circle_rounded) : null,
              ),
            ),
        ],
      ),
    );
  }
}
DART


# 6) Router: add classrooms + drawer screens routes (attendance/grades/announcements/assignments)
# Overwrite app.dart to ensure routes exist + shell uses them
cat > lib/app/app.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme_controller.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/shell.dart';

import '../features/schedule/schedule_screen.dart';
import '../features/classrooms/classrooms_screen.dart';
import '../features/classrooms/classroom_detail_screen.dart';

import '../features/ai/ai_tutor_screen.dart';
import '../features/insights/insights_screen.dart';

import '../features/importer/import_screen.dart';
import '../features/solutions/solutions_screen.dart';
import '../features/settings/settings_screen.dart';

import '../features/profile/profile_screen.dart';
import '../features/notifications/notifications_screen.dart';

import '../features/attendance/attendance_screen.dart';
import '../features/grades/grades_screen.dart';
import '../features/announcements/announcements_screen.dart';
import '../features/assignments/assignments_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const ScheduleScreen()),
          GoRoute(path: '/schedule', builder: (_, __) => const ScheduleScreen()),

          GoRoute(path: '/classrooms', builder: (_, __) => const ClassroomsScreen()),
          GoRoute(
            path: '/classrooms/:id',
            builder: (context, state) => ClassroomDetailScreen(id: state.pathParameters['id']!),
          ),

          GoRoute(path: '/tutor', builder: (_, __) => const AITutorScreen()),
          GoRoute(path: '/insights', builder: (_, __) => const InsightsScreen()),

          GoRoute(path: '/solutions', builder: (_, __) => const SolutionsScreen()),
          GoRoute(path: '/import', builder: (_, __) => const ImportScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),

          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),

          GoRoute(path: '/attendance', builder: (_, __) => const AttendanceScreen()),
          GoRoute(path: '/grades', builder: (_, __) => const GradesScreen()),
          GoRoute(path: '/announcements', builder: (_, __) => const AnnouncementsScreen()),
          GoRoute(path: '/assignments', builder: (_, __) => const AssignmentsScreen()),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ts = ref.watch(themeControllerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: ts.mode,
      theme: buildTheme(ts, Brightness.light),
      darkTheme: buildTheme(ts, Brightness.dark),
    );
  }
}
DART

echo "==> Formatting..."
dart format lib >/dev/null 2>&1 || true

echo "==> Done. Now restart the running app (press R in flutter run) or rerun flutter run."
