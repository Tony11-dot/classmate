import { PracticeService } from '../practice.service';

describe('PracticeService fallback contract', () => {
  const badEngine = {
    generate: jest.fn(async () => {
      return [
        {
          prompt: 'Bad Q',
          options: ['A', 'A', 'B'], // broken
          correctIndex: 5, // invalid
          explanation: '',
        },
      ];
    }),
  };

  const service = new PracticeService(badEngine as any);

  it('repairs invalid fallback output into safe contract', async () => {
    const res = await service.generate({
      subject: 'Physics',
      topic: 'Energy',
      difficulty: 'medium',
      mode: 'practice',
      count: 1,
    });

    const q: any = res.questions[0];

    expect(q.options).toHaveLength(4);
    expect(new Set(q.options).size).toBe(4);
    expect(q.correctIndex).toBeGreaterThanOrEqual(0);
    expect(q.correctIndex).toBeLessThan(4);
    expect(typeof q.explanation).toBe('string');
    expect(q.explanation.length).toBeGreaterThan(0);
  });
});
