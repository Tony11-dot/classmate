import '../../l10n/app_localizations.dart';
import 'notifications_models.dart';

/// Title of a notification in the app's language. Items that carry a known
/// [StudentNotificationTemplate] are rebuilt from the strings file; everything
/// else keeps the literal text the server sent.
///
/// Shared by the Notifications screen, the OS notification banner and the
/// in-app snackbar so all three read the same.
String notificationTitleLocalized(
    AppLocalizations l, StudentNotificationItem item) {
  final t = item.template;
  if (t == null) return item.title;
  switch (t) {
    case StudentNotificationTemplate.newGradePosted:
      return l.notificationNewGradePosted;
    case StudentNotificationTemplate.newGradePostedIn:
      return l.notificationNewGradePostedIn(
        (item.templateArgs['subject'] ?? '').toString(),
      );
    case StudentNotificationTemplate.attendanceAbsent:
      return l.notificationAbsenceRecorded;
    case StudentNotificationTemplate.attendanceLate:
      return l.notificationLateRecorded;
    case StudentNotificationTemplate.attendanceExcused:
      return l.notificationExcusedRecorded;
    case StudentNotificationTemplate.attendanceUpdated:
      return l.notificationAttendanceUpdated;
  }
}

/// Body of a notification in the app's language: templated items rebuild
/// `assessment • grade` / `subject • period • status` from the app's own terms.
String notificationBodyLocalized(
    AppLocalizations l, StudentNotificationItem item) {
  final t = item.template;
  if (t == null) return item.body;
  switch (t) {
    case StudentNotificationTemplate.newGradePosted:
    case StudentNotificationTemplate.newGradePostedIn:
      final grade = (item.templateArgs['grade'] ?? '').toString().trim();
      if (grade.isEmpty) return item.body;
      final assessment =
          (item.templateArgs['assessment'] ?? '').toString().trim();
      return '${assessment.isEmpty ? l.gradesAssessmentFallback : assessment} • $grade';
    case StudentNotificationTemplate.attendanceAbsent:
    case StudentNotificationTemplate.attendanceLate:
    case StudentNotificationTemplate.attendanceExcused:
    case StudentNotificationTemplate.attendanceUpdated:
      final subject = (item.templateArgs['subject'] ?? '').toString().trim();
      final rawPeriod = item.templateArgs['period'];
      final period = rawPeriod is int ? rawPeriod : int.tryParse('$rawPeriod') ?? 0;
      final statusLabel = switch ((item.templateArgs['status'] ?? '').toString()) {
        'absent' => l.attendanceStatusAbsent,
        'late' => l.attendanceStatusLate,
        'justified' => l.attendanceStatusExcused,
        'present' => l.attendanceStatusPresent,
        _ => l.attendanceStatusRecorded,
      };
      return [
        if (subject.isNotEmpty) subject,
        if (period > 0) l.teacherPeriod(period),
        statusLabel,
      ].join(' • ');
  }
}

/// The section a notification belongs to, in the app's language. The server
/// sends its `NotificationKind` lower-cased ("new_assignment",
/// "grade_posted", …); client-made items use the short keys ("grades").
/// Unknown values are humanized rather than shown as a raw enum.
String notificationSourceLabel(AppLocalizations l, String source) {
  final s = source.trim().toLowerCase().replaceAll('-', '_');
  return switch (s) {
    '' || 'system' => l.notificationsSourceSystem,
    'grades' || 'grade' || 'grade_posted' => l.navGrades,
    'attendance' ||
    'attendance_marked' ||
    'attendance_recorded' ||
    'attendance_alert' =>
      l.navAttendance,
    'practice' || 'practice_completed' => l.navPractice,
    'solutions' || 'solution' => l.navSolutions,
    'solution_report' || 'solution_reported' || 'reported_solution' =>
      l.navReports,
    'messages' ||
    'chat' ||
    'message' ||
    'new_message' ||
    'dm' ||
    'dm_message' =>
      l.navMessages,
    'classrooms' ||
    'classroom' ||
    'classroom_message' ||
    'classroom_invite' ||
    'classroom_update' =>
      l.navClassrooms,
    'form' || 'forms' || 'new_form' => l.navForms,
    'assignments' || 'assignment' || 'new_assignment' => l.navAssignments,
    'meetings' || 'meeting' || 'new_meeting' => l.navMeetings,
    'announcements' || 'announcement' => l.navAnnouncements,
    'exam' || 'exams' || 'new_exam' => l.navExams,
    'material' || 'materials' || 'new_material' => l.navMaterials,
    'diploma' || 'diplomas' || 'certificate' || 'new_diploma' =>
      l.navCertificates,
    'nova' || 'tutor' => l.navNova,
    _ => source.trim().replaceAll('_', ' '),
  };
}
