import { PracticeService } from '../practice.service';

describe('PracticeService settings fidelity', () => {
  const engineRegistry = {
    generate: jest.fn(async (req) =>
      Array.from({ length: req.questionCount }, (_, i) => ({
        prompt: `Question ${i + 1} about ${req.topicLabel} with enough detail to remain classroom-valid.`,
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 2,
        correctAnswerText: 'C',
        explanation: `Explanation ${i + 1} for ${req.topicLabel} with a complete, classroom-valid justification.`,
        recommendedTimeSeconds: req.timePreferenceSeconds ?? 30,
        topicMatchNote: req.topicLabel,
      })),
    ),
  };

  const service = new PracticeService(engineRegistry as any);

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('forwards all user-controlled settings into deterministic generation request', async () => {
    const res = await service.generate({
      subject: 'Physics',
      topic: 'Energy',
      difficulty: 'hard',
      mode: 'examPrep',
      count: 4,
      timePreferenceSeconds: 77,
      maxLives: 2,
      useAiTiming: false,
      strictPromptSummary: 'Topic: kinetic energy only',
      topicPath: ['Physics', 'Energy'],
      topicPathText: 'Physics > Energy',
    });

    expect(engineRegistry.generate).toHaveBeenCalledWith(
      expect.objectContaining({
        subject: 'Physics',
        topicLabel: 'Energy',
        topicPath: ['Physics', 'Energy'],
        topicPathText: 'Physics > Energy',
        strictPromptSummary: 'kinetic energy only',
        questionCount: 4,
        difficulty: 'hard',
        mode: 'examPrep',
        timePreferenceSeconds: 77,
        maxLives: 2,
        useAiTiming: false,
      }),
    );

    expect(res.questions).toHaveLength(4);
    expect(res.questions.every((q: any) => q.subject === 'Physics')).toBe(true);
    expect(res.questions.every((q: any) => q.topicLabel === 'Energy')).toBe(true);
    expect(res.questions.every((q: any) => q.mode === 'examPrep')).toBe(true);
    expect(res.questions.every((q: any) => q.difficulty === 'hard')).toBe(true);
    expect(res.questions.every((q: any) => q.recommendedTimeSeconds === 77)).toBe(true);
  });

  it('prefers explicit topicLabel over legacy topic for routing', async () => {
    await service.generate({
      subject: 'Math',
      topic: 'Functions',
      topicLabel: 'Linear equations',
      questionCount: 3,
    });

    expect(engineRegistry.generate).toHaveBeenCalledWith(
      expect.objectContaining({
        subject: 'Math',
        topicLabel: 'Linear equations',
        topicPathText: 'Linear equations',
        questionCount: 3,
      }),
    );
  });

  it('clamps invalid count values to safe bounds', async () => {
    await service.generate({
      subject: 'Math',
      topic: 'Linear equations',
      count: 999,
    });

    expect(engineRegistry.generate).toHaveBeenCalledWith(
      expect.objectContaining({
        questionCount: 20,
      }),
    );
  });

  it('routes language basics custom topics through deterministic generation', async () => {
    const res = await service.generate({
      subject: 'Computer Science',
      topicLabel: 'c# basics',
      difficulty: 'olympiad',
      mode: 'practice',
      questionCount: 10,
    });

    expect(engineRegistry.generate).toHaveBeenCalledWith(
      expect.objectContaining({
        subject: 'Computer Science',
        topicLabel: 'c# basics',
        topicPathText: 'c# basics',
        difficulty: 'olympiad',
        questionCount: 10,
      }),
    );

    expect(res.questions).toHaveLength(10);
    expect(
      res.questions.every((q: any) => q.topicLabel === 'c# basics'),
    ).toBe(true);
  });
});
