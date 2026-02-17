class AppNotification {
  final String id;
  final String title;
  final String body;
  final String? createdAt;
  final String? readAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.createdAt,
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id: j['id'].toString(),
    title: (j['title'] ?? '').toString(),
    body: (j['body'] ?? '').toString(),
    createdAt: j['createdAt']?.toString(),
    readAt: j['readAt']?.toString(),
  );

  bool get unread => readAt == null;
}
