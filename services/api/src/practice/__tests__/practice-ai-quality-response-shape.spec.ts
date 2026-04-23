import { InternalServerErrorException } from '@nestjs/common';
import { PracticeService } from '../practice.service';
import { normalizeQuestionSetShape } from '../practice.safety';

describe('PracticeService fallback output style/order contract', () => {
  const engineRegistry = {
    generate: jest.fn(async () => null),
  };

  class TestPracticeService extends PracticeService {
    async callResponsesJson(args: any): Promise<any> {
      if (args.schemaName === 'practice_questions') {
        return {
          questions: [
            {
              prompt: 'Question one',
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 2,
              correctAnswerText: 'C',
              explanation: 'Explanation one is long enough to pass the validator cleanly.',
              recommendedTimeSeconds: 31,
              topicMatchNote: 'Optics',
            },
            {
              prompt: 'Question two',
              options: ['W', 'X', 'Y', 'Z'],
              correctIndex: 0,
              correctAnswerText: 'W',
              explanation: 'Explanation two is long enough to pass the validator cleanly.',
              recommendedTimeSeconds: 47,
              topicMatchNote: 'Optics',
            },
          ],
        };
      }

      if (args.schemaName === 'practice_verifier') {
        return {
          decisions: [
            { index: 0, verdict: 'accept', reason: 'ok' },
            { index: 1, verdict: 'accept', reason: 'ok' },
          ],
        };
      }

      if (args.schemaName === 'practice_self_verify') {
        return {
          audits: [
            {
              index: 0,
              final_answer: 'C',
              steps: 'Explanation one is long enough to pass the validator cleanly.',
              confidence: 0.96,
              type: 'text',
              validation_passed: true,
              reason: 'ok',
            },
            {
              index: 1,
              final_answer: 'W',
              steps: 'Explanation two is long enough to pass the validator cleanly.',
              confidence: 0.96,
              type: 'text',
              validation_passed: true,
              reason: 'ok',
            },
          ],
        };
      }

      return {};
    }
  }

  const service = new TestPracticeService(engineRegistry as any);

  beforeEach(() => {
    process.env.OPENAI_API_KEY = 'test-key';
  });

  it('returns stable response shape for fallback questions', async () => {
    const res = await service.generate({
      subject: 'Physics',
      topic: 'Optics',
      difficulty: 'medium',
      mode: 'practice',
      count: 2,
    });

    expect(res.questions).toHaveLength(2);

    for (const q of res.questions as any[]) {
      expect(typeof q.id).toBe('string');
      expect(q.subject).toBe('Physics');
      expect(q.topicLabel).toBe('Optics');
      expect(q.mode).toBe('practice');
      expect(q.difficulty).toBe('medium');
      expect(typeof q.prompt).toBe('string');
      expect(Array.isArray(q.options)).toBe(true);
      expect(q.options).toHaveLength(4);
      expect(new Set(q.options).size).toBe(4);
      expect(Number.isInteger(q.correctIndex)).toBe(true);
      expect(q.correctIndex).toBeGreaterThanOrEqual(0);
      expect(q.correctIndex).toBeLessThan(4);
      expect(typeof q.explanation).toBe('string');
      expect(q.explanation.length).toBeGreaterThan(0);
      expect(typeof q.recommendedTimeSeconds).toBe('number');
    }
  });

  it('normalizes raw math and inline code tails into renderable output', () => {
    const normalized = normalizeQuestionSetShape([
      {
        prompt: 'Find the limit. \\lim_{x \\to 2} x^2',
        options: ['4', '2', '8', '0'],
        explanation:
          'What does this print? if (score >= 90) Console.WriteLine("A"); else Console.WriteLine("B");',
      },
      {
        prompt: 'Compute \\frac{1}{2} + \\frac{1}{2}.',
        options: ['1', '2', '0', '1/2'],
        explanation: 'Use common denominators and add the numerators.',
      },
      {
        prompt: 'Evaluate sin(75°) when x_1 = y^n and sqrt(n) appears in ∫_0^1 x^2 dx.',
        options: ['A', 'B', 'C', 'D'],
        explanation: 'What does this snippet do: if score >= 90: print("A") else: print("B")',
      },
      {
        prompt: 'Compute Σ_{k=1}^n k and compare it with Π_{i=1}^n i.',
        options: ['A', 'B', 'C', 'D'],
        explanation: 'Matrix form: \\begin{bmatrix}1 & 2\\3 & 4\\end{bmatrix} and piecewise form \\begin{cases}x^2 & x > 0 \\ 0 & x \\le 0\\end{cases}.',
      },
      {
        prompt: 'Evaluate sin^2(x) + cos^2(x) and lim x->0 sin(x)/x when f\'(x) appears with sqrt(x^2 + 1).',
        options: ['A', 'B', 'C', 'D'],
        explanation: 'What does this print? if (x > 0) console.log(x) else console.log(0)',
      },
    ]);

    expect(String(normalized[0].prompt)).toContain('$\\lim_{x \\to 2} x^2$');
    expect(String(normalized[0].explanation)).toContain('```csharp');
    expect(String(normalized[1].prompt)).toContain('$\\frac{1}{2}$');
    expect(String(normalized[2].prompt)).toContain('$sin(75°)$');
    expect(String(normalized[2].prompt)).toContain('$x_1$');
    expect(String(normalized[2].prompt)).toContain('$y^n$');
    expect(String(normalized[2].prompt)).toContain('$sqrt(n)$');
    expect(String(normalized[2].prompt)).toContain('$∫_0^1 x^2 dx$');
    expect(String(normalized[2].explanation)).toContain('```python');
    expect(String(normalized[3].prompt)).toContain('$Σ_{k=1}^n');
    expect(String(normalized[3].prompt)).toContain('Π_{i=1}^n');
    expect(String(normalized[3].explanation)).toContain('$$\\begin{bmatrix}1 & 2\\3 & 4\\end{bmatrix}$$');
    expect(String(normalized[3].explanation)).toContain('$$\\begin{cases}x^2 & x > 0 \\ 0 & x \\le 0\\end{cases}$$');
    expect(String(normalized[4].prompt)).toContain('$sin^2(x)$');
    expect(String(normalized[4].prompt)).toContain('$cos^2(x)$');
    expect(String(normalized[4].prompt)).toContain('$lim x->0 sin(x)/x$');
    expect(String(normalized[4].prompt)).toContain('$f\'(x)$');
    expect(String(normalized[4].prompt)).toContain('$sqrt(x^2 + 1)$');
    expect(String(normalized[4].explanation)).toContain('```javascript');
    expect(String(normalized[4].explanation)).not.toContain('console.$log');
  });

  it('does not turn plain Big O text into fake LaTeX', () => {
    const normalized = normalizeQuestionSetShape([
      {
        prompt: 'Which statement best explains Big O notation?',
        options: ['A', 'B', 'C', 'D'],
        explanation:
          'Big O notation describes how runtime or space usage grows as input size increases.',
      },
    ]);

    expect(String(normalized[0].prompt)).toContain('Big O notation');
    expect(String(normalized[0].prompt)).not.toContain('\\Big');
    expect(String(normalized[0].explanation)).toContain('Big O notation');
    expect(String(normalized[0].explanation)).not.toContain('\\Big');
  });

  it('rejects fallback items that are obviously too easy for a hard request', async () => {
    class HardMismatchService extends PracticeService {
      async callResponsesJson(args: any): Promise<any> {
        if (args.schemaName === 'practice_questions') {
          return {
            questions: [
              {
                prompt: 'What is 2 + 2?',
                options: ['1', '2', '3', '4'],
                correctIndex: 3,
                correctAnswerText: '4',
                explanation: 'Adding 2 and 2 gives 4.',
                recommendedTimeSeconds: 20,
                topicMatchNote: 'Functions',
              },
            ],
          };
        }

        if (args.schemaName === 'practice_verifier') {
          return {
            decisions: [{ index: 0, verdict: 'accept', reason: 'ok' }],
          };
        }

        return {};
      }
    }

    const mismatchService = new HardMismatchService(engineRegistry as any);

    await expect(
      mismatchService.generate({
        subject: 'Math',
        topic: 'Functions',
        difficulty: 'hard',
        mode: 'practice',
        count: 1,
      }),
    ).rejects.toBeInstanceOf(InternalServerErrorException);
  });

  it('rejects fallback items that are too slow for flashcards', async () => {
    class FlashcardMismatchService extends PracticeService {
      async callResponsesJson(args: any): Promise<any> {
        if (args.schemaName === 'practice_questions') {
          return {
            questions: [
              {
                prompt:
                  'Read the full paragraph and determine which statement best summarizes the relationship between the input, the formula, and the output in the described function machine.',
                options: ['A', 'B', 'C', 'D'],
                correctIndex: 0,
                correctAnswerText: 'A',
                explanation:
                  'This explanation is intentionally long enough to pass the validator cleanly while still representing a slow, heavy item.',
                recommendedTimeSeconds: 60,
                topicMatchNote: 'Functions',
              },
            ],
          };
        }

        if (args.schemaName === 'practice_verifier') {
          return {
            decisions: [{ index: 0, verdict: 'accept', reason: 'ok' }],
          };
        }

        return {};
      }
    }

    const mismatchService = new FlashcardMismatchService(engineRegistry as any);

    await expect(
      mismatchService.generate({
        subject: 'Math',
        topic: 'Functions',
        difficulty: 'medium',
        mode: 'flashcards',
        count: 1,
      }),
    ).rejects.toBeInstanceOf(InternalServerErrorException);
  });

  it('rejects obviously advanced proof-style content for an easy request', async () => {
    class EasyMismatchService extends PracticeService {
      async callResponsesJson(args: any): Promise<any> {
        if (args.schemaName === 'practice_questions') {
          return {
            questions: [
              {
                prompt:
                  'Prove the Stone-Weierstrass theorem for polynomial approximation on continuous functions over [0, 1].',
                options: ['A', 'B', 'C', 'D'],
                correctIndex: 0,
                correctAnswerText: 'A',
                explanation:
                  'A rigorous proof requires theorem-level approximation arguments over continuous function spaces, so this is not an easy classroom item.',
                recommendedTimeSeconds: 20,
                topicMatchNote: 'Functions',
              },
            ],
          };
        }

        if (args.schemaName === 'practice_verifier') {
          return {
            decisions: [{ index: 0, verdict: 'accept', reason: 'ok' }],
          };
        }

        return {};
      }
    }

    const mismatchService = new EasyMismatchService(engineRegistry as any);

    await expect(
      mismatchService.generate({
        subject: 'Math',
        topic: 'Functions',
        difficulty: 'easy',
        mode: 'practice',
        count: 1,
      }),
    ).rejects.toBeInstanceOf(InternalServerErrorException);
  });

  it('rejects trivial hard items even when the time field is inflated', async () => {
    class HardTimingSpoofService extends PracticeService {
      async callResponsesJson(args: any): Promise<any> {
        if (args.schemaName === 'practice_questions') {
          return {
            questions: [
              {
                prompt: 'What is 2 + 2?',
                options: ['1', '2', '3', '4'],
                correctIndex: 3,
                correctAnswerText: '4',
                explanation:
                  'Add the two numbers directly: 2 + 2 = 4. The padded time field should not make this count as a hard item.',
                recommendedTimeSeconds: 80,
                topicMatchNote: 'Functions',
              },
            ],
          };
        }

        if (args.schemaName === 'practice_verifier') {
          return {
            decisions: [{ index: 0, verdict: 'accept', reason: 'ok' }],
          };
        }

        return {};
      }
    }

    const mismatchService = new HardTimingSpoofService(engineRegistry as any);

    await expect(
      mismatchService.generate({
        subject: 'Math',
        topic: 'Functions',
        difficulty: 'hard',
        mode: 'practice',
        count: 1,
      }),
    ).rejects.toBeInstanceOf(InternalServerErrorException);
  });

  it('rejects trivial olympiad items even when the time field is inflated', async () => {
    class OlympiadTimingSpoofService extends PracticeService {
      async callResponsesJson(args: any): Promise<any> {
        if (args.schemaName === 'practice_questions') {
          return {
            questions: [
              {
                prompt: 'Solve for x: x + 2 = 5.',
                options: ['1', '2', '3', '5'],
                correctIndex: 2,
                correctAnswerText: '3',
                explanation:
                  'Subtract 2 from both sides to get x = 3. This is a one-step equation and should not count as olympiad difficulty.',
                recommendedTimeSeconds: 95,
                topicMatchNote: 'Functions',
              },
            ],
          };
        }

        if (args.schemaName === 'practice_verifier') {
          return {
            decisions: [{ index: 0, verdict: 'accept', reason: 'ok' }],
          };
        }

        return {};
      }
    }

    const mismatchService = new OlympiadTimingSpoofService(engineRegistry as any);

    await expect(
      mismatchService.generate({
        subject: 'Math',
        topic: 'Functions',
        difficulty: 'olympiad',
        mode: 'practice',
        count: 1,
      }),
    ).rejects.toBeInstanceOf(InternalServerErrorException);
  });

  it('rejects items when self-verification confidence is below threshold', async () => {
    class LowConfidenceService extends PracticeService {
      async callResponsesJson(args: any): Promise<any> {
        if (args.schemaName === 'practice_questions') {
          return {
            questions: [
              {
                prompt: 'Fallback prompt about Functions',
                options: ['A', 'B', 'C', 'D'],
                correctIndex: 1,
                correctAnswerText: 'B',
                explanation: 'Fallback explanation about Functions that is long enough to pass validation cleanly.',
                recommendedTimeSeconds: 45,
                topicMatchNote: 'Functions',
              },
            ],
          };
        }

        if (args.schemaName === 'practice_self_verify') {
          return {
            audits: [
              {
                index: 0,
                final_answer: 'B',
                steps: 'Fallback explanation about Functions that is long enough to pass validation cleanly.',
                confidence: 0.41,
                type: 'text',
                validation_passed: true,
                reason: 'uncertain',
              },
            ],
          };
        }

        if (args.schemaName === 'practice_verifier') {
          return {
            decisions: [{ index: 0, verdict: 'accept', reason: 'ok' }],
          };
        }

        return {};
      }
    }

    const mismatchService = new LowConfidenceService(engineRegistry as any);

    await expect(
      mismatchService.generate({
        subject: 'Math',
        topic: 'Functions',
        difficulty: 'hard',
        mode: 'practice',
        count: 1,
      }),
    ).rejects.toBeInstanceOf(InternalServerErrorException);
  });

  it('rejects items when self-verification final answer disagrees with the keyed option', async () => {
    class FinalAnswerMismatchService extends PracticeService {
      async callResponsesJson(args: any): Promise<any> {
        if (args.schemaName === 'practice_questions') {
          return {
            questions: [
              {
                prompt: 'Fallback prompt about Functions',
                options: ['A', 'B', 'C', 'D'],
                correctIndex: 1,
                correctAnswerText: 'B',
                explanation: 'Fallback explanation about Functions that is long enough to pass validation cleanly.',
                recommendedTimeSeconds: 45,
                topicMatchNote: 'Functions',
              },
            ],
          };
        }

        if (args.schemaName === 'practice_self_verify') {
          return {
            audits: [
              {
                index: 0,
                final_answer: 'D',
                steps: 'The recomputed answer points to D, so the keyed answer is inconsistent.',
                confidence: 0.97,
                type: 'text',
                validation_passed: true,
                reason: 'mismatch',
              },
            ],
          };
        }

        if (args.schemaName === 'practice_verifier') {
          return {
            decisions: [{ index: 0, verdict: 'accept', reason: 'ok' }],
          };
        }

        return {};
      }
    }

    const mismatchService = new FinalAnswerMismatchService(engineRegistry as any);

    await expect(
      mismatchService.generate({
        subject: 'Math',
        topic: 'Functions',
        difficulty: 'medium',
        mode: 'practice',
        count: 1,
      }),
    ).rejects.toBeInstanceOf(InternalServerErrorException);
  });
});
