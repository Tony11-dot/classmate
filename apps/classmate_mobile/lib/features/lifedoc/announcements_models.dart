enum AnnouncementSeverity { info, warning, critical }

/// Stable identifier for system-generated announcements so the renderer
/// can look up the translated title/body at display time. `null` means
/// the item is a free-form teacher/admin/secretary post and the `title`
/// / `body` fields hold the literal text to show.
enum AnnouncementTemplate {
  gradeRisk,
  weakSubject,
  lowAttendance,
  lateness,
  practiceWeakTopic,
  practiceDrop,
  solutionsActivity,
  allGood,
}

class AnnouncementItem {
  final String id;
  /// Fallback title used when [template] is null (free-form posts).
  final String title;
  /// Fallback body used when [template] is null.
  final String body;
  final AnnouncementSeverity severity;
  final String source; // grades | attendance | solutions | system
  final DateTime createdAt;
  /// Set for system-generated rows; null for free-form admin/teacher posts.
  /// The widget translates against this key + [templateArgs] at render time.
  final AnnouncementTemplate? template;
  /// Substitution args for the template body (e.g. {subject: 'Math',
  /// page: 12, question: 4}). Plain map so callers don't have to import
  /// the enum here.
  final Map<String, Object?> templateArgs;
  /// File / link attachments, same shape AttachmentPills expects:
  /// `[{ type, url, name, mime? }, ...]`. Empty for system-generated
  /// announcements; populated for teacher/admin/secretary posts that
  /// include uploads.
  final List<Map<String, dynamic>> attachments;
  /// User id of the author (server `createdBy`). Empty for system-generated
  /// rows. Used by the teacher Announcements screen to split "Received"
  /// (createdBy != me) from "Published" (createdBy == me).
  final String createdBy;

  const AnnouncementItem({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    required this.source,
    required this.createdAt,
    this.template,
    this.templateArgs = const {},
    this.attachments = const [],
    this.createdBy = '',
  });
}
