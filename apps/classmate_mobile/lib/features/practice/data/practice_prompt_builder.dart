import '../domain/practice_models.dart';

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
    'Lives: ${filter.maxLives} lives',
  ].join(' • ');
}
