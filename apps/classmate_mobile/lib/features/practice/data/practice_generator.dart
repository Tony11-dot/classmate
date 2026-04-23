import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../domain/practice_models.dart';
import 'practice_prompt_builder.dart';
import 'bagrut_repository.dart';

bool _matchesTopicPath(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i].trim().toLowerCase() != right[i].trim().toLowerCase()) {
      return false;
    }
  }
  return true;
}

@visibleForTesting
bool shouldTopUpRemotePracticeResults(PracticeFilter filter) {
  final catalogTopics = practiceSubjectCatalog[filter.subject] ?? const <List<String>>[];
  return catalogTopics.any((topicPath) => _matchesTopicPath(topicPath, filter.topicPath));
}

String normalizeMathInline(String text) {
  final normalizedText = text
      .replaceAll(RegExp(r'\\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n');
  final fenceRe = RegExp(r'```[\s\S]*?```', multiLine: true);
  if (!fenceRe.hasMatch(normalizedText)) {
    return _normalizeMathInlineChunk(normalizedText);
  }

  final out = StringBuffer();
  var cursor = 0;
  for (final match in fenceRe.allMatches(normalizedText)) {
    if (match.start > cursor) {
      out.write(
        _normalizeMathInlineChunk(normalizedText.substring(cursor, match.start)),
      );
    }
    out.write(match.group(0)!);
    cursor = match.end;
  }
  if (cursor < normalizedText.length) {
    out.write(_normalizeMathInlineChunk(normalizedText.substring(cursor)));
  }
  return out.toString();
}

String _normalizeMathInlineChunk(String text) {
  var t = text;

  // Convert \( ... \) → $...$
  t = t.replaceAllMapped(
    RegExp(r'\\\(([\s\S]*?)\\\)'),
    (m) => '\$${m.group(1) ?? m.group(0) ?? ''}\$',
  );

  // Convert \[ ... \] → $$...$$
  t = t.replaceAllMapped(
    RegExp(r'\\\[([\s\S]*?)\\\]'),
    (m) => '\$\$${m.group(1) ?? m.group(0) ?? ''}\$\$',
  );

  // Repair lost leading backslashes on common latex commands inside math/text.
  t = t.replaceAllMapped(
    RegExp(
      r'(^|[^A-Za-z\\])(frac|dfrac|tfrac|sqrt|cdot|times|leq|geq|neq|pm|mp|approx|left|right|alpha|beta|gamma|delta|theta|lambda|mu|pi|sigma|lim|int|sum|prod|sin|cos|tan|sec|csc|cot|log|ln|exp|partial|infty|begin|end)(?=[^A-Za-z]|$)',
    ),
    (m) => '${m.group(1) ?? ''}\\${m.group(2) ?? ''}',
  );

  // Wrap raw LaTeX environments as display math when they are not already delimited.
  t = t.replaceAllMapped(
    RegExp(
      r'(?<!\$)(\\begin\{[a-zA-Z*]+\}[\s\S]*?\\end\{[a-zA-Z*]+\})(?!\$)',
      multiLine: true,
    ),
    (m) => '\$\$${m.group(1) ?? ''}\$\$',
  );

  // Wrap common bare symbolic runs that should render as math.
  t = t.replaceAllMapped(
    RegExp(
      r'(?<!\$)((?:\\)?(?:int|sum|prod|lim)\s*(?:_[^\s,.;:!?]+)?(?:\^[^\s,.;:!?]+)?\s*[^,.;:!?\n]+)(?!\$)',
    ),
    (m) => '\$${m.group(1)}\$',
  );

  // Wrap simple powers if they are still plain text.
  t = _replaceOutsideMathDelimiters(
    t,
    RegExp(r'(?<!\$)([a-zA-Z0-9]+\^[0-9]+)(?!\$)'),
    (m) => '\$${m.group(1)}\$',
  );

  // Wrap simple subscripts/superscripts if they are still plain text.
  t = _replaceOutsideMathDelimiters(
    t,
    RegExp(
      r'(?<!\$)([a-zA-Z][a-zA-Z0-9]*\s*[_^]\s*(?:\{[^{}]+\}|[a-zA-Z0-9+-]+))(?!\$)',
    ),
    (m) => '\$${m.group(1)}\$',
  );

  // Wrap simple slash fractions if they are still plain text.
  t = _replaceOutsideMathDelimiters(
    t,
    RegExp(r'(?<!\$)([0-9a-zA-Z]+/[0-9a-zA-Z]+)(?!\$)'),
    (m) => '\$${m.group(1)}\$',
  );

  return t;
}

String _replaceOutsideMathDelimiters(
  String input,
  RegExp pattern,
  String Function(Match match) replacer,
) {
  final mathRe = RegExp(r'\$\$[\s\S]+?\$\$|\$[^$\n]+\$');
  final out = StringBuffer();
  var cursor = 0;

  for (final match in mathRe.allMatches(input)) {
    if (match.start > cursor) {
      out.write(
        input.substring(cursor, match.start).replaceAllMapped(pattern, replacer),
      );
    }
    out.write(match.group(0)!);
    cursor = match.end;
  }

  if (cursor < input.length) {
    out.write(input.substring(cursor).replaceAllMapped(pattern, replacer));
  }

  return out.toString();
}

class PracticeGenerator {
  static const _apiBase = String.fromEnvironment(
    'CM_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3001',
  );

  static const _devToken = String.fromEnvironment('CM_DEV_TOKEN');

  final BagrutRepository _bagrutRepo = BagrutRepository();

  Future<List<PracticeQuestion>> generate(PracticeFilter filter) async {
    if (filter.mode == PracticeMode.bagrut) {
      final bagrut = await _generateBagrutQuestion(filter);
      if (bagrut != null) return [bagrut];
      return generateFallback(filter);
    }

    final remote = await _generateFromApiWithRetry(filter);
    if (remote.isNotEmpty) return remote;

    return generateFallback(filter);
  }

  Future<PracticeQuestion?> _generateBagrutQuestion(
    PracticeFilter filter,
  ) async {
    final dto = await _bagrutRepo.getQuestion(
      subject: filter.subject,
      topicLabel: filter.topicLabel,
    );
    if (dto == null) return null;

    return PracticeQuestion(
      id: 'bagrut-${dto.examCode}-${dto.questionIndex}-${dto.year}',
      subject: dto.subject,
      topicLabel: dto.topicLabel,
      mode: PracticeMode.bagrut,
      difficulty: _parseDifficulty(dto.difficulty) ?? filter.difficulty,
      prompt: dto.promptLatex.isNotEmpty ? dto.promptLatex : 'Bagrut question',
      options: const [
        'Open with NOVA',
        'Show official solution',
        'Save for later',
        'End question',
      ],
      correctIndex: 1,
      explanation: dto.solutionLatex.isNotEmpty
          ? dto.solutionLatex
          : 'Official Bagrut-style solution unavailable.',
      recommendedTimeSeconds: 3600,
    );
  }

  Future<List<PracticeQuestion>> generateFallback(PracticeFilter filter) async {
    final out = <PracticeQuestion>[];
    final count = filter.questionCount < 1 ? 1 : filter.questionCount;

    for (var i = 0; i < count; i++) {
      out.add(_localQuestion(filter, i));
    }

    return out;
  }

  Future<List<PracticeQuestion>> _generateFromApiWithRetry(
    PracticeFilter filter,
  ) async {
    var last = const <PracticeQuestion>[];
    for (var attempt = 0; attempt < 2; attempt++) {
      last = await _generateFromApi(filter);
      if (last.isNotEmpty) return last;
      await Future<void>.delayed(
        Duration(milliseconds: attempt == 0 ? 700 : 0),
      );
    }
    return last;
  }

  Future<List<PracticeQuestion>> _generateFromApi(PracticeFilter filter) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 60);

    try {
      final uri = Uri.parse('$_apiBase/practice/generate');
      debugPrint('practice.generate uri=$uri');
      debugPrint('practice.generate devTokenLen=${_devToken.length}');
      final req = await client
          .postUrl(uri)
          .timeout(
            const Duration(seconds: 180),
            onTimeout: () => throw TimeoutException(
              'practice.generate postUrl timeout after 180s',
            ),
          );

      req.headers.contentType = ContentType.json;
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (_devToken.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_devToken');
      }

      final payload = <String, Object?>{
        'subject': filter.subject,
        'topicLabel': filter.topicLabel,
        'topicPath': filter.topicPath,
        'topicPathText': filter.topicPath.isEmpty
            ? filter.topicLabel
            : filter.topicPath.join(' > '),
        'mode': filter.mode.name,
        'difficulty': filter.difficulty.name,
        'questionCount': filter.questionCount,
        'timePreferenceSeconds': filter.timePreferenceSeconds,
        'useAiTiming': filter.useAiTiming,
        'maxLives': filter.maxLives,
        'strictPromptSummary': buildStrictPracticeFilterSection(filter),
      };

      debugPrint('practice.generate payload=${jsonEncode(payload)}');
      req.write(jsonEncode(payload));

      final res = await req.close().timeout(
        const Duration(seconds: 180),
        onTimeout: () => throw TimeoutException(
          'practice.generate close timeout after 180s',
        ),
      );
      final body = await utf8
          .decodeStream(res)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw TimeoutException(
              'practice.generate body timeout after 180s',
            ),
          );
      debugPrint('practice.generate status=${res.statusCode}');
      debugPrint(
        'practice.generate bodyPreview=${body.replaceAll(RegExp(r'\s+'), ' ').substring(0, body.length > 600 ? 600 : body.length)}',
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        debugPrint('practice.generate http ${res.statusCode}: $body');
        return const [];
      }

      final decoded = jsonDecode(body);
      final rawQuestions = _extractQuestions(decoded);

      final out = <PracticeQuestion>[];
      for (var i = 0; i < rawQuestions.length; i++) {
        final q = _parseQuestion(rawQuestions[i], filter: filter, index: i);
        if (q != null) out.add(q);
      }

      final targetCount = filter.mode == PracticeMode.bagrut
          ? 1
          : filter.questionCount.clamp(1, 25);

      if (out.length > targetCount) {
        return out.take(targetCount).toList(growable: false);
      }

      if (out.length < targetCount) {
        if (out.isNotEmpty && !shouldTopUpRemotePracticeResults(filter)) {
          return out;
        }

        final toppedUp = <PracticeQuestion>[...out];
        for (var i = toppedUp.length; i < targetCount; i++) {
          toppedUp.add(_localQuestion(filter, i));
        }
        return toppedUp;
      }

      return out;
    } catch (e, st) {
      debugPrint('practice.generate failed: $e');
      debugPrint('$st');
      return const [];
    } finally {
      client.close(force: true);
    }
  }

  List<dynamic> _extractQuestions(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      final direct = decoded['questions'];
      if (direct is List) return direct;

      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        final qs = data['questions'];
        if (qs is List) return qs;
      }

      final items = decoded['items'];
      if (items is List) return items;
    }
    return const [];
  }

  PracticeQuestion? _parseQuestion(
    dynamic raw, {
    required PracticeFilter filter,
    required int index,
  }) {
    if (raw is! Map) return null;

    final map = raw.map((k, v) => MapEntry(k.toString(), v));

    final prompt =
        _asString(map['prompt']) ??
        _asString(map['question']) ??
        _asString(map['text']) ??
        '';

    if (prompt.trim().isEmpty) return null;

    final rawOptions =
        map['options'] ??
        map['choices'] ??
        map['answers'] ??
        map['answerOptions'];
    final options = _asStringList(rawOptions);

    final correctIndex =
        _asInt(map['correctIndex']) ??
        _asInt(map['correct_answer_index']) ??
        _asInt(map['answerIndex']) ??
        0;

    final explanation =
        _asString(map['explanation']) ??
        _asString(map['solution']) ??
        _asString(map['reasoning']) ??
        'Review the logic carefully and ask NOVA for a full walkthrough.';

    final recommendedTimeSeconds =
        _asInt(map['recommendedTimeSeconds']) ??
        _asInt(map['timeSeconds']) ??
        _asInt(map['time_limit_seconds']) ??
        (filter.timePreferenceSeconds ?? 45);

    final safeOptions = options.length == 4
        ? options
        : <String>['Option A', 'Option B', 'Option C', 'Option D'];

    final safeCorrectIndex =
        correctIndex >= 0 && correctIndex < safeOptions.length
        ? correctIndex
        : 0;

    final normalizedPrompt = normalizeMathInline(prompt.trim());
    final normalizedExplanation = normalizeMathInline(explanation.trim());
    final normalizedOptions = safeOptions
      .map((option) => normalizeMathInline(option.trim()))
      .toList(growable: false);

    return PracticeQuestion(
      id:
          _asString(map['id']) ??
          'ai-${DateTime.now().millisecondsSinceEpoch}-$index',
      subject: _asString(map['subject'])?.trim().isNotEmpty == true
        ? _asString(map['subject'])!.trim()
        : filter.subject,
      topicLabel: _asString(map['topicLabel'])?.trim().isNotEmpty == true
        ? _asString(map['topicLabel'])!.trim()
        : filter.topicLabel,
      mode: filter.mode,
      difficulty: filter.difficulty,
      prompt: normalizedPrompt,
      options: normalizedOptions,
      correctIndex: safeCorrectIndex,
      explanation: normalizedExplanation,
      recommendedTimeSeconds: recommendedTimeSeconds < 1
          ? 1
          : recommendedTimeSeconds,
    );
  }

  PracticeQuestion _localQuestion(PracticeFilter filter, int index) {
    final topic = filter.topicLabel.toLowerCase();
    final subject = filter.subject.toLowerCase();

    if (filter.mode == PracticeMode.bagrut) {
      return PracticeQuestion(
        id: 'bagrut-local-$index',
        subject: filter.subject,
        topicLabel: filter.topicLabel,
        mode: filter.mode,
        difficulty: filter.difficulty,
        prompt:
            'Solve a ${filter.subject} question in the topic ${filter.topicLabel} formally in exam style.',
        options: const [
          'Open with NOVA',
          'Show official-style solution',
          'Save for later',
          'End question',
        ],
        correctIndex: 1,
        explanation:
            'Use the official-style solution flow or NOVA to review this prompt step by step in full exam format.',
        recommendedTimeSeconds: 3600,
      );
    }

    if (_mentions(subject, const ['math', 'mathematics']) &&
        _mentions(topic, const ['quadratic', 'quadratic equations'])) {
      return _localQuadraticQuestion(filter, index);
    }

    if (_mentions(subject, const ['computer science', 'cs', 'programming']) &&
        _mentions(topic, const [
          'condition',
          'conditions',
          'conditional',
          'if',
          'else',
          'branch',
          'branching',
          'boolean',
        ])) {
      final a = 2 + (index % 4);
      final b = 1 + ((index * 3) % 4);
      final truth = a > b;
      return PracticeQuestion(
        id: 'fallback-cs-cond-$index',
        subject: filter.subject,
        topicLabel: filter.topicLabel,
        mode: filter.mode,
        difficulty: filter.difficulty,
        prompt:
            'What does this print?\n\nint a = $a;\nint b = $b;\nif (a > b) {\n  print("A");\n} else {\n  print("B");\n}',
        options: const ['A', 'B', 'Nothing', 'Error'],
        correctIndex: truth ? 0 : 1,
        explanation: truth
            ? 'a is greater than b, so the if branch runs.'
            : 'a is not greater than b, so the else branch runs.',
        recommendedTimeSeconds: filter.timePreferenceSeconds ?? 30,
      );
    }

    final x = 2 + index;
    final y = x * 3 + 1;

    return PracticeQuestion(
      id: 'fallback-$index',
      subject: filter.subject,
      topicLabel: filter.topicLabel,
      mode: filter.mode,
      difficulty: filter.difficulty,
      prompt: '${filter.subject} • ${filter.topicLabel}: compute 3 * $x + 1.',
      options: ['$y', '${y + 1}', '${y - 1}', '${x + 1}'],
      correctIndex: 0,
      explanation: '3 * $x + 1 = $y.',
      recommendedTimeSeconds: filter.timePreferenceSeconds ?? 20,
    );
  }

  PracticeQuestion _localQuadraticQuestion(PracticeFilter filter, int index) {
    final seconds = filter.timePreferenceSeconds ??
        (filter.difficulty == PracticeDifficulty.olympiad ? 70 : 50);

    switch (index % 10) {
      case 0:
        return PracticeQuestion(
          id: 'fallback-quadratic-roots-$index',
          subject: filter.subject,
          topicLabel: filter.topicLabel,
          mode: filter.mode,
          difficulty: filter.difficulty,
          prompt:
              r'Solve the quadratic equation $x^2 - 5x + 6 = 0$.',
          options: const [
            r'$x=2$ or $x=3$',
            r'$x=-2$ or $x=-3$',
            r'$x=1$ or $x=6$',
            r'No real roots',
          ],
          correctIndex: 0,
          explanation:
              r'Factor: $x^2 - 5x + 6 = (x-2)(x-3)$, so the roots are $2$ and $3$.',
          recommendedTimeSeconds: seconds,
        );
      case 1:
        return PracticeQuestion(
          id: 'fallback-quadratic-discriminant-$index',
          subject: filter.subject,
          topicLabel: filter.topicLabel,
          mode: filter.mode,
          difficulty: filter.difficulty,
          prompt:
              r'How many real roots does $x^2 + 4x + 5 = 0$ have?',
          options: const [
            r'2 real roots',
            r'1 repeated real root',
            r'0 real roots',
            r'Infinitely many real roots',
          ],
          correctIndex: 2,
          explanation:
              r'The discriminant is $\Delta = b^2 - 4ac = 4^2 - 4(1)(5) = 16 - 20 = -4 < 0$, so there are no real roots.',
          recommendedTimeSeconds: seconds,
        );
      case 2:
        return PracticeQuestion(
          id: 'fallback-quadratic-sum-$index',
          subject: filter.subject,
          topicLabel: filter.topicLabel,
          mode: filter.mode,
          difficulty: filter.difficulty,
          prompt:
              r'Find the sum of the roots of $2x^2 - 7x + 3 = 0$.',
          options: const [
            r'$\frac{7}{2}$',
            r'$\frac{3}{2}$',
            r'$-\frac{7}{2}$',
            r'$7$',
          ],
          correctIndex: 0,
          explanation:
              r'For $ax^2 + bx + c = 0$, the sum of the roots is $-\frac{b}{a} = -\frac{-7}{2} = \frac{7}{2}$.',
          recommendedTimeSeconds: seconds,
        );
      case 3:
        return PracticeQuestion(
          id: 'fallback-quadratic-product-$index',
          subject: filter.subject,
          topicLabel: filter.topicLabel,
          mode: filter.mode,
          difficulty: filter.difficulty,
          prompt:
              r'Find the product of the roots of $x^2 - 8x + 12 = 0$.',
          options: const [r'$8$', r'$12$', r'$-12$', r'$20$'],
          correctIndex: 1,
          explanation:
              r'For $ax^2 + bx + c = 0$, the product of the roots is $\frac{c}{a} = 12$.',
          recommendedTimeSeconds: seconds,
        );
      case 4:
        return PracticeQuestion(
          id: 'fallback-quadratic-parameter-$index',
          subject: filter.subject,
          topicLabel: filter.topicLabel,
          mode: filter.mode,
          difficulty: filter.difficulty,
          prompt:
              r'If $x=1$ is a root of $x^2 - (m+3)x + 2m = 0$, what is $m$?',
          options: const [r'$1$', r'$2$', r'$3$', r'$4$'],
          correctIndex: 1,
          explanation:
              r'Substitute $x=1$: $1-(m+3)+2m=0 \Rightarrow m-2=0$, so $m=2$.',
          recommendedTimeSeconds: seconds,
        );
      case 5:
        return PracticeQuestion(
          id: 'fallback-quadratic-vertex-$index',
          subject: filter.subject,
          topicLabel: filter.topicLabel,
          mode: filter.mode,
          difficulty: filter.difficulty,
          prompt:
              r'What is the minimum value of $f(x)=x^2 - 4x + 7$?',
          options: const [r'$1$', r'$2$', r'$3$', r'$4$'],
          correctIndex: 2,
          explanation:
              r'Complete the square: $x^2 - 4x + 7 = (x-2)^2 + 3$, so the minimum value is $3$.',
          recommendedTimeSeconds: seconds,
        );
      case 6:
        return PracticeQuestion(
          id: 'fallback-quadratic-diff-roots-$index',
          subject: filter.subject,
          topicLabel: filter.topicLabel,
          mode: filter.mode,
          difficulty: filter.difficulty,
          prompt:
              r'The roots of $x^2 - 6x + k = 0$ differ by $2$. Find $k$.',
          options: const [r'$5$', r'$8$', r'$9$', r'$12$'],
          correctIndex: 1,
          explanation:
              r'If the roots differ by $2$ and sum to $6$, they are $2$ and $4$. Their product is $k=8$.',
          recommendedTimeSeconds: seconds,
        );
      case 7:
        return PracticeQuestion(
          id: 'fallback-quadratic-build-equation-$index',
          subject: filter.subject,
          topicLabel: filter.topicLabel,
          mode: filter.mode,
          difficulty: filter.difficulty,
          prompt:
              r'Which equation has roots $3$ and $5$?',
          options: const [
            r'$x^2 - 8x + 15 = 0$',
            r'$x^2 + 8x + 15 = 0$',
            r'$x^2 - 15x + 8 = 0$',
            r'$x^2 - 2x - 15 = 0$',
          ],
          correctIndex: 0,
          explanation:
              r'An equation with roots $r_1,r_2$ is $x^2 - (r_1+r_2)x + r_1r_2 = 0$. Here that is $x^2 - 8x + 15 = 0$.',
          recommendedTimeSeconds: seconds,
        );
      case 8:
        return PracticeQuestion(
          id: 'fallback-quadratic-intercepts-$index',
          subject: filter.subject,
          topicLabel: filter.topicLabel,
          mode: filter.mode,
          difficulty: filter.difficulty,
          prompt:
              r'What are the $x$-intercepts of $y=x^2 - 2x - 8$?',
          options: const [
            r'$x=-2$ and $x=4$',
            r'$x=2$ and $x=4$',
            r'$x=-4$ and $x=2$',
            r'No real intercepts',
          ],
          correctIndex: 0,
          explanation:
              r'Solve $x^2 - 2x - 8=0$. Factor: $(x-4)(x+2)=0$, so the intercepts are $-2$ and $4$.',
          recommendedTimeSeconds: seconds,
        );
      default:
        return PracticeQuestion(
          id: 'fallback-quadratic-double-root-$index',
          subject: filter.subject,
          topicLabel: filter.topicLabel,
          mode: filter.mode,
          difficulty: filter.difficulty,
          prompt:
              r'If $x^2 - 6x + 9 = 0$, which statement is true?',
          options: const [
            r'Two distinct real roots',
            r'One repeated real root at $x=3$',
            r'No real roots',
            r'One repeated real root at $x=-3$',
          ],
          correctIndex: 1,
          explanation:
              r'$x^2 - 6x + 9 = (x-3)^2$, so the equation has a repeated root at $x=3$.',
          recommendedTimeSeconds: seconds,
        );
    }
  }

  bool _mentions(String haystack, List<String> needles) {
    final h = haystack.toLowerCase();
    for (final n in needles) {
      if (h.contains(n)) return true;
    }
    return false;
  }

  String? _asString(Object? v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }

  List<String> _asStringList(Object? v) {
    if (v is List) {
      return v
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  int? _asInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  PracticeDifficulty? _parseDifficulty(String? v) {
    switch ((v ?? '').trim().toLowerCase()) {
      case 'easy':
        return PracticeDifficulty.easy;
      case 'medium':
        return PracticeDifficulty.medium;
      case 'hard':
        return PracticeDifficulty.hard;
      case 'olympiad':
        return PracticeDifficulty.olympiad;
      case 'adaptive':
        return PracticeDifficulty.adaptive;
    }
    return null;
  }
}
