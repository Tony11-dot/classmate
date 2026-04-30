import '../domain/practice_models.dart';

String buildStrictPracticeFilterSection(PracticeFilter filter) {
  final topic = filter.topicPath.isEmpty
      ? filter.topicLabel
      : filter.topicPath.join(' > ');
  final timing = filter.useAiTiming
      ? 'AI timing'
      : '${filter.timePreferenceSeconds ?? 15}s per question';
  // Unique seed per session — forces fresh question generation and bypasses
  // any server-side deterministic or cached responses.
  final sessionSeed = DateTime.now().millisecondsSinceEpoch;

  return '''
STRICT_FILTER_SECTION_DO_NOT_IGNORE

Subject: ${filter.subject}
Topic: $topic
Mode: ${filter.mode.name}
Difficulty: ${filter.difficulty.name}
Question count: ${filter.questionCount}
Timing: $timing
Lives: ${filter.hasInfiniteLives ? "infinite" : filter.maxLives.toString()}
Session seed: $sessionSeed

HARD RULES:
1. Every generated question MUST stay inside the exact Subject above.
2. Every generated question MUST stay inside the exact Topic above.
3. Do NOT drift to a neighboring topic.
4. Do NOT produce mixed-subject trivia unless the subject is exactly General Knowledge.
5. Explanations must stay inside the same subject/topic.
6. Respect the selected mode style.
7. Return exactly ${filter.questionCount} question(s), unless mode is bagrut, which must return exactly 1.
8. Each question must include exactly 4 answer options and one zero-based correctIndex.
9. Keep the difficulty exactly at ${filter.difficulty.name}; do not simplify or generalize.
10. MATH FORMATTING — MANDATORY:
    Every math expression, symbol, variable, or formula MUST be wrapped in LaTeX dollar delimiters.
    Inline math  → single dollar signs:   \$x^2 + y^2 = r^2\$
    Display math → double dollar signs:   \$\$\\int_0^\\infty e^{-x^2}dx = \\frac{\\sqrt{\\pi}}{2}\$\$
    Use DISPLAY (double-dollar) for: integrals, sums, products, limits, multi-term equations,
      fractions, matrices, piecewise cases — anything that reads better on its own dedicated line.
    Use INLINE (single-dollar) for: single variables like \$x\$, short in-sentence formulas.
    FRACTION RULE: always write fractions as \\frac{numerator}{denominator} — NEVER use a
      plain slash / for a fraction inside math. Example: \\frac{\\sin x}{\\cos x} NOT sin(x)/cos(x).
      This rule is ABSOLUTE — check every division in every expression.
    TRIG FUNCTIONS: always prefix with backslash: \\sin, \\cos, \\tan, \\lim, \\log, \\ln, etc.
    SYMBOLS: use LaTeX commands for all special symbols — \\exists, \\forall, \\in, \\infty,
      \\alpha, \\beta, \\pi, \\theta, etc. NEVER paste raw Unicode math symbols (°, ×, ÷, ≤, etc.).
    INLINE vs DISPLAY: do not use \\[...\\] or \\(...\\) — always use \$\$...\$\$ or \$...\$.
    NEVER write raw LaTeX without dollar delimiters.
    NEVER write math as plain ASCII (write \$x^2\$ not x^2, write \$n\$ not n for a variable).
    Answer options and explanations must follow the exact same dollar-delimiter rules.
11. For code examples, use fenced markdown code blocks with a language tag.
12. EXPLANATION FORMAT: Write the explanation as flowing prose with NO blank lines between sentences.
    Do NOT insert empty lines between steps — use a period or semicolon to separate steps.
    The entire explanation must be one or two continuous paragraphs maximum.
13. VARIETY: Every question in this batch must test a DIFFERENT concept, sub-skill, or number.
    Do NOT repeat the same question type, the same numbers, or the same wording.
    Each question must be clearly distinguishable from the others in this batch.
''';
}

String buildPracticePromptSummary(PracticeFilter filter) {
  final timing = filter.useAiTiming
      ? 'AI timing'
      : '${filter.timePreferenceSeconds ?? 15}s';

  return [
    'Subject: ${filter.subject}',
    'Topic: ${filter.topicLabel}',
    'Mode: ${filter.mode.name}',
    'Difficulty: ${filter.difficulty.name}',
    'Questions: ${filter.questionCount}',
    'Timing: $timing',
    'Lives: ${filter.hasInfiniteLives ? "infinite" : "${filter.maxLives} lives"}',
  ].join(' • ');
}
