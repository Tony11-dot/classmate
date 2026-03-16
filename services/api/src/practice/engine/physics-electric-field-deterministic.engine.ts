import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class PhysicsElectricFieldDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase().trim();
    return s === 'physics' && (t.includes('electric field') || t.includes('field strength'));
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

  private makeQuestion(i: number, difficulty: EngineDifficulty, overrideSeconds: number | null): GeneratedQuestion {
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
    const f = this.pick(i, [6, 8, 10, 12]);
    const q = this.pick(i + 1, [2, 4]);
    const e = f / q;

    return this.finish({
      prompt: `A positive charge of ${q} C experiences a force of ${f} N in an electric field. What is the electric field strength?`,
      answer: `${this.num(e)} N/C`,
      distractors: [`${this.num(e + 1)} N/C`, `${f} N/C`, `${q} N/C`],
      explanation: `Electric field strength E = F/q = ${f}/${q} = ${this.num(e)} N/C.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const e = this.pick(i, [3, 4, 5, 6]);
      const q = this.pick(i + 1, [2, 3, 4]);
      const f = e * q;

      return this.finish({
        prompt: `A charge of ${q} C is placed in an electric field of strength ${e} N/C. What force acts on the charge?`,
        answer: `${f} N`,
        distractors: [`${f + e} N`, `${q} N`, `${e} N`],
        explanation: `Force in an electric field is F = qE = ${q}×${e} = ${f} N.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const e = this.pick(i, [8, 10, 12, 14]);
    const q = this.pick(i + 1, [1, 2, 3]);
    const f = e * q;

    return this.finish({
      prompt: `What force acts on a ${q} C charge in an electric field of ${e} N/C?`,
      answer: `${f} N`,
      distractors: [`${f + 2} N`, `${e - q} N`, `${q + e} N`],
      explanation: `Use F = qE = ${q}×${e} = ${f} N.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const v = this.pick(i, [12, 18, 24, 30]);
      const d = this.pick(i + 1, [2, 3, 4, 5]);
      const e = v / d;

      return this.finish({
        prompt: `The potential difference between two plates is ${v} V and their separation is ${d} m. Assuming a uniform field, what is the electric field strength?`,
        answer: `${this.num(e)} V/m`,
        distractors: [`${this.num(e + 1)} V/m`, `${v * d} V/m`, `${this.num(d / v)} V/m`],
        explanation: `For a uniform electric field, E = V/d = ${v}/${d} = ${this.num(e)} V/m.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const f = this.pick(i, [9, 12, 15, 18]);
    const e = this.pick(i + 1, [3, 4, 5, 6]);
    const q = f / e;

    return this.finish({
      prompt: `A charge experiences a force of ${f} N in an electric field of ${e} N/C. What is the charge?`,
      answer: `${this.num(q)} C`,
      distractors: [`${this.num(q + 1)} C`, `${this.num(f + e)} C`, `${this.num(e)} C`],
      explanation: `Since E = F/q, then q = F/E = ${f}/${e} = ${this.num(q)} C.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const e = this.pick(i, [20, 24, 28, 32]);
    const q = this.pick(i + 1, [0.5, 1, 1.5, 2]);
    const f = e * q;

    return this.finish({
      prompt: `A charge of ${this.num(q)} C is placed in a uniform electric field of ${e} N/C. What is the magnitude of the electric force on it?`,
      answer: `${this.num(f)} N`,
      distractors: [`${this.num(f + 2)} N`, `${this.num(e - q)} N`, `${this.num(q)} N`],
      explanation: `Use F = qE = ${this.num(q)}×${e} = ${this.num(f)} N.`,
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
      options.push(`${args.answer}_${options.length + args.seed}`);
    }

    const rotated = rotateBySeed(options.slice(0, 4), args.seed);

    return {
      prompt: args.prompt,
      options: rotated,
      correctIndex: rotated.indexOf(args.answer),
      correctAnswerText: args.answer,
      explanation: args.explanation,
      recommendedTimeSeconds: args.recommendedTimeSeconds,
      topicMatchNote: 'Physics Electric Field',
    };
  }

  private num(n: number): string {
    return Number.isInteger(n) ? String(n) : String(Number(n.toFixed(2)));
  }

  private timeFor(difficulty: EngineDifficulty, overrideSeconds: number | null): number {
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
