enum StudentFormQuestionType {
  shortAnswer,
  paragraph,
  multipleChoice,
  checkboxes,
  dropdown,
  linearScale,
}

class StudentFormChoiceStat {
  final String label;
  final int count;
  final double fraction;

  const StudentFormChoiceStat({
    required this.label,
    required this.count,
    required this.fraction,
  });
}

class StudentFormQuestionStats {
  final List<StudentFormChoiceStat> choiceStats;
  final List<String> textSamples;
  final double? averageScale;

  const StudentFormQuestionStats({
    this.choiceStats = const <StudentFormChoiceStat>[],
    this.textSamples = const <String>[],
    this.averageScale,
  });
}

class StudentFormQuestion {
  final String id;
  final String title;
  final String? description;
  final StudentFormQuestionType type;
  final bool required;
  final List<String> options;
  final int minScale;
  final int maxScale;
  final StudentFormQuestionStats stats;

  const StudentFormQuestion({
    required this.id,
    required this.title,
    required this.type,
    this.description,
    this.required = false,
    this.options = const <String>[],
    this.minScale = 1,
    this.maxScale = 5,
    this.stats = const StudentFormQuestionStats(),
  });
}

class StudentFormSummary {
  final int responsesCount;
  final int pendingCount;
  final double completionRate;
  final String averageDurationLabel;
  final String publishedLabel;

  const StudentFormSummary({
    required this.responsesCount,
    required this.pendingCount,
    required this.completionRate,
    required this.averageDurationLabel,
    required this.publishedLabel,
  });
}

class StudentFormItem {
  final String id;
  final String subject;
  final String title;
  final String description;
  final String teacher;
  final String audienceLabel;
  final bool acceptingResponses;
  final bool allowMultipleResponses;
  final bool published;
  final List<StudentFormQuestion> questions;
  final StudentFormSummary summary;

  const StudentFormItem({
    required this.id,
    required this.subject,
    required this.title,
    required this.description,
    required this.teacher,
    required this.audienceLabel,
    required this.acceptingResponses,
    required this.allowMultipleResponses,
    required this.published,
    required this.questions,
    required this.summary,
  });

  int get questionCount => questions.length;
}
