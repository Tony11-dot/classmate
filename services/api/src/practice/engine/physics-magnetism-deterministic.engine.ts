import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type { GeneratedQuestion, PracticeEngineRequest } from './practice-engine.types';
import { clampTime } from './practice-engine.utils';

@Injectable()
export class PhysicsMagnetismDeterministicEngine implements PracticeEngine {
  readonly supportedModes = ['practice', 'flashcards', 'speedRound', 'examPrep', 'conceptBuilder', 'adaptive'] as const;

  supports(req: PracticeEngineRequest): boolean {
    const s = String(req.subject ?? '').toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase().trim();
    return s === 'physics' && (t.includes('magnetism') || t.includes('magnet') || t.includes('magnetic'));
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]> {
    const count = Math.max(1, Math.min(20, Number(req.questionCount ?? 5)));
    const seconds = clampTime(
      req.timePreferenceSeconds,
      req.difficulty === 'easy' ? 20 : 30,
    );

    const bank: GeneratedQuestion[] = [
      this.mcq(
        'Magnetism',
        'Which of the following materials is commonly attracted to a magnet?',
        ['Plastic', 'Iron', 'Glass', 'Wood'],
        1,
        'Iron is a ferromagnetic material and is commonly attracted to magnets.',
        seconds,
      ),
      this.mcq(
        'Magnetism',
        'What are the two ends of a bar magnet called?',
        ['Positive and negative poles', 'North and south poles', 'Anode and cathode', 'Left and right poles'],
        1,
        'A bar magnet has two poles: north and south.',
        seconds,
      ),
      this.mcq(
        'Magnetism',
        'What happens if you cut a bar magnet into two pieces?',
        ['One piece becomes only north', 'One piece becomes only south', 'Each piece becomes a smaller magnet with two poles', 'Magnetism disappears completely'],
        2,
        'Each piece becomes a smaller magnet that still has both a north pole and a south pole.',
        seconds,
      ),
      this.mcq(
        'Magnetism',
        'Where is the magnetic force strongest on a bar magnet?',
        ['At the center only', 'At the poles', 'Equally everywhere', 'Outside the magnetic field'],
        1,
        'The magnetic force is strongest near the poles of the magnet.',
        seconds,
      ),
      this.mcq(
        'Magnetism',
        'Which poles attract each other?',
        ['North and north', 'South and south', 'Like poles only', 'North and south'],
        3,
        'Unlike poles attract, so north and south attract each other.',
        seconds,
      ),
      this.mcq(
        'Magnetism',
        'What is the region around a magnet where magnetic effects can be detected called?',
        ['Electric circuit', 'Magnetic field', 'Current loop', 'Voltage zone'],
        1,
        'The region around a magnet where magnetic forces can act is called the magnetic field.',
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
