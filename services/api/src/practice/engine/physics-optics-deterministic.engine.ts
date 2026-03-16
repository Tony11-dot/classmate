import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, fillOptionsWithSafeFallback, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class PhysicsOpticsDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase().trim();
    return s === 'physics' && (t.includes('optics') || t.includes('reflection') || t.includes('refraction') || t.includes('mirror') || t.includes('lens'));
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
    const angle = this.pick(i, [20, 30, 40, 50]);

    return this.finish({
      prompt: `A light ray strikes a plane mirror with an angle of incidence of ${angle}°. What is the angle of reflection?`,
      answer: `${angle}°`,
      distractors: [`${90 - angle}°`, `${angle + 10}°`, `${Math.max(0, angle - 10)}°`],
      explanation: `For a plane mirror, angle of reflection equals angle of incidence, so it is ${angle}°.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      return this.finish({
        prompt: `What type of image is formed by a plane mirror?`,
        answer: `Virtual, upright, and same size`,
        distractors: [
          `Real and inverted`,
          `Virtual and magnified`,
          `Real and diminished`,
        ],
        explanation: `A plane mirror forms a virtual, upright image of the same size as the object.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const c = this.pick(i, [3e8]);
    const n = this.pick(i + 1, [1.5, 2, 1.25]);
    const v = c / n;

    return this.finish({
      prompt: `Light travels in a medium with refractive index ${this.num(n)}. If the speed of light in vacuum is 3×10^8 m/s, what is the speed of light in the medium?`,
      answer: `${this.num(v)} m/s`,
      distractors: [
        `${this.num(v + 1e8)} m/s`,
        `${this.num(c * n)} m/s`,
        `${this.num(n)} m/s`,
      ],
      explanation: `Refractive index n = c/v, so v = c/n = 3×10^8 / ${this.num(n)} = ${this.num(v)} m/s.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      return this.finish({
        prompt: `When light passes from air into glass, what usually happens to its speed?`,
        answer: `It decreases`,
        distractors: [`It increases`, `It stays the same`, `It becomes zero`],
        explanation: `Light slows down in a denser optical medium such as glass.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    return this.finish({
      prompt: `A converging lens is also called which type of lens?`,
      answer: `Convex lens`,
      distractors: [`Concave lens`, `Plane mirror`, `Diverging mirror`],
      explanation: `A converging lens bends light rays toward each other and is called a convex lens.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const angle = this.pick(i, [25, 35, 45, 55]);
    return this.finish({
      prompt: `A ray of light strikes a plane mirror at ${angle}° to the normal. Through what angle is the ray deviated from its original straight-line path after reflection?`,
      answer: `${2 * angle}°`,
      distractors: [`${angle}°`, `${90 - angle}°`, `${180 - angle}°`],
      explanation: `For reflection from a plane mirror, the deviation from the original straight path is 2i = 2×${angle} = ${2 * angle}°.`,
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
      topicMatchNote: 'Physics Optics',
    };
  }

  private num(n: number): string {
    if (Number.isInteger(n)) return String(n);
    return Number(n.toPrecision(3)).toString();
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
