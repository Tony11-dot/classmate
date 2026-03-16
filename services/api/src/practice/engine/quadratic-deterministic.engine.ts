import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type { PracticeEngineRequest, GeneratedQuestion } from './practice-engine.types';

type QuadTemplate = {
  a: number;
  b: number;
  c: number;
  answer: string;
  explanation: string;
};

@Injectable()
export class QuadraticDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase();

    return (
      s === 'math' &&
      (
        t.includes('quadratic') ||
        t.includes('algebra')
      )
    );
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]> {
    const out: GeneratedQuestion[] = [];
    const wanted = req.questionCount;

    for (let i = 0; i < wanted; i++) {
      const q = this.makeQuestion(i, req.difficulty);
      out.push({
        prompt: q.prompt,
        options: q.options,
        correctIndex: q.correctIndex,
        correctAnswerText: q.correctAnswerText,
        explanation: q.explanation,
        recommendedTimeSeconds: this.timeFor(req.difficulty, req.timePreferenceSeconds),
        topicMatchNote: 'Quadratic equations',
      });
    }

    return out;
  }

  private timeFor(
    difficulty: string,
    overrideSeconds: number | null,
  ): number {
    if (overrideSeconds != null && Number.isFinite(overrideSeconds)) {
      return Math.max(5, Math.min(900, Math.round(overrideSeconds)));
    }

    switch (difficulty) {
      case 'easy':
        return 25;
      case 'medium':
        return 40;
      case 'hard':
        return 60;
      case 'olympiad':
        return 90;
      default:
        return 45;
    }
  }

  private makeQuestion(i: number, difficulty: string) {
    const bank =
      difficulty === 'easy'
        ? this.easyBank()
        : difficulty === 'medium'
        ? this.mediumBank()
        : difficulty === 'hard'
        ? this.hardBank()
        : this.olympiadBank();

    const item = bank[i % bank.length];
    const options = this.makeOptions(item.answer);

    return {
      prompt: `Solve the quadratic equation: ${item.a}x² ${item.b >= 0 ? '+' : '-'} ${Math.abs(item.b)}x ${item.c >= 0 ? '+' : '-'} ${Math.abs(item.c)} = 0. Which option is a correct root?`,
      options,
      correctIndex: options.indexOf(item.answer),
      correctAnswerText: item.answer,
      explanation: item.explanation,
    };
  }

  private easyBank(): QuadTemplate[] {
    return [
      this.fromRoots(1, -5, 6, '2'),
      this.fromRoots(1, -7, 12, '3'),
      this.fromRoots(1, -9, 20, '4'),
      this.fromRoots(1, -6, 8, '2'),
      this.fromRoots(1, -8, 15, '3'),
      this.fromRoots(1, -10, 21, '3'),
      this.fromRoots(1, -11, 28, '4'),
      this.fromRoots(1, -12, 32, '4'),
      this.fromRoots(1, -13, 42, '6'),
      this.fromRoots(1, -14, 48, '6'),
    ];
  }

  private mediumBank(): QuadTemplate[] {
    return [
      this.fromRoots(2, -8, 6, '1'),
      this.fromRoots(3, -15, 18, '2'),
      this.fromRoots(2, -10, 12, '2'),
      this.fromRoots(4, -20, 24, '2'),
      this.fromRoots(3, -18, 27, '3'),
      this.fromRoots(5, -25, 30, '2'),
      this.fromRoots(2, -14, 24, '3'),
      this.fromRoots(6, -30, 36, '2'),
      this.fromRoots(4, -28, 48, '3'),
      this.fromRoots(3, -21, 30, '2'),
    ];
  }

  private hardBank(): QuadTemplate[] {
    return [
      this.fromRoots(1, -6, 5, '1'),
      this.fromRoots(1, -8, 12, '2'),
      this.fromRoots(2, -12, 16, '2'),
      this.fromRoots(3, -15, 18, '2'),
      this.fromRoots(4, -20, 21, '3/2'),
      this.fromRoots(2, -9, 9, '3/2'),
      this.fromRoots(5, -20, 15, '1'),
      this.fromRoots(6, -19, 10, '2/3'),
      this.fromRoots(2, -11, 12, '3/2'),
      this.fromRoots(3, -10, 3, '1/3'),
    ];
  }

  private olympiadBank(): QuadTemplate[] {
    return [
      this.fromRoots(1, -5, 6, '3'),
      this.fromRoots(2, -7, 3, '3'),
      this.fromRoots(3, -8, 4, '2'),
      this.fromRoots(4, -12, 5, '5/2'),
      this.fromRoots(5, -18, 9, '3'),
      this.fromRoots(2, -13, 15, '5/2'),
      this.fromRoots(3, -16, 21, '3'),
      this.fromRoots(6, -17, 5, '2'),
      this.fromRoots(2, -15, 25, '5/2'),
      this.fromRoots(4, -19, 12, '3'),
    ];
  }

  private fromRoots(a: number, b: number, c: number, answer: string): QuadTemplate {
    return {
      a,
      b,
      c,
      answer,
      explanation:
        `Substitute each option into ${a}x² ${b >= 0 ? '+' : '-'} ${Math.abs(b)}x ${c >= 0 ? '+' : '-'} ${Math.abs(c)}. ` +
        `The correct root makes the expression equal to 0, so the correct answer is ${answer}.`,
    };
  }

  private makeOptions(answer: string): string[] {
    const pool = new Set<string>([answer]);

    const numeric = Number(answer);
    if (Number.isFinite(numeric)) {
      pool.add(String(numeric + 1));
      pool.add(String(numeric - 1));
      pool.add(String(numeric + 2));
      pool.add(String(numeric - 2));
      pool.add(String(-numeric));
      pool.add(String(numeric + 3));
    } else {
      pool.add('1');
      pool.add('2');
      pool.add('3');
      pool.add('4');
      pool.add('-1');
    }

    const arr = Array.from(pool).slice(0, 4);
    while (arr.length < 4) arr.push(String(arr.length + 10));

    const [first, ...rest] = arr;
    return [rest[0], first, rest[1], rest[2]].filter(Boolean) as string[];
  }
}
