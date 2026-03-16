import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, fillOptionsWithSafeFallback, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class PhysicsForcesDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`
      .toLowerCase()
      .trim();

    return (
      s === 'physics' &&
      (
        t.includes('forces') ||
        t.includes('net force') ||
        t.includes('balanced forces') ||
        t.includes('friction')
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
    const right = this.pick(i, [8, 10, 12, 15]);
    const left = this.pick(i + 1, [2, 3, 5, 6]);
    const net = right - left;

    return this.finish({
      prompt: `A body is pushed ${right} N to the right and ${left} N to the left. What is the net force?`,
      answer: `${net} N to the right`,
      distractors: [
        `${right + left} N to the right`,
        `${net} N to the left`,
        `${left} N to the right`,
        `${right} N to the left`,
      ],
      explanation: `Net force = ${right} - ${left} = ${net} N to the right.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const right = this.pick(i, [20, 24, 30]);
      const left = this.pick(i + 1, [10, 12, 15]);
      const net = right - left;

      return this.finish({
        prompt: `A box is pushed with ${right} N to the right and ${left} N to the left. What is the net force on the box?`,
        answer: `${net} N to the right`,
        distractors: [
          `${right + left} N to the right`,
          `${net} N to the left`,
          `${left} N to the right`,
          `${right} N to the left`,
        ],
        explanation: `Net force is the vector sum: ${right} - ${left} = ${net} N to the right.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      return this.finish({
        prompt: `Two equal forces act in opposite directions on an object. Which statement is correct?`,
        answer: `The forces are balanced and net force is zero`,
        distractors: [
          `The object must move right`,
          `The object must accelerate left`,
          `The net force equals one of the forces`,
          `The forces double the acceleration`,
        ],
        explanation: `Equal forces in opposite directions cancel out, so the net force is zero.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const pull = this.pick(i, [18, 24, 30]);
    const friction = this.pick(i + 1, [6, 8, 10]);
    const net = pull - friction;

    return this.finish({
      prompt: `A sled is pulled with ${pull} N while friction opposes motion with ${friction} N. What is the net force?`,
      answer: `${net} N in the direction of pull`,
      distractors: [
        `${pull + friction} N in the direction of pull`,
        `${friction} N in the direction of pull`,
        `${net} N opposite the pull`,
        `${pull} N opposite the pull`,
      ],
      explanation: `Net force = pulling force - friction = ${pull} - ${friction} = ${net} N in the direction of pull.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      return this.finish({
        prompt: `Which factor does NOT affect friction between two surfaces?`,
        answer: `Color of the surfaces`,
        distractors: [
          `Normal force`,
          `Type of materials`,
          `Surface roughness`,
          `How hard surfaces press`,
        ],
        explanation: `Friction depends on material, roughness, and normal force, but not on color.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      return this.finish({
        prompt: `An object has balanced forces acting on it. What can be said about its motion?`,
        answer: `It stays at rest or moves with constant velocity`,
        distractors: [
          `It must speed up`,
          `It must slow down`,
          `It must move right`,
          `It must accelerate`,
        ],
        explanation: `Balanced forces mean zero net force, so there is no acceleration.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const f1 = this.pick(i, [25, 30, 35]);
    const f2 = this.pick(i + 1, [5, 10, 15]);
    const f3 = this.pick(i + 2, [4, 6, 8]);
    const net = f1 - f2 - f3;

    return this.finish({
      prompt: `Three horizontal forces act on an object: ${f1} N right, ${f2} N left, and ${f3} N left. What is the net force?`,
      answer: `${net} N to the right`,
      distractors: [
        `${f1 + f2 + f3} N to the right`,
        `${Math.abs(net)} N to the left`,
        `${f2 + f3} N to the left`,
        `${f1} N to the right`,
      ],
      explanation: `Take right as positive. Net force = ${f1} - ${f2} - ${f3} = ${net} N to the right.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const m = this.pick(i, [2, 4, 5]);
      const net = this.pick(i + 1, [8, 10, 12]);
      const a = net / m;

      return this.finish({
        prompt: `A ${m} kg object has net force ${net} N. What is its acceleration?`,
        answer: `${this.num(a)} m/s²`,
        distractors: [
          `${net} m/s²`,
          `${m} m/s²`,
          `${this.num(a + 1)} m/s²`,
          `${this.num(Math.max(0.5, a - 1))} m/s²`,
        ],
        explanation: `Use a = F_net/m = ${net}/${m} = ${this.num(a)} m/s².`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const push = this.pick(i, [20, 24, 28]);
      const friction = this.pick(i + 1, [5, 8, 10]);
      const net = push - friction;

      return this.finish({
        prompt: `A crate is pushed with ${push} N while friction is ${friction} N opposite motion. Which is correct?`,
        answer: `Net force is ${net} N forward`,
        distractors: [
          `Net force is ${push + friction} N forward`,
          `Net force is ${friction} N backward`,
          `Forces are balanced`,
          `Net force is ${net} N backward`,
        ],
        explanation: `Net force = applied force - friction = ${push} - ${friction} = ${net} N forward.`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
      });
    }

    return this.finish({
      prompt: `A book rests on a table without moving. Which statement is correct about vertical forces on the book?`,
      answer: `The upward normal force equals the downward weight`,
      distractors: [
        `Weight is greater than normal force`,
        `Normal force is zero`,
        `There is upward acceleration`,
        `The forces are unrelated`,
      ],
      explanation: `If the book is at rest, net vertical force is zero, so the normal force balances the weight.`,
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
      topicMatchNote: 'Physics Forces',
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
