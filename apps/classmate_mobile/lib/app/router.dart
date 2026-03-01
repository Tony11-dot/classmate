import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/schedule/schedule_screen.dart';
import '../features/classrooms/classrooms_screen.dart';
import '../features/solutions/solutions_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/tutor/tutor_screen.dart';
import '../features/lifedoc/attendance_screen.dart';
import '../features/lifedoc/grades_screen.dart';
import '../features/lifedoc/assignments_screen.dart';
import '../features/lifedoc/announcements_screen.dart';
import '../features/lifedoc/notifications_screen.dart';

import '../features/account/profile_screen.dart';
import '../features/account/settings_screen.dart';

import '../features/account/login_screen.dart';
import 'shell/app_shell.dart';
import '../core/auth/auth_controller.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    refreshListenable: ref.watch(authSessionProvider),
    redirect: (context, state) {
      final session = ref.read(authSessionProvider);

      // Wait for SharedPreferences token load before redirecting
      if (!session.ready) return null;

      final isLogin = state.matchedLocation == '/login';
      final loggedIn = session.isLoggedIn;

      if (!loggedIn && !isLogin) return '/login';
      if (loggedIn && isLogin) return '/schedule';
      return null;
    },
    initialLocation: '/schedule',
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),

      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/schedule', builder: (_, _) => const ScheduleScreen()),
          GoRoute(
            path: '/classrooms',
            builder: (_, _) => const ClassroomsScreen(),
          ),
          GoRoute(
            path: '/solutions',
            builder: (_, _) => const SolutionsScreen(),
          ),
          GoRoute(path: '/insights', builder: (_, _) => const InsightsScreen()),
          GoRoute(path: '/tutor', builder: (_, _) => const TutorScreen()),
          GoRoute(
            path: '/attendance',
            builder: (_, _) => const AttendanceScreen(),
          ),
          GoRoute(path: '/grades', builder: (_, _) => const GradesScreen()),
          GoRoute(
            path: '/assignments',
            builder: (_, _) => const AssignmentsScreen(),
          ),
          GoRoute(
            path: '/announcements',
            builder: (_, _) => const AnnouncementsScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (_, _) => const NotificationsScreen(),
          ),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
