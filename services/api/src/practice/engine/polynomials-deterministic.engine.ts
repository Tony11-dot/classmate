import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type { GeneratedQuestion, PracticeEngineRequest } from './practice-engine.types';

@Injectable()
export class PolynomialsDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = String(req.subject ?? '').toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase().trim();
    return s === 'math' && (t.includes('polynomials') || t.includes('polynomial'));
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
            : (req.mode === 'examPrep' ? 75 : 45),
        ),
      ),
    );

    const bank: GeneratedQuestion[] = [
      this.mcq(
        'Polynomials',
        'What is the degree of the polynomial 7x^5 - 3x^2 + 4?',
        ['2', '4', '5', '7'],
        2,
        'The degree is the highest exponent of x, which is 5.',
        seconds,
      ),
      this.mcq(
        'Polynomials',
        'What is the coefficient of x^3 in 4x^4 - 6x^3 + x - 2?',
        ['4', '-6', '1', '-2'],
        1,
        'The coefficient of x^3 is the number multiplying x^3, which is -6.',
        seconds,
      ),
      this.mcq(
        'Polynomials',
        'What is P(2) if P(x) = x^2 - 3x + 4?',
        ['2', '4', '6', '8'],
        1,
        'Substitute x = 2: 2^2 - 3(2) + 4 = 4 - 6 + 4 = 2. Wait carefully: 4 - 6 + 4 = 2.',
        seconds,
      ),
      this.mcq(
        'Polynomials',
        'What is the sum (2x^2 + 3x - 1) + (x^2 - x + 4)?',
        ['3x^2 + 2x + 3', '3x^2 + 4x + 3', 'x^2 + 2x + 3', '3x^2 + 2x - 3'],
        0,
        'Add like terms: 2x^2 + x^2 = 3x^2, 3x - x = 2x, and -1 + 4 = 3.',
        seconds,
      ),
      this.mcq(
        'Polynomials',
        'What is the product x(x^2 + 4x - 5)?',
        ['x^3 + 4x^2 - 5x', 'x^3 + 4x - 5', 'x^2 + 4x^2 - 5x', 'x^3 - 4x^2 - 5x'],
        0,
        'Distribute x across each term: x·x^2 = x^3, x·4x = 4x^2, x·(-5) = -5x.',
        seconds,
      ),
      this.mcq(
        'Polynomials',
        'What is the remainder when f(x) = x^2 + 3x + 1 is divided by (x - 1)?',
        ['1', '3', '5', '7'],
        2,
        'By the Remainder Theorem, the remainder is f(1) = 1 + 3 + 1 = 5.',
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
