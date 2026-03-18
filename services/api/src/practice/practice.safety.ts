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

export function normalizeQuestionSetShape<T extends PracticeQuestionLike>(items: T[]): T[] {
  return asArray<T>(items).map((q) => {
    const next = { ...q } as T & PracticeQuestionLike;

    if (!next.prompt && next.question) {
      next.prompt = next.question;
    }

    if (!next.question && next.prompt) {
      next.question = next.prompt;
    }

    if (typeof next.explanation === 'string') {
      next.explanation = next.explanation.trim();
    }

    if (Array.isArray(next.options)) {
      next.options = next.options
        .map((x) => (typeof x === 'string' ? x.trim() : x))
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
