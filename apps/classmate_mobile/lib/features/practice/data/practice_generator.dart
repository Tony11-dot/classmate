import 'dart:convert';
import 'dart:io';

import '../domain/practice_models.dart';
import 'bagrut_repository.dart';

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

    final remote = await _generateFromApi(filter);
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

  Future<List<PracticeQuestion>> _generateFromApi(PracticeFilter filter) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);

    try {
      final uri = Uri.parse('$_apiBase/practice/generate');
      final req = await client.postUrl(uri);

      req.headers.contentType = ContentType.json;
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (_devToken.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_devToken');
      }

      final payload = <String, Object?>{
        'subject': filter.subject,
        'topicLabel': filter.topicLabel,
        'topicPath': filter.topicPath,
        'mode': filter.mode.name,
        'difficulty': filter.difficulty.name,
        'questionCount': filter.questionCount,
        'timePreferenceSeconds': filter.timePreferenceSeconds,
        'useAiTiming': filter.useAiTiming,
        'maxLives': filter.maxLives,
      };

      req.write(jsonEncode(payload));

      final res = await req.close();
      final body = await utf8.decodeStream(res);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        stderr.writeln('practice.generate http ${res.statusCode}: $body');
        return const [];
      }

      final decoded = jsonDecode(body);
      final rawQuestions = _extractQuestions(decoded);

      final out = <PracticeQuestion>[];
      for (var i = 0; i < rawQuestions.length; i++) {
        final q = _parseQuestion(rawQuestions[i], filter: filter, index: i);
        if (q != null) out.add(q);
      }

      return out;
    } catch (e, st) {
      stderr.writeln('practice.generate failed: $e');
      stderr.writeln('$st');
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

    final subject = _asString(map['subject']) ?? filter.subject;
    final topicLabel =
        _asString(map['topicLabel']) ??
        _asString(map['topic']) ??
        filter.topicLabel;
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

    return PracticeQuestion(
      id:
          _asString(map['id']) ??
          'ai-${DateTime.now().millisecondsSinceEpoch}-$index',
      subject: subject,
      topicLabel: topicLabel,
      mode: _parseMode(_asString(map['mode'])) ?? filter.mode,
      difficulty:
          _parseDifficulty(_asString(map['difficulty'])) ?? filter.difficulty,
      prompt: prompt.trim(),
      options: safeOptions,
      correctIndex: safeCorrectIndex,
      explanation: explanation.trim(),
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
        id: 'fallback-bagrut-$index',
        subject: filter.subject,
        topicLabel: filter.topicLabel,
        mode: filter.mode,
        difficulty: filter.difficulty,
        prompt:
            'Bagrut fallback: solve the requested topic formally in exam style.',
        options: const [
          'Open with NOVA',
          'Show official-style solution',
          'Save for later',
          'End question',
        ],
        correctIndex: 1,
        explanation: 'Formal school-style solution will appear here.',
        recommendedTimeSeconds: 3600,
      );
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
      prompt: 'Compute 3 * $x + 1.',
      options: ['$y', '${y + 1}', '${y - 1}', '${x + 1}'],
      correctIndex: 0,
      explanation: '3 * $x + 1 = $y.',
      recommendedTimeSeconds: filter.timePreferenceSeconds ?? 20,
    );
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

  PracticeMode? _parseMode(String? v) {
    switch ((v ?? '').trim().toLowerCase()) {
      case 'practice':
        return PracticeMode.practice;
      case 'flashcards':
        return PracticeMode.flashcards;
      case 'speedround':
      case 'speed_round':
      case 'speed-round':
        return PracticeMode.speedRound;
      case 'examprep':
      case 'exam_prep':
      case 'exam-prep':
        return PracticeMode.examPrep;
      case 'conceptbuilder':
      case 'concept_builder':
      case 'concept-builder':
        return PracticeMode.conceptBuilder;
      case 'adaptive':
        return PracticeMode.adaptive;
      case 'bagrut':
        return PracticeMode.bagrut;
    }
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
