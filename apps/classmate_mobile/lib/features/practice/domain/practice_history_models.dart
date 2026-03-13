import 'practice_models.dart';

class PracticeHistorySession {
  final String id;
  final DateTime completedAt;
  final String subject;
  final String topicLabel;
  final PracticeMode mode;
  final PracticeDifficulty difficulty;
  final int totalQuestions;
  final int answered;
  final int correct;
  final int wrong;
  final int xp;
  final int streak;
  final int accuracyPercent;
  final List<PracticeHistoryQuestion> questions;

  const PracticeHistorySession({
    required this.id,
    required this.completedAt,
    required this.subject,
    required this.topicLabel,
    required this.mode,
    required this.difficulty,
    required this.totalQuestions,
    required this.answered,
    required this.correct,
    required this.wrong,
    required this.xp,
    required this.streak,
    required this.accuracyPercent,
    required this.questions,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'completedAt': completedAt.toIso8601String(),
    'subject': subject,
    'topicLabel': topicLabel,
    'mode': mode.name,
    'difficulty': difficulty.name,
    'totalQuestions': totalQuestions,
    'answered': answered,
    'correct': correct,
    'wrong': wrong,
    'xp': xp,
    'streak': streak,
    'accuracyPercent': accuracyPercent,
    'questions': questions.map((q) => q.toJson()).toList(),
  };

  factory PracticeHistorySession.fromJson(Map<String, dynamic> json) {
    return PracticeHistorySession(
      id: (json['id'] ?? '').toString(),
      completedAt:
          DateTime.tryParse((json['completedAt'] ?? '').toString()) ??
          DateTime.now(),
      subject: (json['subject'] ?? '').toString(),
      topicLabel: (json['topicLabel'] ?? '').toString(),
      mode: PracticeMode.values.firstWhere(
        (x) => x.name == (json['mode'] ?? '').toString(),
        orElse: () => PracticeMode.practice,
      ),
      difficulty: PracticeDifficulty.values.firstWhere(
        (x) => x.name == (json['difficulty'] ?? '').toString(),
        orElse: () => PracticeDifficulty.medium,
      ),
      totalQuestions: _asInt(json['totalQuestions']),
      answered: _asInt(json['answered']),
      correct: _asInt(json['correct']),
      wrong: _asInt(json['wrong']),
      xp: _asInt(json['xp']),
      streak: _asInt(json['streak']),
      accuracyPercent: _asInt(json['accuracyPercent']),
      questions: ((json['questions'] as List?) ?? const [])
          .whereType<Map>()
          .map(
            (x) => PracticeHistoryQuestion.fromJson(
              x.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
          .toList(growable: false),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }
}

class PracticeHistoryQuestion {
  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final int? selectedIndex;
  final bool isCorrect;
  final String explanation;
  final String topicLabel;

  const PracticeHistoryQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.selectedIndex,
    required this.isCorrect,
    required this.explanation,
    required this.topicLabel,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'prompt': prompt,
    'options': options,
    'correctIndex': correctIndex,
    'selectedIndex': selectedIndex,
    'isCorrect': isCorrect,
    'explanation': explanation,
    'topicLabel': topicLabel,
  };

  factory PracticeHistoryQuestion.fromJson(Map<String, dynamic> json) {
    return PracticeHistoryQuestion(
      id: (json['id'] ?? '').toString(),
      prompt: (json['prompt'] ?? '').toString(),
      options: ((json['options'] as List?) ?? const [])
          .map((x) => x.toString())
          .toList(growable: false),
      correctIndex: _asInt(json['correctIndex']),
      selectedIndex: json['selectedIndex'] == null
          ? null
          : _asInt(json['selectedIndex']),
      isCorrect: json['isCorrect'] == true,
      explanation: (json['explanation'] ?? '').toString(),
      topicLabel: (json['topicLabel'] ?? '').toString(),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }
}
