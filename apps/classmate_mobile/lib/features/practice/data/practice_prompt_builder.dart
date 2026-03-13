import '../domain/practice_models.dart';

String buildStrictPracticeFilterSection(PracticeFilter filter) {
  final topic = filter.topicPath.isEmpty
      ? filter.topicLabel
      : filter.topicPath.join(' > ');
  final timing = filter.useAiTiming
      ? 'AI timing'
      : '${filter.timePreferenceSeconds ?? 15}s per question';

  return '''
STRICT_FILTER_SECTION_DO_NOT_IGNORE

Subject: ${filter.subject}
Topic: $topic
Mode: ${filter.mode.name}
Difficulty: ${filter.difficulty.name}
Question count: ${filter.questionCount}
Timing: $timing
Lives: ${filter.hasInfiniteLives ? "infinite" : filter.maxLives.toString()}

HARD RULES:
1. Every generated question MUST stay inside the exact Subject above.
2. Every generated question MUST stay inside the exact Topic above.
3. Do NOT drift to a neighboring topic.
4. Do NOT produce mixed-subject trivia unless the subject is exactly General Knowledge.
5. Explanations must stay inside the same subject/topic.
6. Respect the selected mode style.
''';
}

String buildPracticePromptSummary(PracticeFilter filter) {
  final timing = filter.useAiTiming
      ? 'AI timing'
      : '${filter.timePreferenceSeconds ?? 15}s';

  return [
    'Subject: ${filter.subject}',
    'Topic: ${filter.topicLabel}',
    'Mode: ${filter.mode.name}',
    'Difficulty: ${filter.difficulty.name}',
    'Questions: ${filter.questionCount}',
    'Timing: $timing',
    'Lives: ${filter.hasInfiniteLives ? "infinite" : "${filter.maxLives} lives"}',
  ].join(' • ');
}
