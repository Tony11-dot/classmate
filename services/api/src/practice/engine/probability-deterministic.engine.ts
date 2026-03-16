import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, gcd, reduceFraction, rotateBySeed, uniqueFirst } from './practice-engine.utils';

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
    const total = this.pick(i, [6, 8, 10, 12, 14, 15]);
    const favorable = this.pick(i + 1, [1, 2, 3, 4, 5, 6]);
    const f = Math.min(favorable, total - 1);
    const reduced = reduceFraction(f, total);

    return this.finish({
      prompt: `A bag contains ${total} marbles. ${f} of them are red. One marble is chosen at random. What is the probability of choosing a red marble?`,
      numerator: f,
      denominator: total,
      explanation: `Probability = favorable outcomes / total outcomes = ${f}/${total} = ${reduced.n}/${reduced.d}.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const total = this.pick(i, [20, 24, 30, 36, 40]);
    const first = this.pick(i + 1, [4, 6, 8, 10, 12, 14]);
    const second = this.pick(i + 2, [3, 5, 6, 9, 12, 15]);
    const favorable = Math.min(first + second, total - 1);
    const reduced = reduceFraction(favorable, total);

    return this.finish({
      prompt: `A class has ${total} students. ${first} play football and ${second} play basketball, and no student plays both. If one student is chosen at random, what is the probability that the student plays football or basketball?`,
      numerator: favorable,
      denominator: total,
      explanation: `Since the groups do not overlap, favorable outcomes = ${first} + ${second} = ${favorable}. So the probability is ${favorable}/${total} = ${reduced.n}/${reduced.d}.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const red = this.pick(i, [3, 4, 5, 6, 7]);
    const blue = this.pick(i + 1, [4, 5, 6, 7, 8]);
    const total = red + blue;
    const numerator = red * (red - 1);
    const denominator = total * (total - 1);
    const reduced = reduceFraction(numerator, denominator);

    return this.finish({
      prompt: `A box contains ${red} red balls and ${blue} blue balls. Two balls are drawn without replacement. What is the probability that both balls are red?`,
      numerator,
      denominator,
      explanation: `The probability of red then red is (${red}/${total})·(${red - 1}/${total - 1}) = ${numerator}/${denominator} = ${reduced.n}/${reduced.d}.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const even = this.pick(i, [4, 5, 6, 7]);
    const odd = this.pick(i + 1, [3, 4, 5, 6]);
    const total = even + odd;
    const numerator = 2 * even * odd;
    const denominator = total * (total - 1);
    const reduced = reduceFraction(numerator, denominator);

    return this.finish({
      prompt: `A number is chosen at random from a set containing ${even} even numbers and ${odd} odd numbers. Then a second number is chosen from the remaining numbers without replacement. What is the probability that one chosen number is even and the other is odd?`,
      numerator,
      denominator,
      explanation: `The favorable orders are even-odd or odd-even. So the probability is (${even}/${total})·(${odd}/${total - 1}) + (${odd}/${total})·(${even}/${total - 1}) = ${numerator}/${denominator} = ${reduced.n}/${reduced.d}.`,
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
    const reduced = reduceFraction(args.numerator, args.denominator);
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
    const reduced = reduceFraction(numerator, denominator);
    const correct = `${reduced.n}/${reduced.d}`;

    const raw = [
      correct,
      `${Math.max(1, reduced.n + 1)}/${reduced.d}`,
      `${reduced.n}/${Math.max(2, reduced.d + 1)}`,
      `${reduced.d}/${reduced.n}`,
      `${Math.max(1, reduced.n - 1)}/${reduced.d}`,
      `${reduced.n + 2}/${reduced.d + 2}`,
    ];

    const out = uniqueFirst(raw, 4);

    while (out.length < 4) {
      out.push(`${reduced.n + out.length + seed + 1}/${reduced.d + out.length + 2}`);
    }

    return rotateBySeed(out.slice(0, 4), seed);
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
        return clampTime(overrideSeconds, 80);
      default:
        return clampTime(overrideSeconds, 40);
    }
  }

  private pick<T>(i: number, arr: T[]): T {
    return arr[((i % arr.length) + arr.length) % arr.length];
  }
}
