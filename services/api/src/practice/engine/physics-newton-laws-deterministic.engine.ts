import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class PhysicsNewtonLawsDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`
      .toLowerCase()
      .trim();

    return (
      s === 'physics' &&
      (
        t.includes('newton') ||
        t.includes('second law') ||
        t.includes('f = ma') ||
        t.includes('force, mass, acceleration') ||
        t.includes('force mass acceleration')
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
    const m = this.pick(i, [2, 3, 4, 5]);
    const a = this.pick(i + 1, [2, 3, 4]);
    const f = m * a;

    return this.finish({
      prompt: `A mass of ${m} kg accelerates at ${a} m/s². What force acts on it?`,
      answer: `${f} N`,
      distractors: [
        `${m + a} N`,
        `${m} N`,
        `${a} N`,
        `${f + 2} N`,
      ],
      explanation: `Use Newton's second law: F = ma = ${m}×${a} = ${f} N.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const m = this.pick(i, [4, 5, 6, 8]);
      const a = this.pick(i + 1, [2, 3, 4]);
      const f = m * a;

      return this.finish({
        prompt: `An object with mass ${m} kg accelerates at ${a} m/s². According to Newton's second law, what is the force on it?`,
        answer: `${f} N`,
        distractors: [
          `${m + a} N`,
          `${f + 5} N`,
          `${Math.max(1, f - 5)} N`,
          `${m * (a + 1)} N`,
        ],
        explanation: `F = ma = ${m}×${a} = ${f} N.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const f = this.pick(i, [12, 18, 20, 24]);
      const m = this.pick(i + 1, [3, 4, 5, 6]);
      const a = f / m;

      return this.finish({
        prompt: `A force of ${f} N acts on a mass of ${m} kg. What is the acceleration?`,
        answer: `${this.num(a)} m/s²`,
        distractors: [
          `${f * m} m/s²`,
          `${m / f} m/s²`,
          `${this.num(a + 2)} m/s²`,
          `${this.num(Math.max(0.5, a - 1))} m/s²`,
        ],
        explanation: `a = F/m = ${f}/${m} = ${this.num(a)} m/s².`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const f = this.pick(i, [16, 20, 24, 30]);
    const a = this.pick(i + 1, [2, 4, 5, 6]);
    const m = f / a;

    return this.finish({
      prompt: `An object experiences a force of ${f} N and accelerates at ${a} m/s². What is its mass?`,
      answer: `${this.num(m)} kg`,
      distractors: [
        `${f * a} kg`,
        `${f + a} kg`,
        `${this.num(m + 2)} kg`,
        `${this.num(Math.max(1, m - 1))} kg`,
      ],
      explanation: `m = F/a = ${f}/${a} = ${this.num(m)} kg.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const m = this.pick(i, [3, 4, 5, 6]);
      const a1 = this.pick(i + 1, [2, 3, 4]);
      const f1 = m * a1;
      const answer = `${2 * f1} N`;

      return this.finish({
        prompt: `A ${m} kg body has acceleration ${a1} m/s² under a certain force. If the acceleration doubles while mass stays constant, what is the new force?`,
        answer,
        distractors: [
          `${f1} N`,
          `${4 * f1} N`,
          `${f1 / 2} N`,
          `${2 * f1 + 2} N`,
        ],
        explanation: `Since F = ma, doubling acceleration doubles force. Original force = ${m}×${a1} = ${f1} N, so new force = ${2 * f1} N.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const m = this.pick(i, [5, 8, 10]);
      const net = 0;

      return this.finish({
        prompt: `A ${m} kg object has net force ${net} N acting on it. What is its acceleration?`,
        answer: `0 m/s²`,
        distractors: [
          `${m} m/s²`,
          `1 m/s²`,
          `10 m/s²`,
          `${m * 2} m/s²`,
        ],
        explanation: `By Newton's second law, a = F/m = 0/${m} = 0 m/s².`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const f = this.pick(i, [24, 30, 36]);
    const m = this.pick(i + 1, [3, 4, 6]);
    const a = f / m;
    const t = this.pick(i + 2, [2, 3, 4]);
    const v = a * t;

    return this.finish({
      prompt: `A force of ${f} N acts on a ${m} kg object initially at rest for ${t} s. What speed does it reach?`,
      answer: `${this.num(v)} m/s`,
      distractors: [
        `${this.num(a)} m/s`,
        `${this.num(f * t)} m/s`,
        `${this.num(v + 2)} m/s`,
        `${this.num(Math.max(1, v - 2))} m/s`,
      ],
      explanation: `First find acceleration: a = F/m = ${f}/${m} = ${this.num(a)} m/s². Starting from rest, v = at = ${this.num(a)}×${t} = ${this.num(v)} m/s.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const m = this.pick(i, [2, 3, 4]);
      const a = this.pick(i + 1, [3, 4, 5]);
      const f = m * a;
      const t = this.pick(i + 2, [2, 3, 4]);
      const impulseLikeChange = f * t;

      return this.finish({
        prompt: `A constant net force of ${f} N acts on a ${m} kg object for ${t} s, starting from rest. What is the change in momentum?`,
        answer: `${impulseLikeChange} kg·m/s`,
        distractors: [
          `${f + t} kg·m/s`,
          `${m * t} kg·m/s`,
          `${impulseLikeChange + 2} kg·m/s`,
          `${Math.max(1, impulseLikeChange - 2)} kg·m/s`,
        ],
        explanation: `Change in momentum = Ft = ${f}×${t} = ${impulseLikeChange} kg·m/s.`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const f = this.pick(i, [18, 24, 30]);
      const a = this.pick(i + 1, [3, 4, 5]);
      const m = f / a;

      return this.finish({
        prompt: `Two objects experience the same force. One has acceleration ${a} m/s² under force ${f} N. What is its mass?`,
        answer: `${this.num(m)} kg`,
        distractors: [
          `${this.num(f * a)} kg`,
          `${this.num(a / f)} kg`,
          `${this.num(m + 2)} kg`,
          `${this.num(Math.max(1, m - 1))} kg`,
        ],
        explanation: `From Newton's second law, m = F/a = ${f}/${a} = ${this.num(m)} kg.`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
      });
    }

    const m = this.pick(i, [4, 5, 6]);
    const f1 = this.pick(i + 1, [10, 12, 15]);
    const f2 = this.pick(i + 2, [2, 3, 5]);
    const net = f1 - f2;
    const a = net / m;

    return this.finish({
      prompt: `A ${m} kg object is pulled right by ${f1} N and left by ${f2} N. What is its acceleration?`,
      answer: `${this.num(a)} m/s²`,
      distractors: [
        `${this.num((f1 + f2) / m)} m/s²`,
        `${this.num(net)} m/s²`,
        `${this.num(a + 1)} m/s²`,
        `${this.num(Math.max(0.5, a - 1))} m/s²`,
      ],
      explanation: `Net force = ${f1} - ${f2} = ${net} N. Then a = F_net/m = ${net}/${m} = ${this.num(a)} m/s².`,
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
      topicMatchNote: 'Physics Newton Laws',
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
