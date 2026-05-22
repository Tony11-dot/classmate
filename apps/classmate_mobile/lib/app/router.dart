import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../features/account/login_screen.dart';
import '../features/account/forgot_password_screen.dart';
import '../features/account/profile_screen.dart';
import '../features/account/settings_screen.dart';
import '../features/classrooms/ui/classroom_detail_screen.dart';
import '../features/classrooms/ui/classrooms_home_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/lifedoc/announcements_screen.dart';
import '../features/lifedoc/diplomas_screen.dart';
import '../features/lifedoc/assignments_screen.dart';
import '../features/lifedoc/attendance_screen.dart';
import '../features/lifedoc/exam_detail_screen.dart';
import '../features/lifedoc/domain/exam_models.dart' show StudentExamItem;
import '../features/lifedoc/domain/form_models.dart' show StudentFormItem;
import '../features/lifedoc/exams_screen.dart';
import '../features/lifedoc/form_detail_screen.dart';
import '../features/lifedoc/grades_screen.dart';
import '../features/lifedoc/meetings_screen.dart';
import '../features/lifedoc/student_materials_screen.dart';
import '../screens/animation_demo_screen.dart';
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
import '../features/teacher_mobile/ui/teacher_attendance_history_screen.dart';
import '../features/teacher_mobile/ui/teacher_classroom_analytics_screen.dart';
import '../features/teacher_mobile/ui/teacher_classroom_detail_screen.dart';
import '../features/teacher_mobile/ui/teacher_classrooms_screen.dart';
import '../features/teacher_mobile/ui/teacher_exams_screen.dart';
import '../features/teacher_mobile/ui/teacher_forms_screen.dart';
import '../features/teacher_mobile/ui/teacher_grades_screen.dart';
import '../features/teacher_mobile/ui/teacher_home_screen.dart';
import '../features/teacher_mobile/ui/teacher_insights_screen.dart';
import '../features/teacher_mobile/ui/teacher_new_announcement_screen.dart';
import '../features/teacher_mobile/ui/teacher_schedule_screen.dart';
import '../features/teacher_mobile/ui/teacher_slot_attachments_screen.dart';
import '../features/teacher_mobile/ui/admin_periods_screen.dart';
import '../features/teacher_mobile/ui/teacher_student_profile_screen.dart';
import '../features/teacher_mobile/ui/teacher_students_screen.dart';
import '../features/teacher_mobile/ui/teacher_add_assignment_screen.dart';
import '../features/teacher_mobile/ui/teacher_assignment_detail_screen.dart';
import '../features/teacher_mobile/ui/teacher_add_grade_screen.dart';
import '../features/teacher_mobile/ui/teacher_assignments_screen.dart';
import '../features/teacher_mobile/ui/teacher_classroom_add_assignment_screen.dart';
import '../features/teacher_mobile/ui/teacher_add_material_screen.dart';
import '../features/teacher_mobile/ui/teacher_classroom_add_material_screen.dart';
import '../features/teacher_mobile/ui/teacher_classroom_add_meeting_screen.dart';
import '../features/teacher_mobile/ui/teacher_meetings_screen.dart';
import '../features/teacher_mobile/ui/teacher_create_diploma_screen.dart';
import '../features/teacher_mobile/ui/teacher_create_exam_screen.dart';
import '../features/teacher_mobile/ui/teacher_exam_grades_screen.dart';
import '../features/teacher_mobile/ui/teacher_create_form_screen.dart';
import '../features/teacher_mobile/ui/teacher_form_responses_screen.dart';
import '../features/solutions/solutions_screen.dart';
import '../features/solutions/ui/filter/solutions_books_screen.dart';
import '../features/solutions/ui/filter/solutions_pages_screen.dart';
import '../features/solutions/ui/filter/solutions_questions_screen.dart';
import '../features/solutions/ui/filter/solutions_subject_screen.dart';
import '../features/admin/ui/admin_bell_schedule_screen.dart';
import '../features/admin/ui/admin_dashboard_screen.dart';
import '../features/admin/ui/admin_people_screen.dart';
import '../features/admin/ui/admin_cohorts_screen.dart';
import '../features/admin/ui/admin_schedule_screen.dart';
import '../features/admin/ui/admin_school_settings_screen.dart';
import '../features/admin/ui/admin_settings_screen.dart';
import '../features/admin/ui/admin_export_screen.dart';
import '../features/admin/ui/admin_password_requests_screen.dart';
import '../features/secretary/ui/secretary_students_screen.dart';
import '../features/support/ui/support_screen.dart';
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

      // /login + /forgot-password are both reachable when LOGGED OUT
      // (we don't bounce them to /login). But /login is the only route
      // that we bounce LOGGED-IN users away from — they're allowed on
      // /forgot-password so the in-app "Forgot password?" link from
      // Profile → Change Password actually works.
      final isAuthRoute = state.matchedLocation == '/login'
          || state.matchedLocation == '/forgot-password';
      final isLoginOnly = state.matchedLocation == '/login';
      final loggedIn = session.isLoggedIn;
      final primaryRole = session.primaryRole;
      final isAdminLike = primaryRole == 'ADMIN' || primaryRole == 'SECRETARY';
      final isTeacherRoute = loc.startsWith('/teacher/');
      // Admin-ONLY routes that Secretary must not access
      final isAdminOnlyRoute = loc.startsWith('/admin/');
      final isAdminRoute = loc.startsWith('/admin/')
          || loc.startsWith('/secretary/')
          || loc.startsWith('/messages')
          || loc.startsWith('/announcements')
          || loc == '/tutor'
          || loc.startsWith('/tutor/')
          || loc == '/notifications'
          || loc.startsWith('/notifications/')
          || loc == '/settings'
          || loc == '/profile';
      final isCommonSafe =
          loc.startsWith('/messages') ||
          loc.startsWith('/tutor') ||
          loc == '/exams' ||
          loc.startsWith('/exams/') ||
          loc == '/forms' ||
          loc.startsWith('/forms/') ||
          loc == '/teacher/exams' ||
          loc == '/teacher/forms' ||
          loc == '/teacher/forms/create' ||
          loc.startsWith('/teacher/forms/') ||
          loc == '/teacher/exams/create' ||
          loc.startsWith('/teacher/exams/') ||
          loc == '/teacher/grades/add' ||
          loc == '/teacher/assignments/add' ||
          loc.startsWith('/teacher/assignments/') ||
          loc == '/teacher/materials/add' ||
          loc == '/teacher/meetings/add' ||
          loc == '/teacher/announcements/new' ||
          loc.startsWith('/teacher/classroom/') ||
          loc == '/teacher/students' ||
          loc == '/diplomas' ||
          loc.startsWith('/diplomas/') ||
          loc == '/materials' ||
          loc == '/dev/animation-demo' ||
          loc == '/solutions' ||
          loc.startsWith('/solutions/') ||
          loc == '/profile' ||
          loc == '/settings' ||
          loc == '/announcements' ||
          loc.startsWith('/announcements/') ||
          loc == '/notifications' ||
          loc.startsWith('/notifications/') ||
          // Drawer-reachable info pages — must be open to every role
          // (student / teacher / admin / secretary) without role-based
          // redirect kicking the user back to their home.
          loc == '/about' ||
          loc == '/support';

      final isSecretary = primaryRole == 'SECRETARY';

      if (!loggedIn && !isAuthRoute) return '/login';
      if (loggedIn && isLoginOnly) {
        if (isSecretary) return '/announcements';
        if (isAdminLike) return '/admin/dashboard';
        return session.isTeacherLike ? '/teacher/schedule' : '/schedule';
      }
      // Secretary must not access admin-only routes (e.g. /admin/dashboard,
      // /admin/schedule). Carve-out: /admin/export is shared between
      // admin + secretary (per the export-role spec), so secretary keeps
      // access here even though the path lives under /admin/.
      final secretarySafeAdminRoute = loc == '/admin/export' || loc.startsWith('/admin/export/');
      if (loggedIn && isSecretary && isAdminOnlyRoute && !secretarySafeAdminRoute) {
        return '/announcements';
      }
      // Admin/Secretary: redirect away from non-admin/secretary routes
      if (loggedIn && isAdminLike && !isAdminRoute && !isCommonSafe) {
        return isSecretary ? '/announcements' : '/admin/dashboard';
      }
      // Teacher: redirect away from student routes
      if (loggedIn && session.isTeacherLike && !isAdminLike && !isTeacherRoute && !isCommonSafe) {
        return '/teacher/schedule';
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
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
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

      // ── Classroom detail — full screen, no shell wrapper ─────────────────
      GoRoute(
        path: '/classrooms/:id',
        builder: (ctx, st) =>
            ClassroomDetailScreen(courseId: st.pathParameters['id']!),
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
      // ─────────────────────────────────────────────────────────────────────

      // ── Full-page create/add screens (outside shell — no top bar) ──────────
      GoRoute(
        path: '/teacher/announcements/new',
        builder: (context, state) => const TeacherNewAnnouncementScreen(),
      ),
      GoRoute(
        path: '/teacher/forms/create',
        builder: (context, state) => const TeacherCreateFormScreen(),
      ),
      GoRoute(
        path: '/teacher/forms/:id/responses',
        builder: (context, state) {
          final formId = state.pathParameters['id'] ?? '';
          final title = state.extra as String? ?? 'Responses';
          return TeacherFormResponsesScreen(formId: formId, formTitle: title);
        },
      ),
      GoRoute(
        path: '/teacher/exams/create',
        builder: (context, state) {
          final exam = state.extra as Map<String, dynamic>?;
          return TeacherCreateExamScreen(initialExam: exam);
        },
      ),
      GoRoute(
        path: '/teacher/exams/edit',
        builder: (context, state) {
          // Legacy route used by grades screen — extra is a TeacherAssessment
          final a = state.extra;
          Map<String, dynamic>? examMap;
          if (a is Map<String, dynamic>) {
            examMap = a;
          } else if (a != null) {
            // TeacherAssessment object — convert to map for TeacherCreateExamScreen
            try {
              final ta = a as dynamic;
              examMap = <String, dynamic>{
                'id': ta.id as String?,
                'title': ta.title as String?,
                'courseId': ta.courseId as String?,
                'date': ta.date as String?,
                'maxGrade': ta.maxGrade,
                'published': ta.published as bool?,
              };
            } catch (_) {}
          }
          return TeacherCreateExamScreen(initialExam: examMap);
        },
      ),
      GoRoute(
        path: '/teacher/exams/:id/grades',
        builder: (context, state) {
          final exam = state.extra as Map<String, dynamic>? ?? {};
          return TeacherExamGradesScreen(exam: exam);
        },
      ),
      GoRoute(
        path: '/diplomas/create',
        builder: (context, state) => const TeacherCreateDiplomaScreen(),
      ),
      GoRoute(
        path: '/teacher/grades/add',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final rawIds = extra?['studentIds'] as List?;
          final prefillIds = rawIds?.cast<String>().toSet() ?? <String>{};
          final prefillSubject = extra?['subject'] as String?;
          return TeacherAddGradeScreen(
            prefillStudentIds: prefillIds,
            prefillSubject: prefillSubject,
          );
        },
      ),
      GoRoute(
        path: '/teacher/slot/:slotId/attachments',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? const {};
          List<String>? asStrList(dynamic v) {
            if (v is List) return v.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
            return null;
          }
          return TeacherSlotAttachmentsScreen(
            slotId: state.pathParameters['slotId']!,
            title: (extra['title'] ?? 'Period').toString(),
            subject: extra['subject'] as String?,
            cohortIds: asStrList(extra['cohortIds']),
            studentIds: asStrList(extra['studentIds']),
            date: extra['date'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/teacher/materials/add',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          // Convert any list-shaped prefill from `extra` into List<String>.
          List<String>? asStrList(dynamic v) {
            if (v is List) return v.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
            return null;
          }
          return TeacherAddMaterialScreen(
            prefillCourseId: extra?['courseId'] as String?,
            prefillSubject: extra?['subject'] as String?,
            prefillCohortIds: asStrList(extra?['cohortIds']),
            prefillStudentIds: asStrList(extra?['studentIds']),
            initialMaterial: extra?['_edit'] == true ? extra : null,
          );
        },
      ),
      GoRoute(
        path: '/teacher/meetings/add',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isEdit = extra != null && extra.containsKey('id') && extra.containsKey('link');
          return TeacherAddMeetingScreen(
            prefillCourseId: isEdit ? null : extra?['courseId'] as String?,
            prefillSubject: isEdit ? null : extra?['subject'] as String?,
            initialMeeting: isEdit ? extra : null,
          );
        },
      ),
      GoRoute(
        path: '/teacher/assignments/add',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final rawIds = extra?['prefillStudentIds'] as List?;
          final initAssign = extra?['initialAssignment'] as Map<String, dynamic>?;
          return TeacherAddAssignmentScreen(
            prefillCourseId: extra?['prefillCourseId'] as String? ?? extra?['courseId'] as String?,
            prefillSubject: extra?['prefillSubject'] as String? ?? extra?['subject'] as String?,
            prefillStudentIds: rawIds?.cast<String>() ?? const [],
            initialAssignment: initAssign,
          );
        },
      ),
      GoRoute(
        path: '/teacher/assignments/:id/detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final title = state.extra as String?;
          return TeacherAssignmentDetailScreen(assignmentId: id, assignmentTitle: title);
        },
      ),
      GoRoute(
        path: '/teacher/classroom/:courseId/assignment/add',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return TeacherClassroomAddAssignmentScreen(
            courseId: courseId,
            courseName: (extra['courseName'] ?? '').toString(),
          );
        },
      ),
      GoRoute(
        path: '/teacher/classroom/:courseId/material/add',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return TeacherClassroomAddMaterialScreen(
            courseId: courseId,
            courseName: (extra['courseName'] ?? '').toString(),
          );
        },
      ),
      GoRoute(
        path: '/teacher/classroom/:courseId/meeting/add',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return TeacherClassroomAddMeetingScreen(
            courseId: courseId,
            courseName: (extra['courseName'] ?? '').toString(),
          );
        },
      ),
      // ── Full-screen teacher pages (pushed on top of shell, no shell wrapper) ─
      GoRoute(
        path: '/teacher/attendance/mark',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return TeacherAttendanceScreen(
            initialCohortId: extra['cohortId']?.toString(),
            initialPeriod: extra['period'] is int ? extra['period'] as int : null,
            initialDate: extra['date']?.toString(),
            initialSlotId: extra['slotId']?.toString(),
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
      // ─────────────────────────────────────────────────────────────────────

      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/messages',
            name: 'messages_inbox',
            builder: (context, state) => const MessagesInboxScreen(),
          ),
          GoRoute(
            path: '/teacher/assignments',
            builder: (context, state) => const TeacherAssignmentsScreen(),
          ),
          GoRoute(
            path: '/teacher/materials',
            builder: (context, state) => const TeacherMaterialsStandaloneScreen(),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const schedule_ui.ScheduleScreen(),
          ),
          GoRoute(
            path: '/teacher/schedule',
            builder: (context, state) => const TeacherScheduleScreen(),
          ),
          GoRoute(
            path: '/admin/periods',
            builder: (context, state) => const AdminPeriodsScreen(),
          ),
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/people',
            builder: (context, state) => const AdminPeopleScreen(),
          ),
          GoRoute(
            path: '/admin/cohorts',
            builder: (context, state) => const AdminCohortsScreen(),
          ),
          GoRoute(
            path: '/admin/schedule',
            builder: (context, state) => const AdminScheduleScreen(),
          ),
          GoRoute(
            path: '/admin/school',
            builder: (context, state) => const AdminSchoolSettingsScreen(),
          ),
          GoRoute(
            path: '/admin/bell-schedule',
            builder: (context, state) => const AdminBellScheduleScreen(),
          ),
          GoRoute(
            path: '/admin/export',
            builder: (context, state) => const AdminExportScreen(),
          ),
          GoRoute(
            path: '/admin/password-requests',
            builder: (context, state) => const AdminPasswordRequestsScreen(),
          ),
          GoRoute(
            path: '/admin/settings',
            builder: (context, state) => const AdminSettingsScreen(),
          ),
          GoRoute(
            path: '/support',
            builder: (context, state) => const SupportScreen(),
          ),
          GoRoute(
            path: '/about',
            builder: (context, state) => const AboutScreen(),
          ),
          GoRoute(
            path: '/secretary/students',
            builder: (context, state) => const SecretaryStudentsScreen(),
          ),
          GoRoute(
            path: '/secretary/schedule',
            builder: (context, state) => const AdminScheduleScreen(readOnly: true),
          ),
          GoRoute(
            path: '/teacher/insights',
            builder: (context, state) => const TeacherInsightsScreen(),
          ),
          GoRoute(
            path: '/teacher/home',
            builder: (context, state) => const TeacherHomeScreen(),
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
            path: '/teacher/exams',
            builder: (context, state) => const TeacherExamsScreen(),
          ),
          GoRoute(
            path: '/teacher/meetings',
            builder: (context, state) => const TeacherMeetingsScreen(),
          ),
          GoRoute(
            path: '/teacher/forms',
            builder: (context, state) => const TeacherFormsScreen(),
          ),
          GoRoute(
            path: '/teacher/attendance',
            builder: (context, state) => const TeacherAttendanceHistoryScreen(),
          ),
          GoRoute(
            path: '/teacher/students',
            builder: (context, state) => const TeacherStudentsScreen(),
          ),
          GoRoute(
            path: '/practice',
            builder: (context, state) => const PracticeSetupScreen(),
          ),
          GoRoute(
            path: '/classrooms',
            builder: (context, state) => const ClassroomsHomeScreen(),
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
            path: '/diplomas',
            builder: (context, state) => const DiplomasScreen(),
          ),
          GoRoute(
            path: '/materials',
            builder: (context, state) => const StudentMaterialsScreen(),
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
          GoRoute(
            path: '/dev/animation-demo',
            builder: (context, state) => const AnimationDemoScreen(),
          ),
        ],
      ),
    ],
  );
});
