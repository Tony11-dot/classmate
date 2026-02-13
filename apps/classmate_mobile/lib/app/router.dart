import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'shell.dart';

import '../features/schedule/schedule_screen.dart';
import '../features/classrooms/classrooms_screen.dart';
import '../features/classrooms/classroom_detail_screen.dart';
import '../features/solutions/solutions_screen.dart';
import '../features/tutor/tutor_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/assignments/assignments_screen.dart';
import '../features/attendance/attendance_screen.dart';
import '../features/grades/grades_screen.dart';
import '../features/announcements/announcements_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/alerts/alerts_screen.dart';
import '../features/notifications/notifications_screen.dart';

import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../auth/auth_controller.dart';


class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this.ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
  final Ref ref;
}

final _routerRefreshProvider = Provider<_RouterRefresh>((ref) {
  final r = _RouterRefresh(ref);
  ref.onDispose(r.dispose);
  return r;
});

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  Page<void> nt(Widget child) => NoTransitionPage(child: child);

  final refresh = ref.watch(_routerRefreshProvider);

  return GoRouter(
    refreshListenable: refresh,
    initialLocation: '/app',

    redirect: (context, state) {
      final a = ref.read(authProvider);
      final loc = state.matchedLocation;

      // While loading session, park on splash
      if (!a.ready) return (loc == '/splash') ? null : '/splash';

      final isAuthRoute = (loc == '/login' || loc == '/register' || loc == '/splash');

      if (!a.loggedIn) {
        // logged out -> force login
        return (loc == '/login' || loc == '/register') ? null : '/login';
      }

      // logged in -> keep user out of auth screens
      if (isAuthRoute) return '/app';

      return null;
    },

    routes: [
      GoRoute(path: '/splash', pageBuilder: (c, s) => nt(const SplashScreen())),
      GoRoute(path: '/login', pageBuilder: (c, s) => nt(const LoginScreen())),
      GoRoute(
        path: '/register',
        pageBuilder: (c, s) => nt(const RegisterScreen()),
      ),

      ShellRoute(
        pageBuilder: (context, state, child) => nt(AppShell(child: child)),
        routes: [
          GoRoute(
            path: '/app',
            pageBuilder: (c, s) => nt(const ScheduleScreen()),
          ),
          GoRoute(
            path: '/classrooms',
            pageBuilder: (c, s) => nt(const ClassroomsScreen()),
          ),
          GoRoute(
            path: '/classrooms/:id',
            pageBuilder: (c, s) {
              final id = s.pathParameters['id'] ?? 'demo-1';
              return nt(ClassroomDetailScreen(classroomId: id));
            },
          ),
          GoRoute(
            path: '/solutions',
            pageBuilder: (c, s) => nt(const SolutionsScreen()),
          ),
          GoRoute(
            path: '/insights',
            pageBuilder: (c, s) => nt(const InsightsScreen()),
          ),
          GoRoute(
            path: '/tutor',
            pageBuilder: (c, s) => nt(const TutorScreen()),
          ),
          GoRoute(
            path: '/attendance',
            pageBuilder: (c, s) => nt(const AttendanceScreen()),
          ),
          GoRoute(
            path: '/grades',
            pageBuilder: (c, s) => nt(const GradesScreen()),
          ),
          GoRoute(
            path: '/assignments',
            pageBuilder: (c, s) => nt(const AssignmentsScreen()),
          ),
          GoRoute(
            path: '/announcements',
            pageBuilder: (c, s) => nt(const AnnouncementsScreen()),
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (c, s) => nt(const NotificationsScreen()),
          ),
          GoRoute(
            path: '/alerts',
            pageBuilder: (c, s) => nt(const AlertsScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (c, s) => nt(const ProfileScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (c, s) => nt(const SettingsScreen()),
          ),
        ],
      ),
    ],
    errorPageBuilder: (c, s) => MaterialPage(
      child: Scaffold(body: Center(child: Text('Route error: ${s.error}'))),
    ),
  );
});
