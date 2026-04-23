import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import {
  clampTime,
  fillOptionsWithSafeFallback,
  rotateBySeed,
  uniqueFirst,
} from './practice-engine.utils';

type StatisticsFocus = 'mean' | 'median' | 'mode' | 'range' | 'mixed';

@Injectable()
export class StatisticsDeterministicEngine implements PracticeEngine {
  readonly supportedModes = ['practice', 'flashcards', 'speedRound', 'examPrep', 'conceptBuilder', 'adaptive'] as const;

  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = this.topicDescriptorText(req);

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
    const focus = this.resolveFocus(req);

    for (let i = 0; out.length < req.questionCount && i < req.questionCount * 8; i++) {
      const q = this.makeQuestion(
        i,
        req.difficulty,
        req.timePreferenceSeconds,
        focus,
      );
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
    focus: StatisticsFocus,
  ): GeneratedQuestion {
    switch (difficulty) {
      case 'easy':
        return this.makeEasy(i, overrideSeconds, focus);
      case 'medium':
      case 'adaptive':
        return this.makeMedium(i, overrideSeconds, focus);
      case 'hard':
        return this.makeHard(i, overrideSeconds, focus);
      case 'olympiad':
        return this.makeOlympiad(i, overrideSeconds, focus);
      default:
        return this.makeMedium(i, overrideSeconds, focus);
    }
  }

  private makeEasy(
    i: number,
    overrideSeconds: number | null,
    focus: StatisticsFocus,
  ): GeneratedQuestion {
    const families = this.familyOrder(focus, ['mean', 'median', 'mode', 'range']);
    switch (families[i % families.length]) {
      case 'median':
        return this.easyMedian(i, overrideSeconds);
      case 'mode':
        return this.easyMode(i, overrideSeconds);
      case 'range':
        return this.easyRange(i, overrideSeconds);
      case 'mean':
      default:
        return this.easyMean(i, overrideSeconds);
    }
  }

  private easyMean(i: number, overrideSeconds: number | null): GeneratedQuestion {
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

  private easyMedian(i: number, overrideSeconds: number | null): GeneratedQuestion {
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
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private easyMode(i: number, overrideSeconds: number | null): GeneratedQuestion {
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
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private easyRange(i: number, overrideSeconds: number | null): GeneratedQuestion {
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
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(
    i: number,
    overrideSeconds: number | null,
    focus: StatisticsFocus,
  ): GeneratedQuestion {
    const families = this.familyOrder(focus, ['median', 'mode', 'mean', 'range']);
    switch (families[i % families.length]) {
      case 'mode':
        return this.mediumModeFromFrequency(i, overrideSeconds);
      case 'mean':
        return this.mediumMeanMissingValue(i, overrideSeconds);
      case 'range':
        return this.mediumRangeAfterChange(i, overrideSeconds);
      case 'median':
      default:
        return this.mediumMedianUnordered(i, overrideSeconds);
    }
  }

  private mediumMedianUnordered(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const base = this.pick(i, [3, 5, 7, 9]);
    const nums = [base + 6, base, base + 2, base + 8, base + 4];
    const ordered = nums.slice().sort((x, y) => x - y);
    const answer = ordered[2];

    return this.finish({
      prompt: `Find the median after ordering the data set: ${nums.join(', ')}`,
      answer: String(answer),
      distractors: [
        String(ordered[1]),
        String(ordered[3]),
        String(ordered[0]),
        String(answer + this.pick(i + 3, [1, -1, 2])),
      ],
      explanation: `Ordering gives ${ordered.join(', ')}. With 5 values, the median is the middle value, ${answer}.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private mediumModeFromFrequency(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const values = [
      this.pick(i, [2, 3, 4]),
      this.pick(i + 1, [5, 6, 7]),
      this.pick(i + 2, [8, 9, 10]),
    ];
    const freqs = [2, 5, 3];
    const answer = values[1];

    return this.finish({
      prompt: `A frequency table has values ${values.join(', ')} with frequencies ${freqs.join(', ')}. What is the mode?`,
      answer: this.num(answer),
      distractors: [
        this.num(values[0]),
        this.num(values[2]),
        this.num(freqs[1]),
        this.num(answer + this.pick(i + 4, [1, -1])),
      ],
      explanation: `The mode is the value with the greatest frequency. The highest frequency is 5, so the mode is ${answer}.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private mediumMeanMissingValue(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const nums = [
      this.pick(i, [6, 8, 10]),
      this.pick(i + 1, [12, 14, 16]),
      this.pick(i + 2, [18, 20, 22]),
    ];
    const missing = this.pick(i + 3, [10, 12, 14, 16]);
    const total = nums.reduce((sum, value) => sum + value, 0) + missing;
    const mean = total / 4;

    return this.finish({
      prompt: `The mean of the four numbers ${nums[0]}, ${nums[1]}, ${nums[2]}, and x is ${this.num(mean)}. What is x?`,
      answer: this.num(missing),
      distractors: [
        this.num(mean),
        this.num(total - missing),
        this.num(missing + 2),
        this.num(missing - 2),
      ],
      explanation: `If the mean is ${this.num(mean)} for 4 numbers, the total is ${this.num(mean * 4)}. The known numbers sum to ${nums.reduce((sum, value) => sum + value, 0)}, so x = ${missing}.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private mediumRangeAfterChange(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const min = this.pick(i, [3, 4, 5, 6]);
    const max = this.pick(i + 1, [16, 18, 20, 22]);
    const oldRange = max - min;
    const newMax = max + this.pick(i + 2, [2, 3, 4]);
    const answer = newMax - min;

    return this.finish({
      prompt: `A data set has minimum ${min} and maximum ${max}. If the maximum increases to ${newMax}, what is the new range?`,
      answer: this.num(answer),
      distractors: [
        this.num(oldRange),
        this.num(newMax),
        this.num(newMax - max),
        this.num(answer + 2),
      ],
      explanation: `Range = maximum - minimum. The new range is ${newMax} - ${min} = ${answer}.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(
    i: number,
    overrideSeconds: number | null,
    focus: StatisticsFocus,
  ): GeneratedQuestion {
    const families = this.familyOrder(focus, ['range', 'median', 'mean', 'mode']);
    switch (families[i % families.length]) {
      case 'median':
        return this.hardMedianEvenSet(i, overrideSeconds);
      case 'mean':
        return this.hardMeanFromFrequency(i, overrideSeconds);
      case 'mode':
        return this.hardModeAfterAddingValue(i, overrideSeconds);
      case 'range':
      default:
        return this.hardRangeWithNegativeValues(i, overrideSeconds);
    }
  }

  private hardRangeWithNegativeValues(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const low = this.pick(i, [-7, -6, -5, -4]);
    const high = this.pick(i + 1, [8, 9, 10, 11]);
    const answer = high - low;

    return this.finish({
      prompt: `Find the range of the data set: ${low}, -1, 0, 3, ${high}`,
      answer: String(answer),
      distractors: [
        String(high),
        String(Math.abs(low)),
        String(answer - 1),
        String(high + low),
      ],
      explanation: `Range = maximum - minimum = ${high} - (${low}) = ${answer}.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private hardMedianEvenSet(i: number, overrideSeconds: number | null): GeneratedQuestion {
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

  private hardMeanFromFrequency(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const values = [2, 5, 8, 11].map((base, idx) => base + (i % 3) + idx);
    const freqs = [1, 2, 3, 2];
    const total = values.reduce((sum, value, idx) => sum + value * freqs[idx], 0);
    const count = freqs.reduce((sum, value) => sum + value, 0);
    const answer = total / count;

    return this.finish({
      prompt: `Values ${values.join(', ')} occur with frequencies ${freqs.join(', ')}. What is the mean?`,
      answer: this.num(answer),
      distractors: [
        this.num(values[1]),
        this.num(total),
        this.num(answer + 1),
        this.num(answer - 1),
      ],
      explanation: `Mean = weighted sum / total frequency = ${total} / ${count} = ${this.num(answer)}.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private hardModeAfterAddingValue(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const a = this.pick(i, [3, 4, 5]);
    const b = a + 2;
    const c = a + 5;
    const answer = b;

    return this.finish({
      prompt: `The data set is ${a}, ${b}, ${b}, ${c}, ${c}. One extra value is added so that the mode becomes ${b}. Which value was added?`,
      answer: this.num(b),
      distractors: [
        this.num(a),
        this.num(c),
        this.num(b + 1),
        this.num(c + 1),
      ],
      explanation: `Before adding a value, ${b} and ${c} both appear twice. Adding another ${b} makes ${b} appear three times, so it becomes the unique mode.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(
    i: number,
    overrideSeconds: number | null,
    focus: StatisticsFocus,
  ): GeneratedQuestion {
    const families = this.familyOrder(focus, ['mean', 'median', 'mode', 'range']);
    switch (families[i % families.length]) {
      case 'median':
        return this.olympiadMedianRemoval(i, overrideSeconds);
      case 'mode':
        return this.olympiadModeConstraint(i, overrideSeconds);
      case 'range':
        return this.olympiadRangeReplacement(i, overrideSeconds);
      case 'mean':
      default:
        return this.olympiadMeanMissingTotal(i, overrideSeconds);
    }
  }

  private olympiadMeanMissingTotal(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const base = this.pick(i, [6, 8, 10, 12]);
    const mean = this.pick(i + 1, [14, 16, 18, 20]);
    const count = this.pick(i + 2, [4, 5, 6]);
    const total = mean * count;
    const last = total - base * (count - 1);

    return this.finish({
      prompt: `A data set has ${count} numbers. ${count - 1} of them are ${base}, and the mean of the full data set is ${mean}. What is the remaining number?`,
      answer: this.num(last),
      distractors: [
        this.num(total - base),
        this.num(mean),
        this.num(last - base),
        this.num(last + base),
      ],
      explanation: `Total sum = mean × count = ${mean} × ${count} = ${total}. The known ${count - 1} numbers sum to ${base * (count - 1)}, so the remaining number is ${total} - ${base * (count - 1)} = ${last}.`,
      recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
      seed: i,
    });
  }

  private olympiadMedianRemoval(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const data = this.pick(i, [
      [3, 5, 7, 9, 11, 13],
      [4, 6, 8, 10, 12, 14],
      [2, 4, 6, 8, 10, 12],
      [5, 7, 9, 11, 13, 15],
    ]);
    const answer = data[5];

    return this.finish({
      prompt: `One value is removed from the ordered data set ${data.join(', ')}. The median of the remaining five numbers is ${data[2]}. Which value was removed?`,
      answer: this.num(answer),
      distractors: [
        this.num(data[0]),
        this.num(data[1]),
        this.num(data[3]),
        this.num((data[2] + data[3]) / 2),
      ],
      explanation: `Removing ${answer} leaves ${data.slice(0, 5).join(', ')}. Then the middle of the five remaining values is ${data[2]}.`,
      recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
      seed: i,
    });
  }

  private olympiadModeConstraint(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const x = this.pick(i, [4, 5, 6, 7]);
    const answer = x + 3;
    return this.finish({
      prompt: `In the set ${x}, ${x}, ${x + 1}, ${x + 2}, ${x + 3}, one more number is added so that the mode becomes ${x + 3}. Which number must be added?`,
      answer: this.num(answer),
      distractors: [
        this.num(x),
        this.num(x + 1),
        this.num(x + 2),
        this.num(x + 4),
      ],
      explanation: `The current mode is ${x}, because it appears twice. To make ${x + 3} the mode, it must also be added enough to exceed that frequency, so the added number must be ${x + 3}.`,
      recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
      seed: i,
    });
  }

  private olympiadRangeReplacement(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const min = this.pick(i, [2, 3, 4]);
    const max = this.pick(i + 1, [17, 19, 21]);
    const replacement = max - this.pick(i + 2, [2, 4, 6]);
    const answer = replacement - min;

    return this.finish({
      prompt: `A data set has minimum ${min} and maximum ${max}. The maximum is replaced by ${replacement}. What is the new range?`,
      answer: this.num(answer),
      distractors: [
        this.num(max - min),
        this.num(replacement),
        this.num(replacement - max),
        this.num(answer + 2),
      ],
      explanation: `The minimum stays ${min}. After replacing the maximum with ${replacement}, the new range is ${replacement} - ${min} = ${answer}.`,
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
    const rotated = rotateBySeed(
      fillOptionsWithSafeFallback([args.answer, ...args.distractors], args.answer, args.seed),
      args.seed,
    );

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

  private resolveFocus(req: PracticeEngineRequest): StatisticsFocus {
    const t = this.topicDescriptorText(req);

    if (/(^|\W)mean($|\W)|average|weighted mean/.test(t)) return 'mean';
    if (/(^|\W)median($|\W)/.test(t)) return 'median';
    if (/(^|\W)mode($|\W)/.test(t)) return 'mode';
    if (/(^|\W)range($|\W)|spread|outlier/.test(t)) return 'range';
    return 'mixed';
  }

  private familyOrder(
    focus: StatisticsFocus,
    fallback: Array<Exclude<StatisticsFocus, 'mixed'>>,
  ): Array<Exclude<StatisticsFocus, 'mixed'>> {
    if (focus !== 'mixed') {
      return [focus];
    }
    return fallback;
  }

  private topicDescriptorText(req: PracticeEngineRequest): string {
    const strictSummary = String(req.strictPromptSummary ?? '');
    const strictTopicLine = strictSummary
      .split(/\r?\n/)
      .map((line) => line.trim())
      .find((line) => /^topic\s*:/i.test(line));

    const strictTopicText = strictTopicLine
      ? strictTopicLine.replace(/^topic\s*:/i, '').trim()
      : '';

    return `${req.topicLabel} ${req.topicPathText} ${strictTopicText}`
      .toLowerCase()
      .trim();
  }
}
