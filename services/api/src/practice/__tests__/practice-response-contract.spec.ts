import { PracticeService } from '../practice.service';

describe('PracticeService response contract', () => {
  const engineRegistry = {
    generate: jest.fn(async () => [
      {
        prompt: 'P1',
        options: ['A1', 'B1', 'C1', 'D1'],
        correctIndex: 1,
        explanation: 'E1',
        recommendedTimeSeconds: 41,
      },
      {
        prompt: 'P2',
        options: ['A2', 'B2', 'C2', 'D2'],
        correctIndex: 2,
        explanation: 'E2',
        recommendedTimeSeconds: 42,
      },
      {
        prompt: 'P3',
        options: ['A3', 'B3', 'C3', 'D3'],
        correctIndex: 3,
        explanation: 'E3',
        recommendedTimeSeconds: 43,
      },
    ]),
  };

  const service = new PracticeService(engineRegistry as any);

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('returns stable question objects with required fields and valid option contract', async () => {
    const res = await service.generate({
      subject: 'Math',
      topic: 'Linear equations',
      difficulty: 'medium',
      mode: 'practice',
      count: 3,
    });

    expect(res.questions).toHaveLength(3);

    for (const q of res.questions as any[]) {
      expect(typeof q.id).toBe('string');
      expect(q.id.length).toBeGreaterThan(10);
      expect(q.subject).toBe('Math');
      expect(q.topicLabel).toBe('Linear equations');
      expect(q.mode).toBe('practice');
      expect(q.difficulty).toBe('medium');
      expect(typeof q.prompt).toBe('string');
      expect(typeof q.explanation).toBe('string');
      expect(Number.isInteger(q.correctIndex)).toBe(true);
      expect(q.correctIndex).toBeGreaterThanOrEqual(0);
      expect(q.correctIndex).toBeLessThan(4);
      expect(Array.isArray(q.options)).toBe(true);
      expect(q.options).toHaveLength(4);
      expect(new Set(q.options).size).toBe(4);
      expect(typeof q.options[q.correctIndex]).toBe('string');
      expect(Number.isInteger(q.recommendedTimeSeconds)).toBe(true);
      expect(q.recommendedTimeSeconds).toBeGreaterThan(0);
    }
  });
});
