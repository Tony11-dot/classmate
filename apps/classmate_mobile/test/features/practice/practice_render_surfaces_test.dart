import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classmate_mobile/common/widgets/cm_code_block.dart';
import 'package:classmate_mobile/common/widgets/cm_rich_content.dart';
import 'package:classmate_mobile/core/text/normalize_question.dart';
import 'package:classmate_mobile/features/practice/domain/practice_models.dart';
import 'package:classmate_mobile/features/practice/domain/practice_history_models.dart';
import 'package:classmate_mobile/features/practice/providers/saved_questions_provider.dart';
import 'package:classmate_mobile/features/practice/ui/modes/mode_common.dart';
import 'package:classmate_mobile/features/practice/ui/practice_history_review_screen.dart';
import 'package:classmate_mobile/features/practice/ui/saved_questions_screen.dart';
import 'package:classmate_mobile/l10n/app_localizations.dart';

class TestSavedQuestionsController extends SavedQuestionsController {
  TestSavedQuestionsController(this.seed);
  final List<PracticeQuestion> seed;

  @override
  List<PracticeQuestion> build() => List<PracticeQuestion>.from(seed);
}

Widget _testApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

Widget _testScreenApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  test('prepareRenderableText repairs bare latex commands outside code fences', () {
    final prepared = prepareRenderableText('Compute frac{1}{2} and lim_{x->0} x.');

    expect(prepared, contains(r'$\frac{1}{2}$'));
    expect(prepared, contains(r'$\lim_{x->0} x$'));
  });

  test('prepareRenderableText repairs raw limits payloads from practice API', () {
    final prepared = prepareRenderableText(
      r'Find \lim_{x \to 1} \frac{x^2 + x - 2}{x - 1}\.',
    );

    expect(prepared, contains(r'$\lim_{x \to 1} \frac{x^2 + x - 2}{x - 1}$'));
    expect(prepared, isNot(contains(r'\.')));
  });

  test('prepareRenderableText does not turn left-hand or right-hand prose into latex', () {
    final prepared = prepareRenderableText(
      'Left-hand limit = 7 and right-hand limit = 7, so the limit exists.',
    );

    expect(prepared, contains('Left-hand limit = 7'));
    expect(prepared, contains('right-hand limit = 7'));
    expect(prepared, isNot(contains(r'\left-hand')));
    expect(prepared, isNot(contains(r'\right-hand')));
  });

  test('prepareRenderableText converts inline code tails into fenced blocks', () {
    final prepared = prepareRenderableText(
      'What does this print for score = 82? if (score >= 90) print("A"); else if (score >= 75) print("B"); else print("C");',
    );

    expect(prepared, contains('```'));
    expect(prepared, contains('else if'));
    expect(prepared, contains('print("B");'));
  });

  testWidgets('CMRichContent renders plain math text safely', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const CMRichContent(
          data: r'Find \(x^2+3x+2\) and explain why \(x=1\) is not a root.',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CMRichContent), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CMRichContent renders fenced code blocks with the shared code widget', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const CMRichContent(
          data: '```python\nprint("hi")\n```',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CMCodeBlock), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ModeAnswerTile renders fenced code answers with the shared code widget', (tester) async {
    await tester.pumpWidget(
      _testApp(
        ModeAnswerTile(
          label: '```python\nprint("hi")\n```',
          selected: false,
          revealed: false,
          correct: false,
          wrongSelected: false,
          accent: Colors.blue,
          onTap: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CMCodeBlock), findsOneWidget);
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
      _testScreenApp(PracticeHistoryReviewScreen(session: session)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CMRichContent), findsNWidgets(4));
    expect(find.textContaining('Relativity'), findsWidgets);
    expect(tester.takeException(), isNull);
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
        child: _testApp(
          const SavedQuestionsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CMRichContent), findsNWidgets(2));
    expect(find.textContaining('Relativity'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
