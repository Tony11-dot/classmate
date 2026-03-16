import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';

@Injectable()
export class ProbabilityDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`
      .toLowerCase()
      .trim();

    return (
      s === 'math' &&
      (
        t.includes('probability') ||
        t.includes('chance') ||
        t.includes('random event') ||
        t.includes('outcomes')
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
    const total = this.pick(i, [6, 8, 10, 12]);
    const favorable = this.pick(i + 1, [1, 2, 3, 4, 5]);
    const f = Math.min(favorable, total - 1);

    return this.finish({
      prompt: `A bag contains ${total} marbles. ${f} of them are red. One marble is chosen at random. What is the probability of choosing a red marble?`,
      numerator: f,
      denominator: total,
      explanation: `Probability = favorable outcomes / total outcomes = ${f}/${total}.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const total = this.pick(i, [20, 24, 30, 36]);
    const first = this.pick(i + 1, [4, 6, 8, 10, 12]);
    const second = this.pick(i + 2, [3, 5, 6, 9, 12]);
    const favorable = Math.min(first + second, total - 1);

    return this.finish({
      prompt: `A class has ${total} students. ${first} play football and ${second} play basketball, and no student plays both. If one student is chosen at random, what is the probability that the student plays football or basketball?`,
      numerator: favorable,
      denominator: total,
      explanation: `Since the groups do not overlap, favorable outcomes = ${first} + ${second} = ${favorable}. So the probability is ${favorable}/${total}.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const red = this.pick(i, [3, 4, 5, 6]);
    const blue = this.pick(i + 1, [4, 5, 6, 7]);
    const total = red + blue;

    return this.finish({
      prompt: `A box contains ${red} red balls and ${blue} blue balls. Two balls are drawn without replacement. What is the probability that both balls are red?`,
      numerator: red * (red - 1),
      denominator: total * (total - 1),
      explanation: `The probability of red then red is (${red}/${total})·(${red - 1}/${total - 1}) = ${red * (red - 1)}/${total * (total - 1)}.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const even = this.pick(i, [4, 5, 6]);
    const odd = this.pick(i + 1, [3, 4, 5]);
    const total = even + odd;

    return this.finish({
      prompt: `A number is chosen at random from a set containing ${even} even numbers and ${odd} odd numbers. Then a second number is chosen from the remaining numbers without replacement. What is the probability that one chosen number is even and the other is odd?`,
      numerator: 2 * even * odd,
      denominator: total * (total - 1),
      explanation: `The favorable orders are even-odd or odd-even. So the probability is (${even}/${total})·(${odd}/${total - 1}) + (${odd}/${total})·(${even}/${total - 1}) = ${2 * even * odd}/${total * (total - 1)}.`,
      recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
      seed: i,
    });
  }

  private finish(args: {
    prompt: string;
    numerator: number;
    denominator: number;
    explanation: string;
    recommendedTimeSeconds: number;
    seed: number;
  }): GeneratedQuestion {
    const reduced = this.reduce(args.numerator, args.denominator);
    const answer = `${reduced.n}/${reduced.d}`;
    const options = this.makeOptions(args.numerator, args.denominator, args.seed);

    return {
      prompt: args.prompt,
      options,
      correctIndex: options.indexOf(answer),
      correctAnswerText: answer,
      explanation: args.explanation,
      recommendedTimeSeconds: args.recommendedTimeSeconds,
      topicMatchNote: 'Probability',
    };
  }

  private makeOptions(numerator: number, denominator: number, seed: number): string[] {
    const reduced = this.reduce(numerator, denominator);
    const correct = `${reduced.n}/${reduced.d}`;

    const raw = [
      correct,
      `${Math.max(1, reduced.n + 1)}/${reduced.d}`,
      `${reduced.n}/${Math.max(2, reduced.d + 1)}`,
      `${reduced.d}/${reduced.n}`,
      `${Math.max(1, reduced.n - 1)}/${reduced.d}`,
    ];

    const out: string[] = [];
    for (const item of raw) {
      if (!out.includes(item)) out.push(item);
      if (out.length === 4) break;
    }

    while (out.length < 4) {
      out.push(`${reduced.n + out.length + seed + 1}/${reduced.d + out.length + 2}`);
    }

    return this.rotate(out.slice(0, 4), seed);
  }

  private reduce(n: number, d: number): { n: number; d: number } {
    const g = this.gcd(Math.abs(n), Math.abs(d));
    return { n: n / g, d: d / g };
  }

  private gcd(a: number, b: number): number {
    let x = a;
    let y = b;
    while (y !== 0) {
      const t = x % y;
      x = y;
      y = t;
    }
    return x || 1;
  }

  private rotate<T>(arr: T[], seed: number): T[] {
    if (arr.length <= 1) return arr.slice();
    const k = ((seed % arr.length) + arr.length) % arr.length;
    return arr.slice(k).concat(arr.slice(0, k));
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
        return 25;
      case 'medium':
      case 'adaptive':
        return 40;
      case 'hard':
        return 60;
      case 'olympiad':
        return 80;
      default:
        return 40;
    }
  }

  private pick<T>(i: number, arr: T[]): T {
    return arr[((i % arr.length) + arr.length) % arr.length];
  }
}
