import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class LimitsDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`
      .toLowerCase()
      .trim();

    const looksLikeLimits =
      t.includes('limit') ||
      t.includes('limits') ||
      t.includes('approach') ||
      t.includes('approaches') ||
      t.includes('x->') ||
      t.includes('x →') ||
      t.includes('tends to');

    return s === 'math' && looksLikeLimits;
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
    const a = this.pick(i, [-3, -2, -1, 1, 2, 3]);
    const b = this.pick(i + 1, [-5, -2, 0, 4, 7]);
    const c = this.pick(i + 2, [-2, -1, 0, 1, 2]);

    const answer = a * c + b;

    return this.finish({
      prompt: `Find \\\\\lim\_\{x \\\\to ${c}\} \(${a}x ${this.sign(b)}\)\\.`,
      answer: this.num(answer),
      distractors: [
        this.num(a + b),
        this.num(a * (c + 1) + b),
        this.num(c),
        this.num(answer + this.pick(i + 3, [1, -1, 2])),
      ],
      explanation: `For a linear expression, substitute directly: ${a}(${c}) ${this.sign(b)} = ${answer}.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const c = this.pick(i, [-3, -2, -1, 1, 2, 3]);
      const m = this.pick(i + 1, [2, 3, 4, 5]);
      const p = this.pick(i + 2, [-4, -2, 1, 3]);
      const valueAtC = m * c + p;

      return this.finish({
        prompt: `Find \\\\\lim\_\{x \\\\to ${c}\} \(${m}x ${this.sign(p)}\)\\.`,
        answer: this.num(valueAtC),
        distractors: [
          this.num(m + p),
          this.num(c),
          this.num(valueAtC + this.pick(i + 3, [1, -1, 2])),
          this.num(m * (c - 1) + p),
        ],
        explanation: `Polynomials are continuous, so substitute directly: ${m}(${c}) ${this.sign(p)} = ${valueAtC}.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const c = this.pick(i, [1, 2, 3, 4]);
    const leftK = this.pick(i + 1, [2, 3, 4]);
    const rightK = leftK;
    const leftB = this.pick(i + 2, [-5, -2, 1, 4]);
    const rightB = this.pick(i + 3, [-5, -2, 1, 4]);
    const value = leftK * c + leftB;

    return this.finish({
      prompt:
        `A function is defined by ` +
        `f(x) = ${leftK}x ${this.sign(leftB)} for x < ${c}, and ` +
        `f(x) = ${rightK}x ${this.sign(rightB)} for x > ${c}. ` +
        `If both sides approach the same value, what is \\\\\lim\_\{x \\\\to ${c}\} f\(x\)\\?`,
      answer: this.num(value),
      distractors: [
        this.num(c),
        this.num(value + this.pick(i + 4, [1, -1, 2])),
        this.num(rightK * c + rightB),
        this.num(leftK + rightK),
      ],
      explanation: `Compute the value both sides approach at x = ${c}. The limit is ${value}.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const c = this.pick(i, [-3, -2, -1, 1, 2, 3]);
      const a = this.pick(i + 1, [1, 2, 3, 4]);
      const b = this.pick(i + 2, [-4, -2, 1, 3]);
      const linearAtC = a * c + b;
      const numeratorConst = linearAtC * (c + this.pick(i + 3, [1, 2]));
      const denominatorConst = c + this.pick(i + 3, [1, 2]);
      const answer = linearAtC;

      return this.finish({
        prompt: `Find \\\\\lim\_\{x \\\\to ${c}\} \\\\frac\{\(${a}x ${this.sign(b)}\)\(x ${this.sign(-denominatorConst)}\)\}\{x ${this.sign(-denominatorConst)}\}\\.`,
        answer: this.num(answer),
        distractors: [
          this.num(denominatorConst),
          this.num(answer + this.pick(i + 4, [1, -1, 2])),
          this.num(a + b),
          this.num(numeratorConst),
        ],
        explanation: `For x near ${c}, the common factor cancels, leaving ${a}x ${this.sign(b)}. Substitute x = ${c}: ${answer}.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const c = this.pick(i, [-2, -1, 1, 2, 3]);
    const answer = 2 * c;

    return this.finish({
      prompt: `Find \\\\\lim\_\{x \\\\to ${c}\} \\\\frac\{x\^2 ${this.sign(-(c * c))}\}\{x ${this.sign(-c)}\}\\.`,
      answer: this.num(answer),
      distractors: [
        this.num(c),
        this.num(c * c),
        this.num(answer + this.pick(i + 1, [1, -1, 2])),
        this.num(-answer),
      ],
      explanation: `Factor the numerator: x² - ${c * c} = (x - ${c})(x + ${c}). After cancellation, substitute x = ${c}. The limit is ${c} + ${c} = ${answer}.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const c = this.pick(i, [1, 2, 3, 4]);
      const answer = 2 * c + 1;

      return this.finish({
        prompt: `Find \\\\\lim\_\{x \\\\to ${c}\} \\\\frac\{x\^2 \+ x ${this.sign(-(c * c + c))}\}\{x ${this.sign(-c)}\}\\.`,
        answer: this.num(answer),
        distractors: [
          this.num(c),
          this.num(2 * c),
          this.num(answer + this.pick(i + 1, [1, -1, 2])),
          this.num(c + 1),
        ],
        explanation: `Factor the numerator: x² + x - (${c * c + c}) = (x - ${c})(x + ${c + 1}). After canceling x - ${c}, substitute x = ${c}. The limit is ${c + c + 1} = ${answer}.`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const c = this.pick(i, [1, 2, 3]);
      const left = 2 * c + 3;
      const right = this.pick(i + 1, [7, 9, 11]);

      return this.finish({
        prompt:
          `A function is defined by ` +
          `f(x) = 2x + 3 for x < ${c}, and f(x) = ${right} for x > ${c}. ` +
          `What is \\\\\lim\_\{x \\\\to ${c}\} f\(x\)\\ if the limit exists?`,
        answer: this.num(left === right ? left : left),
        distractors: [
          this.num(right),
          'Does not exist',
          this.num(c),
          this.num(left + 1),
        ],
        explanation: left === right
          ? `Left-hand limit = ${left} and right-hand limit = ${right}, so both sides match. The limit is ${left}.`
          : `Left-hand limit = ${left}, but right-hand limit = ${right}. Since they are different, the two-sided limit does not exist.`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
        forceAnswer: left === right ? this.num(left) : 'Does not exist',
      });
    }

    const c = this.pick(i, [1, 2, 3, 4]);
    const k = this.pick(i + 1, [2, 3, 4]);
    const answer = k;

    return this.finish({
      prompt: `Find k if \\\\\lim\_\{x \\\\to ${c}\} \\\\frac\{kx ${this.sign(-(k * c))}\}\{x ${this.sign(-c)}\} \= ${k}\\.`,
      answer: this.num(answer),
      distractors: [
        this.num(c),
        this.num(k + 1),
        this.num(k - 1),
        this.num(k + c),
      ],
      explanation: `The numerator is k(x - ${c}), so after canceling x - ${c}, the limit becomes k.`,
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
    forceAnswer?: string;
  }): GeneratedQuestion {
    const correct = args.forceAnswer ?? args.answer;
    const raw = [correct, ...args.distractors];
    const options = uniqueFirst(raw, 4);

    while (options.length < 4) {
      options.push(String((args.seed + 3) * (options.length + 2)));
    }

    const rotated = rotateBySeed(options.slice(0, 4), args.seed);

    return {
      prompt: args.prompt,
      options: rotated,
      correctIndex: rotated.indexOf(correct),
      correctAnswerText: correct,
      explanation: args.explanation,
      recommendedTimeSeconds: args.recommendedTimeSeconds,
      topicMatchNote: 'Limits',
    };
  }

  private num(n: number): string {
    return Number.isInteger(n) ? String(n) : String(Number(n.toFixed(2)));
  }

  private sign(n: number): string {
    if (n === 0) return '+ 0';
    return n > 0 ? `+ ${n}` : `- ${Math.abs(n)}`;
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
