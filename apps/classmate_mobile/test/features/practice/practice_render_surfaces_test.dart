import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classmate_mobile/common/widgets/cm_rich_content.dart';
import 'package:classmate_mobile/features/practice/domain/practice_models.dart';
import 'package:classmate_mobile/features/practice/domain/practice_history_models.dart';
import 'package:classmate_mobile/features/practice/providers/saved_questions_provider.dart';
import 'package:classmate_mobile/features/practice/ui/practice_history_review_screen.dart';
import 'package:classmate_mobile/features/practice/ui/saved_questions_screen.dart';

class TestSavedQuestionsController extends SavedQuestionsController {
  TestSavedQuestionsController(this.seed);
  final List<PracticeQuestion> seed;

  @override
  List<PracticeQuestion> build() => List<PracticeQuestion>.from(seed);
}

void main() {
  testWidgets('CMRichContent renders plain math text safely', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CMRichContent(
            data: r'Find \(x^2+3x+2\) and explain why \(x=1\) is not a root.',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CMRichContent), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PracticeHistoryReviewScreen renders prompt + explanation with rich content', (tester) async {
    final session = PracticeHistorySession(
      id: 'sess-1',
      completedAt: DateTime.parse('2026-03-17T18:00:00Z'),
      subject: 'Physics',
      topicLabel: 'Relativity',
      mode: PracticeMode.practice,
      difficulty: PracticeDifficulty.medium,
      totalQuestions: 1,
      answered: 1,
      correct: 1,
      wrong: 0,
      xp: 10,
      streak: 1,
      accuracyPercent: 100,
      questions: const [
        PracticeHistoryQuestion(
          id: 'hq-1',
          prompt: r'What is \(\gamma\) when \(v=0.8c\)?',
          options: ['1.25', '1.67', '2', '0.8'],
          correctIndex: 1,
          selectedIndex: 1,
          isCorrect: true,
          explanation: r'Use \(\gamma = 1/\sqrt{1-v^2/c^2}\).',
          topicLabel: 'Relativity',
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

  testWidgets('SavedQuestionsScreen renders saved prompt + explanation with rich content', (tester) async {
    final seed = <PracticeQuestion>[
      const PracticeQuestion(
        id: 'sq-1',
        subject: 'Physics',
        topicLabel: 'Relativity',
        mode: PracticeMode.practice,
        difficulty: PracticeDifficulty.medium,
        prompt: r'If \(v=0.6c\), what is the time dilation factor?',
        options: ['1.25', '1.67', '2', '0.6'],
        correctIndex: 0,
        explanation: r'Time dilation uses \(\gamma\).',
        recommendedTimeSeconds: 30,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savedQuestionsProvider.overrideWith(() => TestSavedQuestionsController(seed)),
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
