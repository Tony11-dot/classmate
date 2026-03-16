import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  GeneratedQuestion as GQ,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class PhysicsMomentumDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`
      .toLowerCase()
      .trim();

    return (
      s === 'physics' &&
      (
        t.includes('momentum') ||
        t.includes('impulse') ||
        t.includes('collision')
      )
    );
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]> {
    const out: GQ[] = [];
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
  ): GQ {
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

  private makeEasy(i: number, overrideSeconds: number | null): GQ {
    const m = this.pick(i, [2, 3, 4, 5]);
    const v = this.pick(i + 1, [3, 4, 5, 6]);
    const p = m * v;

    return this.finish({
      prompt: `An object of mass ${m} kg moves at ${v} m/s. What is its momentum?`,
      answer: `${p} kg·m/s`,
      distractors: [
        `${m + v} kg·m/s`,
        `${m} kg·m/s`,
        `${v} kg·m/s`,
        `${p + 2} kg·m/s`,
      ],
      explanation: `Momentum p = mv = ${m}×${v} = ${p} kg·m/s.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GQ {
    const mode = i % 3;

    if (mode === 0) {
      const m = this.pick(i, [2, 3, 4, 5]);
      const v = this.pick(i + 1, [4, 5, 6, 8]);
      const p = m * v;

      return this.finish({
        prompt: `A body of mass ${m} kg travels at ${v} m/s. Find its momentum.`,
        answer: `${p} kg·m/s`,
        distractors: [
          `${m + v} kg·m/s`,
          `${p + 4} kg·m/s`,
          `${Math.max(1, p - 4)} kg·m/s`,
          `${m * v * 2} kg·m/s`,
        ],
        explanation: `Momentum = mass × velocity = ${m}×${v} = ${p} kg·m/s.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const f = this.pick(i, [6, 8, 10, 12]);
      const t = this.pick(i + 1, [2, 3, 4, 5]);
      const j = f * t;

      return this.finish({
        prompt: `A force of ${f} N acts on an object for ${t} s. What is the impulse delivered?`,
        answer: `${j} N·s`,
        distractors: [
          `${f + t} N·s`,
          `${j + 3} N·s`,
          `${Math.max(1, j - 3)} N·s`,
          `${f} N·s`,
        ],
        explanation: `Impulse = force × time = ${f}×${t} = ${j} N·s.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const m = this.pick(i, [2, 4, 5]);
    const p = this.pick(i + 1, [12, 16, 20, 24]);
    const v = p / m;

    return this.finish({
      prompt: `An object has mass ${m} kg and momentum ${p} kg·m/s. What is its velocity?`,
      answer: `${this.num(v)} m/s`,
      distractors: [
        `${p} m/s`,
        `${m} m/s`,
        `${this.num(v + 2)} m/s`,
        `${this.num(Math.max(1, v - 1))} m/s`,
      ],
      explanation: `Since p = mv, velocity v = p/m = ${p}/${m} = ${this.num(v)} m/s.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GQ {
    const mode = i % 5;

    if (mode === 0) {
      const m = this.pick(i, [2, 3, 4]);
      const u = this.pick(i + 1, [2, 4, 6]);
      const v = this.pick(i + 2, [8, 10, 12]);
      const dp = m * (v - u);

      return this.finish({
        prompt: `A ${m} kg object changes speed from ${u} m/s to ${v} m/s in the same direction. What is the change in momentum?`,
        answer: `${dp} kg·m/s`,
        distractors: [
          `${m * v} kg·m/s`,
          `${m * u} kg·m/s`,
          `${dp + m} kg·m/s`,
          `${Math.max(1, dp - m)} kg·m/s`,
        ],
        explanation: `Change in momentum = m(v - u) = ${m}×(${v} - ${u}) = ${dp} kg·m/s.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const f = this.pick(i, [10, 12, 15]);
      const t = this.pick(i + 1, [2, 3, 4]);
      const m = this.pick(i + 2, [2, 3, 5]);
      const dv = (f * t) / m;

      return this.finish({
        prompt: `A constant force of ${f} N acts on a ${m} kg object initially at rest for ${t} s. What speed does it gain?`,
        answer: `${this.num(dv)} m/s`,
        distractors: [
          `${f * t} m/s`,
          `${this.num((f * t) / (m * 2))} m/s`,
          `${this.num(dv + 2)} m/s`,
          `${this.num(Math.max(0.5, dv - 1.5))} m/s`,
        ],
        explanation: `Impulse Ft equals change in momentum mΔv. So Δv = Ft/m = (${f}×${t})/${m} = ${this.num(dv)} m/s.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 2) {
      const m1 = this.pick(i, [1, 2, 3]);
      const u1 = this.pick(i + 1, [6, 8, 10]);
      const m2 = this.pick(i + 2, [1, 2, 4]);
      const v = (m1 * u1) / (m1 + m2);

      return this.finish({
        prompt: `A ${m1} kg cart moving at ${u1} m/s sticks to a ${m2} kg cart at rest. What is their common speed after collision?`,
        answer: `${this.num(v)} m/s`,
        distractors: [
          `${u1} m/s`,
          `${this.num((m1 * u1) / m2)} m/s`,
          `${this.num(v + 2)} m/s`,
          `${this.num(Math.max(0.5, v - 1))} m/s`,
        ],
        explanation: `Conservation of momentum gives v = (m₁u₁ + m₂u₂)/(m₁ + m₂) = (${m1}×${u1} + ${m2}×0)/${m1 + m2} = ${this.num(v)} m/s.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 3) {
      const m = this.pick(i, [0.2, 0.5, 1]);
      const u = this.pick(i + 1, [10, 12, 15]);
      const v = -this.pick(i + 2, [4, 5, 6]);
      const j = m * Math.abs(v - u);

      return this.finish({
        prompt: `A ball of mass ${this.num(m)} kg moves toward a wall at ${u} m/s and rebounds at ${Math.abs(v)} m/s. What is the magnitude of the impulse on the ball?`,
        answer: `${this.num(j)} Ns`,
        distractors: [
          `${this.num(m * u)} Ns`,
          `${this.num(m * Math.abs(v))} Ns`,
          `${this.num(j + 1)} Ns`,
          `${this.num(Math.max(0.1, j - 0.8))} Ns`,
        ],
        explanation: `Impulse magnitude equals change in momentum magnitude: J = m|v - u| = ${this.num(m)}×|${v} - ${u}| = ${this.num(j)} Ns.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const m1 = this.pick(i, [10, 12, 15]);
    const m2 = this.pick(i + 1, [20, 18, 25]);
    const u1 = this.pick(i + 2, [6, 8, 10]);
    const v1 = ((m1 - m2) / (m1 + m2)) * u1;

    return this.finish({
      prompt: `A ${m1} kg object moving at ${u1} m/s collides elastically with a stationary ${m2} kg object. What is the velocity of the first object after the collision?`,
      answer: `${this.num(v1)} m/s`,
      distractors: [
        `${u1} m/s`,
        `${this.num(-u1)} m/s`,
        `${this.num(v1 + 2)} m/s`,
        `${this.num(v1 - 2)} m/s`,
      ],
      explanation: `For a 1D elastic collision with the second mass initially at rest, v₁ = ((m₁-m₂)/(m₁+m₂))u₁ = ((${m1}-${m2})/${m1 + m2})×${u1} = ${this.num(v1)} m/s.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GQ {
    const mode = i % 3;

    if (mode === 0) {
      const m = this.pick(i, [2, 4, 5]);
      const u = this.pick(i + 1, [10, 12, 15]);
      const v = this.pick(i + 2, [4, 6, 9]);
      const dp = m * (u - v);

      return this.finish({
        prompt: `A ${m} kg object slows from ${u} m/s to ${v} m/s. What is the magnitude of the impulse on it?`,
        answer: `${dp} N·s`,
        distractors: [
          `${m * u} N·s`,
          `${m * v} N·s`,
          `${dp + 5} N·s`,
          `${Math.max(1, dp - 5)} N·s`,
        ],
        explanation: `Impulse magnitude equals change in momentum: m(u - v) = ${m}×(${u} - ${v}) = ${dp} N·s.`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const m1 = this.pick(i, [1, 2, 3]);
      const u1 = this.pick(i + 1, [8, 10, 12]);
      const m2 = this.pick(i + 2, [1, 2, 3]);
      const u2 = this.pick(i + 3, [2, 4]);
      const total = m1 * u1 + m2 * u2;

      return this.finish({
        prompt: `Two objects move in the same direction: m₁=${m1} kg at ${u1} m/s and m₂=${m2} kg at ${u2} m/s. What is the total momentum?`,
        answer: `${total} kg·m/s`,
        distractors: [
          `${m1 + m2 + u1 + u2} kg·m/s`,
          `${m1 * u1} kg·m/s`,
          `${total + 4} kg·m/s`,
          `${Math.max(1, total - 4)} kg·m/s`,
        ],
        explanation: `Total momentum is the sum: m₁u₁ + m₂u₂ = ${m1}×${u1} + ${m2}×${u2} = ${total} kg·m/s.`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
      });
    }

    const m1 = this.pick(i, [1, 2, 3]);
    const u1 = this.pick(i + 1, [12, 15, 18]);
    const m2 = this.pick(i + 2, [1, 2, 3]);
    const u2 = 0;
    const v = (m1 * u1) / (m1 + m2);

    return this.finish({
      prompt: `A moving body of mass ${m1} kg and speed ${u1} m/s collides and sticks to a stationary body of mass ${m2} kg. What is the final speed?`,
      answer: `${this.num(v)} m/s`,
      distractors: [
        `${u1} m/s`,
        `${this.num(u1 / 2)} m/s`,
        `${this.num(v + 1)} m/s`,
        `${this.num(Math.max(1, v - 1))} m/s`,
      ],
      explanation: `Using momentum conservation for a perfectly inelastic collision: v = (m₁u₁)/(m₁ + m₂) = (${m1}×${u1})/${m1 + m2} = ${this.num(v)} m/s.`,
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
  }): GQ {
    const raw = [args.answer, ...args.distractors];
    const options = uniqueFirst(raw, 4);

    while (options.length < 4) {
      options.push(`__BAD_DUP___`);
    }

    const rotated = rotateBySeed(options.slice(0, 4), args.seed);

    return {
      prompt: args.prompt,
      options: rotated,
      correctIndex: rotated.indexOf(args.answer),
      correctAnswerText: args.answer,
      explanation: args.explanation,
      recommendedTimeSeconds: args.recommendedTimeSeconds,
      topicMatchNote: 'Physics Momentum',
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
