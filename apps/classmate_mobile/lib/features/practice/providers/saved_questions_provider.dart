import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/practice_models.dart';

final savedQuestionsProvider =
    NotifierProvider<SavedQuestionsController, List<PracticeQuestion>>(
      SavedQuestionsController.new,
    );

class SavedQuestionsController extends Notifier<List<PracticeQuestion>> {
  @override
  List<PracticeQuestion> build() => const [];

  void toggle(PracticeQuestion question) {
    final exists = state.any((q) => q.id == question.id);
    if (exists) {
      state = state.where((q) => q.id != question.id).toList(growable: false);
      return;
    }
    state = [question, ...state];
  }

  bool isSaved(String questionId) {
    return state.any((q) => q.id == questionId);
  }

  void clearAll() {
    state = const [];
  }
}
