import { PracticeService } from '../practice.service';

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
});
