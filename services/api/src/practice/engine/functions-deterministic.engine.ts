import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class FunctionsDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`
      .toLowerCase()
      .trim();

    const isCalculusTopic =
      t.includes('derivative') ||
      t.includes('derivatives') ||
      t.includes('differentiate') ||
      t.includes('rate of change') ||
      t.includes('calculus') ||
      t.includes('limit') ||
      t.includes('limits');

    const looksLikeMathFunctions =
      t.includes('function') ||
      t.includes('functions') ||
      t.includes('evaluate f(') ||
      t.includes('evaluate g(') ||
      t.includes('slope') ||
      t.includes('intercept') ||
      t.includes('linear function') ||
      t.includes('domain');

    return s === 'math' && !isCalculusTopic && looksLikeMathFunctions;
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]> {
    const out: GeneratedQuestion[] = [];
    const seen = new Set<string>();

    for (let i = 0; out.length < req.questionCount && i < req.questionCount * 8; i++) {
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
    const m = this.pick(i, [1, 2, 3, 4, -1, -2]);
    const b = this.pick(i + 1, [-5, -3, -1, 0, 2, 4, 6]);
    const x = this.pick(i + 2, [-2, -1, 0, 1, 2, 3]);
    const y = m * x + b;

    return this.finish({
      prompt: `If f(x) = ${this.expr(m, b)}, what is f(${x})?`,
      answer: String(y),
      distractors: [
        String(m + b),
        String(m * (x + 1) + b),
        String(m * x - b),
        String(y + this.pick(i + 3, [1, -1, 2])),
      ],
      explanation: `Substitute x = ${x} into f(x) = ${this.expr(m, b)}. That gives f(${x}) = ${y}.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 2;

    if (mode === 0) {
      const m = this.pick(i, [2, 3, 4, -2, -3]);
      const b = this.pick(i + 1, [-6, -4, -1, 1, 3, 5]);
      const x = this.pick(i + 2, [-3, -1, 0, 2, 4]);
      const y = m * x + b;

      return this.finish({
        prompt: `A linear function is given by y = ${this.expr(m, b)}. What is the value of y when x = ${x}?`,
        answer: String(y),
        distractors: [
          String(m + x + b),
          String(m * x - b),
          String((m + 1) * x + b),
          String(y + this.pick(i + 4, [2, -2, 3])),
        ],
        explanation: `Substitute x = ${x} into y = ${this.expr(m, b)}. The result is y = ${y}.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const m = this.pick(i, [1, 2, 3, 4, -1, -2, -3]);
    const b = this.pick(i + 1, [-5, -2, 0, 3, 6]);
    const x1 = this.pick(i + 2, [-2, -1, 0, 1]);
    const x2 = this.pick(i + 3, [2, 3, 4, 5]);
    const y1 = m * x1 + b;
    const y2 = m * x2 + b;

    return this.finish({
      prompt: `What is the slope of the line passing through the points (${x1}, ${y1}) and (${x2}, ${y2})?`,
      answer: String(m),
      distractors: [
        String(y2 - y1),
        String(x2 - x1),
        String(-m),
        String(m + this.pick(i + 4, [1, -1, 2])),
      ],
      explanation: `Slope = (y₂ - y₁) / (x₂ - x₁) = (${y2} - ${y1}) / (${x2} - ${x1}) = ${m}.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 2;

    if (mode === 0) {
      const m = this.pick(i, [2, 3, 4, -2, -3, -4]);
      const b = this.pick(i + 1, [-8, -5, -2, 1, 4, 7]);
      const x = this.pick(i + 2, [-2, -1, 1, 2, 3]);
      const y = m * x + b;

      return this.finish({
        prompt: `A function passes through (${x}, ${y}) and has slope ${m}. What is its y-intercept?`,
        answer: String(b),
        distractors: [
          String(y - x),
          String(y + x),
          String(b + this.pick(i + 3, [1, -1, 2])),
          String(m + b),
        ],
        explanation: `Use y = mx + b. Substituting (${x}, ${y}) gives ${y} = ${m}(${x}) + b, so b = ${b}.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const m = this.pick(i, [2, 3, 4, -2, -3]);
    const b = this.pick(i + 1, [-6, -3, 0, 2, 5]);
    const k = this.pick(i + 2, [-2, -1, 1, 2, 3]);
    const shift = this.pick(i + 3, [-4, -2, 2, 4]);
    const left = m * (k + shift) + b;
    const right = m * k + b;
    const delta = left - right;

    return this.finish({
      prompt: `For f(x) = ${this.expr(m, b)}, what is the value of f(${k + shift}) - f(${k})?`,
      answer: String(delta),
      distractors: [
        String(m),
        String(shift),
        String(delta + this.pick(i + 4, [1, -1, 2])),
        String(m * k),
      ],
      explanation: `Compute both values: f(${k + shift}) = ${left} and f(${k}) = ${right}. Their difference is ${delta}.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const m = this.pick(i, [2, 3, 4, -2, -3]);
    const b = this.pick(i + 1, [-6, -4, -1, 2, 5]);
    const c = this.pick(i + 2, [-3, -2, -1, 1, 2, 3]);
    const x = this.pick(i + 3, [-2, -1, 0, 1, 2]);
    const value = m * (x + c) + b;

    return this.finish({
      prompt: `If f(x) = ${this.expr(m, b)}, what is f(x + ${this.wrapSigned(c)}) when x = ${x}?`,
      answer: String(value),
      distractors: [
        String(m * x + b),
        String(m * (x - c) + b),
        String(value + this.pick(i + 4, [1, -1, 3])),
        String(m + b + c),
      ],
      explanation: `First compute x + ${this.wrapSigned(c)} = ${x + c}. Then f(${x + c}) = ${this.expr(m, b)} = ${value}.`,
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
    const options = uniqueFirst(raw, 4);

    while (options.length < 4) {
      options.push(String(Number(args.answer) + options.length + args.seed + 3));
    }

    const rotated = rotateBySeed(options.slice(0, 4), args.seed);

    return {
      prompt: args.prompt,
      options: rotated,
      correctIndex: rotated.indexOf(args.answer),
      correctAnswerText: args.answer,
      explanation: args.explanation,
      recommendedTimeSeconds: args.recommendedTimeSeconds,
      topicMatchNote: 'Functions',
    };
  }

  private expr(m: number, b: number): string {
    const xPart = m === 1 ? 'x' : m === -1 ? '-x' : `${m}x`;
    if (b === 0) return xPart;
    return b > 0 ? `${xPart} + ${b}` : `${xPart} - ${Math.abs(b)}`;
  }

  private wrapSigned(n: number): string {
    return n >= 0 ? String(n) : `(${n})`;
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
