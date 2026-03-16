import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class PhysicsEnergyDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`
      .toLowerCase()
      .trim();

    return (
      s === 'physics' &&
      (
        t.includes('energy') ||
        t.includes('work') ||
        t.includes('kinetic') ||
        t.includes('potential') ||
        t.includes('conservation of energy')
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
    const f = this.pick(i, [10, 15, 20, 25]);
    const d = this.pick(i + 1, [2, 3, 4, 5]);
    const w = f * d;

    return this.finish({
      prompt: `A constant force of ${f} N moves an object ${d} m in the same direction. How much work is done?`,
      answer: `${w} J`,
      distractors: [
        `${f + d} J`,
        `${f} J`,
        `${d} J`,
        `${w + 5} J`,
      ],
      explanation: `Work = force × distance = ${f} × ${d} = ${w} J.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const m = this.pick(i, [2, 3, 4, 5]);
      const v = this.pick(i + 1, [4, 6, 8, 10]);
      const ke = 0.5 * m * v * v;

      return this.finish({
        prompt: `An object of mass ${m} kg moves at ${v} m/s. What is its kinetic energy?`,
        answer: `${this.num(ke)} J`,
        distractors: [
          `${m * v} J`,
          `${m * v * v} J`,
          `${this.num(ke + 4)} J`,
          `${this.num(Math.max(1, ke - 4))} J`,
        ],
        explanation: `Kinetic energy = ½mv² = ½×${m}×${v}² = ${this.num(ke)} J.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const m = this.pick(i, [2, 3, 5, 6]);
      const h = this.pick(i + 1, [2, 4, 5, 8]);
      const g = 10;
      const pe = m * g * h;

      return this.finish({
        prompt: `A ${m} kg object is lifted to height ${h} m. Take g = ${g} m/s². What is its gravitational potential energy?`,
        answer: `${pe} J`,
        distractors: [
          `${m * h} J`,
          `${m * g} J`,
          `${pe + 10} J`,
          `${Math.max(1, pe - 10)} J`,
        ],
        explanation: `Potential energy = mgh = ${m}×${g}×${h} = ${pe} J.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const f = this.pick(i, [12, 15, 18, 20]);
    const d = this.pick(i + 1, [3, 4, 5, 6]);
    const w = f * d;

    return this.finish({
      prompt: `A force of ${f} N acts through a distance of ${d} m in the same direction as motion. What work is done?`,
      answer: `${w} J`,
      distractors: [
        `${f + d} J`,
        `${f * d + 6} J`,
        `${Math.max(1, f * d - 6)} J`,
        `${f} J`,
      ],
      explanation: `Work = Fd = ${f}×${d} = ${w} J.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const m = this.pick(i, [2, 4, 6]);
      const h = this.pick(i + 1, [5, 8, 10]);
      const g = 10;
      const pe = m * g * h;

      return this.finish({
        prompt: `A ${m} kg object starts from rest at height ${h} m. Ignore air resistance and take g = ${g} m/s². What is its kinetic energy just before hitting the ground?`,
        answer: `${pe} J`,
        distractors: [
          `${m * h} J`,
          `${pe / 2} J`,
          `${pe + 20} J`,
          `${Math.max(1, pe - 20)} J`,
        ],
        explanation: `By conservation of energy, all initial potential energy becomes kinetic energy. KE = mgh = ${m}×${g}×${h} = ${pe} J.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const m = this.pick(i, [2, 3, 5]);
      const v = this.pick(i + 1, [6, 8, 10]);
      const ke = 0.5 * m * v * v;
      const h = ke / (m * 10);

      return this.finish({
        prompt: `A ${m} kg object has kinetic energy ${this.num(ke)} J. Taking g = 10 m/s², to what height could it rise if all this energy converted to gravitational potential energy?`,
        answer: `${this.num(h)} m`,
        distractors: [
          `${this.num(ke / m)} m`,
          `${this.num(h + 2)} m`,
          `${this.num(Math.max(1, h - 1))} m`,
          `${m} m`,
        ],
        explanation: `Set KE = PE, so ${this.num(ke)} = ${m}×10×h. Hence h = ${this.num(ke)}/${m * 10} = ${this.num(h)} m.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const p = this.pick(i, [40, 60, 80]);
    const t = this.pick(i + 1, [2, 4, 5]);
    const e = p * t;

    return this.finish({
      prompt: `A machine uses power ${p} W for ${t} s. How much energy does it transfer?`,
      answer: `${e} J`,
      distractors: [
        `${p + t} J`,
        `${e + 10} J`,
        `${Math.max(1, e - 10)} J`,
        `${p} J`,
      ],
      explanation: `Energy transferred = power × time = ${p} × ${t} = ${e} J.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const m = this.pick(i, [1, 2, 4]);
      const h1 = this.pick(i + 1, [10, 12, 15]);
      const h2 = this.pick(i + 2, [2, 4, 5]);
      const g = 10;
      const delta = m * g * (h1 - h2);

      return this.finish({
        prompt: `A ${m} kg object falls from ${h1} m to ${h2} m. Ignore air resistance and take g = ${g} m/s². By how much does its kinetic energy increase?`,
        answer: `${delta} J`,
        distractors: [
          `${m * g * h1} J`,
          `${m * g * h2} J`,
          `${delta + 10} J`,
          `${Math.max(1, delta - 10)} J`,
        ],
        explanation: `The increase in kinetic energy equals the loss in potential energy: mg(h₁ - h₂) = ${m}×${g}×(${h1} - ${h2}) = ${delta} J.`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const f = this.pick(i, [10, 12, 15]);
      const d = this.pick(i + 1, [4, 5, 6]);
      const angleFact = 0.5;
      const w = f * d * angleFact;

      return this.finish({
        prompt: `A force of ${f} N acts on an object through ${d} m, but only half the force is in the direction of motion. How much work is done?`,
        answer: `${this.num(w)} J`,
        distractors: [
          `${f * d} J`,
          `${f + d} J`,
          `${this.num(w + 5)} J`,
          `${this.num(Math.max(1, w - 5))} J`,
        ],
        explanation: `Only the component along the motion does work. Effective force = ${f}/2, so work = (${f}/2)×${d} = ${this.num(w)} J.`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
      });
    }

    const m = this.pick(i, [2, 3, 4]);
    const v = this.pick(i + 1, [10, 12, 14]);
    const ke = 0.5 * m * v * v;
    const p = this.pick(i + 2, [50, 60, 75]);
    const t = ke / p;

    return this.finish({
      prompt: `A machine delivers constant power ${p} W to give a ${m} kg object speed ${v} m/s from rest. Ignoring losses, how long does it take?`,
      answer: `${this.num(t)} s`,
      distractors: [
        `${this.num(ke)} s`,
        `${this.num(t + 1)} s`,
        `${this.num(Math.max(1, t - 1))} s`,
        `${p} s`,
      ],
      explanation: `Required energy is kinetic energy: ½mv² = ½×${m}×${v}² = ${this.num(ke)} J. Time = energy/power = ${this.num(ke)}/${p} = ${this.num(t)} s.`,
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
      topicMatchNote: 'Physics Energy',
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
