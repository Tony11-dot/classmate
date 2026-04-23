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
7. Return exactly ${filter.questionCount} question(s), unless mode is bagrut, which must return exactly 1.
8. Each question must include exactly 4 answer options and one zero-based correctIndex.
9. Keep the difficulty exactly at ${filter.difficulty.name}; do not simplify or generalize.
10. For Math, Physics, Chemistry, and CS, format equations with LaTeX delimiters like \$...\$ or \$\$...\$\$.
11. For code examples, use fenced markdown code blocks with a language tag.
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
