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
    return (
      s === 'physics' &&
      (
        t.includes('electricity') ||
        (t.includes('electric') && !t.includes('field') && !t.includes('circuit'))
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
    const q = this.pick(i, [2, 3, 4, 5, 6]);
    const answer = `${q} C`;
    return this.finish({
      prompt: `How much electric charge passes a point when a current of ${q} A flows for 1 second?`,
      answer,
      distractors: [`${q + 1} C`, `${q - 1} C`, `${q * 2} C`],
      explanation: `Charge = current × time = ${q} × 1 = ${q} C.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const iAmp = this.pick(i, [2, 3, 4, 5]);
      const tSec = this.pick(i + 1, [3, 4, 5, 6]);
      const q = iAmp * tSec;

      return this.finish({
        prompt: `A current of ${iAmp} A flows for ${tSec} s. How much charge passes through the wire?`,
        answer: `${q} C`,
        distractors: [`${iAmp + tSec} C`, `${q + iAmp} C`, `${tSec} C`],
        explanation: `Charge Q = I×t = ${iAmp}×${tSec} = ${q} C.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const v = this.pick(i, [6, 9, 12, 15]);
    const q = this.pick(i + 1, [2, 3, 4, 5]);
    const w = v * q;

    return this.finish({
      prompt: `A charge of ${q} C moves through a potential difference of ${v} V. How much electrical work is done?`,
      answer: `${w} J`,
      distractors: [`${v + q} J`, `${v} J`, `${w + q} J`],
      explanation: `Electrical work = V×Q = ${v}×${q} = ${w} J.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const p = this.pick(i, [24, 36, 48, 60]);
      const v = this.pick(i + 1, [6, 12]);
      const current = p / v;

      return this.finish({
        prompt: `A device uses ${p} W when connected to a ${v} V source. What current does it draw?`,
        answer: `${this.num(current)} A`,
        distractors: [
          `${this.num(current + 1)} A`,
          `${this.num(v / (current || 1))} A`,
          `${this.num(p / 2)} A`,
        ],
        explanation: `Power P = VI, so I = P/V = ${p}/${v} = ${this.num(current)} A.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const q = this.pick(i, [12, 18, 24, 30]);
    const t = this.pick(i + 1, [3, 4, 5, 6]);
    const iAmp = q / t;

    return this.finish({
      prompt: `If ${q} C of charge pass through a conductor in ${t} s, what is the current?`,
      answer: `${this.num(iAmp)} A`,
      distractors: [
        `${this.num(iAmp + 1)} A`,
        `${q} A`,
        `${this.num(t / iAmp)} A`,
      ],
      explanation: `Current I = Q/t = ${q}/${t} = ${this.num(iAmp)} A.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const p = this.pick(i, [18, 24, 30, 36]);
    const iAmp = this.pick(i + 1, [2, 3, 4, 5]);
    const v = p / iAmp;

    return this.finish({
      prompt: `A circuit transfers energy at a rate of ${p} W while carrying a current of ${iAmp} A. What is the potential difference across it?`,
      answer: `${this.num(v)} V`,
      distractors: [
        `${this.num(v + 2)} V`,
        `${this.num(p + iAmp)} V`,
        `${this.num(iAmp)} V`,
      ],
      explanation: `Using P = VI, the voltage is V = P/I = ${p}/${iAmp} = ${this.num(v)} V.`,
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
