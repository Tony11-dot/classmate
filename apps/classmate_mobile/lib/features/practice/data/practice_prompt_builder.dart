import '../domain/practice_models.dart';

String buildStrictPracticeFilterSection(PracticeFilter filter) {
  final topic = filter.topicPath.isEmpty
      ? filter.topicLabel
      : filter.topicPath.join(' > ');
  final timing = filter.useAiTiming
      ? 'AI timing'
      : '${filter.timePreferenceSeconds ?? 15}s per question';
  final sessionSeed = DateTime.now().millisecondsSinceEpoch;
  final cognitiveSkills = _cognitiveSkillsFor(filter);
  final varietyGuidance = _varietyGuidanceFor(filter);
  final modeGuidance = _modeGuidanceFor(filter);

  return '''
════════════════════════════════════════════════════════════
CLASSMATE PRACTICE GENERATION CONTRACT — READ EVERY LINE
════════════════════════════════════════════════════════════

Session seed: $sessionSeed
Subject: ${filter.subject}
Topic: $topic
Mode: ${filter.mode.name}
Difficulty: ${filter.difficulty.name}
Questions: ${filter.questionCount}
Timing: $timing
Lives: ${filter.hasInfiniteLives ? "infinite" : filter.maxLives.toString()}

════════════════════════════════════════════════════════════
SECTION 1 — TOPIC CONSTRAINTS (ABSOLUTE)
════════════════════════════════════════════════════════════

1.1  Every question MUST be strictly about: ${filter.subject} → $topic
1.2  Do NOT drift to adjacent topics, related subjects, or broader concepts.
1.3  All explanations must stay within the same subject/topic.
1.4  Difficulty is "${filter.difficulty.name}" — apply it rigorously:
     • easy    → 1-step, direct definition, or single-formula calculation
     • medium  → 2–3 steps, requires applying a concept with a twist
     • hard    → multi-step reasoning, mixed sub-concepts, or deeper insight
     • olympiad→ non-routine; requires insight not obvious from memorisation
1.5  Return exactly ${filter.questionCount} question(s).
     Exception: bagrut mode ALWAYS returns exactly 1.
1.6  Each question must have exactly 4 choices and one zero-based correctIndex.

════════════════════════════════════════════════════════════
SECTION 2 — MATH FORMATTING (NON-NEGOTIABLE)
════════════════════════════════════════════════════════════

2.1  INLINE math (inside a sentence): \\( ... \\)
     Example: The resistance is \\(R = 5\\,\\Omega\\), so \\(V = IR = 10\\,\\text{V}\\).

2.2  DISPLAY math (standalone equation, own line): \\[ ... \\]
     Example:
       Using Ohm's law,
       \\[
         V = IR
       \\]
       Substituting \\(I = 2\\,\\text{A}\\) and \\(R = 5\\,\\Omega\\):
       \\[
         V = 2 \\times 5 = 10\\,\\text{V}
       \\]

2.3  NEVER put blank lines around inline math — it stays in the sentence.
2.4  Display math must sit on its own line with ONE blank line before and after.
2.5  NEVER use bare ASCII math: write \\(x^2\\) not x^2, \\(n\\) not n for a variable.
2.6  FRACTION RULE: always \\frac{a}{b} — NEVER use a plain slash inside math.
2.7  TRIG/LOG: always \\sin, \\cos, \\tan, \\ln, \\log — NEVER bare: sin, cos, ln.
2.8  UNITS: use \\,\\text{unit} — e.g. \\(12\\,\\text{m/s}\\), \\(8\\,\\Omega\\), \\(3\\,\\text{mol}\\).
2.9  CHEMISTRY: subscripts/superscripts inside \\(...\\) — \\(H_2O\\), \\(CO_2\\), \\(Fe^{3+}\\).
2.10 GREEK / SPECIAL: \\alpha, \\beta, \\pi, \\Omega, \\infty, \\approx, \\neq, \\leq, \\geq.
2.11 NEVER paste raw Unicode math symbols (°, ×, ÷, ≤, ≠, α, π, etc.) — use LaTeX.
2.12 CODE EXAMPLES: always fenced code block with language tag.
     Example: ```python
     code here
     ```
2.13 NEVER mix math delimiter styles in the same response.
     Use ONLY \\( \\) for inline and \\[ \\] for display throughout.

════════════════════════════════════════════════════════════
SECTION 3 — VARIETY & COGNITIVE SKILLS (NON-NEGOTIABLE)
════════════════════════════════════════════════════════════

$cognitiveSkills

$varietyGuidance

════════════════════════════════════════════════════════════
SECTION 4 — MODE: ${filter.mode.name.toUpperCase()}
════════════════════════════════════════════════════════════

$modeGuidance

════════════════════════════════════════════════════════════
SECTION 5 — QUALITY RULES
════════════════════════════════════════════════════════════

5.1  Exactly one choice must be correct.
5.2  Wrong choices must be plausible — common mistakes, not random nonsense.
5.3  The explanation must unambiguously justify the correct answer.
5.4  The explanation must NOT contradict the correct answer.
5.5  Units in choices must match units in the question and explanation.
5.6  Explanations: use clear steps separated by blank lines between MAJOR steps.
     Within a step, do NOT insert blank lines between sentences.
5.7  For numeric questions: verify the calculation before finalising.
5.8  Validate every formula used is correct for the topic.

════════════════════════════════════════════════════════════
SECTION 6 — SELF-CHECK (run before output)
════════════════════════════════════════════════════════════

Before generating each question verify:
□  Is this strictly on-topic for "${filter.subject} → $topic"?
□  Is the difficulty exactly "${filter.difficulty.name}"?
□  Is the correct answer actually correct (check the arithmetic/logic)?
□  Are all \\(math\\) delimiters balanced?
□  Are there NO blank lines around inline math?
□  Do all units match?
□  Is the explanation consistent with the correct answer?
□  Is this question different from every other question in this batch?
□  Are distractors plausible (not obviously wrong)?
□  Does the cognitive skill tested differ from the previous question?

''';
}

String _cognitiveSkillsFor(PracticeFilter filter) {
  const skills = [
    'RECALL    — define, identify, name, recognise the concept',
    'APPLY     — use a formula, compute, solve step-by-step',
    'ANALYSE   — explain why, compare two approaches, identify the relationship',
    'EVALUATE  — predict what happens if a parameter changes, judge a claim',
    'DEBUG     — find the error in code/working/reasoning',
    'EXTEND    — apply the concept in an unfamiliar or novel context',
  ];

  return '''Each question in this batch MUST test a DIFFERENT cognitive skill.
Rotate through these skills across the ${filter.questionCount} question(s):

${skills.join('\n')}

Assign cognitive skills in this order: ${_skillsForCount(filter.questionCount)}
Tag each question with its assigned skill in a field "skill": "RECALL" etc.''';
}

String _skillsForCount(int count) {
  const cycle = ['APPLY', 'RECALL', 'ANALYSE', 'EVALUATE', 'DEBUG', 'EXTEND'];
  final result = <String>[];
  for (var i = 0; i < count; i++) {
    result.add('Q${i + 1}: ${cycle[i % cycle.length]}');
  }
  return result.join(', ');
}

String _varietyGuidanceFor(PracticeFilter filter) {
  final subject = filter.subject.toLowerCase();
  final topic = (filter.topicPath.isEmpty
          ? filter.topicLabel
          : filter.topicPath.join(' > '))
      .toLowerCase();

  // Subject-specific variety guidance
  if (subject.contains('math') || subject.contains('maths')) {
    return _mathVariety(topic);
  }
  if (subject.contains('physics')) {
    return _physicsVariety(topic);
  }
  if (subject.contains('electron') || subject.contains('circuit')) {
    return _electronicsVariety(topic);
  }
  if (subject.contains('cs') ||
      subject.contains('computer') ||
      subject.contains('programming')) {
    return _csVariety(topic);
  }
  if (subject.contains('chem')) {
    return _chemVariety(topic);
  }

  // Generic variety rules
  return '''VARIETY RULES:
• Vary what is asked (definition, calculation, application, comparison, error-finding).
• Vary numbers — never use the same numeric values in two questions.
• Vary wording — no two questions should share sentence structure.
• Vary cognitive depth — mix recall, application, and reasoning.
• Never test the exact same sub-skill twice.''';
}

String _mathVariety(String topic) {
  if (topic.contains('quadratic') || topic.contains('equation')) {
    return '''VARIETY — MATH EQUATIONS:
Rotate what is unknown each question:
  Q type A: Solve for x given a standard-form equation
  Q type B: Find the sum/product of roots (Vieta's formulas)
  Q type C: Determine the number of real roots (discriminant)
  Q type D: Identify the vertex / axis of symmetry
  Q type E: Word problem requiring equation setup
  Q type F: Error-finding in a student's solution
Vary the coefficients. No two questions may use the same a, b, c.''';
  }
  if (topic.contains('trigon') || topic.contains('trig')) {
    return '''VARIETY — TRIGONOMETRY:
Rotate what is asked:
  Q type A: Find exact value of \\(\\sin/\\cos/\\tan\\) at a special angle
  Q type B: Use a trig identity to simplify
  Q type C: Solve a trig equation in a given range
  Q type D: Word problem (angle of elevation/depression, bearing)
  Q type E: Conceptual — behaviour of the graph or period/amplitude
Vary angles and contexts each question.''';
  }
  return '''VARIETY — MATH:
Rotate what is solved for each question (different unknowns).
Rotate question format: direct calculation, word problem, proof/justification, error-finding.
No two questions should use the same numbers or the same equation structure.''';
}

String _physicsVariety(String topic) {
  if (topic.contains('kinematic') || topic.contains('motion')) {
    return '''VARIETY — KINEMATICS:
Rotate which variable is the unknown each question:
  Q1: Find final velocity \\(v\\) given \\(u, a, t\\)
  Q2: Find displacement \\(s\\) given \\(u, v, t\\) or \\(u, a, t\\)
  Q3: Find acceleration \\(a\\) given \\(u, v, s\\) or \\(u, v, t\\)
  Q4: Find time \\(t\\) given \\(u, v, a\\)
  Q5: Conceptual — describe motion from a velocity-time graph
  Q6: Error-finding — a student uses the wrong equation
Vary the numbers every question. No two questions share the same numeric values.''';
  }
  return '''VARIETY — PHYSICS:
Rotate which quantity is unknown each question.
Rotate question format: direct calculation, conceptual, graph reading, unit conversion, error-finding.
Vary all numeric values. Never use the same numbers twice.''';
}

String _electronicsVariety(String topic) {
  if (topic.contains('ohm') || topic.contains('resistance') || topic.contains('circuit')) {
    return '''VARIETY — ELECTRONICS / OHM LAW:
Strictly rotate which quantity is unknown:
  Q1: Find \\(V\\) given \\(I\\) and \\(R\\)
  Q2: Find \\(I\\) given \\(V\\) and \\(R\\)
  Q3: Find \\(R\\) given \\(V\\) and \\(I\\)
  Q4: Conceptual — what happens to \\(I\\) when \\(R\\) doubles (\\(V\\) constant)?
  Q5: Series/parallel combination — find equivalent resistance
  Q6: Power calculation \\(P = IV\\) or \\(P = I^2R\\)
Use different numeric values every question.
Units must be correct: \\(\\Omega\\), \\(\\text{V}\\), \\(\\text{A}\\), \\(\\text{W}\\).''';
  }
  return '''VARIETY — ELECTRONICS:
Rotate which component value or circuit parameter is unknown.
Vary question types: calculation, conceptual, circuit analysis, unit identification.
Use different realistic component values every question.
Always include correct SI units.''';
}

String _csVariety(String topic) {
  if (topic.contains('complex') || topic.contains('algorithm') || topic.contains('sort')) {
    return '''VARIETY — ALGORITHMS / COMPLEXITY:
Rotate what is asked:
  Q type A: Identify the time complexity of a given code snippet
  Q type B: Compare two algorithms (which is faster and why?)
  Q type C: Predict number of iterations for a specific \\(n\\)
  Q type D: Space complexity question
  Q type E: Debug — find the bug that changes the complexity
  Q type F: Choose the better algorithm for a described scenario
Use different code snippets each time. Vary \\(n\\) values in examples.''';
  }
  return '''VARIETY — CS / PROGRAMMING:
Rotate question type: trace code output, identify complexity, debug code, complete a function, compare approaches.
Use different algorithms, different variable names, different \\(n\\) values each question.
Code must be in fenced code blocks with a language tag.''';
}

String _chemVariety(String topic) {
  return '''VARIETY — CHEMISTRY:
Rotate question format: identify a formula, balance an equation, calculate moles/mass, conceptual bonding/structure, predict products.
Vary compounds and reactions each question.
All chemical formulas must use proper subscripts inside \\(\\text{...}\\) or \\(...\\).''';
}

String _modeGuidanceFor(PracticeFilter filter) {
  switch (filter.mode) {
    case PracticeMode.flashcards:
      return '''Flashcard mode — recognition and recall focus:
• Each question tests ONE concept or definition.
• Keep questions short — one sentence maximum.
• Choices must be single words or very short phrases.
• No multi-step calculations.
• Prioritise RECALL and IDENTIFY cognitive skills.''';

    case PracticeMode.speedRound:
      return '''Speed Round mode — fast, low reading load:
• Every question must be answerable in under 10 seconds.
• Question text: one sentence. Choices: one word or a number.
• No multi-step questions.
• Prioritise RECALL and APPLY (1-step) skills.''';

    case PracticeMode.examPrep:
      return '''Exam Prep mode — formal and substantial:
• Questions should feel like exam questions.
• Formal tone, precise wording.
• Explanations must be detailed and show full working.
• All difficulties meaningful — easy is not trivial.
• Include at least one multi-step calculation question.''';

    case PracticeMode.conceptBuilder:
      return '''Concept Builder mode — build understanding step by step:
• Start with the core definition/principle.
• Gradually increase depth across the questions.
• Each question adds a layer: recall → apply → analyse → evaluate.
• Explanations should explicitly connect to the underlying principle.''';

    case PracticeMode.adaptive:
      return '''Adaptive mode — mix of difficulty and types:
• Include at least one easy, one medium, and one hard question.
• Mix question formats: definition, calculation, conceptual.
• Explanations must be thorough for harder questions.''';

    case PracticeMode.bagrut:
      return '''Bagrut (Israeli matriculation exam) style:
• Exactly 1 question in the format of an Israeli Bagrut exam.
• Formal language, precise phrasing.
• Show full method in the explanation.
• Difficulty appropriate to the Bagrut level for the subject.
• Include all relevant formula derivations.''';

    default:
      return '''Standard Practice mode:
• Mix of question types — definition, calculation, application, reasoning.
• Each question should stand alone (no dependency on other questions).
• Explanations must show the full method, not just the answer.
• Appropriate depth for the selected difficulty.''';
  }
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
