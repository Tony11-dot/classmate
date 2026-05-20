enum AnnouncementSeverity { info, warning, critical }

class AnnouncementItem {
  final String id;
  final String title;
  final String body;
  final AnnouncementSeverity severity;
  final String source; // grades | attendance | solutions | system
  final DateTime createdAt;
  /// File / link attachments, same shape AttachmentPills expects:
  /// `[{ type, url, name, mime? }, ...]`. Empty for system-generated
  /// announcements; populated for teacher/admin/secretary posts that
  /// include uploads.
  final List<Map<String, dynamic>> attachments;

  const AnnouncementItem({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    required this.source,
    required this.createdAt,
    this.attachments = const [],
  });
}
