import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classmate_mobile/common/widgets/cm_rich_content.dart';
import 'package:classmate_mobile/features/practice/domain/practice_models.dart';
import 'package:classmate_mobile/features/practice/domain/practice_history_models.dart';
import 'package:classmate_mobile/features/practice/providers/saved_questions_provider.dart';
import 'package:classmate_mobile/features/practice/ui/practice_history_review_screen.dart';
import 'package:classmate_mobile/features/practice/ui/saved_questions_screen.dart';

void main() {
  testWidgets('practice history review renders rich content', (tester) async {
    final session = PracticeHistorySession(
      id: 'sess-1',
      subject: 'Physics',
      topicLabel: 'Relativity',
      mode: PracticeMode.practice,
      difficulty: PracticeDifficulty.medium,
      totalQuestions: 1,
      correct: 1,
      wrong: 0,
      answered: 1,
      accuracyPercent: 100,
      xp: 10,
      streak: 1,
      completedAt: DateTime.parse('2026-03-17T18:00:00Z'),
      questions: [
        PracticeHistoryQuestion(
          id: 'q-1',
          subject: 'Physics',
          topicLabel: 'Relativity',
          prompt: r'What is \(\gamma\) when \(v=0.8c\)?',
          options: const ['1.25', '1.67', '2', '0.8'],
          correctIndex: 1,
          selectedIndex: 1,
          explanation: r'Use \(\gamma = 1/\sqrt{1-v^2/c^2}\).',
          recommendedTimeSeconds: 30,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PracticeHistoryReviewScreen(session: session),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Session Review'), findsOneWidget);
    expect(find.byType(CMRichContent), findsWidgets);
    expect(find.textContaining('Relativity'), findsWidgets);
  });

  testWidgets('saved questions screen renders rich content', (tester) async {
    final seed = <SavedQuestion>[
      SavedQuestion(
        id: 'sq-1',
        subject: 'Physics',
        topicLabel: 'Relativity',
        prompt: r'If \(v=0.6c\), what is the time dilation factor?',
        options: const ['1.25', '1.67', '2', '0.6'],
        correctIndex: 0,
        explanation: r'Time dilation uses \(\gamma\).',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savedQuestionsProvider.overrideWith(() => SavedQuestionsController(seed: seed)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SavedQuestionsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Saved questions'), findsOneWidget);
    expect(find.byType(CMRichContent), findsWidgets);
    expect(find.textContaining('Relativity'), findsWidgets);
  });
}
