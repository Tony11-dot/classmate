import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/app_shell.dart';
import '../features/schedule/schedule_screen.dart';
import '../features/lesson/lesson_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: GoRouter(
        initialLocation: '/schedule',
        routes: [
          ShellRoute(
            builder: (_, __, child) => AppShell(child: child),
            routes: [
              GoRoute(
                path: '/schedule',
                builder: (_, __) => const ScheduleScreen(),
              ),
              GoRoute(
                path: '/lesson',
                builder: (_, __) => const LessonScreen(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
