import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../features/account/login_screen.dart';
import '../features/account/profile_screen.dart';
import '../features/account/settings_screen.dart';
import '../features/classrooms/ui/classroom_detail_screen.dart';
import '../features/classrooms/ui/classrooms_home_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/lifedoc/announcements_screen.dart';
import '../features/lifedoc/alerts_screen.dart';
import '../features/lifedoc/assignments_screen.dart';
import '../features/lifedoc/attendance_screen.dart';
import '../features/lifedoc/grades_screen.dart';
import '../features/lifedoc/notifications_screen.dart';
import '../features/practice/ui/practice_session_screen.dart';
import '../features/practice/ui/practice_setup_screen.dart';
import '../features/practice/ui/saved_questions_screen.dart';
import '../features/schedule/schedule_screen.dart' as schedule_ui;
import '../features/solutions/solutions_screen.dart';
import '../features/solutions/ui/filter/solutions_books_screen.dart';
import '../features/solutions/ui/filter/solutions_pages_screen.dart';
import '../features/solutions/ui/filter/solutions_questions_screen.dart';
import '../features/solutions/ui/filter/solutions_subject_screen.dart';
import '../features/tutor/tutor_screen.dart';
import 'shell/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    refreshListenable: ref.watch(authSessionProvider),
    redirect: (context, state) {
      final session = ref.read(authSessionProvider);

      if (!session.ready) return null;

      final loc = state.matchedLocation;
      if (loc.startsWith('/student/')) {
        if (loc == '/student/schedule') return '/schedule';
        if (loc == '/student/classrooms') return '/classrooms';
        if (loc == '/student/tutor') return '/tutor';
        if (loc == '/student/insights') return '/insights';
        if (loc == '/student/solutions') return '/solutions';
        return loc.replaceFirst('/student', '');
      }

      final isLogin = state.matchedLocation == '/login';
      final loggedIn = session.isLoggedIn;

      if (!loggedIn && !isLogin) return '/login';
      if (loggedIn && isLogin) return '/schedule';
      return null;
    },
    initialLocation: '/schedule',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // fullscreen focus route
      GoRoute(
        path: '/practice/session',
        builder: (context, state) => const PracticeSessionScreen(),
      ),

      // solutions filter flow
      GoRoute(
        path: '/solutions/subjects',
        builder: (context, state) => const SolutionsSubjectScreen(),
      ),
      GoRoute(
        path: '/solutions/books',
        builder: (context, state) => const SolutionsBooksScreen(),
      ),
      GoRoute(
        path: '/solutions/pages',
        builder: (context, state) => const SolutionsPagesScreen(),
      ),
      GoRoute(
        path: '/solutions/questions',
        builder: (context, state) => const SolutionsQuestionsScreen(),
      ),

      // shell routes with top + bottom bars
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const schedule_ui.ScheduleScreen(),
          ),
          GoRoute(
            path: '/practice',
            builder: (context, state) => const PracticeSetupScreen(),
          ),
          GoRoute(
            path: '/classrooms',
            builder: (context, state) => const ClassroomsHomeScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (ctx, st) =>
                    ClassroomDetailScreen(courseId: st.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/solutions',
            builder: (context, state) => const SolutionsScreen(),
          ),
          GoRoute(
            path: '/insights',
            builder: (context, state) => const InsightsScreen(),
          ),
          GoRoute(
            path: '/tutor',
            builder: (context, state) => TutorScreen(
              initialPrompt: state.uri.queryParameters['prompt'],
              initialSubject: state.uri.queryParameters['subject'],
              initialTitle: state.uri.queryParameters['title'],
            ),
          ),
          GoRoute(
            path: '/attendance',
            builder: (context, state) => const AttendanceScreen(),
          ),
          GoRoute(
            path: '/grades',
            builder: (context, state) => const GradesScreen(),
          ),
          GoRoute(
            path: '/assignments',
            builder: (context, state) => const AssignmentsScreen(),
          ),
          GoRoute(
            path: '/announcements',
            builder: (context, state) => const AnnouncementsScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/alerts',
            builder: (context, state) => const AlertsScreen(),
          ),
          GoRoute(
            path: '/saved-questions',
            builder: (context, state) => const SavedQuestionsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
