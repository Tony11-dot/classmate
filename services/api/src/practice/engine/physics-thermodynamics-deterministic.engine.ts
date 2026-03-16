import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineDifficulty,
} from './practice-engine.types';
import { clampTime, rotateBySeed, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class PhysicsThermodynamicsDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase().trim();
    return s === 'physics' && (t.includes('thermodynamics') || t.includes('heat') || t.includes('temperature') || t.includes('specific heat'));
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

  private makeQuestion(i: number, difficulty: EngineDifficulty, overrideSeconds: number | null): GeneratedQuestion {
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
    return this.finish({
      prompt: `What happens to the temperature of an object when it gains thermal energy and no phase change occurs?`,
      answer: `It increases`,
      distractors: [`It decreases`, `It becomes zero`, `It must stay constant`],
      explanation: `Adding thermal energy usually raises temperature when no phase change occurs.`,
      recommendedTimeSeconds: this.timeFor('easy', overrideSeconds),
      seed: i,
    });
  }

  private makeMedium(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const m = this.pick(i, [2, 3, 4, 5]);
      const c = this.pick(i + 1, [100, 200, 300]);
      const dt = this.pick(i + 2, [4, 5, 6]);
      const q = m * c * dt;

      return this.finish({
        prompt: `A ${m} kg substance with specific heat capacity ${c} J/kg°C is heated by ${dt}°C. How much heat energy is absorbed?`,
        answer: `${q} J`,
        distractors: [`${m + c + dt} J`, `${q + c} J`, `${m * dt} J`],
        explanation: `Use Q = mcΔT = ${m}×${c}×${dt} = ${q} J.`,
        recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
        seed: i,
      });
    }

    return this.finish({
      prompt: `Two objects at different temperatures are placed in contact. In which direction does heat flow spontaneously?`,
      answer: `From the hotter object to the colder object`,
      distractors: [
        `From the colder object to the hotter object`,
        `In both directions equally with no net flow`,
        `Heat does not flow unless work is done`,
      ],
      explanation: `Thermal energy flows spontaneously from higher temperature to lower temperature until equilibrium is reached.`,
      recommendedTimeSeconds: this.timeFor('medium', overrideSeconds),
      seed: i,
    });
  }

  private makeHard(i: number, overrideSeconds: number | null): GeneratedQuestion {
    if (i % 2 === 0) {
      const q = this.pick(i, [1200, 1800, 2400, 3000]);
      const m = this.pick(i + 1, [2, 3, 4]);
      const c = this.pick(i + 2, [100, 150, 200]);
      const dt = q / (m * c);

      return this.finish({
        prompt: `An object of mass ${m} kg and specific heat capacity ${c} J/kg°C absorbs ${q} J of heat. By how much does its temperature rise?`,
        answer: `${this.num(dt)}°C`,
        distractors: [`${this.num(dt + 1)}°C`, `${this.num(q / c)}°C`, `${this.num(m * c)}°C`],
        explanation: `From Q = mcΔT, we get ΔT = Q/(mc) = ${q}/(${m}×${c}) = ${this.num(dt)}°C.`,
        recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
        seed: i,
      });
    }

    return this.finish({
      prompt: `What is thermal equilibrium?`,
      answer: `A state where objects in contact are at the same temperature and no net heat flows`,
      distractors: [
        `A state where both objects contain the same thermal energy`,
        `A state where both objects have zero heat`,
        `A state where heat flows equally in opposite directions because temperatures are different`,
      ],
      explanation: `Thermal equilibrium means equal temperature and no net heat transfer.`,
      recommendedTimeSeconds: this.timeFor('hard', overrideSeconds),
      seed: i,
    });
  }

  private makeOlympiad(i: number, overrideSeconds: number | null): GeneratedQuestion {
    const m = this.pick(i, [1, 2, 3, 4]);
    const c = this.pick(i + 1, [200, 250, 300]);
    const dt = this.pick(i + 2, [8, 10, 12]);
    const q = m * c * dt;

    return this.finish({
      prompt: `How much heat is required to raise the temperature of ${m} kg of a material with specific heat ${c} J/kg°C by ${dt}°C?`,
      answer: `${q} J`,
      distractors: [`${q + 100} J`, `${m + c + dt} J`, `${m * c} J`],
      explanation: `Use Q = mcΔT = ${m}×${c}×${dt} = ${q} J.`,
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
      topicMatchNote: 'Physics Thermodynamics',
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
