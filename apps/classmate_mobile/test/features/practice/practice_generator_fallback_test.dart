import 'package:flutter_test/flutter_test.dart';

import 'package:classmate_mobile/features/practice/data/practice_generator.dart';
import 'package:classmate_mobile/features/practice/domain/practice_models.dart';

void main() {
  test('normalizeMathInline preserves fenced code blocks while still normalizing prose math', () {
    const input = '''
Explain why x^2 grows faster than x.

```python
def square(x):
    return x^2
```

Then compare frac{1}{2} with 3/4.
''';

    final normalized = normalizeMathInline(input);

    expect(normalized, contains('```python\ndef square(x):\n    return x^2\n```'));
    expect(normalized, contains(r'$x^2$ grows faster than x.'));
    expect(normalized, contains(r'\frac{1}{2}'));
    expect(normalized, contains(r'$3/4$'));
  });

  test('normalizeMathInline repairs richer math constructs without touching code fences', () {
    const input = r'''
Evaluate int_0^1 x^2 dx, sum_{k=1}^n k, and x_2 with y^n.

Display this matrix:
\[begin{bmatrix}1 & 2\\3 & 4\end{bmatrix}\]

```javascript
const total = items.reduce((sum, item) => sum + item.value, 0)
```
''';

    final normalized = normalizeMathInline(input);

    expect(normalized, contains(r'$\int_0^1 x^2 dx$'));
    expect(normalized, contains(r'$\sum_{k=1}^n k$'));
    expect(normalized, contains(r'$x_2$'));
    expect(normalized, contains(r'$y^n$'));
    expect(normalized, contains(r'$$\begin{bmatrix}1 & 2\\3 & 4\end{bmatrix}$$'));
    expect(
      normalized,
      contains('```javascript\nconst total = items.reduce((sum, item) => sum + item.value, 0)\n```'),
    );
  });

  test('tops up only catalog-backed remote topics', () {
    const catalogFilter = PracticeFilter(
      subject: 'Math',
      mode: PracticeMode.practice,
      difficulty: PracticeDifficulty.medium,
      topicPath: <String>['Algebra'],
      questionCount: 3,
      timePreferenceSeconds: 30,
      useAiTiming: false,
      maxLives: 3,
      hasInfiniteLives: false,
    );
    const customFilter = PracticeFilter(
      subject: 'Computer Science',
      mode: PracticeMode.practice,
      difficulty: PracticeDifficulty.medium,
      topicPath: <String>['python recursion base case confusion'],
      questionCount: 3,
      timePreferenceSeconds: 30,
      useAiTiming: false,
      maxLives: 3,
      hasInfiniteLives: false,
    );

    expect(shouldTopUpRemotePracticeResults(catalogFilter), isTrue);
    expect(shouldTopUpRemotePracticeResults(customFilter), isFalse);
  });

  group('PracticeGenerator.generateFallback', () {
    test('returns exact-count quadratic questions matching the requested filter', () async {
      final generator = PracticeGenerator();
      const filter = PracticeFilter(
        subject: 'Math',
        mode: PracticeMode.practice,
        difficulty: PracticeDifficulty.olympiad,
        topicPath: <String>['Algebra', 'Quadratic equations'],
        questionCount: 10,
        timePreferenceSeconds: null,
        useAiTiming: true,
        maxLives: 3,
        hasInfiniteLives: false,
      );

      final questions = await generator.generateFallback(filter);

      expect(questions, hasLength(10));
      for (final question in questions) {
        expect(question.subject, filter.subject);
        expect(question.topicLabel, filter.topicLabel);
        expect(question.mode, filter.mode);
        expect(question.difficulty, filter.difficulty);
        expect(question.options, hasLength(4));
        expect(question.correctIndex, inInclusiveRange(0, 3));
        expect(question.recommendedTimeSeconds, greaterThan(0));

        final combined = '${question.prompt} ${question.explanation}'.toLowerCase();
        expect(
          RegExp(r'quadratic|root|roots|discriminant|vertex|intercepts|x\^2').hasMatch(combined),
          isTrue,
          reason: 'Question should stay inside quadratic equations.',
        );
        expect(combined.contains('3 *'), isFalse);
      }
    });

    test('preserves requested count for non-quadratic generic fallback too', () async {
      final generator = PracticeGenerator();
      const filter = PracticeFilter(
        subject: 'Biology',
        mode: PracticeMode.practice,
        difficulty: PracticeDifficulty.medium,
        topicPath: <String>['Cells'],
        questionCount: 7,
        timePreferenceSeconds: 30,
        useAiTiming: false,
        maxLives: 3,
        hasInfiniteLives: false,
      );

      final questions = await generator.generateFallback(filter);

      expect(questions, hasLength(7));
      expect(questions.every((question) => question.subject == 'Biology'), isTrue);
      expect(questions.every((question) => question.topicLabel == 'Cells'), isTrue);
      expect(questions.every((question) => question.options.length == 4), isTrue);
    });
  });
}