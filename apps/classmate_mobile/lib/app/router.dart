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
import '../features/lifedoc/assignments_screen.dart';
import '../features/lifedoc/attendance_screen.dart';
import '../features/lifedoc/exam_detail_screen.dart';
import '../features/lifedoc/domain/exam_models.dart' show StudentExamItem;
import '../features/lifedoc/domain/form_models.dart' show StudentFormItem;
import '../features/lifedoc/exams_screen.dart';
import '../features/lifedoc/form_detail_screen.dart';
import '../features/lifedoc/grades_screen.dart';
import '../features/lifedoc/meetings_screen.dart';
import '../features/lifedoc/notifications_models.dart';
import '../features/lifedoc/notifications_screen.dart';
import '../features/messages/ui/message_request_screen.dart';
import '../features/messages/ui/message_thread_screen.dart';
import '../features/messages/ui/messages_inbox_screen.dart';
import '../features/practice/ui/practice_session_screen.dart';
import '../features/practice/ui/practice_setup_screen.dart';
import '../features/practice/ui/saved_questions_screen.dart';
import '../features/schedule/schedule_screen.dart' as schedule_ui;
import '../features/teacher_mobile/ui/teacher_attendance_screen.dart';
import '../features/teacher_mobile/ui/teacher_classroom_analytics_screen.dart';
import '../features/teacher_mobile/ui/teacher_classroom_detail_screen.dart';
import '../features/teacher_mobile/ui/teacher_classrooms_screen.dart';
import '../features/teacher_mobile/ui/teacher_grades_screen.dart';
import '../features/teacher_mobile/ui/teacher_home_screen.dart';
import '../features/teacher_mobile/ui/teacher_new_announcement_screen.dart';
import '../features/teacher_mobile/ui/teacher_student_profile_screen.dart';
import '../features/teacher_mobile/ui/teacher_week_schedule_screen.dart';
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
      final isTeacherRoute = loc.startsWith('/teacher/');
      final isCommonTeacherSafe =
          loc.startsWith('/messages') ||
          loc.startsWith('/tutor') ||
          loc == '/exams' ||
          loc.startsWith('/exams/') ||
          loc == '/forms' ||
          loc.startsWith('/forms/') ||
          loc == '/profile' ||
          loc == '/settings' ||
          loc == '/announcements' ||
          loc.startsWith('/announcements/') ||
          loc == '/notifications' ||
          loc.startsWith('/notifications/');

      if (!loggedIn && !isLogin) return '/login';
      if (loggedIn && isLogin) {
        return session.isTeacherLike ? '/teacher/home' : '/schedule';
      }
      if (loggedIn && session.isTeacherLike && !isTeacherRoute && !isCommonTeacherSafe) {
        return '/teacher/home';
      }
      if (loggedIn && !session.isTeacherLike && isTeacherRoute) return '/schedule';
      return null;
    },
    initialLocation: '/schedule',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/practice/session',
        builder: (context, state) => const PracticeSessionScreen(),
      ),

      GoRoute(
        path: '/announcements/:id',
        builder: (context, state) => AnnouncementDetailScreen(
          announcementId: state.pathParameters['id']!,
        ),
      ),

      GoRoute(
        path: '/notifications/:id',
        builder: (context, state) => NotificationDetailScreen(
          notificationId: Uri.decodeComponent(state.pathParameters['id']!),
          initialNotification: state.extra is StudentNotificationItem
              ? state.extra as StudentNotificationItem
              : null,
        ),
      ),

      GoRoute(
        path: '/meetings/:id',
        builder: (context, state) => MeetingDetailScreen(
          meetingId: state.pathParameters['id']!,
          initialMeeting: state.extra is Map
              ? Map<String, dynamic>.from(state.extra as Map)
              : null,
        ),
      ),

      GoRoute(
        path: '/assignments/:id',
        builder: (context, state) => AssignmentDetailScreen(
          assignmentId: state.pathParameters['id']!,
          initialAssignment: state.extra is Map
              ? Map<String, dynamic>.from(state.extra as Map)
              : null,
        ),
      ),

      GoRoute(
        path: '/exams/:id',
        builder: (context, state) => ExamDetailScreen(
          examId: state.pathParameters['id']!,
          initialExam: state.extra is StudentExamItem
              ? state.extra as StudentExamItem
              : null,
        ),
      ),

      GoRoute(
        path: '/forms',
        builder: (context, state) => const AppShell(
          child: ExamsScreen(mode: ExamsScreenMode.formsOnly),
        ),
      ),

      GoRoute(
        path: '/forms/:id',
        builder: (context, state) => FormDetailScreen(
          formId: state.pathParameters['id']!,
          initialForm: state.extra is StudentFormItem
              ? state.extra as StudentFormItem
              : null,
        ),
      ),

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

      GoRoute(
        path: '/messages',
        name: 'messages_inbox',
        builder: (context, state) =>
            const AppShell(child: MessagesInboxScreen()),
      ),
      GoRoute(
        path: '/messages/request/:id',
        name: 'message_request',
        builder: (context, state) => MessageRequestScreen(
          threadId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/messages/:id',
        name: 'dm_thread',
        builder: (context, state) => MessageThreadScreen(
          threadId: state.pathParameters['id']!,
        ),
      ),

      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const schedule_ui.ScheduleScreen(),
          ),
          GoRoute(
            path: '/teacher/home',
            builder: (context, state) => const TeacherHomeScreen(),
          ),
          GoRoute(
            path: '/teacher/attendance',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return TeacherAttendanceScreen(
                initialCohortId: extra['cohortId']?.toString(),
                initialPeriod: extra['period'] is int ? extra['period'] as int : null,
                initialDate: extra['date']?.toString(),
              );
            },
          ),
          GoRoute(
            path: '/teacher/classrooms',
            builder: (context, state) => const TeacherClassroomsScreen(),
          ),
          GoRoute(
            path: '/teacher/grades',
            builder: (context, state) => const TeacherGradesScreen(),
          ),
          GoRoute(
            path: '/teacher/classroom/:courseId',
            builder: (context, state) {
              final courseId = state.pathParameters['courseId'] ?? '';
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return TeacherClassroomDetailScreen(
                courseId: courseId,
                courseName: (extra['name'] ?? '').toString(),
                subject: (extra['subject'] ?? '').toString(),
                cohortName: extra['cohortName']?.toString(),
                grade: extra['grade'] is int ? extra['grade'] as int : null,
              );
            },
          ),
          GoRoute(
            path: '/teacher/announcements/new',
            builder: (context, state) => const TeacherNewAnnouncementScreen(),
          ),
          GoRoute(
            path: '/teacher/schedule/week',
            builder: (context, state) => const TeacherWeekScheduleScreen(),
          ),
          GoRoute(
            path: '/teacher/classroom/:courseId/analytics',
            builder: (context, state) {
              final courseId = state.pathParameters['courseId'] ?? '';
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return TeacherClassroomAnalyticsScreen(
                courseId: courseId,
                courseName: (extra['name'] ?? '').toString(),
                subject: (extra['subject'] ?? '').toString(),
              );
            },
          ),
          GoRoute(
            path: '/teacher/student/:studentId',
            builder: (context, state) {
              final studentId = state.pathParameters['studentId'] ?? '';
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return TeacherStudentProfileScreen(
                studentId: studentId,
                studentName: (extra['name'] ?? 'Student').toString(),
              );
            },
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
            path: '/meetings',
            builder: (context, state) => const MeetingsScreen(),
          ),
          GoRoute(
            path: '/exams',
            builder: (context, state) => const ExamsScreen(mode: ExamsScreenMode.examsOnly),
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
