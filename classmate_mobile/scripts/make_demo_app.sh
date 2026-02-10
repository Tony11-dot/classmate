#!/usr/bin/env bash
set -euo pipefail

echo "==> Creating demo mode gameplay screens..."

mkdir -p lib/demo lib/features/auth lib/features/home lib/features/classrooms lib/features/assignments lib/features/leaderboard lib/features/notifications lib/features/settings lib/app

# -------------------------
# Demo data / fake backend
# -------------------------
cat > lib/demo/demo_data.dart <<'DART'
class DemoUser {
  final String id;
  final String name;
  final String role; // student|teacher
  int points;
  DemoUser({required this.id, required this.name, required this.role, required this.points});
}

class DemoClassroom {
  final String id;
  final String name;
  final String teacher;
  final String room;
  final String time;
  DemoClassroom({required this.id, required this.name, required this.teacher, required this.room, required this.time});
}

class DemoAssignment {
  final String id;
  final String classroomId;
  final String title;
  final String due;
  final int reward;
  bool submitted;
  DemoAssignment({
    required this.id,
    required this.classroomId,
    required this.title,
    required this.due,
    required this.reward,
    this.submitted = false,
  });
}

class DemoNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  bool seen;
  DemoNotification({required this.id, required this.title, required this.body, required this.time, this.seen=false});
}

class DemoStore {
  static DemoUser user = DemoUser(id: "u1", name: "Tony Aboud", role: "student", points: 120);

  static final classrooms = <DemoClassroom>[
    DemoClassroom(id:"c1", name:"Physics 10", teacher:"Ms. Hila", room:"Lab 2", time:"Sun 10:00"),
    DemoClassroom(id:"c2", name:"Math 5 Units", teacher:"Mr. Amir", room:"B-14", time:"Mon 08:15"),
    DemoClassroom(id:"c3", name:"Computer Science", teacher:"Ms. Noa", room:"C-3", time:"Wed 12:20"),
  ];

  static final assignments = <DemoAssignment>[
    DemoAssignment(id:"a1", classroomId:"c1", title:"Free Fall Worksheet", due:"Today 23:59", reward: 15),
    DemoAssignment(id:"a2", classroomId:"c2", title:"Derivatives Practice Set", due:"Tomorrow 20:00", reward: 20),
    DemoAssignment(id:"a3", classroomId:"c3", title:"Build a Login UI", due:"Fri 16:00", reward: 30),
  ];

  static final notifications = <DemoNotification>[
    DemoNotification(id:"n1", title:"Points awarded!", body:"You earned +10 for attendance.", time:"2m ago"),
    DemoNotification(id:"n2", title:"New assignment", body:"Physics 10: Free Fall Worksheet.", time:"1h ago"),
    DemoNotification(id:"n3", title:"Leaderboard", body:"You moved to #2 this week.", time:"Yesterday"),
  ];

  static void reset() {
    user = DemoUser(id: "u1", name: "Tony Aboud", role: "student", points: 120);
    for (final a in assignments) { a.submitted = false; }
    for (final n in notifications) { n.seen = false; }
  }
}
DART

# -------------------------
# App router + shell
# -------------------------
cat > lib/app/app.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/shell.dart';
import '../features/settings/settings_screen.dart';
import '../features/classrooms/classrooms_screen.dart';
import '../features/classrooms/classroom_detail_screen.dart';
import '../features/assignments/assignments_screen.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/notifications/notifications_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const ClassroomsScreen()),
          GoRoute(path: '/classrooms', builder: (_, __) => const ClassroomsScreen()),
          GoRoute(
            path: '/classrooms/:id',
            builder: (context, state) => ClassroomDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(path: '/assignments', builder: (_, __) => const AssignmentsScreen()),
          GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(useMaterial3: true),
    );
  }
}
DART

cat > lib/features/home/shell.dart <<'DART'
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
          Center(child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(children: [
              const Icon(Icons.stars_rounded, size: 18),
              const SizedBox(width: 6),
              Text('${user.points}', style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
          )),
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
        selectedIndex: _indexForLocation(GoRouterState.of(context).uri.toString()),
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/classrooms'); break;
            case 1: context.go('/assignments'); break;
            case 2: context.go('/leaderboard'); break;
            default: context.go('/classrooms');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Classes'),
          NavigationDestination(icon: Icon(Icons.checklist_rounded), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.leaderboard_outlined), label: 'Rank'),
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
DART

# -------------------------
# Auth
# -------------------------
cat > lib/features/auth/login_screen.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(text: "tony@school.com");
  final pass = TextEditingController(text: "123456");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('Welcome back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Sign in to continue.', style: TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 28),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/classrooms'),
                child: const Text('Sign in'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.push('/register'),
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
DART

cat > lib/features/auth/register_screen.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController(text: "Tony Aboud");
  final email = TextEditingController(text: "tony@school.com");
  final school = TextEditingController(text: "Your School");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')),
            const SizedBox(height: 12),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: school, decoration: const InputDecoration(labelText: 'School')),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/classrooms'),
                child: const Text('Create & Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
DART

# -------------------------
# Classes
# -------------------------
cat > lib/features/classrooms/classrooms_screen.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../demo/demo_data.dart';

class ClassroomsScreen extends StatelessWidget {
  const ClassroomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classes = DemoStore.classrooms;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const SizedBox(height: 6),
        const Text('Your classrooms', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        for (final c in classes)
          Card(
            child: ListTile(
              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${c.teacher} • ${c.room} • ${c.time}'),
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
import '../../demo/demo_data.dart';

class ClassroomDetailScreen extends StatelessWidget {
  final String id;
  const ClassroomDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final c = DemoStore.classrooms.firstWhere((x) => x.id == id);
    final a = DemoStore.assignments.where((x) => x.classroomId == id).toList();

    return Scaffold(
      appBar: AppBar(title: Text(c.name)),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.teacher, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text('Room ${c.room} • ${c.time}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Assignments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final x in a)
            Card(
              child: ListTile(
                title: Text(x.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('Due: ${x.due} • Reward: +${x.reward}'),
                trailing: x.submitted ? const Icon(Icons.check_circle_rounded) : const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/assignments'),
              ),
            ),
        ],
      ),
    );
  }
}
DART

# -------------------------
# Assignments + points
# -------------------------
cat > lib/features/assignments/assignments_screen.dart <<'DART'
import 'package:flutter/material.dart';
import '../../demo/demo_data.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});
  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  @override
  Widget build(BuildContext context) {
    final list = DemoStore.assignments;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('To do', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        for (final a in list)
          Card(
            child: ListTile(
              title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('Due: ${a.due} • Reward: +${a.reward}'),
              trailing: a.submitted
                ? const Icon(Icons.check_circle_rounded)
                : FilledButton(
                    onPressed: () {
                      setState(() {
                        a.submitted = true;
                        DemoStore.user.points += a.reward;
                        DemoStore.notifications.insert(0, DemoNotification(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: "Submitted",
                          body: "You earned +${a.reward} points for ${a.title}.",
                          time: "now",
                        ));
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Submitted! +${a.reward} points')),
                      );
                    },
                    child: const Text('Submit'),
                  ),
            ),
          ),
      ],
    );
  }
}
DART

# -------------------------
# Leaderboard
# -------------------------
cat > lib/features/leaderboard/leaderboard_screen.dart <<'DART'
import 'package:flutter/material.dart';
import '../../demo/demo_data.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = DemoStore.user.points;
    final items = [
      ("Maya", me + 40),
      ("Tony", me),
      ("Yousef", me - 15),
      ("Rana", me - 30),
    ];

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('Weekly leaderboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        for (int i = 0; i < items.length; i++)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('#${i+1}')),
              title: Text(items[i].$1, style: const TextStyle(fontWeight: FontWeight.w800)),
              trailing: Text('${items[i].$2}', style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          )
      ],
    );
  }
}
DART

# -------------------------
# Notifications
# -------------------------
cat > lib/features/notifications/notifications_screen.dart <<'DART'
import 'package:flutter/material.dart';
import '../../demo/demo_data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final list = DemoStore.notifications;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          for (final n in list)
            Card(
              child: ListTile(
                title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${n.body}\n${n.time}'),
                isThreeLine: true,
                trailing: n.seen ? const Icon(Icons.done_all_rounded) : const Icon(Icons.circle, size: 10),
                onTap: () => setState(() => n.seen = true),
              ),
            )
        ],
      ),
    );
  }
}
DART

# -------------------------
# Settings
# -------------------------
cat > lib/features/settings/settings_screen.dart <<'DART'
import 'package:flutter/material.dart';
import '../../demo/demo_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: ListTile(
              title: const Text('Reset demo', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Restores points, submissions, notifications.'),
              trailing: const Icon(Icons.refresh_rounded),
              onTap: () {
                DemoStore.reset();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo reset.')));
              },
            ),
          ),
        ],
      ),
    );
  }
}
DART

# -------------------------
# main.dart -> App
# -------------------------
cat > lib/main.dart <<'DART'
import 'package:flutter/material.dart';
import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}
DART

echo "==> Done. Demo gameplay app created."
echo "==> Run it:"
echo "flutter run -d <device> --dart-define=API_BASE_URL=http://<mac_ip>:3000"
