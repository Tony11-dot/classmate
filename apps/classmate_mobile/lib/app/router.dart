import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/schedule/schedule_screen.dart';
import '../features/classrooms/classrooms_screen.dart';
import '../features/tutor/tutor_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/solutions/solutions_screen.dart';

import '../features/lifedoc/attendance_screen.dart';
import '../features/lifedoc/grades_screen.dart';
import '../features/lifedoc/assignments_screen.dart';
import '../features/lifedoc/announcements_screen.dart';
import '../features/lifedoc/notifications_screen.dart';

import '../features/account/profile_screen.dart';
import '../features/account/settings_screen.dart';
import '../features/account/customization_screen.dart';

import 'shell/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/schedule',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/schedule',
            builder: (_, __) => const ScheduleScreen(),
          ),
          GoRoute(
            path: '/classrooms',
            builder: (_, __) => const ClassroomsScreen(),
          ),
          GoRoute(path: '/tutor', builder: (_, __) => const TutorScreen()),
          GoRoute(
            path: '/insights',
            builder: (_, __) => const InsightsScreen(),
          ),
          GoRoute(
            path: '/solutions',
            builder: (_, __) => const SolutionsScreen(),
          ),

          // LifeDoc
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
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),

          // Account
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/customization',
            builder: (_, __) => const CustomizationScreen(),
          ),
        ],
      ),
    ],
  );
});
