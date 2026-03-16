import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class PhysicsElectricityDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase().trim();

    const isElectricityTopic =
      t.includes('electricity') ||
      t.includes('electric current') ||
      t.includes('current electricity') ||
      t.includes('electric charge') ||
      t.includes('potential difference') ||
      t.includes('voltage') ||
      t.includes('electrical power');

    const isExcluded =
      t.includes('electric field') ||
      t.includes('field strength') ||
      t.includes('circuits') ||
      t.includes('circuit') ||
      t.includes('resistance') ||
      t.includes('ohm') ||
      t.includes('energy') ||
      t.includes('work') ||
      t.includes('kinetic') ||
      t.includes('potential') ||
      t.includes('gravitational') ||
      t.includes('conservation of energy') ||
      t.includes('mechanical energy') ||
      t.includes('momentum') ||
      t.includes('kinematics') ||
      t.includes('newton') ||
      t.includes('force') ||
      t.includes('waves') ||
      t.includes('optics') ||
      t.includes('thermo');

    return s === 'physics' && isElectricityTopic && !isExcluded;
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]> {
    const out: GeneratedQuestion[] = [];
    const seen = new Set<string>();

    for (let i = 0; out.length < req.questionCount && i < req.questionCount * 12; i++) {
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
    const mode = i % 3;

    if (mode === 0) {
      return this.finish({
        prompt: `What is the SI unit of electric current?`,
        answer: `Ampere`,
        distractors: [`Volt`, `Ohm`, `Coulomb`],
        explanation: `Electric current is measured in amperes (A).`,
        recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const q = this.pick(i, [2, 3, 5]);
      const t = this.pick(i + 1, [2, 4, 6]);
      const charge = q * t;
      return this.finish({
        prompt: `A current of ${q} A flows for ${t} s. How much charge passes a point in the circuit?`,
        answer: `${charge} C`,
        distractors: [`${q + t} C`, `${q} C`, `${t} C`],
        explanation: `Charge Q = It = ${q}×${t} = ${charge} C.`,
        recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
        seed: i,
      });
    }

    const v = this.pick(i, [6, 12, 24]);
    const iamp = this.pick(i + 1, [1, 2, 3]);
    const p = v * iamp;
    return this.finish({
      prompt: `A device operates at ${v} V and draws ${iamp} A. What is its electrical power?`,
      answer: `${p} W`,
      distractors: [`${v + iamp} W`, `${v} W`, `${iamp} W`],
      explanation: `Power P = VI = ${v}×${iamp} = ${p} W.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 4;

    if (mode === 0) {
      const v = this.pick(i, [12, 18, 24]);
      const r = this.pick(i + 1, [3, 4, 6]);
      const current = v / r;

      return this.finish({
        prompt: `A circuit has a voltage of ${v} V and a resistance of ${r} Ω. What is the current?`,
        answer: `${this.num(current)} A`,
        distractors: [
          `${v * r} A`,
          `${this.num(r / v)} A`,
          `${r} A`,
        ],
        explanation: `Using Ohm's law, I = V/R = ${v}/${r} = ${this.num(current)} A.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const iamp = this.pick(i, [2, 3, 4]);
      const r = this.pick(i + 1, [5, 6, 8]);
      const v = iamp * r;

      return this.finish({
        prompt: `A current of ${iamp} A flows through a resistor of ${r} Ω. What is the voltage across it?`,
        answer: `${v} V`,
        distractors: [
          `${iamp + r} V`,
          `${this.num(iamp / r)} V`,
          `${r} V`,
        ],
        explanation: `Voltage V = IR = ${iamp}×${r} = ${v} V.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 2) {
      const q = this.pick(i, [4, 6, 10]);
      const t = this.pick(i + 1, [2, 5, 10]);
      const iamp = q / t;

      return this.finish({
        prompt: `${q} C of charge passes through a conductor in ${t} s. What is the current?`,
        answer: `${this.num(iamp)} A`,
        distractors: [
          `${q * t} A`,
          `${q} A`,
          `${t} A`,
        ],
        explanation: `Current I = Q/t = ${q}/${t} = ${this.num(iamp)} A.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const v = this.pick(i, [10, 20, 30]);
    const iamp = this.pick(i + 1, [2, 3, 5]);
    const p = v * iamp;

    return this.finish({
      prompt: `A device runs on ${v} V and draws ${iamp} A. What power does it use?`,
      answer: `${p} W`,
      distractors: [
        `${v + iamp} W`,
        `${v / iamp} W`,
        `${iamp} W`,
      ],
      explanation: `Power P = VI = ${v}×${iamp} = ${p} W.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 4;

    if (mode === 0) {
      const v = this.pick(i, [12, 18, 24]);
      const p = this.pick(i + 1, [24, 36, 48]);
      const iamp = p / v;

      return this.finish({
        prompt: `A device uses ${p} W of power on a ${v} V supply. What current does it draw?`,
        answer: `${this.num(iamp)} A`,
        distractors: [
          `${p * v} A`,
          `${this.num(v / p)} A`,
          `${this.num(iamp + 1)} A`,
        ],
        explanation: `Using P = VI, current I = P/V = ${p}/${v} = ${this.num(iamp)} A.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const q = this.pick(i, [120, 180, 240]);
      const iamp = this.pick(i + 1, [2, 3, 4]);
      const t = q / iamp;

      return this.finish({
        prompt: `How long does it take a current of ${iamp} A to transfer ${q} C of charge?`,
        answer: `${this.num(t)} s`,
        distractors: [
          `${q * iamp} s`,
          `${this.num(iamp / q)} s`,
          `${q} s`,
        ],
        explanation: `Q = It, so t = Q/I = ${q}/${iamp} = ${this.num(t)} s.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 2) {
      const v = this.pick(i, [6, 12, 24]);
      const iamp = this.pick(i + 1, [2, 4, 5]);
      const e = this.pick(i + 2, [60, 120, 240]);
      const t = e / (v * iamp);

      return this.finish({
        prompt: `A device connected to ${v} V draws ${iamp} A. How long will it take to transfer ${e} J of electrical energy?`,
        answer: `${this.num(t)} s`,
        distractors: [
          `${v * iamp * e} s`,
          `${this.num((v * iamp) / e)} s`,
          `${e} s`,
        ],
        explanation: `Power P = VI = ${v * iamp} W, and E = Pt. So t = E/P = ${e}/${v * iamp} = ${this.num(t)} s.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const v = this.pick(i, [12, 15, 20]);
    const r = this.pick(i + 1, [3, 5, 10]);
    const p = (v * v) / r;

    return this.finish({
      prompt: `A resistor of ${r} Ω is connected across a ${v} V source. How much power does it dissipate?`,
      answer: `${this.num(p)} W`,
      distractors: [
        `${v * r} W`,
        `${this.num(v / r)} W`,
        `${r} W`,
      ],
      explanation: `Power can be found by P = V²/R = ${v * v}/${r} = ${this.num(p)} W.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const v = this.pick(i, [12, 18, 24]);
    const p = this.pick(i + 1, [24, 54, 96]);
    const t = this.pick(i + 2, [5, 10, 20]);
    const iamp = p / v;
    const q = iamp * t;

    return this.finish({
      prompt: `A device operates at ${v} V and ${p} W for ${t} s. How much charge passes through it during that time?`,
      answer: `${this.num(q)} C`,
      distractors: [
        `${p * t} C`,
        `${this.num(v * t)} C`,
        `${this.num(q + 10)} C`,
      ],
      explanation: `First find current: I = P/V = ${p}/${v} = ${this.num(iamp)} A. Then charge Q = It = ${this.num(iamp)}×${t} = ${this.num(q)} C.`,
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
      topicMatchNote: 'Physics Electricity',
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
