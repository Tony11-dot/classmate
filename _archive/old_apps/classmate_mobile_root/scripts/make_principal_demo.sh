#!/usr/bin/env bash
set -euo pipefail

echo "==> Writing principal-grade demo (schedule + AI tutor + insights + themes + profile + import + solutions)..."

mkdir -p lib/app lib/demo lib/state lib/theme lib/features/{auth,home,schedule,ai,insights,profile,importer,solutions,classrooms,settings,notifications}

# -------------------------
# DEMO DATA (Schedule, classes, assignments, insights)
# -------------------------
cat > lib/demo/demo_store.dart <<'DART'
import 'dart:math';

class DemoUser {
  final String id;
  String name;
  String role; // student|teacher|admin
  int points;
  String school;
  String grade;
  DemoUser({
    required this.id,
    required this.name,
    required this.role,
    required this.points,
    required this.school,
    required this.grade,
  });
}

class DemoClassroom {
  final String id;
  final String name;
  final String teacher;
  final String room;
  DemoClassroom({required this.id, required this.name, required this.teacher, required this.room});
}

class DemoScheduleItem {
  final String id;
  final String day;  // Sun..Thu
  final String time; // 08:15
  final String title;
  final String room;
  final String type; // lesson|exam|event
  DemoScheduleItem({required this.id, required this.day, required this.time, required this.title, required this.room, required this.type});
}

class DemoAssignment {
  final String id;
  final String classroomId;
  final String title;
  final String due;
  final int reward;
  bool submitted;
  DemoAssignment({required this.id, required this.classroomId, required this.title, required this.due, required this.reward, this.submitted=false});
}

class DemoInsight {
  final String id;
  final String title;
  final String body;
  final String level; // good|warn|risk
  DemoInsight({required this.id, required this.title, required this.body, required this.level});
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
  static final _rng = Random(7);

  static DemoUser user = DemoUser(
    id: 'u1',
    name: 'Tony Aboud',
    role: 'student',
    points: 180,
    school: 'Demo High School',
    grade: '10',
  );

  static final classrooms = <DemoClassroom>[
    DemoClassroom(id:'c1', name:'Physics 10', teacher:'Ms. Hila', room:'Lab 2'),
    DemoClassroom(id:'c2', name:'Math 5 Units', teacher:'Mr. Amir', room:'B-14'),
    DemoClassroom(id:'c3', name:'Computer Science', teacher:'Ms. Noa', room:'C-3'),
  ];

  static final schedule = <DemoScheduleItem>[
    DemoScheduleItem(id:'s1', day:'Sun', time:'08:15', title:'Math 5 Units', room:'B-14', type:'lesson'),
    DemoScheduleItem(id:'s2', day:'Sun', time:'10:00', title:'Physics 10', room:'Lab 2', type:'lesson'),
    DemoScheduleItem(id:'s3', day:'Mon', time:'12:20', title:'Computer Science', room:'C-3', type:'lesson'),
    DemoScheduleItem(id:'s4', day:'Tue', time:'09:00', title:'Physics Quiz', room:'Lab 2', type:'exam'),
    DemoScheduleItem(id:'s5', day:'Wed', time:'13:30', title:'Project Work', room:'Library', type:'event'),
  ];

  static final assignments = <DemoAssignment>[
    DemoAssignment(id:'a1', classroomId:'c1', title:'Free Fall Worksheet', due:'Today 23:59', reward: 15),
    DemoAssignment(id:'a2', classroomId:'c2', title:'Derivatives Practice Set', due:'Tomorrow 20:00', reward: 20),
    DemoAssignment(id:'a3', classroomId:'c3', title:'Login UI + Validation', due:'Thu 16:00', reward: 25),
    DemoAssignment(id:'a4', classroomId:'c3', title:'Mini-API Integration', due:'Fri 12:00', reward: 35),
  ];

  static final notifications = <DemoNotification>[
    DemoNotification(id:'n1', title:'Attendance streak!', body:'You got +8 points for showing up on time.', time:'5m ago'),
    DemoNotification(id:'n2', title:'New assignment', body:'Physics 10: Free Fall Worksheet.', time:'1h ago'),
    DemoNotification(id:'n3', title:'Leaderboard update', body:'You’re now #2 this week.', time:'Yesterday'),
  ];

  static List<DemoInsight> generateInsights() {
    // looks AI-ish but safe + demo friendly
    final p = user.points;
    final done = assignments.where((a) => a.submitted).length;
    final total = assignments.length;

    return [
      DemoInsight(
        id:'i1',
        title:'Momentum',
        body: done >= 2 ? 'Great pace: you completed $done/$total tasks. Keep the streak today.' : 'You’re at $done/$total tasks. One quick submission today will boost your week.',
        level: done >= 2 ? 'good' : 'warn',
      ),
      DemoInsight(
        id:'i2',
        title:'Risk',
        body: 'Physics Quiz Tuesday 09:00. Recommendation: 12 minutes review on Free Fall + 6 practice questions.',
        level:'warn',
      ),
      DemoInsight(
        id:'i3',
        title:'Personalized plan',
        body: 'Based on your recent activity, focus next: (1) Submit “Derivatives”, (2) Review Physics formulas, (3) Start CS mini-API.',
        level: p > 200 ? 'good' : 'good',
      ),
    ];
  }

  static String fakeTutorReply(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('physics') || m.contains('free fall')) {
      return "Let’s do it Bagrut-style:\n1) Identify knowns (v0, a=g, t).\n2) Pick equation: v=v0+gt or y=y0+v0t+½gt².\nTell me: do we know time or height?";
    }
    if (m.contains('math') || m.contains('derivative')) {
      return "Quick plan:\n• If it’s a polynomial: power rule.\n• If it’s product/quotient: choose rule.\nSend me the exact function and I’ll walk you through step-by-step.";
    }
    if (m.contains('schedule') || m.contains('today')) {
      return "Today: Math 08:15, Physics 10:00.\nIf you do 1 task submission, you likely gain +15–25 points and move up the leaderboard.";
    }
    return "I’m your Classmate AI Tutor.\nTell me what subject + what you’re stuck on, and I’ll guide you with small steps and a quick quiz at the end.";
  }

  static int importFromGoogleClassroomMock() {
    // “import” 3 items + 2 assignments (mock)
    schedule.addAll([
      DemoScheduleItem(id:'sx${_rng.nextInt(999)}', day:'Thu', time:'11:00', title:'Homeroom', room:'A-1', type:'event'),
      DemoScheduleItem(id:'sx${_rng.nextInt(999)}', day:'Thu', time:'12:20', title:'Computer Science', room:'C-3', type:'lesson'),
      DemoScheduleItem(id:'sx${_rng.nextInt(999)}', day:'Thu', time:'14:00', title:'Parent Notes', room:'Online', type:'event'),
    ]);
    assignments.addAll([
      DemoAssignment(id:'ax${_rng.nextInt(999)}', classroomId:'c2', title:'Limits practice (imported)', due:'Sun 20:00', reward: 18),
      DemoAssignment(id:'ax${_rng.nextInt(999)}', classroomId:'c1', title:'Kinematics set (imported)', due:'Mon 20:00', reward: 22),
    ]);
    notifications.insert(0, DemoNotification(id:'ni${_rng.nextInt(999)}', title:'Imported!', body:'Google Classroom sync imported schedule + tasks.', time:'now'));
    return 5;
  }

  static void reset() {
    user = DemoUser(id: 'u1', name: 'Tony Aboud', role: 'student', points: 180, school: 'Demo High School', grade: '10');
    for (final a in assignments) { a.submitted = false; }
    for (final n in notifications) { n.seen = false; }
  }
}
DART

# -------------------------
# THEME SYSTEM (presets + customization)
# -------------------------
cat > lib/theme/theme_controller.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemePreset { soft, sharp, iosClean }

class ThemeState {
  final ThemeMode mode;
  final ThemePreset preset;
  final Color seed;
  final double radius;   // 6..20
  final double density;  // -2..2 (visual density)
  const ThemeState({
    required this.mode,
    required this.preset,
    required this.seed,
    required this.radius,
    required this.density,
  });

  ThemeState copyWith({ThemeMode? mode, ThemePreset? preset, Color? seed, double? radius, double? density}) {
    return ThemeState(
      mode: mode ?? this.mode,
      preset: preset ?? this.preset,
      seed: seed ?? this.seed,
      radius: radius ?? this.radius,
      density: density ?? this.density,
    );
  }
}

class ThemeController extends StateNotifier<ThemeState> {
  ThemeController(): super(const ThemeState(
    mode: ThemeMode.system,
    preset: ThemePreset.iosClean,
    seed: Colors.blue,
    radius: 14,
    density: 0,
  ));

  void setMode(ThemeMode m) => state = state.copyWith(mode: m);
  void setPreset(ThemePreset p) => state = state.copyWith(preset: p);
  void setSeed(Color c) => state = state.copyWith(seed: c);
  void setRadius(double r) => state = state.copyWith(radius: r);
  void setDensity(double d) => state = state.copyWith(density: d);
}

final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeState>((ref) => ThemeController());

ThemeData buildTheme(ThemeState s, Brightness b) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: b,
    colorSchemeSeed: s.seed,
    visualDensity: VisualDensity(horizontal: s.density, vertical: s.density),
  );

  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.radius));

  // Preset tweaks: keep subtle so it feels “Apple-clean”
  TextTheme tt = base.textTheme;
  if (s.preset == ThemePreset.sharp) {
    tt = tt.apply(fontSizeFactor: 0.98);
  } else if (s.preset == ThemePreset.soft) {
    tt = tt.apply(fontSizeFactor: 1.02);
  }

  return base.copyWith(
    textTheme: tt,
    cardTheme: CardThemeData(shape: shape, elevation: 0.5),
    listTileTheme: ListTileThemeData(shape: shape),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(s.radius)),
    ),
    filledButtonTheme: FilledButtonThemeData(style: ButtonStyle(shape: MaterialStatePropertyAll(shape))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: ButtonStyle(shape: MaterialStatePropertyAll(shape))),
  );
}
DART

# -------------------------
# APP + ROUTER (tabs: Home, Schedule, Tutor, Insights, More)
# -------------------------
cat > lib/app/app.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/shell.dart';
import '../features/profile/profile_screen.dart';
import '../features/schedule/schedule_screen.dart';
import '../features/ai/ai_tutor_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/importer/import_screen.dart';
import '../features/solutions/solutions_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/notifications/notifications_screen.dart';

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
          GoRoute(path: '/tutor', builder: (_, __) => const AITutorScreen()),
          GoRoute(path: '/insights', builder: (_, __) => const InsightsScreen()),
          GoRoute(path: '/solutions', builder: (_, __) => const SolutionsScreen()),
          GoRoute(path: '/import', builder: (_, __) => const ImportScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
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

cat > lib/features/home/shell.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../demo/demo_store.dart';

class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final u = DemoStore.user;
    final loc = GoRouterState.of(context).uri.toString();

    int idx = 0;
    if (loc.startsWith('/schedule') || loc == '/') idx = 0;
    else if (loc.startsWith('/tutor')) idx = 1;
    else if (loc.startsWith('/insights')) idx = 2;
    else idx = 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classmate'),
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
        onDestinationSelected: (i) {
          switch(i){
            case 0: context.go('/schedule'); break;
            case 1: context.go('/tutor'); break;
            case 2: context.go('/insights'); break;
            case 3: context.go('/settings'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.smart_toy_outlined), label: 'Tutor'),
          NavigationDestination(icon: Icon(Icons.auto_graph_outlined), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.tune_rounded), label: 'More'),
        ],
      ),
    );
  }
}
DART

# -------------------------
# AUTH (simple, demo)
# -------------------------
cat > lib/features/auth/login_screen.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(text: 'tony@school.com');
  final pass = TextEditingController(text: '123456');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),
            const Text('Welcome to Classmate', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            const Text('Schedule • Points • AI Tutor • Insights', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 26),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () => context.go('/schedule'), child: const Text('Sign in'))),
            const SizedBox(height: 10),
            TextButton(onPressed: () => context.push('/register'), child: const Text('Create account')),
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

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = TextEditingController(text: 'Tony Aboud');
    final school = TextEditingController(text: 'Demo High School');
    final grade = TextEditingController(text: '10');

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')),
            const SizedBox(height: 12),
            TextField(controller: school, decoration: const InputDecoration(labelText: 'School')),
            const SizedBox(height: 12),
            TextField(controller: grade, decoration: const InputDecoration(labelText: 'Grade')),
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () => context.go('/schedule'), child: const Text('Create & Continue'))),
          ],
        ),
      ),
    );
  }
}
DART

# -------------------------
# SCHEDULE
# -------------------------
cat > lib/features/schedule/schedule_screen.dart <<'DART'
import 'package:flutter/material.dart';
import '../../demo/demo_store.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = DemoStore.schedule;
    final grouped = <String, List<DemoScheduleItem>>{};
    for (final i in items) { grouped.putIfAbsent(i.day, () => []).add(i); }
    for (final k in grouped.keys) { grouped[k]!.sort((a,b) => a.time.compareTo(b.time)); }

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('This week', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        for (final day in ['Sun','Mon','Tue','Wed','Thu'])
          if (grouped[day] != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Text(day, style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
            for (final x in grouped[day]!)
              Card(
                child: ListTile(
                  leading: _icon(x.type),
                  title: Text(x.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${x.time} • ${x.room}'),
                ),
              ),
          ],
      ],
    );
  }

  Widget _icon(String t) {
    switch(t){
      case 'exam': return const Icon(Icons.assignment_turned_in_outlined);
      case 'event': return const Icon(Icons.event_outlined);
      default: return const Icon(Icons.school_outlined);
    }
  }
}
DART

# -------------------------
# AI TUTOR (demo AI)
# -------------------------
cat > lib/features/ai/ai_tutor_screen.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../demo/demo_store.dart';

class AITutorScreen extends StatefulWidget {
  const AITutorScreen({super.key});
  @override State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  final ctrl = TextEditingController();
  final msgs = <(bool me, String text)>[
    (false, "Hey Tony — I’m your Classmate AI Tutor.\nTell me what you want to study and I’ll guide you step-by-step."),
  ];

  void send() {
    final t = ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      msgs.add((true, t));
      msgs.add((false, DemoStore.fakeTutorReply(t)));
      ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: msgs.length,
            itemBuilder: (_, i) {
              final m = msgs[i];
              final align = m.$1 ? CrossAxisAlignment.end : CrossAxisAlignment.start;
              final bg = m.$1 ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest;
              return Column(
                crossAxisAlignment: align,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Card(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: bg),
                        child: Text(m.$2),
                      ),
                    ),
                  ).animate().fadeIn(duration: 160.ms).slideY(begin: 0.06, end: 0),
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
              Expanded(
                child: TextField(
                  controller: ctrl,
                  onSubmitted: (_) => send(),
                  decoration: const InputDecoration(hintText: 'Ask the tutor…'),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(onPressed: send, child: const Text('Send')),
            ],
          ),
        ),
      ],
    );
  }
}
DART

# -------------------------
# INSIGHTS (AI-ish dashboard)
# -------------------------
cat > lib/features/insights/insights_screen.dart <<'DART'
import 'package:flutter/material.dart';
import '../../demo/demo_store.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final insights = DemoStore.generateInsights();
    final u = DemoStore.user;
    final done = DemoStore.assignments.where((a)=>a.submitted).length;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('AI Insights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline_rounded),
            title: Text('${u.name} • Grade ${u.grade}', style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text('Points: ${u.points} • Tasks done: $done/${DemoStore.assignments.length}'),
          ),
        ),
        const SizedBox(height: 10),
        for (final i in insights)
          Card(
            child: ListTile(
              leading: Icon(_icon(i.level)),
              title: Text(i.title, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(i.body),
            ),
          ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.checklist_rounded),
            title: const Text('Recommended next step', style: TextStyle(fontWeight: FontWeight.w900)),
            subtitle: const Text('Tap “Solutions” to see guided tasks with rewards.'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).pushNamed('/solutions'),
          ),
        ),
      ],
    );
  }

  IconData _icon(String level) {
    switch(level){
      case 'risk': return Icons.error_outline_rounded;
      case 'warn': return Icons.warning_amber_rounded;
      default: return Icons.verified_outlined;
    }
  }
}
DART

# -------------------------
# SOLUTIONS (guided “gameplay” tasks)
# -------------------------
cat > lib/features/solutions/solutions_screen.dart <<'DART'
import 'package:flutter/material.dart';
import '../../demo/demo_store.dart';

class SolutionsScreen extends StatefulWidget {
  const SolutionsScreen({super.key});
  @override State<SolutionsScreen> createState() => _SolutionsScreenState();
}

class _SolutionsScreenState extends State<SolutionsScreen> {
  final steps = <(String title, String body, int reward, bool done)>[
    ('Quick win: Submit one assignment', 'Pick the easiest task and submit to gain points fast.', 20, false),
    ('Physics prep', '12 minutes formulas + 6 practice questions.', 15, false),
    ('Math sprint', 'Derivative drills: 10 questions, check answers.', 18, false),
    ('Teacher feedback loop', 'Ask tutor for 3 mistakes you make most.', 10, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solutions')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const Text('Guided plan (demo)', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          for (int i=0;i<steps.length;i++)
            Card(
              child: ListTile(
                leading: steps[i].$4 ? const Icon(Icons.check_circle_rounded) : const Icon(Icons.radio_button_unchecked),
                title: Text(steps[i].$1, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${steps[i].$2}\nReward: +${steps[i].$3}'),
                isThreeLine: true,
                trailing: steps[i].$4 ? null : FilledButton(
                  onPressed: (){
                    setState(() {
                      steps[i] = (steps[i].$1, steps[i].$2, steps[i].$3, true);
                      DemoStore.user.points += steps[i].$3;
                      DemoStore.notifications.insert(0, DemoNotification(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: 'Solution completed',
                        body: 'You earned +${steps[i].$3} points: ${steps[i].$1}',
                        time: 'now',
                      ));
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Completed! +${steps[i].$3} points')));
                  },
                  child: const Text('Complete'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
DART

# -------------------------
# IMPORT (Google Classroom “sync” mock)
# -------------------------
cat > lib/features/importer/import_screen.dart <<'DART'
import 'package:flutter/material.dart';
import '../../demo/demo_store.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_download_outlined),
              title: const Text('Sync from Google Classroom (demo)', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text('Adds schedule items + assignments and shows notifications.'),
              trailing: FilledButton(
                onPressed: () {
                  final n = DemoStore.importFromGoogleClassroomMock();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported $n items.')));
                },
                child: const Text('Sync'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
DART

# -------------------------
# PROFILE
# -------------------------
cat > lib/features/profile/profile_screen.dart <<'DART'
import 'package:flutter/material.dart';
import '../../demo/demo_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final name = TextEditingController(text: DemoStore.user.name);
  late final school = TextEditingController(text: DemoStore.user.school);
  late final grade = TextEditingController(text: DemoStore.user.grade);

  @override
  Widget build(BuildContext context) {
    final u = DemoStore.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline_rounded)),
            title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text('${u.school} • Grade ${u.grade}'),
          )),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
                  const SizedBox(height: 10),
                  TextField(controller: school, decoration: const InputDecoration(labelText: 'School')),
                  const SizedBox(height: 10),
                  TextField(controller: grade, decoration: const InputDecoration(labelText: 'Grade')),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: (){
                        setState(() {
                          DemoStore.user.name = name.text.trim();
                          DemoStore.user.school = school.text.trim();
                          DemoStore.user.grade = grade.text.trim();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved.')));
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
DART

# -------------------------
# NOTIFICATIONS
# -------------------------
cat > lib/features/notifications/notifications_screen.dart <<'DART'
import 'package:flutter/material.dart';
import '../../demo/demo_store.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override State<NotificationsScreen> createState() => _NotificationsScreenState();
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
                title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${n.body}\n${n.time}'),
                isThreeLine: true,
                trailing: n.seen ? const Icon(Icons.done_all_rounded) : const Icon(Icons.circle, size: 10),
                onTap: () => setState(() => n.seen = true),
              ),
            ),
        ],
      ),
    );
  }
}
DART

# -------------------------
# SETTINGS (themes, presets, radius/density, demo reset, quick links)
# -------------------------
cat > lib/features/settings/settings_screen.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../demo/demo_store.dart';
import '../../theme/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ts = ref.watch(themeControllerProvider);

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('More', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),

        Card(
          child: ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: const Text('Import', style: TextStyle(fontWeight: FontWeight.w900)),
            subtitle: const Text('Google Classroom sync (demo)'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/import'),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.light_mode_outlined),
            title: const Text('Theme mode', style: TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text(ts.mode.name),
            onTap: () => _modeSheet(context, ref),
          ),
        ),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Presets', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: [
                    ChoiceChip(
                      label: const Text('iOS Clean'),
                      selected: ts.preset == ThemePreset.iosClean,
                      onSelected: (_) => ref.read(themeControllerProvider.notifier).setPreset(ThemePreset.iosClean),
                    ),
                    ChoiceChip(
                      label: const Text('Soft'),
                      selected: ts.preset == ThemePreset.soft,
                      onSelected: (_) => ref.read(themeControllerProvider.notifier).setPreset(ThemePreset.soft),
                    ),
                    ChoiceChip(
                      label: const Text('Sharp'),
                      selected: ts.preset == ThemePreset.sharp,
                      onSelected: (_) => ref.read(themeControllerProvider.notifier).setPreset(ThemePreset.sharp),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Radius', style: TextStyle(fontWeight: FontWeight.w900)),
                Slider(
                  min: 6, max: 22, divisions: 16,
                  value: ts.radius,
                  onChanged: (v) => ref.read(themeControllerProvider.notifier).setRadius(v),
                ),
                const Text('Density', style: TextStyle(fontWeight: FontWeight.w900)),
                Slider(
                  min: -2, max: 2, divisions: 8,
                  value: ts.density,
                  onChanged: (v) => ref.read(themeControllerProvider.notifier).setDensity(v),
                ),
                const SizedBox(height: 10),
                const Text('Accent', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: [
                    for (final c in const [Colors.blue, Colors.teal, Colors.indigo, Colors.purple, Colors.pink, Colors.orange, Colors.green])
                      InkWell(
                        onTap: () => ref.read(themeControllerProvider.notifier).setSeed(c),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(width: 26, height: 26, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.auto_fix_high_outlined),
            title: const Text('Solutions', style: TextStyle(fontWeight: FontWeight.w900)),
            subtitle: const Text('Guided plan + rewards'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/solutions'),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.refresh_rounded),
            title: const Text('Reset demo', style: TextStyle(fontWeight: FontWeight.w900)),
            subtitle: const Text('Restores points, submissions, notifications'),
            onTap: () {
              DemoStore.reset();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo reset.')));
            },
          ),
        ),
      ],
    );
  }

  void _modeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('System'), onTap: () { ref.read(themeControllerProvider.notifier).setMode(ThemeMode.system); Navigator.pop(context); }),
            ListTile(title: const Text('Light'), onTap: () { ref.read(themeControllerProvider.notifier).setMode(ThemeMode.light); Navigator.pop(context); }),
            ListTile(title: const Text('Dark'), onTap: () { ref.read(themeControllerProvider.notifier).setMode(ThemeMode.dark); Navigator.pop(context); }),
          ],
        ),
      ),
    );
  }
}
DART

# -------------------------
# MAIN
# -------------------------
cat > lib/main.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: App()));
}
DART

echo "==> Done."
echo "==> Next: flutter clean && flutter pub get && flutter run ..."
DART

# fix accidental here-doc label typo safety (noop)
