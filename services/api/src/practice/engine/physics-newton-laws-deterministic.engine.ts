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
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase().trim();

    return (
      s === 'physics' &&
      (
        t.includes('newton') ||
        t.includes('f=ma') ||
        t.includes('f = ma') ||
        (t.includes('force') && t.includes('mass') && t.includes('acceleration'))
      ) &&
      !t.includes('friction') &&
      !t.includes('balanced forces') &&
      !t.includes('normal force') &&
      !t.includes('kinematics') &&
      !t.includes('average speed') &&
      !t.includes('average velocity') &&
      !t.includes('distance-time') &&
      !t.includes('wave') &&
      !t.includes('optics') &&
      !t.includes('thermo') &&
      !t.includes('electric') &&
      !t.includes('circuit') &&
      !t.includes('energy') &&
      !t.includes('momentum')
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
    const f = this.pick(i, [8, 10, 12, 15]);
    const m = this.pick(i + 1, [2, 4, 5]);
    const a = f / m;

    return this.finish({
      prompt: `A net force of ${f} N acts on a mass of ${m} kg. What is the acceleration?`,
      answer: `${this.num(a)} m/s²`,
      distractors: [
        `${this.num(a + 1)} m/s²`,
        `${f} m/s²`,
        `${m} m/s²`,
      ],
      explanation: `Newton's second law gives a = F/m = ${f}/${m} = ${this.num(a)} m/s².`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const m = this.pick(i, [2, 3, 4, 5]);
      const a = this.pick(i + 1, [2, 3, 4, 5]);
      const f = m * a;

      return this.finish({
        prompt: `What net force is needed to accelerate a ${m} kg object at ${a} m/s²?`,
        answer: `${f} N`,
        distractors: [
          `${m + a} N`,
          `${f + m} N`,
          `${a} N`,
        ],
        explanation: `Using F = ma, the force is ${m}×${a} = ${f} N.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const f1 = this.pick(i, [18, 20, 24, 30]);
    const f2 = this.pick(i + 1, [6, 8, 10, 12]);
    const m = this.pick(i + 2, [2, 3, 4, 6]);
    const net = f1 - f2;
    const a = net / m;

    return this.finish({
      prompt: `A force of ${f1} N acts to the right and ${f2} N acts to the left on a ${m} kg object. What is its acceleration?`,
      answer: `${this.num(a)} m/s² to the right`,
      distractors: [
        `${this.num(a)} m/s² to the left`,
        `${net} m/s² to the right`,
        `${this.num(a + 1)} m/s² to the right`,
      ],
      explanation: `Net force = ${f1} - ${f2} = ${net} N to the right. Then a = F_net/m = ${net}/${m} = ${this.num(a)} m/s² to the right.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const f = this.pick(i, [24, 30, 36, 42]);
      const a = this.pick(i + 1, [3, 4, 6]);
      const m = f / a;

      return this.finish({
        prompt: `A net force of ${f} N produces an acceleration of ${a} m/s². What is the mass of the object?`,
        answer: `${this.num(m)} kg`,
        distractors: [
          `${this.num(m + 1)} kg`,
          `${this.num(f / 2)} kg`,
          `${this.num(a)} kg`,
        ],
        explanation: `Rearrange F = ma to m = F/a = ${f}/${a} = ${this.num(m)} kg.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      return this.finish({
        prompt: `Which statement is correct according to Newton's first law?`,
        answer: `An object with zero net force stays at rest or moves with constant velocity`,
        distractors: [
          `Any moving object must have a net force in its direction of motion`,
          `A larger mass always means a larger acceleration`,
          `For every force there is a larger opposite force`,
        ],
        explanation: `Newton's first law says zero net force means no acceleration, so velocity stays constant.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const m = this.pick(i, [5, 6, 8]);
    const f1 = this.pick(i + 1, [50, 60, 72]);
    const f2 = this.pick(i + 2, [10, 12, 16]);
    const net = f1 - f2;
    const a = net / m;

    return this.finish({
      prompt: `A ${m} kg cart is pulled right by ${f1} N while friction of ${f2} N acts left. What is the cart's acceleration?`,
      answer: `${this.num(a)} m/s² to the right`,
      distractors: [
        `${this.num(a)} m/s² to the left`,
        `${net} m/s² to the right`,
        `${this.num(a + 2)} m/s² to the right`,
      ],
      explanation: `Net force = ${f1} - ${f2} = ${net} N right. Then a = ${net}/${m} = ${this.num(a)} m/s² right.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const m = this.pick(i, [3, 4, 5, 6]);
    const f1 = this.pick(i + 1, [36, 42, 48, 54]);
    const f2 = this.pick(i + 2, [6, 8, 12, 14]);
    const f3 = this.pick(i + 3, [4, 5, 6, 8]);
    const net = f1 - f2 - f3;
    const a = net / m;

    return this.finish({
      prompt: `Three horizontal forces act on a ${m} kg object: ${f1} N right, ${f2} N left, and ${f3} N left. What is its acceleration?`,
      answer: `${this.num(a)} m/s² to the right`,
      distractors: [
        `${this.num(a)} m/s² to the left`,
        `${net} m/s² to the right`,
        `${this.num(a + 1)} m/s² to the right`,
      ],
      explanation: `Net force = ${f1} - ${f2} - ${f3} = ${net} N right. Then a = ${net}/${m} = ${this.num(a)} m/s² right.`,
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
