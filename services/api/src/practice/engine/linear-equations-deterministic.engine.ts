import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';

@Injectable()
export class LinearEquationsDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`
      .toLowerCase()
      .trim();

    const isSystemTopic =
      t.includes('system of equations') ||
      t.includes('systems of equations') ||
      t.includes('simultaneous equations') ||
      (t.includes('system') && t.includes('equation'));

    if (isSystemTopic) return false;

    return (
      s === 'math' &&
      (
        t.includes('linear equation') ||
        t.includes('linear equations') ||
        t.includes('solve for x') ||
        t.includes('one-variable equation') ||
        t.includes('one variable equation') ||
        (t.includes('linear') && !t.includes('quadratic'))
      )
    );
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]> {
    const out: GeneratedQuestion[] = [];

    for (let i = 0; i < req.questionCount; i++) {
      out.push(this.makeQuestion(i, req.difficulty, req.timePreferenceSeconds));
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
    const answer = this.pick(i, [-6, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6]);
    const a = this.pick(i + 1, [2, 3, 4, 5, 6, 7, 8]);
    const c = this.pick(i + 2, [-9, -7, -4, -1, 2, 5, 8, 11, 14]);
    const b = c - a * answer;

    const prompt = `Solve for x: ${this.linearExpr(a, b)} = ${c}`;
    const explanation =
      `Subtract ${this.wrapSigned(b)} from both sides: ${a}x = ${c - b}. ` +
      `Then divide by ${a}: x = ${answer}.`;

    return this.finish(answer, prompt, explanation, this.timeFor('easy', overrideSeconds), i);
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const answer = this.pick(i, [-5, -4, -3, -2, -1, 1, 2, 3, 4, 5]);
    const left = this.pick(i + 1, [3, 4, 5, 6, 7, 8]);
    const right = this.pick(i + 2, [1, 2, 3, 4]);
    const b = this.pick(i + 3, [-8, -5, -2, 1, 4, 7, 10]);
    const d = (left - right) * answer + b;

    const prompt = `Solve for x: ${this.linearExpr(left, b)} = ${this.linearExpr(right, d)}`;
    const explanation =
      `Move the x terms to one side and the constants to the other: ` +
      `${left}x - ${right}x = ${d} ${this.oppositeSigned(b)}. ` +
      `So ${left - right}x = ${d - b}, and x = ${answer}.`;

    return this.finish(answer, prompt, explanation, this.timeFor('medium', overrideSeconds), i);
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const answer = this.pick(i, [-4, -3, -2, -1, 1, 2, 3, 4]);
    const p = this.pick(i + 1, [2, 3, 4, 5]);
    const a = this.pick(i + 2, [1, 2, 3]);
    const b = this.pick(i + 3, [-5, -3, -2, 1, 2, 4]);
    const q = this.pick(i + 4, [1, 2, 3, 4]);
    const c = p * (a * answer + b) - q * answer;

    const prompt = `Solve for x: ${p}(${this.linearExpr(a, b)}) = ${this.linearExpr(q, c)}`;
    const explanation =
      `Expand the left side: ${p * a}x ${this.signPart(p * b)} = ${this.linearExpr(q, c)}. ` +
      `Move ${q}x to the left: ${p * a - q}x ${this.signPart(p * b)} = ${c}. ` +
      `Then ${p * a - q}x = ${c - p * b}, so x = ${answer}.`;

    return this.finish(answer, prompt, explanation, this.timeFor('hard', overrideSeconds), i);
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const answer = this.pick(i, [-3, -2, -1, 1, 2, 3, 4]);
    const a = this.pick(i + 1, [2, 3, 4, 5]);
    const b = this.pick(i + 2, [-4, -2, 1, 3, 5]);
    const c = this.pick(i + 3, [1, 2, 3]);
    const d = this.pick(i + 4, [1, 2, 3, 4]);
    const e = this.pick(i + 5, [-3, -1, 2, 4]);
    const leftValue = a * (answer + b) - c;
    const f = leftValue - d * (answer + e);

    const prompt =
      `Solve for x: ${a}(x ${this.signPart(b)}) - ${c} = ${d}(x ${this.signPart(e)}) ${f >= 0 ? '+' : '-'} ${Math.abs(f)}`;
    const explanation =
      `Expand both sides: ${a}x ${this.signPart(a * b - c)} = ${d}x ${this.signPart(d * e + f)}. ` +
      `Move the x terms together: ${a - d}x = ${d * e + f - (a * b - c)}. ` +
      `So x = ${answer}.`;

    return this.finish(answer, prompt, explanation, this.timeFor('olympiad', overrideSeconds), i);
  }

  private finish(
    answer: number,
    prompt: string,
    explanation: string,
    recommendedTimeSeconds: number,
    i: number,
  ): GeneratedQuestion {
    const correct = String(answer);
    const options = this.makeOptions(answer, i);

    return {
      prompt,
      options,
      correctIndex: options.indexOf(correct),
      correctAnswerText: correct,
      explanation,
      recommendedTimeSeconds,
      topicMatchNote: 'Linear equations',
    };
  }

  private makeOptions(answer: number, i: number): string[] {
    const raw = [
      answer,
      answer + this.pick(i + 1, [1, 2, -1, -2]),
      -answer === answer ? answer + 3 : -answer,
      answer + this.pick(i + 2, [3, -3, 4, -4]),
      answer + this.pick(i + 3, [5, -5, 6, -6]),
    ];

    const unique: number[] = [];
    for (const n of raw) {
      if (!unique.includes(n)) unique.push(n);
      if (unique.length === 4) break;
    }

    while (unique.length < 4) {
      const next = answer + 7 + unique.length;
      if (!unique.includes(next)) unique.push(next);
    }

    return unique.slice(0, 4).map(String);
  }

  private timeFor(
    difficulty: EngineDifficulty,
    overrideSeconds: number | null,
  ): number {
    if (overrideSeconds != null && Number.isFinite(overrideSeconds)) {
      return Math.max(5, Math.min(900, Math.round(overrideSeconds)));
    }

    switch (difficulty) {
      case 'easy':
        return 25;
      case 'medium':
      case 'adaptive':
        return 40;
      case 'hard':
        return 60;
      case 'olympiad':
        return 80;
      default:
        return 40;
    }
  }

  private linearExpr(coeff: number, constant: number): string {
    if (constant === 0) return `${coeff}x`;
    return `${coeff}x ${constant >= 0 ? '+' : '-'} ${Math.abs(constant)}`;
  }

  private wrapSigned(value: number): string {
    return value >= 0 ? String(value) : `(${value})`;
  }

  private oppositeSigned(value: number): string {
    return value >= 0 ? `- ${value}` : `+ ${Math.abs(value)}`;
  }

  private signPart(value: number): string {
    return value >= 0 ? `+ ${value}` : `- ${Math.abs(value)}`;
  }

  private pick<T>(i: number, arr: T[]): T {
    return arr[((i % arr.length) + arr.length) % arr.length];
  }
}
