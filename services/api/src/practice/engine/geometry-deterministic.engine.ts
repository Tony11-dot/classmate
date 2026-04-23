import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, fillOptionsWithSafeFallback, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class GeometryDeterministicEngine implements PracticeEngine {
  readonly supportedModes = ['practice', 'flashcards', 'speedRound', 'examPrep', 'conceptBuilder', 'adaptive'] as const;

  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`
      .toLowerCase()
      .trim();

    return (
      s === 'math' &&
      (
        t.includes('geometry') ||
        t.includes('triangle') ||
        t.includes('rectangle') ||
        t.includes('circle') ||
        t.includes('perimeter') ||
        t.includes('area')
      )
    );
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]> {
    const out: GeneratedQuestion[] = [];
    const seen = new Set<string>();

    for (let i = 0; out.length < req.questionCount && i < req.questionCount * 8; i++) {
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
    const l = this.pick(i, [4, 5, 6, 7, 8, 9]);
    const w = this.pick(i + 1, [2, 3, 4, 5, 6]);
    const area = l * w;

    return this.finishNumeric({
      prompt: `A rectangle has length ${l} cm and width ${w} cm. What is its area?`,
      answer: area,
      explanation: `Area of a rectangle = length × width = ${l} × ${w} = ${area}.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
      topicMatchNote: 'Geometry',
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const b = this.pick(i, [6, 8, 10, 12, 14]);
    const h = this.pick(i + 1, [3, 4, 5, 6, 7]);
    const area = (b * h) / 2;

    return this.finishNumeric({
      prompt: `A triangle has base ${b} cm and height ${h} cm. What is its area?`,
      answer: area,
      explanation: `Area of a triangle = (base × height) / 2 = (${b} × ${h}) / 2 = ${area}.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
      topicMatchNote: 'Geometry',
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const a = this.pick(i, [5, 7, 8, 9, 10, 12]);
    const b = this.pick(i + 1, [12, 15, 17, 20, 24]);
    const c = Math.sqrt(a * a + b * b);
    const answer = Number.isInteger(c) ? c : Number(c.toFixed(2));

    return this.finishNumeric({
      prompt: `A right triangle has legs ${a} cm and ${b} cm. What is the length of the hypotenuse?`,
      answer,
      explanation: `By the Pythagorean theorem, c² = ${a}² + ${b}² = ${a * a} + ${b * b} = ${a * a + b * b}. So c = ${answer}.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
      topicMatchNote: 'Geometry',
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const r = this.pick(i, [2, 3, 4, 5, 6]);
    const answer = `${2 * r}π`;

    return this.finishText({
      prompt: `A circle has radius ${r} cm. What is its circumference in terms of π?`,
      answer,
      explanation: `Circumference of a circle = 2πr = 2π·${r} = ${2 * r}π.`,
      recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
      seed: i,
      topicMatchNote: 'Geometry',
    });
  }

  private finishNumeric(args: {
    prompt: string;
    answer: number;
    explanation: string;
    recommendedTimeSeconds: number;
    seed: number;
    topicMatchNote: string;
  }): GeneratedQuestion {
    const answer = this.num(args.answer);
    const options = this.makeNumericOptions(args.answer, args.seed);

    return {
      prompt: args.prompt,
      options,
      correctIndex: options.indexOf(answer),
      correctAnswerText: answer,
      explanation: args.explanation,
      recommendedTimeSeconds: args.recommendedTimeSeconds,
      topicMatchNote: args.topicMatchNote,
    };
  }

  private finishText(args: {
    prompt: string;
    answer: string;
    explanation: string;
    recommendedTimeSeconds: number;
    seed: number;
    topicMatchNote: string;
  }): GeneratedQuestion {
    const options = this.makeTextOptions(args.answer, args.seed);

    return {
      prompt: args.prompt,
      options,
      correctIndex: options.indexOf(args.answer),
      correctAnswerText: args.answer,
      explanation: args.explanation,
      recommendedTimeSeconds: args.recommendedTimeSeconds,
      topicMatchNote: args.topicMatchNote,
    };
  }

  private makeNumericOptions(answer: number, seed: number): string[] {
    const a = Number(answer);
    const raw = [
      this.num(a),
      this.num(a + 2),
      this.num(Math.max(1, a - 2)),
      this.num(a + 4),
      this.num(Math.max(1, a - 4)),
    ];

    return this.uniqueRotate(raw, seed);
  }

  private makeTextOptions(answer: string, seed: number): string[] {
    const coeff = Number(String(answer).replace('π', ''));
    const raw = [
      answer,
      `${coeff + 2}π`,
      `${Math.max(1, coeff - 2)}π`,
      `${coeff / 2}π`,
      `${coeff + 4}π`,
    ];

    return this.uniqueRotate(raw, seed);
  }

  private uniqueRotate(raw: string[], seed: number): string[] {
    const out = fillOptionsWithSafeFallback(uniqueFirst(raw, 4), raw[0] ?? '', seed);
    return rotateBySeed(out.slice(0, 4), seed);
  }

  private num(n: number): string {
    return Number.isInteger(n) ? String(n) : String(Number(n.toFixed(2)));
  }

  private timeFor(
    difficulty: EngineDifficulty,
    overrideSeconds: number | null,
  ): number {
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
