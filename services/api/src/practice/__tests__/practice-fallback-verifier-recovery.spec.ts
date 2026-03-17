import { PracticeService } from '../practice.service';

describe('PracticeService verifier recovery fallback', () => {
  const engineRegistry = {
    generate: jest.fn(async () => null),
  };

  class TestPracticeService extends PracticeService {
    private verifierCalls = 0;

    async callResponsesJson(args: any): Promise<any> {
      if (args.schemaName === 'practice_questions') {
        return {
          questions: [
            {
              prompt: 'What is the degree of 4x^5 - 3x + 1?',
              options: ['2', '3', '4', '5'],
              correctIndex: 3,
              correctAnswerText: '5',
              explanation:
                'The degree of a polynomial is the highest exponent with a nonzero coefficient, so the degree is 5.',
              recommendedTimeSeconds: 75,
              topicMatchNote: 'Polynomials',
            },
            {
              prompt: 'What is the remainder when x^2 + 3x + 2 is divided by x + 1?',
              options: ['0', '1', '2', '-1'],
              correctIndex: 0,
              correctAnswerText: '0',
              explanation:
                'By the Remainder Theorem, substitute x = -1 to get 1 - 3 + 2 = 0, so the remainder is 0.',
              recommendedTimeSeconds: 75,
              topicMatchNote: 'Polynomials',
            },
            {
              prompt: 'What is the sum of the coefficients of x^2 + 4x + 7?',
              options: ['7', '9', '11', '12'],
              correctIndex: 3,
              correctAnswerText: '12',
              explanation:
                'The sum of coefficients is found by evaluating the polynomial at x = 1, giving 1 + 4 + 7 = 12.',
              recommendedTimeSeconds: 75,
              topicMatchNote: 'Polynomials',
            },
          ],
        };
      }

      if (args.schemaName === 'practice_verifier') {
        this.verifierCalls += 1;
        return {
          decisions: [
            { index: 0, verdict: 'reject', reason: 'too_strict' },
            { index: 1, verdict: 'reject', reason: 'too_strict' },
            { index: 2, verdict: 'reject', reason: 'too_strict' },
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

  it('returns locally valid questions when verifier rejects an otherwise valid set', async () => {
    const res = await service.generate({
      subject: 'Math',
      topic: 'Polynomials',
      difficulty: 'hard',
      mode: 'examPrep',
      count: 3,
      timePreferenceSeconds: 75,
      useAiTiming: true,
      maxLives: 2,
    });

    expect(res.questions).toHaveLength(3);

    for (const q of res.questions as any[]) {
      expect(q.topicLabel).toBe('Polynomials');
      expect(q.mode).toBe('examPrep');
      expect(q.difficulty).toBe('hard');
      expect(q.options).toHaveLength(4);
      expect(new Set(q.options).size).toBe(4);
      expect(q.correctIndex).toBeGreaterThanOrEqual(0);
      expect(q.correctIndex).toBeLessThan(4);
      expect(typeof q.prompt).toBe('string');
      expect(q.prompt.length).toBeGreaterThan(0);
      expect(typeof q.explanation).toBe('string');
      expect(q.explanation.length).toBeGreaterThan(0);
      expect(q.recommendedTimeSeconds).toBe(75);
    }
  });
});
