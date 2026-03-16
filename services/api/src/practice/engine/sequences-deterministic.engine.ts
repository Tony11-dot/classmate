import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class SequencesDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`
      .toLowerCase()
      .trim();

    return (
      s === 'math' &&
      (
        t.includes('sequence') ||
        t.includes('sequences') ||
        t.includes('arithmetic sequence') ||
        t.includes('geometric sequence') ||
        t.includes('common difference') ||
        t.includes('common ratio') ||
        t.includes('next term')
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
    const start = this.pick(i, [2, 4, 6, 8, 10]);
    const diff = this.pick(i + 1, [2, 3, 4, 5]);
    const seq = [start, start + diff, start + 2 * diff, start + 3 * diff];
    const answer = start + 4 * diff;

    return this.finish({
      prompt: `Find the next term in the arithmetic sequence: ${seq.join(', ')}, ...`,
      answer: this.num(answer),
      distractors: [
        this.num(answer - 1),
        this.num(answer + 1),
        this.num(seq[3] + diff + 2),
        this.num(diff),
      ],
      explanation: `This is an arithmetic sequence with common difference ${diff}. So the next term is ${seq[3]} + ${diff} = ${answer}.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const start = this.pick(i, [3, 5, 7, 9]);
      const diff = this.pick(i + 1, [2, 4, 6]);
      const n = this.pick(i + 2, [5, 6, 7, 8]);
      const answer = start + (n - 1) * diff;

      return this.finish({
        prompt: `In the arithmetic sequence ${start}, ${start + diff}, ${start + 2 * diff}, ... what is the ${this.ordinal(n)} term?`,
        answer: this.num(answer),
        distractors: [
          this.num(start + n * diff),
          this.num(start + (n - 2) * diff),
          this.num(diff * n),
          this.num(answer + this.pick(i + 3, [1, -1, 2])),
        ],
        explanation: `For an arithmetic sequence, term ${n} = first term + (${n} - 1) × difference = ${start} + ${n - 1} × ${diff} = ${answer}.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const start = this.pick(i, [2, 3, 4, 5]);
    const ratio = this.pick(i + 1, [2, 3, 4]);
    const seq = [start, start * ratio, start * ratio * ratio, start * ratio * ratio * ratio];
    const answer = seq[3] * ratio;

    return this.finish({
      prompt: `Find the next term in the geometric sequence: ${seq.join(', ')}, ...`,
      answer: this.num(answer),
      distractors: [
        this.num(seq[3] + ratio),
        this.num(seq[3] * (ratio - 1)),
        this.num(answer + ratio),
        this.num(seq[2] * ratio),
      ],
      explanation: `This is a geometric sequence with common ratio ${ratio}. So the next term is ${seq[3]} × ${ratio} = ${answer}.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const start = this.pick(i, [1, 2, 3, 4, 5]);
      const ratio = this.pick(i + 1, [2, 3, 4]);
      const n = this.pick(i + 2, [4, 5, 6]);
      const answer = start * Math.pow(ratio, n - 1);

      return this.finish({
        prompt: `In the geometric sequence ${start}, ${start * ratio}, ${start * ratio * ratio}, ... what is the ${this.ordinal(n)} term?`,
        answer: this.num(answer),
        distractors: [
          this.num(start * Math.pow(ratio, n)),
          this.num(start * Math.pow(ratio, n - 2)),
          this.num(answer + ratio),
          this.num(start * (n - 1) * ratio),
        ],
        explanation: `For a geometric sequence, term ${n} = first term × ratio^(${n} - 1) = ${start} × ${ratio}^${n - 1} = ${answer}.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const start = this.pick(i, [4, 6, 8, 10]);
    const diff = this.pick(i + 1, [3, 4, 5, 6]);
    const k = this.pick(i + 2, [4, 5, 6, 7]);
    const term = start + (k - 1) * diff;

    return this.finish({
      prompt: `An arithmetic sequence has first term ${start} and common difference ${diff}. If a term equals ${term}, which term number is it?`,
      answer: this.num(k),
      distractors: [
        this.num(k + 1),
        this.num(k - 1),
        this.num(diff),
        this.num(start + diff),
      ],
      explanation: `Solve ${term} = ${start} + (n - 1) × ${diff}. Then ${term - start} = (n - 1) × ${diff}, so n - 1 = ${(term - start) / diff}, hence n = ${k}.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const start = this.pick(i, [2, 3, 4, 5]);
      const diff = this.pick(i + 1, [2, 3, 4]);
      const m = this.pick(i + 2, [3, 4, 5]);
      const n = this.pick(i + 3, [7, 8, 9]);
      const termM = start + (m - 1) * diff;
      const termN = start + (n - 1) * diff;
      const answer = termN - termM;

      return this.finish({
        prompt: `In an arithmetic sequence, the ${this.ordinal(m)} term is ${termM} and the ${this.ordinal(n)} term is ${termN}. What is the common difference?`,
        answer: this.num(diff),
        distractors: [
          this.num(answer),
          this.num(diff + 1),
          this.num(diff - 1),
          this.num((termN - termM) / (n - m + 1)),
        ],
        explanation: `The difference between term ${n} and term ${m} is (${n - m}) × d = ${termN} - ${termM} = ${answer}. So d = ${answer} ÷ ${n - m} = ${diff}.`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const start = this.pick(i, [3, 4, 5, 6]);
      const ratio = this.pick(i + 1, [2, 3]);
      const n = this.pick(i + 2, [4, 5, 6]);
      const term = start * Math.pow(ratio, n - 1);
      const next = term * ratio;

      return this.finish({
        prompt: `The ${this.ordinal(n)} term of a geometric sequence is ${term}, and the common ratio is ${ratio}. What is the ${this.ordinal(n + 1)} term?`,
        answer: this.num(next),
        distractors: [
          this.num(term + ratio),
          this.num(term * (ratio - 1)),
          this.num(term / ratio),
          this.num(next + ratio),
        ],
        explanation: `In a geometric sequence, each term is multiplied by the common ratio. So the next term is ${term} × ${ratio} = ${next}.`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
      });
    }

    const start = this.pick(i, [5, 7, 9, 11]);
    const diff = this.pick(i + 1, [2, 3, 4]);
    const n = this.pick(i + 2, [6, 7, 8]);
    const sum = (n / 2) * (2 * start + (n - 1) * diff);

    return this.finish({
      prompt: `Find the sum of the first ${n} terms of the arithmetic sequence ${start}, ${start + diff}, ${start + 2 * diff}, ...`,
      answer: this.num(sum),
      distractors: [
        this.num(sum + diff),
        this.num(sum - diff),
        this.num(start + (n - 1) * diff),
        this.num(n * (start + diff)),
      ],
      explanation: `Sum of first ${n} arithmetic terms = n/2 × [2a + (n - 1)d] = ${n}/2 × [2(${start}) + (${n} - 1)(${diff})] = ${sum}.`,
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
      options.push(this.num(Number(args.answer) + options.length + args.seed + 3));
    }

    const rotated = rotateBySeed(options.slice(0, 4), args.seed);

    return {
      prompt: args.prompt,
      options: rotated,
      correctIndex: rotated.indexOf(args.answer),
      correctAnswerText: args.answer,
      explanation: args.explanation,
      recommendedTimeSeconds: args.recommendedTimeSeconds,
      topicMatchNote: 'Sequences',
    };
  }

  private num(n: number): string {
    return Number.isInteger(n) ? String(n) : String(Number(n.toFixed(2)));
  }

  private ordinal(n: number): string {
    if (n % 100 >= 11 && n % 100 <= 13) return `${n}th`;
    switch (n % 10) {
      case 1: return `${n}st`;
      case 2: return `${n}nd`;
      case 3: return `${n}rd`;
      default: return `${n}th`;
    }
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
