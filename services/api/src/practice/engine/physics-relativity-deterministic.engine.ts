import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type { GeneratedQuestion, PracticeEngineRequest } from './practice-engine.types';

@Injectable()
export class PhysicsRelativityDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = String(req.subject ?? '').toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase().trim();
    return s === 'physics' && (t.includes('relativity') || t.includes('special relativity') || t.includes('general relativity'));
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]> {
    const count = Math.max(1, Math.min(20, Number(req.questionCount ?? 5)));
    const seconds = Math.max(
      5,
      Math.min(
        900,
        Math.round(
          Number.isFinite(Number(req.timePreferenceSeconds))
            ? Number(req.timePreferenceSeconds)
            : 45,
        ),
      ),
    );

    const bank: GeneratedQuestion[] = [
      this.mcq(
        'Relativity',
        'According to special relativity, what happens to the length of an object moving close to the speed of light relative to an observer?',
        ['It increases', 'It stays the same', 'It contracts in the direction of motion', 'It disappears'],
        2,
        'Special relativity predicts length contraction in the direction of motion for very high speeds.',
        seconds,
      ),
      this.mcq(
        'Relativity',
        'What does time dilation mean in special relativity?',
        ['Moving clocks run faster', 'Moving clocks run slower relative to a stationary observer', 'Time stops for all observers', 'Only light experiences time'],
        1,
        'Time dilation means a moving clock is measured to run slower compared with a stationary observer’s clock.',
        seconds,
      ),
      this.mcq(
        'Relativity',
        'Which statement is a postulate of special relativity?',
        ['The speed of light in vacuum is the same for all inertial observers', 'Mass is always constant in all situations', 'Gravity acts only on planets', 'Time flows identically in all frames'],
        0,
        'A core postulate of special relativity is that the speed of light in vacuum is constant for all inertial observers.',
        seconds,
      ),
      this.mcq(
        'Relativity',
        'In general relativity, gravity is best described as:',
        ['A magnetic force', 'A curvature of spacetime', 'A friction effect', 'A chemical attraction'],
        1,
        'General relativity describes gravity as the curvature of spacetime caused by mass and energy.',
        seconds,
      ),
      this.mcq(
        'Relativity',
        'What does the equation E = mc² express?',
        ['Electric potential equals mass times charge squared', 'Energy and mass are equivalent', 'Entropy equals momentum times speed', 'Energy is always constant in a circuit'],
        1,
        'The equation E = mc² expresses mass-energy equivalence.',
        seconds,
      ),
      this.mcq(
        'Relativity',
        'What principle says the effects of gravity and acceleration can be locally indistinguishable?',
        ['Uncertainty principle', 'Conservation principle', 'Equivalence principle', 'Superposition principle'],
        2,
        'The equivalence principle states that locally, the effects of gravity and acceleration can be indistinguishable.',
        seconds,
      ),
    ];

    return bank.slice(0, count);
  }

  private mcq(
    topicMatchNote: string,
    prompt: string,
    options: string[],
    correctIndex: number,
    explanation: string,
    recommendedTimeSeconds: number,
  ): GeneratedQuestion {
    return {
      prompt,
      options,
      correctIndex,
      correctAnswerText: options[correctIndex],
      explanation,
      recommendedTimeSeconds,
      topicMatchNote,
    };
  }
}
