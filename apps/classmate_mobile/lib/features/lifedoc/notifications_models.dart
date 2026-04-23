enum StudentNotificationSeverity { info, warning, critical }

class StudentNotificationItem {
  final String id;
  final String title;
  final String body;
  final String source;
  final DateTime createdAt;
  final StudentNotificationSeverity severity;
  final bool isRead;
  final bool isLocal;

  const StudentNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.source,
    required this.createdAt,
    required this.severity,
    required this.isRead,
    this.isLocal = false,
  });

  StudentNotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    String? source,
    DateTime? createdAt,
    StudentNotificationSeverity? severity,
    bool? isRead,
    bool? isLocal,
  }) {
    return StudentNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      severity: severity ?? this.severity,
      isRead: isRead ?? this.isRead,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'severity': severity.name,
      'isRead': isRead,
      'isLocal': isLocal,
    };
  }

  factory StudentNotificationItem.fromJson(Map<String, dynamic> json) {
    final severityRaw = '${json['severity'] ?? 'info'}'.trim().toLowerCase();
    final severity = switch (severityRaw) {
      'critical' => StudentNotificationSeverity.critical,
      'warning' => StudentNotificationSeverity.warning,
      _ => StudentNotificationSeverity.info,
    };

    return StudentNotificationItem(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      body: '${json['body'] ?? ''}',
      source: '${json['source'] ?? 'system'}',
      createdAt:
          DateTime.tryParse('${json['createdAt'] ?? ''}') ?? DateTime.now(),
      severity: severity,
      isRead: json['isRead'] == true,
      isLocal: json['isLocal'] == true,
    );
  }
}
