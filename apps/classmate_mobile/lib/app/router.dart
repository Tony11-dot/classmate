import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../features/schedule/schedule_screen.dart';
import '../features/classrooms/classrooms_screen.dart';
import '../features/solutions/solutions_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/tutor/tutor_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/attendance/attendance_screen.dart';
import '../features/grades/grades_screen.dart';
import '../features/assignments/assignments_screen.dart';
import '../features/announcements/announcements_screen.dart';

import 'shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/app',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      if (!auth.ready) return '/boot';
      // No login. If auth failed, still show UI but with banner.
      return null;
    },
    routes: [
      GoRoute(path: '/boot', builder: (_, __) => const _BootScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/app', builder: (_, __) => const ScheduleScreen()),
          GoRoute(
            path: '/classrooms',
            builder: (_, __) => const ClassroomsScreen(),
          ),
          GoRoute(
            path: '/solutions',
            builder: (_, __) => const SolutionsScreen(),
          ),
          GoRoute(
            path: '/insights',
            builder: (_, __) => const InsightsScreen(),
          ),
          GoRoute(path: '/tutor', builder: (_, __) => const TutorScreen()),

          // Drawer pages
          GoRoute(
            path: '/attendance',
            builder: (_, __) => const AttendanceScreen(),
          ),
          GoRoute(path: '/grades', builder: (_, __) => const GradesScreen()),
          GoRoute(
            path: '/assignments',
            builder: (_, __) => const AssignmentsScreen(),
          ),
          GoRoute(
            path: '/announcements',
            builder: (_, __) => const AnnouncementsScreen(),
          ),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this.ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
  final Ref ref;
}

class _BootScreen extends ConsumerWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(authProvider);
    return Scaffold(
      body: Center(
        child: a.ready
            ? const SizedBox.shrink()
            : const CircularProgressIndicator(),
      ),
    );
  }
}
