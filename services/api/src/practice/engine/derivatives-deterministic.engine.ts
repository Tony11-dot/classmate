import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, fillOptionsWithSafeFallback, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class DerivativesDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`
      .toLowerCase()
      .trim();

    return (
      s === 'math' &&
      (
        t.includes('derivative') ||
        t.includes('derivatives') ||
        t.includes('differentiate') ||
        t.includes('d/dx') ||
        (t.includes('calculus') && t.includes('derivative'))
      )
    );
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]> {
    const out: GeneratedQuestion[] = [];
    const seen = new Set<string>();

    for (let i = 0; out.length < req.questionCount && i < req.questionCount * 10; i++) {
      const q = this.makeQuestion(i, req.difficulty, req.timePreferenceSeconds);
      const key = `${q.prompt}__${q.correctAnswerText}`;
      if (seen.has(key)) continue;
      seen.add(key);
      out.push(q);
    }

    return out;
  }

  private makeQuestion(
    i: number,
    difficulty: EngineDifficulty,
    overrideSeconds: number | null,
  ): GeneratedQuestion {
    switch (difficulty) {
      case 'easy':
        return this.makeEasy(i, overrideSeconds);
      case 'medium':
      case 'adaptive':
        return this.makeMedium(i, overrideSeconds);
      case 'hard':
        return this.makeHard(i, overrideSeconds);
      case 'olympiad':
        return this.makeOlympiad(i, overrideSeconds);
      default:
        return this.makeMedium(i, overrideSeconds);
    }
  }

  private makeEasy(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const a = this.pick(i, [2, 3, 4, 5, 6]);
    const answer = `${a}`;

    return this.finish({
      prompt: `If f(x) = ${a}x, what is f'(x)?`,
      answer,
      distractors: [
        `${a + 1}`,
        `${Math.max(1, a - 1)}`,
        `${a}x`,
        `${a}x^2`,
      ],
      explanation: `The derivative of ax is a. So the derivative of ${a}x is ${a}.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const a = this.pick(i, [2, 3, 4, 5]);
      const n = this.pick(i + 1, [2, 3, 4, 5]);
      const answer = `${a * n}x^${n - 1}`;

      return this.finish({
        prompt: `Find the derivative of f(x) = ${a}x^${n}.`,
        answer,
        distractors: [
          `${a * n}x^${n}`,
          `${a + n}x^${Math.max(1, n - 1)}`,
          `${n}x^${n - 1}`,
          `${a * n}`,
        ],
        explanation: `Use the power rule: d/dx(ax^n) = a·n·x^(n-1). So the derivative is ${a * n}x^${n - 1}.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const a = this.pick(i, [2, 3, 4, 5]);
    const b = this.pick(i + 1, [1, 2, 3, 4, 5]);
    const answer = `${a}`;

    return this.finish({
      prompt: `If f(x) = ${a}x + ${b}, what is f'(${this.pick(i + 2, [0, 1, 2, 3])})?`,
      answer,
      distractors: [
        `${b}`,
        `${a + b}`,
        `${Math.max(1, a - 1)}`,
        `${a}x`,
      ],
      explanation: `The derivative of ax + b is a. So f'(x) = ${a}, and therefore f'(given point) = ${a}.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const a = this.pick(i, [2, 3, 4, 5]);
      const n = this.pick(i + 1, [3, 4, 5, 6]);
      const b = this.pick(i + 2, [1, 2, 3, 4, 5]);
      const answer = `${a * n}x^${n - 1} + ${b}`;

      return this.finish({
        prompt: `Find the derivative of f(x) = ${a}x^${n} + ${b}x.`,
        answer,
        distractors: [
          `${a * n}x^${n} + ${b}`,
          `${a * n}x^${n - 1}`,
          `${a * n}x^${n - 1} + ${b}x`,
          `${a + b}x^${n - 1}`,
        ],
        explanation: `Differentiate term by term. d/dx(${a}x^${n}) = ${a * n}x^${n - 1} and d/dx(${b}x) = ${b}. So the derivative is ${a * n}x^${n - 1} + ${b}.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const a = this.pick(i, [2, 3, 4, 5]);
    const n = this.pick(i + 1, [2, 3, 4, 5]);
    const x = this.pick(i + 2, [1, 2, 3]);
    const answerValue = a * n * Math.pow(x, n - 1);
    const answer = `${answerValue}`;

    return this.finish({
      prompt: `If f(x) = ${a}x^${n}, what is f'(${x})?`,
      answer,
      distractors: [
        `${a * Math.pow(x, n)}`,
        `${a * n * Math.pow(x, n)}`,
        `${n * Math.pow(x, n - 1)}`,
        `${answerValue + this.pick(i + 3, [1, 2, -1])}`,
      ],
      explanation: `First find f'(x) = ${a * n}x^${n - 1}. Then substitute x = ${x}: f'(${x}) = ${answerValue}.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const a = this.pick(i, [1, 2, 3, 4]);
      const b = this.pick(i + 1, [2, 3, 4, 5]);
      const c = this.pick(i + 2, [1, 2, 3, 4]);
      const answer = `${a * b}x^${b - 1} - ${c}`;

      return this.finish({
        prompt: `Find the derivative of f(x) = ${a}x^${b} - ${c}x.`,
        answer,
        distractors: [
          `${a * b}x^${b} - ${c}`,
          `${a * b}x^${b - 1}`,
          `${a * b}x^${b - 1} - ${c}x`,
          `${a + b - c}`,
        ],
        explanation: `Differentiate term by term: d/dx(${a}x^${b}) = ${a * b}x^${b - 1} and d/dx(${c}x) = ${c}. So the derivative is ${a * b}x^${b - 1} - ${c}.`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const a = this.pick(i, [2, 3, 4, 5]);
      const n = this.pick(i + 1, [3, 4, 5]);
      const x = this.pick(i + 2, [1, 2, 3]);
      const derivativeAtX = a * n * Math.pow(x, n - 1);
      const answer = `${derivativeAtX}`;

      return this.finish({
        prompt: `For f(x) = ${a}x^${n}, find the slope of the tangent at x = ${x}.`,
        answer,
        distractors: [
          `${a * Math.pow(x, n)}`,
          `${a * n * Math.pow(x, n)}`,
          `${n * Math.pow(x, n - 1)}`,
          `${derivativeAtX + this.pick(i + 3, [2, -2, 3])}`,
        ],
        explanation: `The slope of the tangent equals the derivative at that x-value. Since f'(x) = ${a * n}x^${n - 1}, at x = ${x} the slope is ${derivativeAtX}.`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
      });
    }

    const a = this.pick(i, [2, 3, 4]);
    const b = this.pick(i + 1, [2, 3, 4]);
    const c = this.pick(i + 2, [1, 2, 3]);
    const x = this.pick(i + 3, [1, 2]);
    const answerValue = a * b * Math.pow(x, b - 1) + c;
    const answer = `${answerValue}`;

    return this.finish({
      prompt: `If f(x) = ${a}x^${b} + ${c}x, what is the slope of the tangent line at x = ${x}?`,
      answer,
      distractors: [
        `${a * Math.pow(x, b) + c * x}`,
        `${a * b * Math.pow(x, b - 1)}`,
        `${a * b * Math.pow(x, b) + c}`,
        `${answerValue + this.pick(i + 4, [1, -1, 2])}`,
      ],
      explanation: `Differentiate first: f'(x) = ${a * b}x^${b - 1} + ${c}. Then substitute x = ${x}: slope = ${answerValue}.`,
      recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
      seed: i,
    });
  }

  private finish(args: {
    prompt: string;
    answer: string;
    distractors: string[];
    explanation: string;
    recommendedTimeSeconds: number;
    seed: number;
  }): GeneratedQuestion {
    const raw = [args.answer, ...args.distractors];
    const options = fillOptionsWithSafeFallback(uniqueFirst(raw, 4), args.answer, args.seed);

    const rotated = rotateBySeed(options.slice(0, 4), args.seed);

    return {
      prompt: args.prompt,
      options: rotated,
      correctIndex: rotated.indexOf(args.answer),
      correctAnswerText: args.answer,
      explanation: args.explanation,
      recommendedTimeSeconds: args.recommendedTimeSeconds,
      topicMatchNote: 'Derivatives',
    };
  }

  private timeFor(
    difficulty: EngineDifficulty,
    overrideSeconds: number | null,
  ): number {
    switch (difficulty) {
      case 'easy':
        return clampTime(overrideSeconds, 25);
      case 'medium':
      case 'adaptive':
        return clampTime(overrideSeconds, 40);
      case 'hard':
        return clampTime(overrideSeconds, 60);
      case 'olympiad':
        return clampTime(overrideSeconds, 75);
      default:
        return clampTime(overrideSeconds, 40);
    }
  }

  private pick<T>(i: number, arr: T[]): T {
    return arr[((i % arr.length) + arr.length) % arr.length];
  }
}
