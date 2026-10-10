import '../../l10n/app_localizations.dart';

/// Display helpers for fields the API may send empty, or filled with one of
/// its English placeholder words (`Class`, `Teacher`, `School`). The data
/// layer keeps the raw value; these pick the translated word at render time
/// so no English fallback ever reaches a Hebrew, Arabic, French or Russian UI.

String formTitleLabel(AppLocalizations l, String raw) =>
    raw.trim().isEmpty ? l.commonUntitled : raw;

String examTitleLabel(AppLocalizations l, String raw) =>
    raw.trim().isEmpty ? l.gradesAssessmentFallback : raw;

String formSubjectLabel(AppLocalizations l, String raw) =>
    raw.trim().isEmpty ? l.formTitle : raw;

String teacherNameLabel(AppLocalizations l, String raw) {
  final v = raw.trim();
  return (v.isEmpty || v == 'Teacher') ? l.roleTeacher : raw;
}

String audienceLabel(AppLocalizations l, String raw) {
  final v = raw.trim();
  if (v.isEmpty || v == 'Class') return l.scheduleClassFallback;
  if (v == 'School' || v == 'School audience') return l.navSchool;
  return raw;
}

String attachmentNameLabel(AppLocalizations l, String raw) =>
    raw.trim().isEmpty ? l.chatPreviewAttachment : raw;
