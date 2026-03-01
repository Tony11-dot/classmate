class SolutionsFilters {
  const SolutionsFilters({
    this.subject,
    this.sourceType,
    this.sourceName,
    this.page,
    this.questionNumber,
  });

  final String? subject;
  final String? sourceType;
  final String? sourceName;
  final int? page;
  final String? questionNumber;

  SolutionsFilters copyWith({
    String? subject,
    String? sourceType,
    String? sourceName,
    int? page,
    String? questionNumber,
    bool clearSubject = false,
    bool clearSourceType = false,
    bool clearSourceName = false,
    bool clearPage = false,
    bool clearQuestionNumber = false,
  }) {
    return SolutionsFilters(
      subject: clearSubject ? null : (subject ?? this.subject),
      sourceType: clearSourceType ? null : (sourceType ?? this.sourceType),
      sourceName: clearSourceName ? null : (sourceName ?? this.sourceName),
      page: clearPage ? null : (page ?? this.page),
      questionNumber: clearQuestionNumber ? null : (questionNumber ?? this.questionNumber),
    );
  }

  Map<String, String> toQuery() {
    final q = <String, String>{};
    if (subject != null && subject!.trim().isNotEmpty) q['subject'] = subject!.trim();
    if (sourceType != null && sourceType!.trim().isNotEmpty) q['sourceType'] = sourceType!.trim();
    if (sourceName != null && sourceName!.trim().isNotEmpty) q['sourceName'] = sourceName!.trim();
    if (page != null) q['page'] = page.toString();
    if (questionNumber != null && questionNumber!.trim().isNotEmpty) q['questionNumber'] = questionNumber!.trim();
    return q;
  }
}
