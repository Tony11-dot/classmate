import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, fillOptionsWithSafeFallback, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class PhysicsCircuitsDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase().trim();
    return s === 'physics' && (t.includes('circuits') || t.includes('ohm') || t.includes('resistance'));
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
    const v = this.pick(i, [6, 8, 10, 12]);
    const r = this.pick(i + 1, [2, 4]);
    const current = v / r;

    return this.finish({
      prompt: `A resistor of ${r} Ω is connected to a ${v} V battery. What current flows?`,
      answer: `${this.num(current)} A`,
      distractors: [`${this.num(current + 1)} A`, `${this.num(v + r)} A`, `${this.num(r)} A`],
      explanation: `By Ohm's law, I = V/R = ${v}/${r} = ${this.num(current)} A.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const iAmp = this.pick(i, [2, 3, 4, 5]);
      const r = this.pick(i + 1, [3, 4, 5, 6]);
      const v = iAmp * r;

      return this.finish({
        prompt: `A current of ${iAmp} A flows through a resistor of ${r} Ω. What is the voltage across it?`,
        answer: `${v} V`,
        distractors: [`${v + r} V`, `${iAmp + r} V`, `${r} V`],
        explanation: `Using V = IR, the voltage is ${iAmp}×${r} = ${v} V.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const r1 = this.pick(i, [2, 3, 4]);
    const r2 = this.pick(i + 1, [5, 6, 7]);
    const total = r1 + r2;

    return this.finish({
      prompt: `Two resistors of ${r1} Ω and ${r2} Ω are connected in series. What is their total resistance?`,
      answer: `${total} Ω`,
      distractors: [`${r1 * r2} Ω`, `${Math.abs(r2 - r1)} Ω`, `${this.num((r1 + r2) / 2)} Ω`],
      explanation: `In series, resistances add directly: ${r1} + ${r2} = ${total} Ω.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const r1 = this.pick(i, [4, 6, 8]);
      const r2 = this.pick(i + 1, [4, 6, 8]);
      const total = (r1 * r2) / (r1 + r2);

      return this.finish({
        prompt: `Two resistors of ${r1} Ω and ${r2} Ω are connected in parallel. What is their equivalent resistance?`,
        answer: `${this.num(total)} Ω`,
        distractors: [`${r1 + r2} Ω`, `${this.num((r1 + r2) / 2)} Ω`, `${Math.abs(r2 - r1)} Ω`],
        explanation: `For two resistors in parallel, R_eq = (R₁R₂)/(R₁+R₂) = (${r1}×${r2})/(${r1}+${r2}) = ${this.num(total)} Ω.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const v = this.pick(i, [12, 18, 24]);
    const r = this.pick(i + 1, [3, 6, 8]);
    const p = (v * v) / r;

    return this.finish({
      prompt: `A resistor of ${r} Ω is connected across ${v} V. How much power does it dissipate?`,
      answer: `${this.num(p)} W`,
      distractors: [`${this.num(v / r)} W`, `${this.num(v * r)} W`, `${this.num(p + 2)} W`],
      explanation: `Power in a resistor can be found from P = V²/R = ${v}²/${r} = ${this.num(p)} W.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const v = this.pick(i, [12, 18, 24]);
    const r1 = this.pick(i + 1, [2, 3, 4]);
    const r2 = this.pick(i + 2, [4, 6, 8]);
    const total = r1 + r2;
    const current = v / total;

    return this.finish({
      prompt: `A ${v} V battery is connected to two series resistors of ${r1} Ω and ${r2} Ω. What is the circuit current?`,
      answer: `${this.num(current)} A`,
      distractors: [`${this.num(current + 1)} A`, `${this.num(v / r1)} A`, `${this.num(total)} A`],
      explanation: `Series resistance is ${r1}+${r2} = ${total} Ω. Then I = V/R = ${v}/${total} = ${this.num(current)} A.`,
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
      topicMatchNote: 'Physics Circuits',
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
