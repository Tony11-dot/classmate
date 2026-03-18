enum ExamAudienceType { classGroup, majorGroup, gradeGroup, customStudents }

class ExamAudience {
  final ExamAudienceType type;
  final String label;

  const ExamAudience({required this.type, required this.label});
}

class ExamMaterialItem {
  final String id;
  final String name;
  final String kind;
  final String? url;

  const ExamMaterialItem({
    required this.id,
    required this.name,
    required this.kind,
    required this.url,
  });
}

class StudentExamItem {
  final String id;
  final String subject;
  final String? topic;
  final String title;
  final String? caption;
  final String dateLabel;
  final String? hourLabel;
  final String? periodLabel;
  final String? durationLabel;
  final String teacher;
  final List<ExamMaterialItem> materials;
  final ExamAudience audience;

  const StudentExamItem({
    required this.id,
    required this.subject,
    required this.topic,
    required this.title,
    required this.caption,
    required this.dateLabel,
    required this.hourLabel,
    required this.periodLabel,
    required this.durationLabel,
    required this.teacher,
    required this.materials,
    required this.audience,
  });
}
