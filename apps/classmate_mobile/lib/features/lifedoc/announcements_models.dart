enum AnnouncementSeverity { info, warning, critical }

class AnnouncementItem {
  final String id;
  final String title;
  final String body;
  final AnnouncementSeverity severity;
  final String source; // grades | attendance | solutions | system
  final DateTime createdAt;

  const AnnouncementItem({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    required this.source,
    required this.createdAt,
  });
}
