class Assignment {
  final String id;
  final String title;
  final String? description;
  final String? dueAt; // ISO string
  final int? grade;
  final String? subjectId;
  final String? createdAt;
  final String? createdBy;

  Assignment({
    required this.id,
    required this.title,
    this.description,
    this.dueAt,
    this.grade,
    this.subjectId,
    this.createdAt,
    this.createdBy,
  });

  factory Assignment.fromJson(Map<String, dynamic> j) => Assignment(
    id: (j['id'] ?? '').toString(),
    title: (j['title'] ?? '').toString(),
    description: j['description']?.toString(),
    dueAt: j['dueAt']?.toString(),
    grade: j['grade'] is int
        ? j['grade'] as int
        : (j['grade'] as num?)?.toInt(),
    subjectId: j['subjectId']?.toString(),
    createdAt: j['createdAt']?.toString(),
    createdBy: j['createdBy']?.toString(),
  );
}

class AssignmentSubmission {
  final String id;
  final String assignmentId;
  final String studentUserId;
  final String? text;
  final String? mediaUrl;
  final String? createdAt;

  AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentUserId,
    this.text,
    this.mediaUrl,
    this.createdAt,
  });

  factory AssignmentSubmission.fromJson(Map<String, dynamic> j) =>
      AssignmentSubmission(
        id: (j['id'] ?? '').toString(),
        assignmentId: (j['assignmentId'] ?? '').toString(),
        studentUserId: (j['studentUserId'] ?? '').toString(),
        text: j['text']?.toString(),
        mediaUrl: j['mediaUrl']?.toString(),
        createdAt: j['createdAt']?.toString(),
      );
}
