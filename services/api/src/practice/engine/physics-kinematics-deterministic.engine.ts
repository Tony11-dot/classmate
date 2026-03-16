import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class PhysicsKinematicsDeterministicEngine implements PracticeEngine {

  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase().trim();

    return (
      s === 'physics' &&
      (
        t.includes('kinematics') ||
        t.includes('distance-time') ||
        t.includes('velocity') ||
        t.includes('average velocity') ||
        t.includes('average speed') ||
        t.includes('acceleration')
      ) &&
      !t.includes('newton') &&
      !t.includes('force') &&
      !t.includes('forces') &&
      !t.includes('friction') &&
      !t.includes('energy') &&
      !t.includes('work') &&
      !t.includes('momentum') &&
      !t.includes('impulse') &&
      !t.includes('electric') &&
      !t.includes('circuit') &&
      !t.includes('wave') &&
      !t.includes('optics') &&
      !t.includes('thermo')
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
    if (i % 2 === 0) {
      const d = this.pick(i, [20, 30, 40, 50]);
      const t = this.pick(i + 1, [2, 4, 5, 10]);
      const answer = d / t;

      return this.finish({
        prompt: `A body travels ${d} m in ${t} s. What is its average speed?`,
        answer: `${answer} m/s`,
        distractors: [
          `${d + t} m/s`,
          `${d * t} m/s`,
          `${Math.max(1, answer - 1)} m/s`,
          `${answer + 2} m/s`,
        ],
        explanation: `Average speed = distance / time = ${d} / ${t} = ${answer} m/s.`,
        recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
        seed: i,
      });
    }

    const u = this.pick(i, [0, 2, 4, 6]);
    const a = this.pick(i + 1, [2, 3, 4]);
    const t = this.pick(i + 2, [2, 3, 5]);
    const v = u + a * t;

    return this.finish({
      prompt: `An object starts with velocity ${u} m/s and accelerates at ${a} m/s² for ${t} s. What is its final velocity?`,
      answer: `${v} m/s`,
      distractors: [
        `${u + a} m/s`,
        `${a * t} m/s`,
        `${v + 2} m/s`,
        `${Math.max(0, v - 2)} m/s`,
      ],
      explanation: `Use v = u + at = ${u} + ${a}×${t} = ${v} m/s.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const d1 = this.pick(i, [120, 150, 180]);
      const t1 = this.pick(i + 1, [2, 3, 4]);
      const d2 = this.pick(i + 2, [40, 60, 90]);
      const t2 = this.pick(i + 3, [1, 2, 3]);
      const displacement = d1 - d2;
      const totalTime = t1 + t2;
      const avgV = displacement / totalTime;
      const dir = avgV >= 0 ? 'north' : 'south';

      return this.finish({
        prompt: `A car travels ${d1} km north in ${t1} h and then ${d2} km south in ${t2} h. What is its average velocity for the whole trip?`,
        answer: `${Math.abs(avgV)} km/h ${dir}`,
        distractors: [
          `${Math.abs(d1 + d2) / totalTime} km/h north`,
          `${Math.abs(displacement)} km/h ${dir}`,
          `${Math.abs(avgV) + 5} km/h ${dir}`,
          `${Math.abs(avgV)} km/h ${dir === 'north' ? 'south' : 'north'}`,
        ],
        explanation: `Average velocity = displacement / total time. Displacement = ${d1} - ${d2} = ${displacement} km. Total time = ${totalTime} h. So average velocity = ${avgV} km/h, i.e. ${Math.abs(avgV)} km/h ${dir}.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const u = this.pick(i, [0, 4, 6, 8]);
      const a = this.pick(i + 1, [2, 3, 4]);
      const t = this.pick(i + 2, [3, 4, 5, 6]);
      const v = u + a * t;

      return this.finish({
        prompt: `An object has initial velocity ${u} m/s and accelerates uniformly at ${a} m/s² for ${t} s. What is its final velocity?`,
        answer: `${v} m/s`,
        distractors: [
          `${a * t} m/s`,
          `${u + a} m/s`,
          `${v + 3} m/s`,
          `${Math.max(0, v - 3)} m/s`,
        ],
        explanation: `Use v = u + at = ${u} + ${a}×${t} = ${v} m/s.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    const u = this.pick(i, [12, 15, 18, 20]);
    const a = this.pick(i + 1, [2, 3, 4, 5]);
    const t = u / a;

    return this.finish({
      prompt: `A moving object slows uniformly from ${u} m/s with deceleration ${a} m/s². How long does it take to come to rest?`,
      answer: `${this.num(t)} s`,
      distractors: [
        `${u - a} s`,
        `${u + a} s`,
        `${this.num(t + 2)} s`,
        `${this.num(Math.max(1, t - 1))} s`,
      ],
      explanation: `Use v = u + at with final velocity 0. So 0 = ${u} - ${a}t, hence t = ${u}/${a} = ${this.num(t)} s.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const u = this.pick(i, [2, 4, 6, 8]);
      const a = this.pick(i + 1, [2, 3, 4]);
      const t = this.pick(i + 2, [3, 4, 5]);
      const s = u * t + 0.5 * a * t * t;

      return this.finish({
        prompt: `An object starts with velocity ${u} m/s and accelerates at ${a} m/s² for ${t} s. How far does it travel in that time?`,
        answer: `${this.num(s)} m`,
        distractors: [
          `${u * t + a * t * t} m`,
          `${u + a * t} m`,
          `${this.num(s + 5)} m`,
          `${this.num(Math.max(1, s - 5))} m`,
        ],
        explanation: `Use s = ut + ½at² = ${u}×${t} + ½×${a}×${t}² = ${this.num(s)} m.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const u = this.pick(i, [20, 24, 30]);
      const g = 10;
      const t = u / g;

      return this.finish({
        prompt: `A ball is thrown straight up at ${u} m/s. Assuming g = ${g} m/s², how long does it take to reach the highest point?`,
        answer: `${this.num(t)} s`,
        distractors: [
          `${this.num(2 * t)} s`,
          `${this.num(t / 2)} s`,
          `${this.num(t + 1)} s`,
          `${u} s`,
        ],
        explanation: `At the top, final velocity is 0. Using v = u - gt gives 0 = ${u} - ${g}t, so t = ${u}/${g} = ${this.num(t)} s.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    const d = this.pick(i, [300, 360, 400, 480]);
    const t = this.pick(i + 1, [30, 40, 50, 60]);
    const speed = d / t;

    return this.finish({
      prompt: `A runner covers ${d} m in ${t} s. What is the runner's average speed?`,
      answer: `${this.num(speed)} m/s`,
      distractors: [
        `${d} m/s`,
        `${t} m/s`,
        `${this.num(speed + 2)} m/s`,
        `${this.num(Math.max(1, speed - 2))} m/s`,
      ],
      explanation: `Average speed = distance / time = ${d}/${t} = ${this.num(speed)} m/s.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const mode = i % 3;

    if (mode === 0) {
      const u = this.pick(i, [5, 10, 15]);
      const a = this.pick(i + 1, [2, 3, 4]);
      const t = this.pick(i + 2, [4, 5, 6]);
      const v = u + a * t;
      const avg = (u + v) / 2;

      return this.finish({
        prompt: `An object moves with uniform acceleration from ${u} m/s to ${v} m/s in ${t} s. What is its average velocity during this interval?`,
        answer: `${this.num(avg)} m/s`,
        distractors: [
          `${this.num(v)} m/s`,
          `${this.num((v - u) / t)} m/s`,
          `${this.num(avg + 2)} m/s`,
          `${this.num(Math.max(1, avg - 2))} m/s`,
        ],
        explanation: `For uniform acceleration, average velocity = (u + v)/2 = (${u} + ${v})/2 = ${this.num(avg)} m/s.`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
      });
    }

    if (mode === 1) {
      const u = this.pick(i, [0, 4, 8]);
      const a = this.pick(i + 1, [2, 3, 4]);
      const t = this.pick(i + 2, [5, 6, 8]);
      const s = u * t + 0.5 * a * t * t;

      return this.finish({
        prompt: `A body starts with velocity ${u} m/s and acceleration ${a} m/s². How much distance does it cover in ${t} s?`,
        answer: `${this.num(s)} m`,
        distractors: [
          `${u + a * t} m`,
          `${u * t + a * t * t} m`,
          `${this.num(s + 4)} m`,
          `${this.num(Math.max(1, s - 4))} m`,
        ],
        explanation: `Use s = ut + ½at² = ${u}×${t} + ½×${a}×${t}² = ${this.num(s)} m.`,
        recommendedTimeSeconds: this.timeFor('olympiad', overrideSeconds),
        seed: i,
      });
    }

    const d = this.pick(i, [100, 150, 200]);
    const t1 = this.pick(i + 1, [10, 15, 20]);
    const t2 = this.pick(i + 2, [5, 10]);
    const rest = this.pick(i + 3, [5, 10]);
    const totalDistance = 2 * d;
    const totalTime = t1 + rest + t2;
    const avgSpeed = totalDistance / totalTime;

    return this.finish({
      prompt: `A student runs ${d} m in ${t1} s, rests for ${rest} s, then runs another ${d} m in ${t2} s. What is the average speed for the whole interval?`,
      answer: `${this.num(avgSpeed)} m/s`,
      distractors: [
        `${this.num(totalDistance / (t1 + t2))} m/s`,
        `${this.num(d / t1)} m/s`,
        `${this.num(avgSpeed + 1)} m/s`,
        `${this.num(Math.max(1, avgSpeed - 1))} m/s`,
      ],
      explanation: `Average speed = total distance / total time = ${totalDistance} / ${totalTime} = ${this.num(avgSpeed)} m/s.`,
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
      options.push(`${args.answer}_${options.length + args.seed}`);
    }

    const rotated = rotateBySeed(options.slice(0, 4), args.seed);

    return {
      prompt: args.prompt,
      options: rotated,
      correctIndex: rotated.indexOf(args.answer),
      correctAnswerText: args.answer,
      explanation: args.explanation,
      recommendedTimeSeconds: args.recommendedTimeSeconds,
      topicMatchNote: 'Physics Kinematics',
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
