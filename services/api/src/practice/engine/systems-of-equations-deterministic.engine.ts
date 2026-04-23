import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';

@Injectable()
export class SystemsOfEquationsDeterministicEngine implements PracticeEngine {
  readonly supportedModes = ['practice', 'flashcards', 'speedRound', 'examPrep', 'conceptBuilder', 'adaptive'] as const;

  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`
      .toLowerCase()
      .trim();

    return (
      s === 'math' &&
      (
        t.includes('system of equations') ||
        t.includes('systems of equations') ||
        t.includes('simultaneous equations') ||
        t.includes('solve the system') ||
        (t.includes('system') && t.includes('equation'))
      )
    );
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]> {
    const out: GeneratedQuestion[] = [];

    for (let i = 0; i < req.questionCount; i++) {
      out.push(this.makeQuestion(i, req.difficulty, req.timePreferenceSeconds));
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
    const x = this.pick(i, [-4, -3, -2, -1, 1, 2, 3, 4]);
    const y = this.pick(i + 1, [-3, -2, -1, 1, 2, 3, 4, 5]);

    const a1 = this.pick(i + 2, [1, 2, 3]);
    const b1 = this.pick(i + 3, [1, 2, 3]);
    const a2 = this.pick(i + 4, [1, 2, 3]);
    const b2 = -this.pick(i + 5, [1, 2, 3]);

    const c1 = a1 * x + b1 * y;
    const c2 = a2 * x + b2 * y;

    return this.finish({
      prompt: `Solve the system:\n${this.equation(a1, b1, c1)}\n${this.equation(a2, b2, c2)}`,
      x,
      y,
      explanation:
        `Use substitution or elimination. Solving the system gives x = ${x} and y = ${y}. ` +
        `Checking the pair in both equations confirms both equalities are true.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const x = this.pick(i, [-5, -4, -3, -2, -1, 1, 2, 3, 4]);
    const y = this.pick(i + 1, [-4, -3, -2, -1, 1, 2, 3, 4]);

    const a1 = this.pick(i + 2, [2, 3, 4, 5]);
    const b1 = this.pick(i + 3, [1, 2, 3, 4]);
    const a2 = this.pick(i + 4, [1, 2, 3, 4]);
    const b2 = -this.pick(i + 5, [2, 3, 4, 5]);

    const c1 = a1 * x + b1 * y;
    const c2 = a2 * x + b2 * y;

    return this.finish({
      prompt: `Solve the system:\n${this.equation(a1, b1, c1)}\n${this.equation(a2, b2, c2)}`,
      x,
      y,
      explanation:
        `Eliminate one variable. From the simplified system, x = ${x}. ` +
        `Substitute back to get y = ${y}.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const x = this.pick(i, [-4, -3, -2, -1, 1, 2, 3, 4]);
    const y = this.pick(i + 1, [-4, -3, -2, -1, 1, 2, 3, 4]);

    const m = this.pick(i + 2, [2, 3, 4]);
    const n = this.pick(i + 3, [2, 3, 4, 5]);
    const p = this.pick(i + 4, [1, 2, 3]);
    const q = -this.pick(i + 5, [1, 2, 3]);
    const r = this.pick(i + 6, [3, 4, 5]);

    const c1 = m * (x + p) + n * y;
    const c2 = q * x + r * (y - p);

    return this.finish({
      prompt: `Solve the system:\n${m}(x + ${p}) + ${n}y = ${c1}\n${q}x + ${r}(y - ${p}) = ${c2}`,
      x,
      y,
      explanation:
        `Expand both equations first, then collect like terms. ` +
        `After solving the linear system, x = ${x} and y = ${y}.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const x = this.pick(i, [-3, -2, -1, 1, 2, 3, 4]);
    const y = this.pick(i + 1, [-3, -2, -1, 1, 2, 3, 4]);

    const a = this.pick(i + 2, [2, 3, 4, 5]);
    const b = this.pick(i + 3, [2, 3, 4]);
    const c = this.pick(i + 4, [1, 2, 3]);
    const d = this.pick(i + 5, [1, 2, 3]);
    const e = this.pick(i + 6, [2, 3, 4]);

    const rhs1 = a * (x + c) - b * (y - d);
    const rhs2 = e * x + (a - 1) * y;

    return this.finish({
      prompt: `Solve the system:\n${a}(x + ${c}) - ${b}(y - ${d}) = ${rhs1}\n${e}x + ${a - 1}y = ${rhs2}`,
      x,
      y,
      explanation:
        `Expand the brackets and simplify each equation. ` +
        `Then eliminate one variable to obtain x = ${x}, and substitute to get y = ${y}.`,
      recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
      seed: i,
    });
  }

  private finish(args: {
    prompt: string;
    x: number;
    y: number;
    explanation: string;
    recommendedTimeSeconds: number;
    seed: number;
  }): GeneratedQuestion {
    const answer = this.pair(args.x, args.y);
    const options = this.makeOptions(args.x, args.y, args.seed);

    return {
      prompt: args.prompt,
      options,
      correctIndex: options.indexOf(answer),
      correctAnswerText: answer,
      explanation: args.explanation,
      recommendedTimeSeconds: args.recommendedTimeSeconds,
      topicMatchNote: 'Systems of equations',
    };
  }

  private makeOptions(x: number, y: number, i: number): string[] {
    const raw = [
      this.pair(x, y),
      this.pair(y, x),
      this.pair(-x, y),
      this.pair(x, -y),
      this.pair(
        x + this.pick(i + 7, [1, -1, 2]),
        y + this.pick(i + 8, [1, -1, -2]),
      ),
    ];

    const out: string[] = [];
    for (const item of raw) {
      if (!out.includes(item)) out.push(item);
      if (out.length === 4) break;
    }

    while (out.length < 4) {
      out.push(this.pair(x + 3 + out.length, y - 2 - out.length));
    }

    return out.slice(0, 4);
  }

  private pair(x: number, y: number): string {
    return `(x, y) = (${x}, ${y})`;
  }

  private equation(ax: number, by: number, c: number): string {
    const xPart = `${ax}x`;
    const yPart = by >= 0 ? `+ ${by}y` : `- ${Math.abs(by)}y`;
    return `${xPart} ${yPart} = ${c}`;
  }

  private timeFor(
    difficulty: EngineDifficulty,
    overrideSeconds: number | null,
  ): number {
    if (overrideSeconds != null && Number.isFinite(overrideSeconds)) {
      return Math.max(5, Math.min(900, Math.round(overrideSeconds)));
    }

    switch (difficulty) {
      case 'easy':
        return 35;
      case 'medium':
      case 'adaptive':
        return 50;
      case 'hard':
        return 70;
      case 'olympiad':
        return 90;
      default:
        return 50;
    }
  }

  private pick<T>(i: number, arr: T[]): T {
    return arr[((i % arr.length) + arr.length) % arr.length];
  }
}
