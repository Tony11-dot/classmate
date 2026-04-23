import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type { GeneratedQuestion, PracticeEngineRequest } from './practice-engine.types';
import { clampTime } from './practice-engine.utils';

@Injectable()
export class SetTheoryDeterministicEngine implements PracticeEngine {
  readonly supportedModes = ['practice', 'flashcards', 'speedRound', 'examPrep', 'conceptBuilder', 'adaptive'] as const;

  supports(req: PracticeEngineRequest): boolean {
    const s = String(req.subject ?? '').toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase().trim();
    return s === 'math' && (t.includes('set theory') || t.includes('sets') || t.includes('set '));
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]> {
    const count = Math.max(1, Math.min(20, Number(req.questionCount ?? 5)));
    const seconds = clampTime(req.timePreferenceSeconds, 18);

    const bank: GeneratedQuestion[] = [
      this.mcq(
        'Set theory',
        'If A = {1, 2, 3} and B = {3, 4, 5}, what is A ∩ B?',
        ['{1, 2, 3, 4, 5}', '{3}', '{1, 2}', '{4, 5}'],
        1,
        'The intersection contains elements common to both sets. Only 3 is common.',
        seconds,
      ),
      this.mcq(
        'Set theory',
        'If A = {1, 2, 3} and B = {3, 4, 5}, what is A ∪ B?',
        ['{3}', '{1, 2, 4, 5}', '{1, 2, 3, 4, 5}', '{1, 2, 3}'],
        2,
        'The union contains all distinct elements that are in A or B.',
        seconds,
      ),
      this.mcq(
        'Set theory',
        'If A = {1, 2, 3, 4} and B = {3, 4}, what is A \\ B?',
        ['{1, 2}', '{3, 4}', '{1, 2, 3, 4}', '{}'],
        0,
        'A \\ B means elements in A that are not in B, so the result is {1, 2}.',
        seconds,
      ),
      this.mcq(
        'Set theory',
        'If U = {1, 2, 3, 4, 5} and A = {2, 4}, what is Aᶜ?',
        ['{2, 4}', '{1, 3, 5}', '{1, 2, 3}', '{4, 5}'],
        1,
        'The complement of A in U is every element in U that is not in A.',
        seconds,
      ),
      this.mcq(
        'Set theory',
        'How many subsets does a set with 2 elements have?',
        ['2', '3', '4', '8'],
        2,
        'A set with n elements has 2^n subsets. For n = 2, that is 4.',
        seconds,
      ),
      this.mcq(
        'Set theory',
        'Which statement is always true?',
        ['A ∩ B contains elements in A or B', 'A ∪ B contains elements in both A and B only', 'A ∩ B contains elements common to both sets', 'A \\ B contains all elements of B'],
        2,
        'The intersection of two sets contains exactly the elements common to both sets.',
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
