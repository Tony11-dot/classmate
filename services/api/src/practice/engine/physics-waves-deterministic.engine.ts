import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, fillOptionsWithSafeFallback, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class PhysicsWavesDeterministicEngine implements PracticeEngine {
  readonly supportedModes = ['practice', 'flashcards', 'speedRound', 'examPrep', 'conceptBuilder', 'adaptive'] as const;

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
      ) &&
      !t.includes('kinematics') &&
      !t.includes('newton') &&
      !t.includes('force') &&
      !t.includes('energy') &&
      !t.includes('momentum') &&
      !t.includes('electric') &&
      !t.includes('circuit') &&
      !t.includes('optics') &&
      !t.includes('thermo')
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
    const f = this.pick(i, [2, 4, 5, 10]);
    const t = 1 / f;

    return this.finish({
      prompt: `A wave has frequency ${f} Hz. What is its period?`,
      answer: `${this.num(t)} s`,
      distractors: [
        `${this.num(f)} s`,
        `${this.num(t + 0.1)} s`,
        `${this.num(Math.max(0.05, t / 2))} s`,
      ],
      explanation: `Period and frequency are related by T = 1/f = 1/${f} = ${this.num(t)} s.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const f = this.pick(i, [2, 3, 4, 5]);
      const l = this.pick(i + 1, [2, 3, 5, 6]);
      const v = f * l;

      return this.finish({
        prompt: `A wave has frequency ${f} Hz and wavelength ${l} m. What is its wave speed?`,
        answer: `${v} m/s`,
        distractors: [
          `${f + l} m/s`,
          `${f} m/s`,
          `${l} m/s`,
        ],
        explanation: `Wave speed is v = fλ = ${f}×${l} = ${v} m/s.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const v = this.pick(i, [12, 15, 18, 20]);
    const f = this.pick(i + 1, [3, 4, 5]);
    const l = v / f;

    return this.finish({
      prompt: `A wave travels at ${v} m/s and has frequency ${f} Hz. What is its wavelength?`,
      answer: `${this.num(l)} m`,
      distractors: [
        `${this.num(v + f)} m`,
        `${this.num(f)} m`,
        `${this.num(l + 1)} m`,
      ],
      explanation: `Wavelength λ = v/f = ${v}/${f} = ${this.num(l)} m.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const t = this.pick(i, [0.2, 0.25, 0.5, 1]);
      const f = 1 / t;

      return this.finish({
        prompt: `A wave completes one oscillation in ${this.num(t)} s. What is its frequency?`,
        answer: `${this.num(f)} Hz`,
        distractors: [
          `${this.num(t)} Hz`,
          `${this.num(f + 1)} Hz`,
          `${this.num(Math.max(0.5, f / 2))} Hz`,
        ],
        explanation: `Frequency is the reciprocal of period: f = 1/T = 1/${this.num(t)} = ${this.num(f)} Hz.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const v = this.pick(i, [24, 30, 36]);
      const l = this.pick(i + 1, [3, 4, 6]);
      const f = v / l;

      return this.finish({
        prompt: `A wave moves at ${v} m/s with wavelength ${l} m. What is its frequency?`,
        answer: `${this.num(f)} Hz`,
        distractors: [
          `${this.num(v + l)} Hz`,
          `${this.num(f + 2)} Hz`,
          `${this.num(l)} Hz`,
        ],
        explanation: `Using v = fλ, frequency is f = v/λ = ${v}/${l} = ${this.num(f)} Hz.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const f = this.pick(i, [5, 6, 8]);
    const l = this.pick(i + 1, [0.5, 1.5, 2]);
    const v = f * l;

    return this.finish({
      prompt: `A source vibrates at ${f} Hz and creates waves of wavelength ${this.num(l)} m. What is the wave speed?`,
      answer: `${this.num(v)} m/s`,
      distractors: [
        `${this.num(v + 1)} m/s`,
        `${this.num(f)} m/s`,
        `${this.num(l)} m/s`,
      ],
      explanation: `Wave speed is v = fλ = ${f}×${this.num(l)} = ${this.num(v)} m/s.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const v = this.pick(i, [18, 24, 30]);
    const t = this.pick(i + 1, [0.2, 0.25, 0.5]);
    const f = 1 / t;
    const l = v / f;

    return this.finish({
      prompt: `A wave travels at ${v} m/s and has period ${this.num(t)} s. What is its wavelength?`,
      answer: `${this.num(l)} m`,
      distractors: [
        `${this.num(v * t)} m`,
        `${this.num(l + 1)} m`,
        `${this.num(f)} m`,
      ],
      explanation: `First find f = 1/T = 1/${this.num(t)} = ${this.num(f)} Hz. Then λ = v/f = ${v}/${this.num(f)} = ${this.num(l)} m.`,
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
