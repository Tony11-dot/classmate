export type PracticeQuestionLike = {
  prompt?: string;
  question?: string;
  explanation?: string;
  answer?: unknown;
  correctAnswer?: unknown;
  options?: unknown;
};

export type PracticeSetAssessment = {
  ok: boolean;
  issues: string[];
};

function asArray<T = unknown>(v: unknown): T[] {
  return Array.isArray(v) ? (v as T[]) : [];
}

function str(v: unknown): string {
  return typeof v === 'string' ? v.trim() : '';
}

function hasValue(v: unknown): boolean {
  if (typeof v === 'string') return v.trim().length > 0;
  if (typeof v === 'number') return Number.isFinite(v);
  if (typeof v === 'boolean') return true;
  return v !== null && v !== undefined;
}

function getQuestionText(q: PracticeQuestionLike): string {
  return str(q.prompt) || str(q.question);
}

function getAnswerValue(q: PracticeQuestionLike): unknown {
  return q.correctAnswer ?? q.answer;
}

function optionCount(q: PracticeQuestionLike): number {
  return asArray(q.options).length;
}

const LATEX_COMMAND_ALTERNATION =
  'frac|sqrt|sum|prod|int|oint|lim|inf|sup|alpha|beta|gamma|delta|epsilon|zeta|eta|theta|iota|kappa|lambda|mu|nu|xi|pi|rho|sigma|tau|upsilon|phi|chi|psi|omega|Alpha|Beta|Gamma|Delta|Epsilon|Zeta|Eta|Theta|Iota|Kappa|Lambda|Mu|Nu|Xi|Pi|Rho|Sigma|Tau|Upsilon|Phi|Chi|Psi|Omega|partial|nabla|infty|cdot|times|div|pm|mp|leq|geq|neq|approx|equiv|propto|sim|simeq|subset|supset|in|notin|cup|cap|emptyset|forall|exists|neg|wedge|vee|oplus|otimes|circ|bullet|vec|hat|bar|tilde|dot|ddot|overline|underline|overleftarrow|overrightarrow|mathbf|mathrm|mathit|mathbb|mathcal|text|big|Big|bigg|Bigg|begin|end|pmatrix|bmatrix|vmatrix|cases|ldots|cdots|vdots|ddots|to|rightarrow|leftarrow|Rightarrow|Leftarrow|leftrightarrow|Leftrightarrow|sin|cos|tan|cot|sec|csc|arcsin|arccos|arctan|sinh|cosh|tanh|log|ln|exp|det|dim|ker|mod|max|min|gcd|lcm|deg';
const LATEX_SLASH_REPAIR_ALTERNATION =
  'frac|sum|prod|int|oint|alpha|beta|gamma|delta|epsilon|zeta|eta|theta|iota|kappa|lambda|mu|nu|xi|pi|rho|sigma|tau|upsilon|phi|chi|psi|omega|Alpha|Beta|Gamma|Delta|Epsilon|Zeta|Eta|Theta|Iota|Kappa|Lambda|Mu|Nu|Xi|Pi|Rho|Sigma|Tau|Upsilon|Phi|Chi|Psi|Omega|partial|nabla|infty|cdot|times|div|pm|mp|leq|geq|neq|approx|equiv|propto|sim|simeq|subset|supset|notin|cup|cap|emptyset|forall|exists|neg|wedge|vee|oplus|otimes|circ|bullet|vec|hat|bar|tilde|dot|ddot|overline|underline|overleftarrow|overrightarrow|mathbf|mathrm|mathit|mathbb|mathcal|ldots|cdots|vdots|ddots|rightarrow|leftarrow|Rightarrow|Leftarrow|leftrightarrow|Leftrightarrow';

const RENDERABLE_CODE_FENCE_RE = /(```|~~~)[^\n]*\n[\s\S]*?\1/gm;
const BARE_LATEX_RE = new RegExp(
  `(?<![\\$])\\\\(${LATEX_COMMAND_ALTERNATION})(?=[^a-zA-Z]|$)`,
);
const LATEX_SLASH_REPAIR_RE = new RegExp(
  String.raw`(^|[^A-Za-z\\])(${LATEX_SLASH_REPAIR_ALTERNATION})(?=[^A-Za-z]|$)`,
  'g',
);
const INLINE_CODE_SENTENCE_TAIL_RE = /^(.+?[?:])\s+([\s\S]+)$/;

function normalizeQuestionText(value: string): string {
  return String(value ?? '')
    .replace(/\r\n/g, '\n')
    .replace(/\r/g, '\n')
    .replace(/(?<!\n)\n(?!\n)/g, ' ')
    .replace(/[ \t]{2,}/g, ' ')
    .trim();
}

export function normalizeRenderablePracticeText(input: string): string {
  const normalized = String(input ?? '').replace(/\r\n/g, '\n').replace(/\r/g, '\n');
  if (!RENDERABLE_CODE_FENCE_RE.test(normalized)) {
    return prepareRenderableChunk(normalized);
  }

  RENDERABLE_CODE_FENCE_RE.lastIndex = 0;
  let cursor = 0;
  let out = '';
  for (const match of normalized.matchAll(RENDERABLE_CODE_FENCE_RE)) {
    const index = match.index ?? 0;
    if (index > cursor) {
      out += prepareRenderableChunk(normalized.slice(cursor, index));
    }
    out += match[0];
    cursor = index + match[0].length;
  }
  if (cursor < normalized.length) {
    out += prepareRenderableChunk(normalized.slice(cursor));
  }
  return out;
}

function prepareRenderableChunk(input: string): string {
  let text = maybeFenceInlineCodeTail(input);
  text = protectLatexEnvironmentBlocks(text);
  const containsBareLatex = BARE_LATEX_RE.test(text);

  text = replaceOutsidePlaceholderMarkers(text, /\\([.,!?;:])/g, (_: string, mark: string) => mark);
  text = replaceOutsidePlaceholderMarkers(text, /\\(?=\s)/g, () => '');

  text = text.replace(/\\\(([^\n]+?)\\\)/g, (_, body: string) => `INLINE_OPEN${body}INLINE_CLOSE`);
  text = text.replace(/\\\[([\s\S]*?)\\\]/g, (_, body: string) => `BLOCK_OPEN${body}BLOCK_CLOSE`);
  text = text.replace(LATEX_SLASH_REPAIR_RE, (_, prefix: string, command: string) => `${prefix}\\${command}`);
  text = text.replace(/(^|[^A-Za-z\\])(lim)(?=[_^])/g, (_, prefix: string, command: string) => `${prefix}\\${command}`);

  text = autoWrapBareLatex(text);
  text = protectCommonUnicodeMathRuns(text);
  text = mergeInlineMathRuns(text);

  text = autoWrapPlainSymbolicMath(text);

  let rendered = text
    .replace(/BLOCK_OPEN/g, () => '$$')
    .replace(/BLOCK_CLOSE/g, () => '$$')
    .replace(/INLINE_OPEN/g, () => '$')
    .replace(/INLINE_CLOSE/g, () => '$');

  rendered = rendered.replace(
    /\$([^$\n]+)\$([_^](?:\{[^{}]+\}|[A-Za-z0-9]))/g,
    (_, expr: string, suffix: string) => `$${expr}${suffix}$`,
  );

  return rendered;
}

function protectLatexEnvironmentBlocks(input: string): string {
  return input.replace(
    /\\begin\{([a-zA-Z*]+)\}([\s\S]*?)\\end\{\1\}/g,
    (match: string) => `BLOCK_OPEN${match}BLOCK_CLOSE`,
  );
}

function autoWrapBareLatex(src: string): string {
  if (!BARE_LATEX_RE.test(src)) return src;

  const delimRe = /\$\$[\s\S]+?\$\$|\$[^$\n]+?\$|\\\[[\s\S]+?\\\]|\\\(.+?\\\)|INLINE_OPEN[\s\S]*?INLINE_CLOSE|BLOCK_OPEN[\s\S]*?BLOCK_CLOSE/g;
  let cursor = 0;
  let out = '';
  for (const match of src.matchAll(delimRe)) {
    const index = match.index ?? 0;
    if (index > cursor) {
      out += wrapBareInChunk(src.slice(cursor, index));
    }
    out += match[0];
    cursor = index + match[0].length;
  }
  if (cursor < src.length) {
    out += wrapBareInChunk(src.slice(cursor));
  }
  return out;
}

function wrapBareInChunk(chunk: string): string {
  if (!BARE_LATEX_RE.test(chunk)) return chunk;
  const runRe = /\\[a-zA-Z]+(?:\{[^{}]*(?:\{[^{}]*\}[^{}]*)?\}|\[[^\]]*\]|[_^]\{[^{}]*\}|[_^][a-zA-Z0-9]|\s*)*/g;
  let cursor = 0;
  let out = '';
  for (const match of chunk.matchAll(runRe)) {
    const index = match.index ?? 0;
    if (index > cursor) out += chunk.slice(cursor, index);
    const rawRun = match[0];
    const run = rawRun.trimEnd();
    const trailing = rawRun.slice(run.length);
    out += `$${run}$${trailing}`;
    cursor = index + rawRun.length;
  }
  if (cursor < chunk.length) out += chunk.slice(cursor);
  return out;
}

function maybeFenceInlineCodeTail(input: string): string {
  if (input.includes('```') || input.includes('~~~')) return input;

  const match = INLINE_CODE_SENTENCE_TAIL_RE.exec(input.trim());
  if (!match) return input;

  const stem = String(match[1] ?? '').trim();
  const tail = String(match[2] ?? '').trim();
  if (!looksLikeInlineCodeTail(tail)) return input;

  const formatted = formatInlineCodeTail(tail);
  if (!formatted) return input;

  const language = inferInlineCodeLanguage(tail);
  const fence = language ? `\`\`\`${language}`.replace(/\\`/g, '`') : '```';
  return `${stem}\n\n${fence}\n${formatted}\n\`\`\``.replace(/\\`/g, '`');
}

function looksLikeInlineCodeTail(tail: string): boolean {
  if (!tail.includes('(') || !tail.includes(')')) return false;
  if (
    !tail.includes(';') &&
    !tail.includes('{') &&
    !tail.includes('}') &&
    !looksLikePythonInlineCode(tail) &&
    !/\b(?:console\.log|Console\.WriteLine|System\.out\.println|return|throw|if|else if|else|switch|case)\b/i.test(
      tail,
    )
  ) {
    return false;
  }
  return /\b(if|else|for|while|switch|case|return|print|console\.log|System\.out\.println|Console\.WriteLine|int|double|float|bool|boolean|String|var|const|let|def|function|class)\b/i.test(
    tail,
  );
}

function formatInlineCodeTail(code: string): string {
  if (looksLikePythonInlineCode(code)) {
    return code
      .trim()
      .replace(/:\s*(?=(?:print|return|[A-Za-z_][A-Za-z0-9_]*\())/g, ':\n    ')
      .replace(/\s+elif\s+/gi, '\nelif ')
      .replace(/\s+else:\s*/gi, '\nelse:\n    ')
      .replace(/\n{3,}/g, '\n\n')
      .trim();
  }

  return code
    .trim()
    .replace(/;\s*/g, ';\n')
    .replace(/\s+else if\s+/gi, '\nelse if ')
    .replace(/\s+else\s+/gi, '\nelse ')
    .replace(/^(if|else if)\s*(\([^\n]+?\))\s+([^{}\n].*)$/gim, '$1 $2\n  $3')
    .replace(/^else\s+([^{}\n].*)$/gim, 'else\n  $1')
    .replace(/\s*\{\s*/g, ' {\n')
    .replace(/\s*\}\s*/g, '\n}\n')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

function looksLikePythonInlineCode(code: string): boolean {
  const value = String(code ?? '').trim();
  if (!value.includes(':')) return false;
  if (/[;{}]/.test(value)) return false;

  return /\b(if|elif|else|for|while|def|class|return|print)\b/i.test(value);
}

function inferInlineCodeLanguage(code: string): string {
  const lower = code.toLowerCase();
  if (looksLikePythonInlineCode(code)) return 'python';
  if (lower.includes('console.writeline')) return 'csharp';
  if (lower.includes('console.log')) return 'javascript';
  if (lower.includes('system.out.println')) return 'java';
  if (lower.includes('print(')) return 'dart';
  return '';
}

function autoWrapPlainSymbolicMath(input: string): string {
  const protectedRe = /```[\s\S]*?```|~~~[\s\S]*?~~~|\$\$[\s\S]+?\$\$|\$[^$\n]+?\$|INLINE_OPEN[\s\S]*?INLINE_CLOSE|BLOCK_OPEN[\s\S]*?BLOCK_CLOSE/g;
  let cursor = 0;
  let out = '';

  for (const match of input.matchAll(protectedRe)) {
    const index = match.index ?? 0;
    if (index > cursor) {
      out += wrapPlainSymbolicMathInChunk(input.slice(cursor, index));
    }
    out += match[0];
    cursor = index + match[0].length;
  }

  if (cursor < input.length) {
    out += wrapPlainSymbolicMathInChunk(input.slice(cursor));
  }

  return out;
}

function wrapPlainSymbolicMathInChunk(chunk: string): string {
  let out = chunk;

  const wrappers: RegExp[] = [
    /(?<![$\\])((?:lim|\\lim)\s+[A-Za-z]\s*(?:->|→|\\to)\s*[^\s,;:.!?\n]+\s+(?:[A-Za-z][A-Za-z0-9]*\([^()\n]+\)|\([^()\n]+\)|[A-Za-z0-9_{}^+-]+)(?:\s*\/\s*(?:[A-Za-z][A-Za-z0-9]*\([^()\n]+\)|\([^()\n]+\)|[A-Za-z0-9_{}^+-]+))?)(?![$\\])/gi,
    /(?<![$\\])(∫(?:_[^\s,;:.!?\n]+)?(?:\^[^\s,;:.!?\n]+)?\s*[^,;:.!?\n]+?\sd[a-zA-Z])(?![$\\])/g,
    /(?<![$\\])([∫∑ΣΠ√][^,;:.!?\n]*?[A-Za-z0-9)\]}°])(?![$\\])/g,
    /(?<![$\\])((?:\\)?\b(?:sin|cos|tan|cot|sec|csc|log|ln|exp)\b(?:\^(?:\{[^{}\n]+\}|[-+]?[A-Za-z0-9]+))?\s*(?:\([^()\n]+\)|[A-Za-z0-9_]+))(?![$\\])/gi,
    /(?<![$\\])((?:\\)?sqrt\([^()\n]+\))(?![$\\])/g,
    /(?<![$\\])(\b[A-Za-z][A-Za-z0-9]*'+\([^()\n]*\))(?![$\\])/g,
    /(?<![$\\])((?:[A-Za-z][A-Za-z0-9]*\([^()\n]+\)|\([^()\n]+\)|[A-Za-z0-9_{}^+-]+)\s*\/\s*(?:[A-Za-z][A-Za-z0-9]*\([^()\n]+\)|\([^()\n]+\)|[A-Za-z0-9_{}^+-]+))(?![$\\])/g,
    /(?<![$\\])(\b(?:[A-Za-z][A-Za-z0-9]*|\([^()\n]+\)|\d+[A-Za-z]+)(?:_(?:\{[^{}\n]+\}|[A-Za-z0-9]+)|\^(?:\{[^{}\n]+\}|[-+]?[A-Za-z0-9]+)){1,2})(?![$\\])/g,
  ];

  for (const pattern of wrappers) {
    out = replaceOutsideWrappedMath(out, pattern, (raw: string, token?: string) => {
      const value = String(token ?? raw).trim();
      if (!value) return raw;
        return `$${value}$`;
    });
  }

  return out;
}

function protectCommonUnicodeMathRuns(input: string): string {
  return input
    .replace(
      /(∫(?:_[^\s,;:.!?\n]+)?(?:\^[^\s,;:.!?\n]+)?\s*[^,;:.!?\n]+?\sd[a-zA-Z])/g,
      (_, expr: string) => `INLINE_OPEN${expr}INLINE_CLOSE`,
    )
    .replace(
      /((?:∑|Σ|∏|Π)(?:_[^\s,;:.!?\n]+)?(?:\^[^\s,;:.!?\n]+)?(?:\s+[^\s,;:.!?\n]+){1,4})/g,
      (_, expr: string) => `INLINE_OPEN${expr}INLINE_CLOSE`,
    );
}

function replaceOutsidePlaceholderMarkers(
  input: string,
  pattern: RegExp,
  replacer: (...args: any[]) => string,
): string {
  const placeholderRe = /INLINE_OPEN[\s\S]*?INLINE_CLOSE|BLOCK_OPEN[\s\S]*?BLOCK_CLOSE/g;
  let cursor = 0;
  let out = '';

  for (const match of input.matchAll(placeholderRe)) {
    const index = match.index ?? 0;
    if (index > cursor) {
      out += input.slice(cursor, index).replace(pattern, replacer as any);
    }
    out += match[0];
    cursor = index + match[0].length;
  }

  if (cursor < input.length) {
    out += input.slice(cursor).replace(pattern, replacer as any);
  }

  return out;
}

function replaceOutsideWrappedMath(
  input: string,
  pattern: RegExp,
  replacer: (raw: string, token?: string) => string,
): string {
  const mathRe = /\$\$[\s\S]+?\$\$|\$[^$\n]+?\$/g;
  let cursor = 0;
  let out = '';

  for (const match of input.matchAll(mathRe)) {
    const index = match.index ?? 0;
    if (index > cursor) {
      out += input.slice(cursor, index).replace(pattern, replacer);
    }
    out += match[0];
    cursor = index + match[0].length;
  }

  if (cursor < input.length) {
    out += input.slice(cursor).replace(pattern, replacer);
  }

  return out;
}

function mergeInlineMathRuns(input: string): string {
  let out = input;
  const adjacentRe = /\$([^$\n]+)\$\s+\$([^$\n]+)\$/g;
  while (adjacentRe.test(out)) {
    out = out.replace(
      adjacentRe,
      (_, left: string, right: string) => `MATH_OPEN${left} ${right}MATH_CLOSE`,
    );
  }

  const limitTargetRe = /\$((?:\\lim|\\sum|\\prod|\\int|\\oint)[^$\n]*)\$\s+([A-Za-z][A-Za-z0-9]*\([^\n)]*\)|[A-Za-z][A-Za-z0-9]*)/g;
  while (limitTargetRe.test(out)) {
    out = out.replace(
      limitTargetRe,
      (_, expr: string, target: string) => `MATH_OPEN${expr} ${target}MATH_CLOSE`,
    );
  }

  const trailingExponentRe = /\$([^$\n]+)\$([_^](?:\{[^{}]+\}|[A-Za-z0-9]))/g;
  while (trailingExponentRe.test(out)) {
    out = out.replace(
      trailingExponentRe,
      (_, expr: string, suffix: string) => `MATH_OPEN${expr}${suffix}MATH_CLOSE`,
    );
  }

  return out.replace(/MATH_OPEN/g, '$').replace(/MATH_CLOSE/g, '$');
}

export function normalizeQuestionSetShape<T extends PracticeQuestionLike>(items: T[]): T[] {
  return asArray<T>(items).map((q) => {
    const next = { ...q } as T & PracticeQuestionLike;

    if (!next.prompt && next.question) {
      next.prompt = next.question;
    }

    if (!next.question && next.prompt) {
      next.question = next.prompt;
    }

    if (typeof next.prompt === 'string') {
      next.prompt = normalizeRenderablePracticeText(next.prompt);
    }

    if (typeof next.question === 'string') {
      next.question = normalizeRenderablePracticeText(next.question);
    }

    if (typeof next.explanation === 'string') {
      next.explanation = normalizeRenderablePracticeText(next.explanation);
    }

    if (Array.isArray(next.options)) {
      next.options = next.options
        .map((x) =>
          typeof x === 'string' ? normalizeRenderablePracticeText(x) : x,
        )
        .filter((x) => hasValue(x));
    }

    return next as T;
  });
}

export function assessQuestionSetIntegrity<T extends PracticeQuestionLike>(items: T[]): PracticeSetAssessment {
  const questions = asArray<T>(items);

  if (!questions.length) {
    return { ok: false, issues: ['empty_set'] };
  }

  const issues: string[] = [];

  questions.forEach((q, index) => {
    const prefix = `q${index}`;

    const prompt = getQuestionText(q);
    if (!prompt) issues.push(`${prefix}:missing_prompt`);

    const explanation = str(q.explanation);
    if (!explanation) issues.push(`${prefix}:missing_explanation`);

    const answer = getAnswerValue(q);
    if (!hasValue(answer)) issues.push(`${prefix}:missing_answer`);

    if (Array.isArray(q.options) && optionCount(q) < 2) {
      issues.push(`${prefix}:too_few_options`);
    }

    if (typeof answer === 'string' && Array.isArray(q.options) && q.options.length > 0) {
      const normalizedAnswer = answer.trim().toLowerCase();
      const matchesOption = q.options.some((o) => String(o).trim().toLowerCase() === normalizedAnswer);
      if (!matchesOption) {
        const looksLikeOptionLetter = /^[a-d]$/i.test(answer.trim());
        if (!looksLikeOptionLetter) {
          issues.push(`${prefix}:answer_not_in_options`);
        }
      }
    }

    if (prompt && explanation) {
      const promptLc = prompt.toLowerCase();
      const explanationLc = explanation.toLowerCase();

      if (
        explanationLc.includes('correction:') ||
        explanationLc.includes('adjust options') ||
        explanationLc.includes('reconsider') ||
        explanationLc.includes('maybe ') ||
        explanationLc.includes('approximately about') ||
        explanationLc.includes('nearly around')
      ) {
        issues.push(`${prefix}:self_correction_language`);
      }

      if (
        promptLc === explanationLc ||
        explanationLc.length < 8 ||
        explanationLc === String(answer).trim().toLowerCase()
      ) {
        issues.push(`${prefix}:weak_explanation`);
      }
    }
  });

  return { ok: issues.length === 0, issues };
}

export function shouldAcceptConfidenceHeuristic<T extends PracticeQuestionLike>(items: T[]): boolean {
  const questions = asArray<T>(items);
  if (!questions.length) return false;

  const totalPromptChars = questions.reduce((n, q) => n + getQuestionText(q).length, 0);
  const totalExplanationChars = questions.reduce((n, q) => n + str(q.explanation).length, 0);

  return totalPromptChars >= questions.length * 12 && totalExplanationChars >= questions.length * 20;
}

export function chooseSmartFallbackCount(requestedCount: number, availableCount: number): number {
  const safeRequested = Number.isFinite(requestedCount) ? Math.max(1, Math.floor(requestedCount)) : 1;
  const safeAvailable = Number.isFinite(availableCount) ? Math.max(0, Math.floor(availableCount)) : 0;

  if (safeAvailable <= 0) return 0;
  if (safeAvailable >= safeRequested) return safeRequested;
  if (safeAvailable >= 2) return Math.min(2, safeAvailable);
  return 1;
}
