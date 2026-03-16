import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class StatisticsDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`
      .toLowerCase()
      .trim();

    return (
      s === 'math' &&
      (
        t.includes('statistics') ||
        t.includes('mean') ||
        t.includes('median') ||
        t.includes('mode') ||
        t.includes('range') ||
        t.includes('average')
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
    const a = this.pick(i, [2, 4, 6, 8, 10]);
    const b = this.pick(i + 1, [4, 6, 8, 10, 12]);
    const c = this.pick(i + 2, [6, 8, 10, 12, 14]);
    const d = this.pick(i + 3, [8, 10, 12, 14, 16]);
    const nums = [a, b, c, d];
    const answer = (a + b + c + d) / 4;

    return this.finish({
      prompt: `Find the mean of the data set: ${nums.join(', ')}`,
      answer: String(answer),
      distractors: [
        String(nums[1]),
        String(nums[2]),
        String(answer + this.pick(i + 4, [1, -1, 2])),
        String(a + d),
      ],
      explanation: `Mean = (${nums.join(' + ')}) / 4 = ${a + b + c + d} / 4 = ${answer}.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const start = this.pick(i, [2, 4, 6, 8]);
      const step = this.pick(i + 1, [2, 3, 4]);
      const nums = [start, start + step, start + 2 * step, start + 3 * step, start + 4 * step];
      const answer = nums[2];

      return this.finish({
        prompt: `Find the median of the data set: ${nums.join(', ')}`,
        answer: String(answer),
        distractors: [
          String(nums[1]),
          String(nums[3]),
          String(answer + this.pick(i + 2, [1, -1, 2])),
          String(nums[0]),
        ],
        explanation: `There are 5 values, so the median is the middle value after ordering them. The median is ${answer}.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const base = this.pick(i, [3, 4, 5, 6]);
    const nums = [base, base + 2, base, base + 4, base + 6, base];
    const answer = base;

    return this.finish({
      prompt: `Find the mode of the data set: ${nums.join(', ')}`,
      answer: String(answer),
      distractors: [
        String(base + 2),
        String(base + 4),
        String(base + 6),
        String(answer + this.pick(i + 3, [1, -1, 2])),
      ],
      explanation: `The mode is the value that appears most often. ${answer} appears 3 times, so the mode is ${answer}.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const start = this.pick(i, [5, 7, 9, 11]);
      const nums = [start, start + 3, start + 5, start + 8, start + 12];
      const answer = nums[4] - nums[0];

      return this.finish({
        prompt: `Find the range of the data set: ${nums.join(', ')}`,
        answer: String(answer),
        distractors: [
          String(nums[4]),
          String(nums[0]),
          String(answer + this.pick(i + 1, [1, -1, 2])),
          String(nums[3] - nums[1]),
        ],
        explanation: `Range = maximum - minimum = ${nums[4]} - ${nums[0]} = ${answer}.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const x = this.pick(i, [2, 3, 4, 5]);
    const nums = [x, x + 2, x + 4, x + 6, x + 8, x + 10];
    const answer = (nums[2] + nums[3]) / 2;

    return this.finish({
      prompt: `Find the median of the data set: ${nums.join(', ')}`,
      answer: String(answer),
      distractors: [
        String(nums[2]),
        String(nums[3]),
        String(answer + this.pick(i + 2, [1, -1, 2])),
        String((nums[1] + nums[4]) / 2),
      ],
      explanation: `There are 6 values, so the median is the average of the 3rd and 4th values: (${nums[2]} + ${nums[3]}) / 2 = ${answer}.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const a = this.pick(i, [4, 6, 8, 10]);
    const b = this.pick(i + 1, [8, 10, 12, 14]);
    const c = this.pick(i + 2, [12, 14, 16, 18]);
    const d = this.pick(i + 3, [16, 18, 20, 22]);
    const e = this.pick(i + 4, [20, 22, 24, 26]);
    const nums = [a, b, c, d, e];
    const answer = (a + b + c + d + e) / 5;

    return this.finish({
      prompt: `Find the mean of the data set: ${nums.join(', ')}`,
      answer: String(answer),
      distractors: [
        String(c),
        String((b + d) / 2),
        String(answer + this.pick(i + 5, [1, -1, 2])),
        String(a + e),
      ],
      explanation: `Mean = (${nums.join(' + ')}) / 5 = ${a + b + c + d + e} / 5 = ${answer}.`,
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
      options.push(String(Number(args.answer) + options.length + args.seed + 3));
    }

    const rotated = rotateBySeed(options.slice(0, 4), args.seed);

    return {
      prompt: args.prompt,
      options: rotated,
      correctIndex: rotated.indexOf(args.answer),
      correctAnswerText: args.answer,
      explanation: args.explanation,
      recommendedTimeSeconds: args.recommendedTimeSeconds,
      topicMatchNote: 'Statistics',
    };
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
