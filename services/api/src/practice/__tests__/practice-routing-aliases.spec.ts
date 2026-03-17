import { PracticeService } from '../practice.service';

describe('PracticeService request alias normalization', () => {
  const engineRegistry = {
    generate: jest.fn(async (req) => {
      const topic = String(req.topicLabel ?? '');
      if (req.subject === 'Physics' && topic === 'Energy') {
        return Array.from({ length: req.questionCount }, (_, i) => ({
          prompt: `Energy question ${i + 1}`,
          options: ['36 J', '72 J', '12 J', '40 J'],
          correctIndex: 0,
          explanation: 'Energy explanation',
          recommendedTimeSeconds: 40,
        }));
      }

      if (req.subject === 'Math' && topic === 'Linear equations') {
        return Array.from({ length: req.questionCount }, (_, i) => ({
          prompt: `Linear question ${i + 1}`,
          options: ['-5', '-1', '5', '-3'],
          correctIndex: 0,
          explanation: 'Linear explanation',
          recommendedTimeSeconds: 45,
        }));
      }

      return null;
    }),
  };

  const service = new PracticeService(engineRegistry as any);

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('maps legacy topic/count aliases for physics', async () => {
    const res = await service.generate({
      subject: 'Physics',
      topic: 'Energy',
      difficulty: 'medium',
      mode: 'practice',
      count: 5,
    });

    expect(engineRegistry.generate).toHaveBeenCalledWith(
      expect.objectContaining({
        subject: 'Physics',
        topicLabel: 'Energy',
        topicPathText: 'Energy',
        questionCount: 5,
      }),
    );

    expect(res.questions).toHaveLength(5);
    expect(res.questions.every((q: any) => q.topicLabel === 'Energy')).toBe(true);
  });

  it('maps legacy topic/count aliases for math', async () => {
    const res = await service.generate({
      subject: 'Math',
      topic: 'Linear equations',
      difficulty: 'medium',
      mode: 'practice',
      count: 3,
    });

    expect(engineRegistry.generate).toHaveBeenCalledWith(
      expect.objectContaining({
        subject: 'Math',
        topicLabel: 'Linear equations',
        topicPathText: 'Linear equations',
        questionCount: 3,
      }),
    );

    expect(res.questions).toHaveLength(3);
    expect(res.questions.every((q: any) => q.topicLabel === 'Linear equations')).toBe(true);
  });
});
