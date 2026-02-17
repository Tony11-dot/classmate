class ClassroomSubject {
  final String id;
  final String name;
  ClassroomSubject({required this.id, required this.name});

  factory ClassroomSubject.fromJson(Map<String, dynamic> j) {
    return ClassroomSubject(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
    );
  }
}

class ClassroomListItem {
  final String id;
  final String title;
  final int grade;
  final String schoolId;
  final ClassroomSubject subject;
  final String role;

  ClassroomListItem({
    required this.id,
    required this.title,
    required this.grade,
    required this.schoolId,
    required this.subject,
    required this.role,
  });

  factory ClassroomListItem.fromJson(Map<String, dynamic> j) {
    return ClassroomListItem(
      id: (j['id'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      grade: (j['grade'] ?? 0) is int ? (j['grade'] as int) : int.tryParse('${j['grade']}') ?? 0,
      schoolId: (j['schoolId'] ?? '').toString(),
      subject: ClassroomSubject.fromJson((j['subject'] ?? const {}) as Map<String, dynamic>),
      role: (j['role'] ?? '').toString(),
    );
  }
}
