/// Cleans up plain text for rendering inside MathView or plain text widgets.
/// Preserves intentional line breaks — does NOT convert single newlines to
/// spaces, because step-by-step explanations need those breaks.
String normalizeQuestionText(String input) {
  var s = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  // Collapse 4+ consecutive newlines to a paragraph break.
  s = s.replaceAll(RegExp(r'\n{4,}'), '\n\n\n');
  // Collapse 3 consecutive newlines to two.
  s = s.replaceAll(RegExp(r'\n{3}'), '\n\n');
  // Remove trailing whitespace on each line.
  s = s.split('\n').map((line) => line.trimRight()).join('\n');
  // Collapse multiple inline spaces (but not newlines).
  s = s.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
  return s.trim();
}

final RegExp _renderableCodeFenceRe = RegExp(
  r'(```|~~~)[^\n]*\n[\s\S]*?\1',
  multiLine: true,
);

// Unambiguous math commands — can ONLY appear in LaTeX, never in plain prose.
final _unambiguousMathRe = RegExp(
  r'(?<![\\$a-zA-Z])\\'
  r'(?:frac|dfrac|tfrac|cfrac|sqrt|int|oint|iint|iiint|sum|prod|coprod|'
  r'lim|limsup|liminf|partial|nabla|infty|binom|tbinom|dbinom|'
  r'alpha|beta|gamma|delta|epsilon|varepsilon|zeta|eta|theta|vartheta|'
  r'iota|kappa|lambda|mu|nu|xi|pi|rho|sigma|varsigma|tau|upsilon|'
  r'phi|varphi|chi|psi|omega|'
  r'Gamma|Delta|Theta|Lambda|Xi|Pi|Sigma|Upsilon|Phi|Psi|Omega|'
  r'hbar|ell|cdot|cdots|ldots|vdots|ddots|'
  r'times|div|pm|mp|oplus|otimes|'
  r'leq|le|geq|ge|neq|ne|approx|equiv|propto|sim|simeq|cong|'
  r'subset|supset|subseteq|supseteq|in|notin|cup|cap|setminus|emptyset|'
  r'forall|exists|neg|vec|hat|bar|tilde|dot|ddot|'
  r'overline|underline|widehat|widetilde|overbrace|underbrace|'
  r'overrightarrow|overleftarrow|'
  r'mathbf|mathbb|mathcal|mathrm|mathit|boldsymbol|text|'
  r'rightarrow|leftarrow|Rightarrow|Leftarrow|leftrightarrow|Leftrightarrow|'
  r'uparrow|downarrow|'
  r'sin|cos|tan|cot|sec|csc|arcsin|arccos|arctan|sinh|cosh|tanh|'
  r'log|ln|exp|det|ker|dim|gcd|min|max|sup|inf|arg)'
  r'(?=[^a-zA-Z]|$)',
);

// LaTeX math run: \command + any {args}, [args], subscripts, superscripts.
final _mathRunRe = RegExp(
  r'\\[a-zA-Z]+'
  r'(?:'
    r'\{[^{}]*(?:\{[^{}]*(?:\{[^{}]*\}[^{}]*)?\}[^{}]*)?\}'
    r'|\[[^\]]*\]'
    r'|[_^]\{[^{}]*(?:\{[^{}]*(?:\{[^{}]*\}[^{}]*)?\}[^{}]*)?\}'
    r'|[_^][a-zA-Z0-9]'
  r')*',
);

/// Converts Unicode math symbols to their LaTeX equivalents.
/// Called on raw math content (without surrounding delimiters).
String sanitizeMathLatex(String math) {
  var s = math;

  // Convert bare numeric fractions written with / to \frac{}{}.
  // e.g.  3/4  →  \frac{3}{4}   (only when both sides are pure digits)
  s = s.replaceAllMapped(
    RegExp(r'(?<![\\{])\b(\d+)\s*/\s*(\d+)\b(?![}])'),
    (m) => '\\frac{${m.group(1)!}}{${m.group(2)!}}',
  );

  // Degree symbol: 75° → 75^\circ  (must come before bare ° replacement)
  s = s.replaceAllMapped(RegExp(r'(\d+(?:\.\d+)?)°'), (m) => '${m.group(1)!}^\\circ');
  // Bare ° not following a digit (rare edge case)
  s = s.replaceAllMapped(RegExp(r'(?<!\d)°'), (_) => '^\\circ');

  // Square root: √6 → \sqrt{6}, √{x} → \sqrt{x}, √n → \sqrt{n}
  s = s.replaceAllMapped(RegExp(r'√\{([^}]+)\}'), (m) => '\\sqrt{${m.group(1)!}}');
  s = s.replaceAllMapped(RegExp(r'√(\d+(?:\.\d+)?)'), (m) => '\\sqrt{${m.group(1)!}}');
  s = s.replaceAllMapped(RegExp(r'√([a-zA-Z])'), (m) => '\\sqrt{${m.group(1)!}}');

  // Arithmetic & algebra
  s = s.replaceAll('×', '\\times ');
  s = s.replaceAll('÷', '\\div ');
  s = s.replaceAll('·', '\\cdot ');
  s = s.replaceAll('⋅', '\\cdot ');
  s = s.replaceAll('±', '\\pm ');
  s = s.replaceAll('∓', '\\mp ');

  // Comparison
  s = s.replaceAll('≤', '\\le ');
  s = s.replaceAll('≥', '\\ge ');
  s = s.replaceAll('≠', '\\ne ');
  s = s.replaceAll('≈', '\\approx ');
  s = s.replaceAll('≡', '\\equiv ');
  s = s.replaceAll('≃', '\\simeq ');
  s = s.replaceAll('≅', '\\cong ');
  s = s.replaceAll('∼', '\\sim ');
  s = s.replaceAll('∝', '\\propto ');

  // Set / logic
  s = s.replaceAll('∈', '\\in ');
  s = s.replaceAll('∉', '\\notin ');
  s = s.replaceAll('⊂', '\\subset ');
  s = s.replaceAll('⊃', '\\supset ');
  s = s.replaceAll('⊆', '\\subseteq ');
  s = s.replaceAll('⊇', '\\supseteq ');
  s = s.replaceAll('∪', '\\cup ');
  s = s.replaceAll('∩', '\\cap ');
  s = s.replaceAll('∅', '\\emptyset ');
  s = s.replaceAll('∀', '\\forall ');
  s = s.replaceAll('∃', '\\exists ');
  s = s.replaceAll('¬', '\\neg ');
  s = s.replaceAll('∧', '\\land ');
  s = s.replaceAll('∨', '\\lor ');

  // Calculus / analysis
  s = s.replaceAll('∫', '\\int ');
  s = s.replaceAll('∮', '\\oint ');
  s = s.replaceAll('∂', '\\partial ');
  s = s.replaceAll('∇', '\\nabla ');
  s = s.replaceAll('∞', '\\infty ');
  s = s.replaceAll('Σ', '\\Sigma ');
  s = s.replaceAll('Π', '\\Pi ');

  // Arrows
  s = s.replaceAll('→', '\\rightarrow ');
  s = s.replaceAll('←', '\\leftarrow ');
  s = s.replaceAll('↔', '\\leftrightarrow ');
  s = s.replaceAll('⇒', '\\Rightarrow ');
  s = s.replaceAll('⇐', '\\Leftarrow ');
  s = s.replaceAll('⇔', '\\Leftrightarrow ');
  s = s.replaceAll('↑', '\\uparrow ');
  s = s.replaceAll('↓', '\\downarrow ');

  // Greek lowercase
  s = s.replaceAll('α', '\\alpha ');
  s = s.replaceAll('β', '\\beta ');
  s = s.replaceAll('γ', '\\gamma ');
  s = s.replaceAll('δ', '\\delta ');
  s = s.replaceAll('ε', '\\varepsilon ');
  s = s.replaceAll('ζ', '\\zeta ');
  s = s.replaceAll('η', '\\eta ');
  s = s.replaceAll('θ', '\\theta ');
  s = s.replaceAll('ι', '\\iota ');
  s = s.replaceAll('κ', '\\kappa ');
  s = s.replaceAll('λ', '\\lambda ');
  s = s.replaceAll('μ', '\\mu ');
  s = s.replaceAll('ν', '\\nu ');
  s = s.replaceAll('ξ', '\\xi ');
  s = s.replaceAll('π', '\\pi ');
  s = s.replaceAll('ρ', '\\rho ');
  s = s.replaceAll('σ', '\\sigma ');
  s = s.replaceAll('τ', '\\tau ');
  s = s.replaceAll('υ', '\\upsilon ');
  s = s.replaceAll('φ', '\\phi ');
  s = s.replaceAll('χ', '\\chi ');
  s = s.replaceAll('ψ', '\\psi ');
  s = s.replaceAll('ω', '\\omega ');

  // Greek uppercase (Σ and Π handled above for sum/product context)
  s = s.replaceAll('Γ', '\\Gamma ');
  s = s.replaceAll('Δ', '\\Delta ');
  s = s.replaceAll('Θ', '\\Theta ');
  s = s.replaceAll('Λ', '\\Lambda ');
  s = s.replaceAll('Ξ', '\\Xi ');
  s = s.replaceAll('Υ', '\\Upsilon ');
  s = s.replaceAll('Φ', '\\Phi ');
  s = s.replaceAll('Ψ', '\\Psi ');
  s = s.replaceAll('Ω', '\\Omega ');

  // Number sets
  s = s.replaceAll('ℝ', '\\mathbb{R}');
  s = s.replaceAll('ℤ', '\\mathbb{Z}');
  s = s.replaceAll('ℕ', '\\mathbb{N}');
  s = s.replaceAll('ℚ', '\\mathbb{Q}');
  s = s.replaceAll('ℂ', '\\mathbb{C}');
  s = s.replaceAll('ℏ', '\\hbar ');

  // Misc
  s = s.replaceAll('…', '\\ldots ');
  s = s.replaceAll('‖', '\\|');

  // Ohm symbol (electronics)
  s = s.replaceAll('Ω', '\\Omega ');
  // Micro prefix
  s = s.replaceAll('µ', '\\mu ');

  return s;
}

/// Applies [fn] to the content inside every \$...\$ and \$\$...\$\$ region.
String applyToMathRegions(String text, String Function(String) fn) {
  final mathRe = RegExp(r'\$\$([\s\S]+?)\$\$|\$([^$\n]+?)\$');
  final out = StringBuffer();
  var cursor = 0;
  for (final m in mathRe.allMatches(text)) {
    if (m.start > cursor) out.write(text.substring(cursor, m.start));
    if (m.group(1) != null) {
      out.write('\$\$${fn(m.group(1)!)}\$\$');
    } else {
      out.write('\$${fn(m.group(2)!)}\$');
    }
    cursor = m.end;
  }
  if (cursor < text.length) out.write(text.substring(cursor));
  return out.toString();
}

/// Normalises LaTeX delimiters and wraps bare LaTeX as a safety net.
/// Run order matters — delimiter normalisation first, then bare-command wrapping.
String prepareRenderableText(String input) {
  var text = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  // Collapse 3+ newlines to 2 (one paragraph break max — prevents walls of whitespace).
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

  // Protect code fences — never touch LaTeX inside ``` blocks.
  final fences = <String>[];
  text = text.replaceAllMapped(_renderableCodeFenceRe, (m) {
    final idx = fences.length;
    fences.add(m.group(0)!);
    return '\x00F$idx\x00';
  });

  // \[...\] → $$...$$ when standalone on its own line (display math)
  //         → $...$  when mid-sentence (inline math)
  final sourceForContext = text;
  text = text.replaceAllMapped(
    RegExp(r'\\\[([\s\S]*?)\\\]'),
    (m) {
      final content = m.group(1)!;
      final charBefore = m.start > 0 ? sourceForContext[m.start - 1] : '\n';
      final charAfter =
          m.end < sourceForContext.length ? sourceForContext[m.end] : '\n';
      final standaloneLeft =
          charBefore == '\n' || charBefore == ' ' && m.start <= 1 || m.start == 0;
      final standaloneRight =
          charAfter == '\n' || m.end == sourceForContext.length;
      return (standaloneLeft && standaloneRight)
          ? '\$\$$content\$\$'
          : '\$$content\$';
    },
  );

  // \(...\) → $...$  (inline math)
  text = text.replaceAllMapped(
    RegExp(r'\\\((.+?)\\\)', dotAll: true),
    (m) => '\$${m.group(1)!}\$',
  );

  // Fallback for MALFORMED LaTeX (a common model glitch): an opening delimiter
  // with no matching close. Paired delimiters were already consumed above, so
  // any remaining `\[` / `\(` is unmatched — wrap it to end-of-line so it still
  // renders as math instead of leaking raw "\[" / "\(" into the UI.
  text = text.replaceAllMapped(
    RegExp(r'\\\[([^\n]*)$', multiLine: true),
    (m) => '\$\$${m.group(1)!}\$\$',
  );
  text = text.replaceAllMapped(
    RegExp(r'\\\(([^\n]*)$', multiLine: true),
    (m) => '\$${m.group(1)!}\$',
  );

  // Wrap bare \begin{env}...\end{env} not already inside delimiters.
  text = _wrapBareEnvironments(text);

  // Safety net: wrap any remaining bare \command{args} outside delimiters.
  text = _wrapBareMathCommands(text);

  // Sanitize Unicode math symbols inside all math regions.
  text = applyToMathRegions(text, sanitizeMathLatex);

  // Remove blank lines that were inserted directly before/after inline math.
  // (Inline math must not create paragraph breaks.)
  text = _removeBlankLinesAroundInlineMath(text);

  // Also collapse blank lines immediately adjacent to display math. The
  // block parser still treats `$$...$$` as its own block — keeping the
  // surrounding newlines just adds visible empty lines above/below the
  // formula. One newline on each side is enough to delimit the block.
  text = text.replaceAllMapped(
    RegExp(r'\n{2,}(\$\$[\s\S]+?\$\$)'),
    (m) => '\n${m.group(1)!}',
  );
  text = text.replaceAllMapped(
    RegExp(r'(\$\$[\s\S]+?\$\$)\n{2,}'),
    (m) => '${m.group(1)!}\n',
  );

  // Restore code fences.
  for (var i = 0; i < fences.length; i++) {
    text = text.replaceFirst('\x00F$i\x00', fences[i]);
  }

  return text;
}

/// Removes stray blank lines that appear immediately before/after an inline
/// \$...\$ span (not \$\$...\$\$). These cause inline math to become a
/// paragraph, which breaks rendering.
String _removeBlankLinesAroundInlineMath(String text) {
  // Collapse blank line immediately before an inline-math-only line.
  text = text.replaceAllMapped(
    RegExp(r'\n\n(\$(?!\$)[^$\n]+?\$)\n\n'),
    (m) => ' ${m.group(1)!} ',
  );
  return text;
}

/// Wraps `\begin{env}...\end{env}` not already inside $$...$$ in `$$...$$`.
String _wrapBareEnvironments(String text) {
  final protected = <String>[];
  var t = text.replaceAllMapped(
    RegExp(r'\$\$[\s\S]+?\$\$|\$[^$\n]+?\$'),
    (m) {
      final idx = protected.length;
      protected.add(m.group(0)!);
      return '\x00ENV$idx\x00';
    },
  );

  t = t.replaceAllMapped(
    RegExp(r'\\begin(\{[a-zA-Z*]+\}[\s\S]*?\\end\{[a-zA-Z*]+\})'),
    (m) => '\$\$\\begin${m.group(1)!}\$\$',
  );

  for (var i = 0; i < protected.length; i++) {
    t = t.replaceFirst('\x00ENV$i\x00', protected[i]);
  }
  return t;
}

/// Safety-net wrapper for bare \command{args} runs outside delimiters.
/// Conservative: only wraps when a paragraph contains LaTeX math commands.
/// A paragraph is treated as "pure math" (→ $$...$$) only when it contains
/// NO prose words at all — otherwise individual runs are wrapped as inline.
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

  // Process paragraph by paragraph (split on 2+ newlines).
  final paras = t.split(RegExp(r'\n{2,}'));
  final result = paras.map((para) {
    if (!_unambiguousMathRe.hasMatch(para)) return para;

    // Only wrap as display ($$...$$) when the paragraph is PURELY math —
    // no prose words whatsoever, no sentence structure.
    if (_isPureMathParagraph(para)) {
      return '\$\$${para.trim()}\$\$';
    }

    // Mixed paragraph: wrap each bare run individually as inline ($...$).
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

  var out = result;
  for (var i = 0; i < prot.length; i++) {
    out = out.replaceFirst('\x00P$i\x00', prot[i]);
  }
  return out;
}

/// Returns true ONLY when [para] is entirely mathematical content with
/// absolutely no prose. Stricter than before — requires the content to be
/// devoid of any sentence fragments, articles, or plain-English words.
bool _isPureMathParagraph(String para) {
  final trimmed = para.trim();
  if (trimmed.isEmpty) return false;
  if (!_unambiguousMathRe.hasMatch(trimmed)) return false;

  // Strip all math runs and all non-letter chars.
  final stripped = trimmed
      .replaceAll(_mathRunRe, '')
      .replaceAll(RegExp(r'[\d+\-*/=<>()\[\]^_,.|;:!?\\\s{}]'), '');

  // If anything with 2+ letters remains, treat as mixed prose — NOT pure math.
  // This is stricter than the old 3-letter threshold, preventing sentences
  // like "at x = 5" from being classified as pure math.
  if (RegExp(r'[a-zA-Z]{2,}').hasMatch(stripped)) return false;

  // Also reject if the paragraph looks like a sentence (ends with . ? !)
  if (RegExp(r'[.?!]\s*$').hasMatch(trimmed)) return false;

  return true;
}
