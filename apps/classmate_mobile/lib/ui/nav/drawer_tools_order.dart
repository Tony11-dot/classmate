import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth/auth_controller.dart';
import '../../l10n/app_localizations.dart';

/// One reorderable entry in the drawer's "School Tools" section.
/// The route is the stable id used for ordering + persistence.
class DrawerTool {
  const DrawerTool({required this.route, required this.icon, required this.label});
  final String route;
  final IconData icon;
  final String label;
}

/// Maps the live auth session to a stable role key used to scope the saved
/// order. Mirrors the precedence in MainDrawer.
String drawerToolsRoleKey({
  required String primaryRole,
  required bool isTeacherLike,
}) {
  switch (primaryRole) {
    case 'PARENT':
      return 'parent';
    case 'SECRETARY':
      return 'secretary';
    case 'ADMIN':
      return 'admin';
    default:
      return isTeacherLike ? 'teacher' : 'student';
  }
}

/// The DEFAULT (shipped) ordering of the reorderable "School Tools" items for
/// a given role. Core + Account entries are intentionally NOT here — only the
/// middle "School Tools" group is user-reorderable.
List<DrawerTool> defaultDrawerTools(String roleKey, AppLocalizations l) {
  switch (roleKey) {
    case 'teacher':
      return [
        DrawerTool(route: '/teacher/home', icon: Icons.dashboard_rounded, label: l.navTeacherWorkspace),
        DrawerTool(route: '/teacher/cohorts', icon: Icons.groups_rounded, label: l.navCohorts),
        DrawerTool(route: '/teacher/attendance', icon: Icons.fact_check_rounded, label: l.navAttendance),
        DrawerTool(route: '/teacher/grades', icon: Icons.grade_rounded, label: l.navGrades),
        DrawerTool(route: '/announcements', icon: Icons.campaign_rounded, label: l.navAnnouncements),
        DrawerTool(route: '/notifications', icon: Icons.notifications_rounded, label: l.navNotifications),
        DrawerTool(route: '/teacher/assignments', icon: Icons.assignment_rounded, label: l.navAssignments),
        DrawerTool(route: '/teacher/materials', icon: Icons.folder_shared_rounded, label: l.navMaterials),
        DrawerTool(route: '/teacher/meetings', icon: Icons.video_call_rounded, label: l.navMeetings),
        DrawerTool(route: '/solutions', icon: Icons.lightbulb_rounded, label: l.titleSolutions),
        DrawerTool(route: '/teacher/students', icon: Icons.people_rounded, label: l.teacherStudentsLabel),
        DrawerTool(route: '/teacher/exams', icon: Icons.quiz_rounded, label: l.navExams),
        DrawerTool(route: '/teacher/certificates', icon: Icons.workspace_premium_rounded, label: l.navCertificates),
        DrawerTool(route: '/teacher/forms', icon: Icons.assignment_turned_in_rounded, label: l.navForms),
        DrawerTool(route: '/notes', icon: Icons.sticky_note_2_rounded, label: l.notesTitle),
        DrawerTool(route: '/cmail', icon: Icons.alternate_email_rounded, label: l.cmailTitle),
      ];
    case 'parent':
      return [
        DrawerTool(route: '/parent/attendance', icon: Icons.how_to_reg_rounded, label: l.navAttendance),
        DrawerTool(route: '/parent/grades', icon: Icons.grade_rounded, label: l.navGrades),
        DrawerTool(route: '/parent/exams', icon: Icons.quiz_rounded, label: l.navExams),
        DrawerTool(route: '/parent/certificates', icon: Icons.military_tech_rounded, label: l.navDiplomas),
        DrawerTool(route: '/parent/assignments', icon: Icons.assignment_rounded, label: l.navAssignments),
        DrawerTool(route: '/parent/meetings', icon: Icons.video_call_rounded, label: l.navMeetings),
        DrawerTool(route: '/parent/materials', icon: Icons.folder_rounded, label: l.navMaterials),
        DrawerTool(route: '/announcements', icon: Icons.campaign_rounded, label: l.navAnnouncements),
        DrawerTool(route: '/parent/notifications', icon: Icons.notifications_rounded, label: l.navNotifications),
        DrawerTool(route: '/cmail', icon: Icons.alternate_email_rounded, label: l.cmailTitle),
      ];
    case 'admin':
      return [
        DrawerTool(route: '/admin/dashboard', icon: Icons.dashboard_rounded, label: l.navDashboard),
        DrawerTool(route: '/admin/people', icon: Icons.people_rounded, label: l.navPeople),
        DrawerTool(route: '/admin/insights', icon: Icons.insights_rounded, label: l.navInsights),
        DrawerTool(route: '/admin/cohorts', icon: Icons.groups_rounded, label: l.navCohorts),
        DrawerTool(route: '/admin/schedule', icon: Icons.manage_history_rounded, label: l.adminScheduleTitle),
        DrawerTool(route: '/admin/school', icon: Icons.school_rounded, label: l.adminSchoolSettingsTitle),
        DrawerTool(route: '/admin/grade-scales', icon: Icons.abc_rounded, label: l.navGradeScales),
        DrawerTool(route: '/admin/reports', icon: Icons.flag_outlined, label: l.navReports),
        DrawerTool(route: '/admin/certificates', icon: Icons.workspace_premium_rounded, label: l.navCertificates),
        DrawerTool(route: '/admin/export', icon: Icons.download_rounded, label: l.navExportData),
        DrawerTool(route: '/notes', icon: Icons.sticky_note_2_rounded, label: l.notesTitle),
        DrawerTool(route: '/cmail', icon: Icons.alternate_email_rounded, label: l.cmailTitle),
      ];
    case 'secretary':
      return [
        DrawerTool(route: '/secretary/home', icon: Icons.dashboard_rounded, label: l.navHome),
        DrawerTool(route: '/secretary/schedule', icon: Icons.manage_history_rounded, label: l.adminScheduleTitle),
        DrawerTool(route: '/secretary/people', icon: Icons.people_rounded, label: l.navPeople),
        DrawerTool(route: '/secretary/cohorts', icon: Icons.groups_rounded, label: l.navCohorts),
        DrawerTool(route: '/secretary/certificates', icon: Icons.workspace_premium_rounded, label: l.navCertificates),
        DrawerTool(route: '/announcements', icon: Icons.campaign_rounded, label: l.navAnnouncements),
        DrawerTool(route: '/messages', icon: Icons.chat_bubble_rounded, label: l.navMessages),
        DrawerTool(route: '/secretary/export', icon: Icons.download_rounded, label: l.navExportData),
        DrawerTool(route: '/cmail', icon: Icons.alternate_email_rounded, label: l.cmailTitle),
      ];
    default: // student
      return [
        DrawerTool(route: '/messages', icon: Icons.chat_bubble_rounded, label: l.navMessages),
        DrawerTool(route: '/attendance', icon: Icons.how_to_reg_rounded, label: l.navAttendance),
        DrawerTool(route: '/grades', icon: Icons.grade_rounded, label: l.navGrades),
        DrawerTool(route: '/assignments', icon: Icons.assignment_rounded, label: l.navAssignments),
        DrawerTool(route: '/materials', icon: Icons.folder_rounded, label: l.navMaterials),
        DrawerTool(route: '/solutions', icon: Icons.lightbulb_rounded, label: l.titleSolutions),
        DrawerTool(route: '/meetings', icon: Icons.video_call_rounded, label: l.navMeetings),
        DrawerTool(route: '/announcements', icon: Icons.campaign_rounded, label: l.navAnnouncements),
        DrawerTool(route: '/notifications', icon: Icons.notifications_rounded, label: l.navNotifications),
        DrawerTool(route: '/exams', icon: Icons.quiz_rounded, label: l.navExams),
        DrawerTool(route: '/forms', icon: Icons.assignment_turned_in_rounded, label: l.navForms),
        DrawerTool(route: '/saved-questions', icon: Icons.bookmark_rounded, label: l.navSavedQuestions),
        DrawerTool(route: '/certificates', icon: Icons.workspace_premium_rounded, label: l.navCertificates),
        DrawerTool(route: '/diplomas', icon: Icons.military_tech_rounded, label: l.navDiplomas),
        DrawerTool(route: '/cmail', icon: Icons.alternate_email_rounded, label: l.cmailTitle),
      ];
  }
}

/// Reorders [items] by the saved [order] (list of routes). Any tool not in the
/// saved order (e.g. a newly-shipped item) keeps its default position at the end.
List<DrawerTool> applyDrawerToolsOrder(List<DrawerTool> items, List<String> order) {
  if (order.isEmpty) return items;
  final byRoute = {for (final t in items) t.route: t};
  final out = <DrawerTool>[];
  final used = <String>{};
  for (final r in order) {
    final t = byRoute[r];
    if (t != null && !used.contains(r)) {
      out.add(t);
      used.add(r);
    }
  }
  for (final t in items) {
    if (!used.contains(t.route)) out.add(t);
  }
  return out;
}

/// Holds the saved School-Tools order for the CURRENT user's role.
final drawerToolsOrderProvider =
    NotifierProvider<DrawerToolsOrderNotifier, List<String>>(DrawerToolsOrderNotifier.new);

class DrawerToolsOrderNotifier extends Notifier<List<String>> {
  String _roleKey = 'student';

  String get roleKey => _roleKey;

  @override
  List<String> build() {
    final session = ref.watch(authSessionProvider);
    _roleKey = drawerToolsRoleKey(
      primaryRole: session.primaryRole,
      isTeacherLike: session.isTeacherLike,
    );
    Future.microtask(_load);
    return const <String>[];
  }

  String get _prefsKey => 'drawer_tools_order_$_roleKey';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey) ?? const <String>[];
    if (saved.isNotEmpty) state = saved;
  }

  Future<void> setOrder(List<String> routes) async {
    state = routes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, routes);
  }

  Future<void> reset() async {
    state = const <String>[];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
