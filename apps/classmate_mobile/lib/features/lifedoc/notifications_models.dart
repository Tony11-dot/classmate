enum StudentNotificationSeverity { info, warning, critical }

class StudentNotificationItem {
  final String id;
  final String title;
  final String body;
  final String source;
  final DateTime createdAt;
  final StudentNotificationSeverity severity;
  final bool isRead;

  const StudentNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.source,
    required this.createdAt,
    required this.severity,
    required this.isRead,
  });
}
