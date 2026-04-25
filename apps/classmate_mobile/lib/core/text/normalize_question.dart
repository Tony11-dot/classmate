String normalizeQuestionText(String input) {
  var s = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  s = s.replaceAllMapped(RegExp(r'(?<!\n)\n(?!\n)'), (_) => ' ');
  s = s.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
  return s.trim();
}

const _latexCommandAlternation =
  'frac|sqrt|sum|prod|int|oint|lim|inf|sup|alpha|beta|gamma|delta|epsilon|zeta|eta|theta|iota|kappa|lambda|mu|nu|xi|pi|rho|sigma|tau|upsilon|phi|chi|psi|omega|Alpha|Beta|Gamma|Delta|Epsilon|Zeta|Eta|Theta|Iota|Kappa|Lambda|Mu|Nu|Xi|Pi|Rho|Sigma|Tau|Upsilon|Phi|Chi|Psi|Omega|partial|nabla|infty|cdot|times|div|pm|mp|leq|geq|neq|approx|equiv|propto|sim|simeq|subset|supset|in|notin|cup|cap|emptyset|forall|exists|neg|wedge|vee|oplus|otimes|circ|bullet|vec|hat|bar|tilde|dot|ddot|overline|underline|overleftarrow|overrightarrow|mathbf|mathrm|mathit|mathbb|mathcal|text|big|Big|bigg|Bigg|begin|end|pmatrix|bmatrix|vmatrix|cases|ldots|cdots|vdots|ddots|to|rightarrow|leftarrow|Rightarrow|Leftarrow|leftrightarrow|Leftrightarrow|sin|cos|tan|cot|sec|csc|arcsin|arccos|arctan|sinh|cosh|tanh|log|ln|exp|det|dim|ker|mod|max|min|gcd|lcm|deg';

// For auto-prefixing bare commands: excludes common English words that collide
// with LaTeX command names, to prevent prose like "x is in the set" from
// becoming "x is \in the set" (→ ∈ symbol).
final _latexAutoPrefixAlternation = _latexCommandAlternation
    .split('|')
    .where((cmd) => !const {
      'to',  // \to → →
      'text', 'mod', 'dim', 'ker', 'deg',
      'in',  // \in → ∈
      'inf', // \inf → infimum
      'sup', // \sup → supremum
      'exp', // \exp → e^x
      'det', // \det → det()
      'max', 'min', 'log', 'gcd', 'lcm',
    }.contains(cmd))
    .join('|');

final RegExp _renderableCodeFenceRe = RegExp(
  r'(```|~~~)[^\n]*\n[\s\S]*?\1',
  multiLine: true,
);

final RegExp _bareLatexRe = RegExp(
  r'(?<![\\$])\\(' + _latexCommandAlternation + r')(?=[^a-zA-Z]|$)',
);

final RegExp _inlineCodeQuestionTailRe = RegExp(
  r'^(.+?\?)\s+(.+)$',
  dotAll: true,
);

String prepareRenderableText(String input) {
  final normalized = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  if (!_renderableCodeFenceRe.hasMatch(normalized)) {
    return _prepareRenderableChunk(normalized);
  }

  final out = StringBuffer();
  var cursor = 0;
  for (final match in _renderableCodeFenceRe.allMatches(normalized)) {
    if (match.start > cursor) {
      out.write(_prepareRenderableChunk(normalized.substring(cursor, match.start)));
    }
    out.write(match.group(0)!);
    cursor = match.end;
  }
  if (cursor < normalized.length) {
    out.write(_prepareRenderableChunk(normalized.substring(cursor)));
  }
  return out.toString();
}

String _prepareRenderableChunk(String input) {
  // Step 1: normalize prose connectors (-> to "to", etc.)
  // math regions are protected inside this call
  var text = _normalizeProseConnectors(_maybeFenceInlineCodeTail(input));

  // Step 2: wrap bare \begin{env}...\end{env} blocks that aren't inside \[...\]
  text = _wrapBareEnvironments(text);

  final containsBareLatex = _bareLatexRe.hasMatch(text);

  text = text.replaceAllMapped(RegExp(r'\\([.,!?;:])'), (m) => m.group(1) ?? '');
  // Remove lone backslash before whitespace, but NOT the second \ in LaTeX \\
  // line-breaks (e.g. inside \begin{cases}...\end{cases}).
  text = text.replaceAllMapped(RegExp(r'(?<!\\)\\(?=\s)'), (_) => '');

  text = text.replaceAllMapped(
    RegExp(r'\\\(([^\n]+?)\\\)'),
    (m) => 'INLINE_OPEN${m.group(1) ?? ''}INLINE_CLOSE',
  );
  text = text.replaceAllMapped(
    RegExp(r'\\\[([\s\S]*?)\\\]'),
    (m) => 'BLOCK_OPEN${m.group(1) ?? ''}BLOCK_CLOSE',
  );

  // Only auto-prefix bare LaTeX command names when the text already contains
  // real LaTeX markers — otherwise common English words like "to", "sin",
  // "max" get silently rewritten to \to, \sin, \max and rendered as symbols.
  if (containsBareLatex) {
    text = text.replaceAllMapped(
      RegExp(r'(^|[^A-Za-z\\])(' + _latexAutoPrefixAlternation + r')(?=[^A-Za-z]|$)'),
      (m) => '${m.group(1) ?? ''}\\${m.group(2) ?? ''}',
    );
  }

  text = _autoWrapBareLatex(text);
  text = _mergeInlineMathRuns(text);

  if (!containsBareLatex) {
    // Protect existing math regions so the x^2 / fraction auto-wraps don't
    // inject $...$ markers *inside* an already-delimited math span.
    // Without this, $\frac{x^2 + 1}{2}$ becomes $\frac{$x^2$ + 1}{2}$ — broken.
    final autoProtected = <String>[];
    void autoProtect(RegExp re) {
      text = text.replaceAllMapped(re, (m) {
        final idx = autoProtected.length;
        autoProtected.add(m.group(0)!);
        return '\x02AP$idx\x02';
      });
    }
    autoProtect(RegExp(r'INLINE_OPEN[\s\S]*?INLINE_CLOSE'));
    autoProtect(RegExp(r'BLOCK_OPEN[\s\S]*?BLOCK_CLOSE'));
    autoProtect(RegExp(r'\$\$[\s\S]+?\$\$'));
    autoProtect(RegExp(r'\$[^$\n]+?\$'));

    text = text.replaceAllMapped(
      RegExp(r'(?<![$\\])([a-zA-Z0-9]+\^[0-9]+)(?![$\\])'),
      (m) => 'INLINE_OPEN${m.group(1) ?? ''}INLINE_CLOSE',
    );

    // Only wrap numeric-only fractions (e.g. 2/3, 7/8). Units like m/s, km/h
    // and English slash-phrases like "and/or" must NOT be wrapped — doing so
    // changes their font and removes spaces in surrounding sentences.
    text = text.replaceAllMapped(
      RegExp(r'(?<![/$\\a-zA-Z])([0-9]+/[0-9]+)(?![/$\\a-zA-Z])'),
      (m) => 'INLINE_OPEN${m.group(1) ?? ''}INLINE_CLOSE',
    );

    // Restore protected regions
    for (var i = 0; i < autoProtected.length; i++) {
      text = text.replaceFirst('\x02AP$i\x02', autoProtected[i]);
    }
  }

  return text
      .replaceAll('BLOCK_OPEN', r'$$')
      .replaceAll('BLOCK_CLOSE', r'$$')
      .replaceAll('INLINE_OPEN', r'$')
      .replaceAll('INLINE_CLOSE', r'$');
}

// ── Bare environment wrapping ─────────────────────────────────────────────────

/// Wraps `\begin{env}...\end{env}` blocks not already inside `\[...\]` or `$$`
/// in proper `\[...\]` delimiters so the LaTeX renderer can handle them.
String _wrapBareEnvironments(String text) {
  // Protect already-delimited regions so we don't double-wrap
  final protected = <String>[];
  var t = text.replaceAllMapped(
    RegExp(r'\$\$[\s\S]+?\$\$|\\\[[\s\S]*?\\\]|\\\([^\n]*?\\\)|\$[^$\n]+?\$'),
    (m) {
      final idx = protected.length;
      protected.add(m.group(0)!);
      return '\x00ENV$idx\x00';
    },
  );

  // Wrap bare \begin{env}...\end{env}
  t = t.replaceAllMapped(
    RegExp(r'\\begin(\{[a-zA-Z*]+\}[\s\S]*?\\end\{[a-zA-Z*]+\})'),
    (m) => r'\[' '\begin${m.group(1)!}' r'\]',
  );

  // Restore protected regions
  for (var i = 0; i < protected.length; i++) {
    t = t.replaceFirst('\x00ENV$i\x00', protected[i]);
  }
  return t;
}

// ── Prose connector normalization ─────────────────────────────────────────────

String _normalizeProseConnectors(String input) {
  var text = input;

  // Protect inline code spans AND math regions before any substitution
  final placeholders = <String>[];

  void protectPattern(RegExp re) {
    text = text.replaceAllMapped(re, (m) {
      final idx = placeholders.length;
      placeholders.add(m.group(0)!);
      return '\x00PROT$idx\x00';
    });
  }

  protectPattern(RegExp(r'`[^`\n]+`'));             // `inline code`
  protectPattern(RegExp(r'\$\$[\s\S]+?\$\$'));      // $$block math$$
  protectPattern(RegExp(r'\$[^$\n]+?\$'));           // $inline math$
  protectPattern(RegExp(r'\\\[[\s\S]*?\\\]'));       // \[...\]
  protectPattern(RegExp(r'\\\([^\n]*?\\\)'));        // \(...\)

  // Arrow connectors → "to" (covers -> => → ⇒ used as prose connectors)
  text = text.replaceAllMapped(
    RegExp(r'(?<=\w)\s*(?:->|=>|→|⇒)\s*(?=\w)'),
    (_) => ' to ',
  );
  text = text.replaceAllMapped(
    RegExp(r'(^|\n)[ \t]*(?:->|=>|→|⇒)[ \t]+'),
    (m) => '${m.group(1) ?? ''}\u2022 ',
  );
  text = text.replaceAllMapped(
    RegExp(r'\s*(?:->|→|⇒|=>)\s*'),
    (_) => ' to ',
  );

  // Restore protected spans
  for (var i = 0; i < placeholders.length; i++) {
    text = text.replaceFirst('\x00PROT$i\x00', placeholders[i]);
  }

  return text;
}

// ── LaTeX auto-wrap helpers ───────────────────────────────────────────────────

String _autoWrapBareLatex(String src) {
  if (!_bareLatexRe.hasMatch(src)) return src;

  // Protect already-delimited regions (including BLOCK/INLINE placeholders
  // that have already been substituted for \[...\] and \(...\)).
  final delimRe = RegExp(
    r'BLOCK_OPEN[\s\S]*?BLOCK_CLOSE'
    r'|INLINE_OPEN[^\n]*?INLINE_CLOSE'
    r'|\$\$[\s\S]+?\$\$'
    r'|\$[^$\n]+?\$'
    r'|\\\[[\s\S]+?\\\]'
    r'|\\\(.+?\\\)',
  );

  final out = StringBuffer();
  var cursor = 0;
  for (final match in delimRe.allMatches(src)) {
    if (match.start > cursor) {
      out.write(_wrapBareInChunk(src.substring(cursor, match.start)));
    }
    out.write(match.group(0)!);
    cursor = match.end;
  }
  if (cursor < src.length) {
    out.write(_wrapBareInChunk(src.substring(cursor)));
  }
  return out.toString();
}

String _wrapBareInChunk(String chunk) {
  if (!_bareLatexRe.hasMatch(chunk)) return chunk;

  final runRe = RegExp(
    r'\\[a-zA-Z]+(?:\{[^{}]*(?:\{[^{}]*\}[^{}]*)?\}|\[[^\]]*\]|[_^]\{[^{}]*\}|[_^][a-zA-Z0-9]|\s*)*',
  );

  final out = StringBuffer();
  var cursor = 0;
  for (final match in runRe.allMatches(chunk)) {
    if (match.start > cursor) out.write(chunk.substring(cursor, match.start));
    final rawRun = match.group(0)!;
    final run = rawRun.trimRight();
    final trailing = rawRun.substring(run.length);
    out.write(r'$' + run + r'$' + trailing);
    cursor = match.end;
  }
  if (cursor < chunk.length) out.write(chunk.substring(cursor));
  return out.toString();
}

// ── Inline code tail fencing ──────────────────────────────────────────────────

String _maybeFenceInlineCodeTail(String input) {
  if (input.contains('```') || input.contains('~~~')) return input;

  final match = _inlineCodeQuestionTailRe.firstMatch(input.trim());
  if (match == null) return input;

  final stem = (match.group(1) ?? '').trim();
  final tail = (match.group(2) ?? '').trim();
  if (!_looksLikeInlineCodeTail(tail)) return input;

  final formatted = _formatInlineCodeTail(tail);
  if (formatted.isEmpty) return input;

  final language = _inferInlineCodeLanguage(tail);
  final fence = language.isEmpty ? '```' : '```$language';

  return '$stem\n\n$fence\n$formatted\n```';
}

bool _looksLikeInlineCodeTail(String tail) {
  if (!tail.contains('(') || !tail.contains(')')) return false;
  if (!tail.contains(';') && !tail.contains('{') && !tail.contains('}')) {
    return false;
  }

  return RegExp(
    r'\b(if|else|for|while|switch|case|return|print|console\.log|System\.out\.println|int|double|float|bool|boolean|String|var|const|let|def|function|class)\b',
    caseSensitive: false,
  ).hasMatch(tail);
}

String _formatInlineCodeTail(String code) {
  var formatted = code.trim();
  formatted = formatted.replaceAllMapped(RegExp(r';\s*'), (_) => ';\n');
  formatted = formatted.replaceAllMapped(
    RegExp(r'\s+else if\s+', caseSensitive: false),
    (_) => '\nelse if ',
  );
  formatted = formatted.replaceAllMapped(
    RegExp(r'\s+else\s+', caseSensitive: false),
    (_) => '\nelse ',
  );
  formatted = formatted.replaceAllMapped(
    RegExp(
      r'^(if|else if)\s*(\([^\n]+?\))\s+([^{}\n].*;)$',
      caseSensitive: false,
      multiLine: true,
    ),
    (m) => '${m.group(1)} ${m.group(2)}\n  ${(m.group(3) ?? '').trim()}',
  );
  formatted = formatted.replaceAllMapped(
    RegExp(
      r'^else\s+([^{}\n].*;)$',
      caseSensitive: false,
      multiLine: true,
    ),
    (m) => 'else\n  ${(m.group(1) ?? '').trim()}',
  );
  formatted = formatted.replaceAllMapped(
    RegExp(r'\s*(\{)\s*'),
    (_) => ' {\n',
  );
  formatted = formatted.replaceAllMapped(
    RegExp(r'\s*(\})\s*'),
    (_) => '\n}\n',
  );
  formatted = formatted.replaceAllMapped(RegExp(r'\n{3,}'), (_) => '\n\n');
  return formatted.trim();
}

String _inferInlineCodeLanguage(String code) {
  final lower = code.toLowerCase();
  if (lower.contains('console.log')) return 'javascript';
  if (lower.contains('system.out.println')) return 'java';
  if (lower.contains('print(')) return 'dart';
  return '';
}

// ── Inline math merging ───────────────────────────────────────────────────────

String _mergeInlineMathRuns(String input) {
  var out = input;
  final adjacentRe = RegExp(r'\$([^$\n]+)\$\s+\$([^$\n]+)\$');
  while (adjacentRe.hasMatch(out)) {
    out = out.replaceAllMapped(
      adjacentRe,
      (m) => 'MATH_OPEN${_joinInlineMathRuns(m.group(1) ?? '', m.group(2) ?? '')}MATH_CLOSE',
    );
  }

  final limitTargetRe = RegExp(
    r'\$((?:\\lim|\\sum|\\prod|\\int|\\oint)[^$\n]*)\$\s+([A-Za-z][A-Za-z0-9]*\([^\n)]*\)|[A-Za-z][A-Za-z0-9]*)',
  );
  while (limitTargetRe.hasMatch(out)) {
    out = out.replaceAllMapped(
      limitTargetRe,
      (m) => 'MATH_OPEN${m.group(1)} ${m.group(2)}MATH_CLOSE',
    );
  }

  return out
      .replaceAll('MATH_OPEN', r'$')
      .replaceAll('MATH_CLOSE', r'$');
}

String _joinInlineMathRuns(String left, String right) {
  final lhs = left.trimRight();
  final rhs = right.trimLeft();
  if (lhs.isEmpty) return rhs;
  if (rhs.isEmpty) return lhs;

  final leftEndsWithCommand = RegExp(r'\\[A-Za-z]+$').hasMatch(lhs);
  final rightStartsWithCommand = RegExp(r'^\\[A-Za-z]+').hasMatch(rhs);
  final leftEndsTight = RegExp(r'[({\[_^]$').hasMatch(lhs);
  final rightStartsTight = RegExp(r'^[)}\]_^,.;:]').hasMatch(rhs);

  if (leftEndsWithCommand || rightStartsWithCommand || leftEndsTight || rightStartsTight) {
    return '$lhs$rhs';
  }

  return '$lhs $rhs';
}
