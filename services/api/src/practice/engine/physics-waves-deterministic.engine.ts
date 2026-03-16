import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class PhysicsWavesDeterministicEngine implements PracticeEngine {

  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase().trim();

    return (
      s === 'physics' &&
      (
        t.includes('waves') ||
        t.includes('wave speed') ||
        t.includes('wavelength') ||
        t.includes('frequency') ||
        t.includes('period') ||
        t.includes('amplitude')
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
    const f = this.pick(i, [2, 3, 4, 5]);
    const t = 1 / f;

    return this.finish({
      prompt: `A wave has frequency ${f} Hz. What is its period?`,
      answer: `${this.num(t)} s`,
      distractors: [`${f} s`, `${this.num(t + 0.25)} s`, `${this.num(f / 2)} s`],
      explanation: `Period and frequency are related by T = 1/f = 1/${f} = ${this.num(t)} s.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const f = this.pick(i, [2, 3, 4, 5]);
      const lambda = this.pick(i + 1, [4, 5, 6, 8]);
      const v = f * lambda;

      return this.finish({
        prompt: `A wave has frequency ${f} Hz and wavelength ${lambda} m. What is its speed?`,
        answer: `${v} m/s`,
        distractors: [`${f + lambda} m/s`, `${lambda} m/s`, `${v + 2} m/s`],
        explanation: `Wave speed is v = fλ = ${f}×${lambda} = ${v} m/s.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const v = this.pick(i, [12, 16, 20, 24]);
    const f = this.pick(i + 1, [2, 4, 5]);
    const lambda = v / f;

    return this.finish({
      prompt: `A wave travels at ${v} m/s and has frequency ${f} Hz. What is its wavelength?`,
      answer: `${this.num(lambda)} m`,
      distractors: [`${this.num(lambda + 1)} m`, `${this.num(v * f)} m`, `${this.num(f)} m`],
      explanation: `Wavelength λ = v/f = ${v}/${f} = ${this.num(lambda)} m.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const crestToCrest = this.pick(i, [3, 4, 5, 6]);
      const wavelength = crestToCrest;

      return this.finish({
        prompt: `The distance between two consecutive crests of a wave is ${crestToCrest} m. What is the wavelength?`,
        answer: `${wavelength} m`,
        distractors: [`${wavelength * 2} m`, `${this.num(wavelength / 2)} m`, `${wavelength + 1} m`],
        explanation: `The wavelength is the distance between two consecutive crests, so it is ${wavelength} m.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const f = this.pick(i, [4, 5, 8, 10]);
    const t = 1 / f;

    return this.finish({
      prompt: `A source produces ${f} complete vibrations each second. What is the period of the wave?`,
      answer: `${this.num(t)} s`,
      distractors: [`${f} s`, `${this.num(t + 0.1)} s`, `${this.num(f / 10)} s`],
      explanation: `Frequency is ${f} Hz, so the period is T = 1/f = ${this.num(t)} s.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const v = this.pick(i, [30, 36, 40, 48]);
    const lambda = this.pick(i + 1, [3, 4, 5, 6]);
    const f = v / lambda;

    return this.finish({
      prompt: `A wave moves at ${v} m/s and has wavelength ${lambda} m. What is its frequency?`,
      answer: `${this.num(f)} Hz`,
      distractors: [`${this.num(f + 1)} Hz`, `${this.num(v + lambda)} Hz`, `${this.num(lambda)} Hz`],
      explanation: `Frequency f = v/λ = ${v}/${lambda} = ${this.num(f)} Hz.`,
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
      topicMatchNote: 'Physics Waves',
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
