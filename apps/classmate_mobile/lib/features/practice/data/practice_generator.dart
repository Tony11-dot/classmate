import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import '../../../core/config/env.dart';


import '../domain/practice_models.dart';
import '../domain/practice_subjects.dart';
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

bool shouldTopUpRemotePracticeResults(PracticeFilter filter) {
  final catalogTopics = practiceTopicsFor(filter.subject, filter.grade);
  return catalogTopics.any((topicPath) => _matchesTopicPath(topicPath, filter.topicPath));
}

// ── Math normalisation ─────────────────────────────────────────────────────────

// Unambiguous LaTeX commands: can ONLY appear in math, never in plain English prose.
// Used as the trigger condition before wrapping bare expressions.
final _unambiguousMathRe = RegExp(
  r'(?<![\\$a-zA-Z])\\'
  r'(?:frac|dfrac|tfrac|cfrac|sqrt|int|oint|iint|iiint|sum|prod|coprod|'
  r'lim|limsup|liminf|partial|nabla|infty|binom|tbinom|dbinom|'
  r'alpha|beta|gamma|delta|epsilon|varepsilon|zeta|eta|theta|vartheta|'
  r'iota|kappa|lambda|mu|nu|xi|pi|varpi|rho|varrho|sigma|varsigma|'
  r'tau|upsilon|phi|varphi|chi|psi|omega|'
  r'Gamma|Delta|Theta|Lambda|Xi|Pi|Sigma|Upsilon|Phi|Psi|Omega|'
  r'hbar|ell|cdot|cdots|ldots|vdots|ddots|'
  r'times|div|pm|mp|oplus|otimes|'
  r'leq|le|geq|ge|neq|ne|approx|equiv|propto|sim|simeq|cong|'
  r'subset|supset|subseteq|supseteq|in|notin|cup|cap|setminus|emptyset|'
  r'forall|exists|neg|vec|hat|bar|tilde|dot|ddot|'
  r'overline|underline|widehat|widetilde|overbrace|underbrace|'
  r'overrightarrow|overleftarrow|'
  r'mathbf|mathbb|mathcal|mathrm|mathit|boldsymbol|'
  r'rightarrow|leftarrow|Rightarrow|Leftarrow|leftrightarrow|Leftrightarrow|'
  r'uparrow|downarrow|'
  r'sin|cos|tan|cot|sec|csc|arcsin|arccos|arctan|sinh|cosh|tanh|'
  r'log|ln|exp|det|ker|dim|gcd|min|max|sup|inf|arg)'
  r'(?=[^a-zA-Z]|$)',
);

// A LaTeX math run: \command followed by any combination of {args}, [args], _x, ^x.
// Supports 3 levels of brace nesting — handles \frac{\sqrt{x}}{y} and similar.
final _mathRunRe = RegExp(
  r'\\[a-zA-Z]+'
  r'(?:'
    r'\{[^{}]*(?:\{[^{}]*(?:\{[^{}]*\}[^{}]*)?\}[^{}]*)?\}'
    r'|\[[^\]]*\]'
    r'|[_^]\{[^{}]*(?:\{[^{}]*(?:\{[^{}]*\}[^{}]*)?\}[^{}]*)?\}'
    r'|[_^][a-zA-Z0-9]'
  r')*',
);

/// Returns true if [line] (already stripped of protected placeholders) is
/// entirely math — LaTeX command runs + operators/digits/single-letter vars,
/// with no English prose words of 3+ letters outside of LaTeX arguments.
bool _isPureMathParagraph(String line) {
  final trimmed = line.trim();
  if (trimmed.isEmpty) return false;
  if (!_unambiguousMathRe.hasMatch(trimmed)) return false;

  // Strip LaTeX runs, then check what's left for prose words.
  final stripped = trimmed
      .replaceAll(_mathRunRe, '')
      .replaceAll(RegExp(r'[\d+\-*/=<>()\[\]^_,.|;:!?\\\s{}]'), '');

  // Any remaining sequence of 3+ letters = prose word → not pure math.
  return !RegExp(r'[a-zA-Z]{3,}').hasMatch(stripped);
}

/// Wraps bare LaTeX command runs (backslash present, no \$ delimiter) in
/// \$...\$ (inline) or \$\$...\$\$ (display, when the whole paragraph is math).
String _wrapBareMathCommands(String text) {
  if (!_unambiguousMathRe.hasMatch(text)) return text;

  // Protect already-delimited regions.
  final prot = <String>[];
  var t = text.replaceAllMapped(
    RegExp(r'\$\$[\s\S]+?\$\$|\$[^$\n]+?\$'),
    (m) {
      final i = prot.length;
      prot.add(m.group(0)!);
      return '\x00P$i\x00';
    },
  );

  // Process paragraph by paragraph (double-newline boundaries).
  final paras = t.split(RegExp(r'\n{2,}'));
  final result = paras.map((para) {
    if (!_unambiguousMathRe.hasMatch(para)) return para;

    if (_isPureMathParagraph(para)) {
      // Whole paragraph is math → display block.
      return '\$\$${para.trim()}\$\$';
    }

    // Mixed paragraph: wrap each bare LaTeX run in \$...\$ individually.
    final buf = StringBuffer();
    var cursor = 0;
    for (final m in _mathRunRe.allMatches(para)) {
      if (m.start > cursor) buf.write(para.substring(cursor, m.start));
      buf.write('\$${m.group(0)!}\$');
      cursor = m.end;
    }
    if (cursor < para.length) buf.write(para.substring(cursor));
    return buf.toString();
  }).join('\n\n');

  // Restore protected regions.
  var out = result;
  for (var i = 0; i < prot.length; i++) {
    out = out.replaceFirst('\x00P$i\x00', prot[i]);
  }
  return out;
}

String normalizeMathInline(String text) {
  final normalizedText = text
      .replaceAll(RegExp(r'\\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n');
  final fenceRe = RegExp(r'```[\s\S]*?```', multiLine: true);
  if (!fenceRe.hasMatch(normalizedText)) {
    return _normalizeMathInlineChunk(normalizedText);
  }

  // Process non-fence segments; pass code fences through unchanged.
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

  // ── Pre-pass: fix common server-side AI formatting errors ────────────────

  // 1. Unicode square root → \sqrt{}: √6 → \sqrt{6}, √n → \sqrt{n}
  t = t.replaceAllMapped(
    RegExp(r'√\{([^}]+)\}'),
    (m) => '\\sqrt{${m.group(1)!}}',
  );
  t = t.replaceAllMapped(
    RegExp(r'√(\d+(?:\.\d+)?)'),
    (m) => '\\sqrt{${m.group(1)!}}',
  );
  t = t.replaceAllMapped(
    RegExp(r'√([a-zA-Z])'),
    (m) => '\\sqrt{${m.group(1)!}}',
  );

  // 2. Degree symbol → LaTeX: 75° → 75^\circ  (handle decimal too: 37.5°)
  t = t.replaceAllMapped(
    RegExp(r'(\d+(?:\.\d+)?)°'),
    (m) => '${m.group(1)!}^\\circ',
  );
  // Bare ° not following a digit (edge case: e.g. "° C")
  t = t.replaceAllMapped(
    RegExp(r'(?<!\d)°'),
    (_) => '^\\circ',
  );

  // 3a. ($A$+$B$)/n → $\frac{A+B}{n}$  (slash OUTSIDE closing paren)
  t = t.replaceAllMapped(
    RegExp(r'\(\$([^$\n]+)\$([+\-×·])\$([^$\n]+)\$\)\/(\d+)'),
    (m) =>
        '\$\\frac{${m.group(1)!}${m.group(2)!}${m.group(3)!}}{${m.group(4)!}}\$',
  );
  // 3b. ($A$)/n → $\frac{A}{n}$  (slash OUTSIDE closing paren)
  t = t.replaceAllMapped(
    RegExp(r'\(\$([^$\n]+)\$\)\/(\d+)'),
    (m) => '\$\\frac{${m.group(1)!}}{${m.group(2)!}}\$',
  );
  // 3c. ($A$/n) → $\frac{A}{n}$  (slash INSIDE closing paren — server style)
  t = t.replaceAllMapped(
    RegExp(r'\(\$([^$\n]+)\$\/(\d+)\)'),
    (m) => '\$\\frac{${m.group(1)!}}{${m.group(2)!}}\$',
  );

  // 4a. Bare trig/log INSIDE $…$: $sin(x)$ → $\sin(x)$
  t = t.replaceAllMapped(
    RegExp(
      r'\$((?:sin|cos|tan|cot|sec|csc|arcsin|arccos|arctan|sinh|cosh|tanh|log|ln)\()',
      caseSensitive: true,
    ),
    (m) => '\$\\${m.group(1)!}',
  );

  // 4b. Bare trig/log OUTSIDE any math delimiter (e.g. "sin(x) = 0.5")
  //     Add backslash so step 4 (_wrapBareMathCommands) picks it up later.
  t = _replaceOutsideMathDelimiters(
    t,
    RegExp(
      r'\b(sin|cos|tan|cot|sec|csc|arcsin|arccos|arctan|sinh|cosh|tanh|log|ln)\s*\(',
      caseSensitive: true,
    ),
    (m) => '\\${m.group(1)!}(',
  );

  // 4c. Ohm symbol Ω → \Omega outside math delimiters
  t = _replaceOutsideMathDelimiters(
    t,
    RegExp(r'(\d+(?:\.\d+)?)\s*Ω'),
    (m) => '\$${m.group(1)!}\\,\\Omega\$',
  );

  // 4d. Micro prefix µ → \mu
  t = t.replaceAll('µ', '\\mu ');

  // ── Step 1: Normalise alternate LaTeX delimiters → $...$ / $$...$$ ───────
  // \(...\) → $...$  (inline)
  t = t.replaceAllMapped(
    RegExp(r'\\\(([\s\S]*?)\\\)'),
    (m) => '\$${m.group(1)!}\$',
  );
  // \[...\] → $$...$$ when standalone, $...$ when embedded mid-sentence.
  final srcForCtx = t;
  t = t.replaceAllMapped(
    RegExp(r'\\\[([\s\S]*?)\\\]'),
    (m) {
      final content = m.group(1)!;
      final before = m.start > 0 ? srcForCtx[m.start - 1] : '\n';
      final after = m.end < srcForCtx.length ? srcForCtx[m.end] : '\n';
      final standalone = (before == '\n' || m.start == 0) &&
          (after == '\n' || m.end == srcForCtx.length);
      return standalone ? '\$\$$content\$\$' : '\$$content\$';
    },
  );

  // Step 2: Repair missing backslashes on common LaTeX command names written
  // as plain text (e.g. AI writes "frac" instead of "\frac").
  t = t.replaceAllMapped(
    RegExp(
      r'(^|[^A-Za-z\\])'
      r'(frac|dfrac|tfrac|sqrt|cdot|times|leq|geq|neq|pm|mp|approx|'
      r'alpha|beta|gamma|delta|theta|lambda|mu|pi|sigma|'
      r'lim|int|sum|prod|partial|infty|begin|end)'
      r'(?=[^A-Za-z]|$)',
    ),
    (m) => '${m.group(1)!}\\${m.group(2)!}',
  );

  // Step 3: Wrap bare \begin{env}...\end{env} not already delimited.
  t = t.replaceAllMapped(
    RegExp(
      r'(?<!\$)(\\begin\{[a-zA-Z*]+\}[\s\S]*?\\end\{[a-zA-Z*]+\})(?!\$)',
      multiLine: true,
    ),
    (m) => '\$\$${m.group(1)!}\$\$',
  );

  // Step 4: Wrap bare \command{args} runs not yet delimited.
  // This catches the most important failure mode: AI writes \frac{x}{y}
  // with backslash but without surrounding $...$.
  t = _wrapBareMathCommands(t);

  // Step 5: Wrap plain-text powers (x^2, a^3) not yet inside $...$.
  t = _replaceOutsideMathDelimiters(
    t,
    RegExp(r'[a-zA-Z0-9]\^[0-9]+'),
    (m) => '\$${m.group(0)!}\$',
  );

  // Step 6: Wrap plain-text subscripts/superscripts (a_1, x_{n+1}).
  t = _replaceOutsideMathDelimiters(
    t,
    RegExp(r'[a-zA-Z][a-zA-Z0-9]*\s*[_^]\s*(?:\{[^{}]+\}|[a-zA-Z0-9+\-]+)'),
    (m) => '\$${m.group(0)!}\$',
  );

  // Step 7: Wrap numeric-only fractions (1/2, 3/4).
  // Explicitly excludes unit fractions like m/s, km/h by requiring digits on both sides.
  t = _replaceOutsideMathDelimiters(
    t,
    RegExp(r'[0-9]+/[0-9]+'),
    (m) => '\$${m.group(0)!}\$',
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
  static const _devToken = String.fromEnvironment('CM_DEV_TOKEN');

  final BagrutRepository _bagrutRepo = BagrutRepository();

  /// The signed-in user's JWT, set by the session controller before each
  /// generation. WITHOUT this, /practice/generate was hit with no auth in
  /// production (CM_DEV_TOKEN is only set in dev) → 401 → the app silently
  /// fell back to the same local questions every time. Propagates to the
  /// bagrut repo too.
  String? _authToken;
  set authToken(String? t) {
    _authToken = t;
    _bagrutRepo.authToken = t;
  }

  String? get authToken => _authToken;

  /// Bearer token to send: the real session JWT when present, else the dev
  /// token (local dev only).
  String get _bearer {
    final t = (_authToken ?? '').trim();
    return t.isNotEmpty ? t : _devToken;
  }

  // Rolling list of recent question prompts per (subject+topic) key.
  // Sent to the server as context so it generates genuinely different questions.
  static final Map<String, List<String>> _recentPrompts = {};
  static const _maxRecentPrompts = 30;

  static String _recentKey(PracticeFilter f) =>
      '${f.subject}:${f.topicLabel}:${f.mode.name}';

  static List<String> _getRecent(PracticeFilter f) =>
      _recentPrompts[_recentKey(f)] ?? const [];

  static void _recordPrompts(PracticeFilter f, List<PracticeQuestion> qs) {
    final key = _recentKey(f);
    final list = _recentPrompts.putIfAbsent(key, () => []);
    for (final q in qs) {
      list.add(q.prompt);
    }
    if (list.length > _maxRecentPrompts) {
      list.removeRange(0, list.length - _maxRecentPrompts);
    }
  }

  Future<List<PracticeQuestion>> generate(PracticeFilter filter) async {
    if (filter.mode == PracticeMode.bagrut) {
      final bagrut = await _generateBagrutQuestion(filter);
      if (bagrut != null) return [bagrut];
      return generateFallback(filter);
    }

    final remote = await _generateFromApiWithRetry(filter);
    if (remote.isNotEmpty) {
      _recordPrompts(filter, remote);
      return remote;
    }

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

    // Offset by a random salt so the local fallback set isn't byte-identical
    // every session (it's only reached when the AI generator is unreachable).
    final salt = math.Random().nextInt(11);
    for (var i = 0; i < count; i++) {
      out.add(_localQuestion(filter, i + salt));
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
      // Routes live at the ROOT (there is NO /api prefix on the server —
      // /practice/generate is 401 with no auth, /api/practice/generate is
      // 404). Adding /api was a mistake that made every request 404 → silent
      // fallback. Post to the root base; auth is sent below.
      final base = Env.stripApiSuffix(Env.apiBaseUrl);
      final uri = Uri.parse('$base/practice/generate');
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
      final bearer = _bearer;
      if (bearer.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
      }

      final recent = _getRecent(filter);
      final payload = <String, Object?>{
        'subject': practiceSubjectAiName(filter.subject),
        if (filter.grade != null) 'grade': filter.grade,
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
        'sessionSeed': DateTime.now().millisecondsSinceEpoch,
        'strictPromptSummary': buildStrictPracticeFilterSection(filter),
        // Anti-repetition: tell the server which question prompts were already
        // shown so it generates genuinely new ones.
        if (recent.isNotEmpty) 'recentPrompts': recent,
      };

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

      if (res.statusCode < 200 || res.statusCode >= 300) {
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
    } catch (e) {
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

    // Math / algebra / arithmetic: generate a REAL computed question with a
    // correct answer + plausible distractors, so practice is usable even when
    // the AI generator is unreachable. Varies by index so a set isn't clones.
    if (_mentions(subject, const ['math', 'mathematics', 'algebra', 'arithmetic']) ||
        _mentions(topic, const [
          'algebra', 'arithmetic', 'equation', 'equations', 'linear',
          'solve', 'expression', 'expressions', 'evaluate'
        ])) {
      return _localAlgebraQuestion(filter, index);
    }

    // Generic last-resort fallback — only reached when the AI generator is
    // completely unreachable (offline / server down) for a non-math topic.
    // Route the student to NOVA for a real, topic-accurate walkthrough.
    // Honest and never looks broken.
    return PracticeQuestion(
      id: 'fallback-$index',
      subject: filter.subject,
      topicLabel: filter.topicLabel,
      mode: filter.mode,
      difficulty: filter.difficulty,
      prompt:
          'Practice a ${filter.difficulty.name} ${filter.subject} question on ${filter.topicLabel}.',
      options: const [
        'Open with NOVA',
        'Show a worked solution',
        'Save for later',
        'End session',
      ],
      correctIndex: 0,
      explanation:
          'We could not reach the question generator just now. Open this topic with NOVA for a full step-by-step walkthrough, then try Practice again when you are back online.',
      recommendedTimeSeconds: filter.timePreferenceSeconds ?? 30,
    );
  }

  /// Real, computed math MCQ used as an offline/AI-unavailable fallback for
  /// math/algebra/arithmetic topics. Produces a correct answer with three
  /// plausible distractors, varied by [index] so a set isn't repetitive.
  PracticeQuestion _localAlgebraQuestion(PracticeFilter filter, int index) {
    final hard = filter.difficulty == PracticeDifficulty.hard ||
        filter.difficulty == PracticeDifficulty.olympiad;
    final scale = hard ? 9 : 4;
    final type = index % 3;
    final a = 2 + (index % scale);
    final b = 1 + ((index * 3) % scale);
    final x = 1 + ((index * 2) % scale);

    String prompt;
    int answer;
    String explanation;
    switch (type) {
      case 0: // solve a*x + b = c for x
        final c = a * x + b;
        prompt = 'Solve for x:  \$$a x + $b = $c\$';
        answer = x;
        explanation = '\$$a x = $c - $b = ${c - b}\$, so \$x = ${c - b} \\div $a = $x\$.';
        break;
      case 1: // evaluate a*x + b
        prompt = 'Evaluate \$$a x + $b\$ when \$x = $x\$.';
        answer = a * x + b;
        explanation = '\$$a \\times $x + $b = ${a * x} + $b = ${a * x + b}\$.';
        break;
      default: // simplify a(x + b) at x
        prompt = 'Expand and evaluate \$$a(x + $b)\$ when \$x = $x\$.';
        answer = a * (x + b);
        explanation = '\$$a(x + $b) = $a x + ${a * b}\$; at \$x=$x\$: \$${a * x} + ${a * b} = ${a * (x + b)}\$.';
        break;
    }

    // Build 4 distinct options with the correct answer at a rotating slot.
    final correctIndex = index % 4;
    final distractors = <int>{answer + 1, answer - 1, answer + a, answer - b, answer + 2}
        .where((v) => v != answer)
        .toList();
    final options = <String>[];
    var d = 0;
    for (var i = 0; i < 4; i++) {
      if (i == correctIndex) {
        options.add('$answer');
      } else {
        options.add('${distractors[d % distractors.length]}');
        d++;
      }
    }

    return PracticeQuestion(
      id: 'fallback-algebra-$index',
      subject: filter.subject,
      topicLabel: filter.topicLabel,
      mode: filter.mode,
      difficulty: filter.difficulty,
      prompt: prompt,
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
      recommendedTimeSeconds: filter.timePreferenceSeconds ?? (hard ? 60 : 40),
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
