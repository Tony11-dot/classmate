import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/practice_models.dart';

const _savedQuestionsPrefsKey = 'practice_saved_questions_v1';

final savedQuestionsProvider =
    NotifierProvider<SavedQuestionsController, List<PracticeQuestion>>(
      SavedQuestionsController.new,
    );

class SavedQuestionsController extends Notifier<List<PracticeQuestion>> {
  void toggleQuestion(PracticeQuestion question) {
    final exists = state.any((x) => x.id == question.id);
    if (exists) {
      state = [
        for (final x in state)
          if (x.id != question.id) x,
      ];
      _persist(state);
      return;
    }

    state = [question, ...state];
    _persist(state);
  }

  @override
  List<PracticeQuestion> build() {
    _load();
    return const [];
  }

  void toggle(PracticeQuestion question) {
    final exists = state.any((q) => q.id == question.id);
    if (exists) {
      state = state.where((q) => q.id != question.id).toList(growable: false);
      _persist(state);
      return;
    }
    state = [question, ...state];
    _persist(state);
  }

  bool isSaved(String questionId) {
    return state.any((q) => q.id == questionId);
  }

  void clearAll() {
    state = const [];
    _persist(state);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_savedQuestionsPrefsKey);
    if ((raw ?? '').trim().isEmpty) return;

    try {
      final decoded = jsonDecode(raw!);
      if (decoded is! List) return;
      state = decoded
          .whereType<Map>()
          .map(
            (item) => _questionFromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      state = const [];
    }
  }

  Future<void> _persist(List<PracticeQuestion> questions) async {
    final prefs = await SharedPreferences.getInstance();
    if (questions.isEmpty) {
      await prefs.remove(_savedQuestionsPrefsKey);
      return;
    }

    await prefs.setString(
      _savedQuestionsPrefsKey,
      jsonEncode(questions.map(_questionToJson).toList(growable: false)),
    );
  }

  Map<String, dynamic> _questionToJson(PracticeQuestion question) {
    return <String, dynamic>{
      'id': question.id,
      'subject': question.subject,
      'topicLabel': question.topicLabel,
      'mode': question.mode.name,
      'difficulty': question.difficulty.name,
      'prompt': question.prompt,
      'options': question.options,
      'correctIndex': question.correctIndex,
      'explanation': question.explanation,
      'recommendedTimeSeconds': question.recommendedTimeSeconds,
    };
  }

  PracticeQuestion _questionFromJson(Map<String, dynamic> json) {
    final modeName = '${json['mode'] ?? PracticeMode.practice.name}'.trim();
    final difficultyName =
        '${json['difficulty'] ?? PracticeDifficulty.medium.name}'.trim();

    return PracticeQuestion(
      id: '${json['id'] ?? ''}',
      subject: '${json['subject'] ?? 'Practice'}',
      topicLabel: '${json['topicLabel'] ?? 'All topics'}',
      mode: PracticeMode.values.firstWhere(
        (item) => item.name == modeName,
        orElse: () => PracticeMode.practice,
      ),
      difficulty: PracticeDifficulty.values.firstWhere(
        (item) => item.name == difficultyName,
        orElse: () => PracticeDifficulty.medium,
      ),
      prompt: '${json['prompt'] ?? ''}',
      options: (json['options'] as List?)
              ?.map((item) => item.toString())
              .toList(growable: false) ??
          const <String>[],
      correctIndex: (json['correctIndex'] as num?)?.toInt() ?? 0,
      explanation: '${json['explanation'] ?? ''}',
      recommendedTimeSeconds:
          (json['recommendedTimeSeconds'] as num?)?.toInt() ?? 60,
    );
  }
}
