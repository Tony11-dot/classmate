import { PracticeService } from '../../practice.service';

describe('PHASE 8 — routing pipeline fallback boundary', () => {
  const engineRegistry = {
    generate: jest.fn(async () => null),
  };

  const service = new PracticeService(engineRegistry as any);

  const aiQuestion = {
    prompt: 'Which statement is true about a vector space?',
    options: [
      'It is closed under addition and scalar multiplication',
      'It must contain exactly one vector',
      'It cannot include the zero vector',
      'Its scalars must always be integers',
    ],
    correctIndex: 0,
    correctAnswerText: 'It is closed under addition and scalar multiplication',
    explanation:
      'A vector space is defined by closure under vector addition and scalar multiplication, along with the other vector space axioms.',
    recommendedTimeSeconds: 45,
    topicMatchNote: 'vector spaces',
  };

  const originalApiKey = process.env.OPENAI_API_KEY;

  beforeEach(() => {
    jest.clearAllMocks();
    process.env.OPENAI_API_KEY = 'test-key';
  });

  afterAll(() => {
    process.env.OPENAI_API_KEY = originalApiKey;
  });

  it('uses verified AI fallback when symbolic generation is not ready', async () => {
    const requestSpy = jest
      .spyOn(service as any, 'requestQuestionSet')
      .mockResolvedValue([aiQuestion]);
    const verifySpy = jest
      .spyOn(service as any, 'verifyQuestionSet')
      .mockResolvedValue([aiQuestion]);

    const res = await service.generate({
      subject: 'Math',
      topicLabel: 'vector spaces',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 1,
    } as any);

    expect(requestSpy).toHaveBeenCalledTimes(1);
    expect(verifySpy).toHaveBeenCalledTimes(1);
    expect(res.questions).toHaveLength(1);
    expect(res.questions[0]).toMatchObject({
      subject: 'Math',
      topicLabel: 'vector spaces',
      mode: 'practice',
      difficulty: 'medium',
      prompt: aiQuestion.prompt,
      explanation: aiQuestion.explanation,
      recommendedTimeSeconds: aiQuestion.recommendedTimeSeconds,
    });
  });

  it('uses verified AI fallback when deterministic output fails mode fidelity validation', async () => {
    const deterministicEngineRegistry = {
      generate: jest.fn(async () => [
        {
          prompt:
            'Read the full paragraph and determine which statement best summarizes the relationship between the input, the formula, and the output in the scenario before choosing the most accurate description.',
          options: ['A relation', 'A rule', 'A pattern', 'An output'],
          correctIndex: 1,
          correctAnswerText: 'A rule',
          explanation:
            'This explanation is intentionally long enough to remain valid structurally while representing a slow, heavy deterministic flashcard that should now be rejected before routing returns it.',
          recommendedTimeSeconds: 60,
          topicMatchNote: 'Functions',
        },
      ]),
    };

    const deterministicFallbackService = new PracticeService(
      deterministicEngineRegistry as any,
    );

    const fallbackQuestion = {
      prompt: 'What does a function assign to each allowed input?',
      options: ['Exactly one output', 'Two unrelated outputs', 'A random graph', 'Only negative values'],
      correctIndex: 0,
      correctAnswerText: 'Exactly one output',
      explanation:
        'A function assigns exactly one output to each input in its domain.',
      recommendedTimeSeconds: 20,
      topicMatchNote: 'Functions',
    };

    const requestSpy = jest
      .spyOn(deterministicFallbackService as any, 'requestQuestionSet')
      .mockResolvedValue([fallbackQuestion]);
    const verifySpy = jest
      .spyOn(deterministicFallbackService as any, 'verifyQuestionSet')
      .mockResolvedValue([fallbackQuestion]);

    const res = await deterministicFallbackService.generate({
      subject: 'Math',
      topicLabel: 'Functions',
      mode: 'flashcards',
      difficulty: 'medium',
      questionCount: 1,
    } as any);

    expect(deterministicEngineRegistry.generate).toHaveBeenCalledTimes(1);
    expect(requestSpy).toHaveBeenCalledTimes(1);
    expect(verifySpy).toHaveBeenCalledTimes(1);
    expect(res.questions).toHaveLength(1);
    expect(res.questions[0]).toMatchObject({
      subject: 'Math',
      topicLabel: 'Functions',
      mode: 'flashcards',
      difficulty: 'medium',
      recommendedTimeSeconds: fallbackQuestion.recommendedTimeSeconds,
    });
    expect(res.questions[0].prompt).toContain('function assign');
    expect(res.questions[0].explanation).toContain('exactly one output');
  });

  it('uses verified AI fallback when conceptual generation is not ready', async () => {
    const conceptualService = {
      resolve: jest.fn(() => ({
        ok: true,
        ready: false,
        subject: 'Computer Science',
        topic: 'Big O',
        confidence: 0.4,
        needsClarification: false,
        gaps: ['no_conceptual_seed_path_yet'],
        seeds: [],
        intake: {
          rawSubject: 'Computer Science',
          rawTopic: 'Big O',
          normalizedSubject: 'Computer Science',
          normalizedTopic: 'Big O',
          effectiveSubject: 'Computer Science',
          effectiveTopic: 'Big O',
          topicType: 'conceptual',
          breadth: 'medium',
          quizzability: 'medium',
          confidence: 0.7,
          generationStrategy: 'conceptual',
          needsClarification: false,
          reasons: [],
        },
      })),
    };

    const conceptualFallbackService = new PracticeService(
      engineRegistry as any,
      undefined as any,
      conceptualService as any,
    );

    const conceptualAiQuestion = {
      prompt: 'Which statement best explains Big O notation?',
      options: [
        'It describes how runtime grows as input size grows',
        'It names the exact runtime in seconds on every machine',
        'It proves a program always uses constant memory',
        'It only applies to recursive algorithms',
      ],
      correctIndex: 0,
      correctAnswerText: 'It describes how runtime grows as input size grows',
      explanation:
        'Big O notation expresses an upper-bound growth rate for time or space as the input size increases.',
      recommendedTimeSeconds: 40,
      topicMatchNote: 'Big O',
    };

    const requestSpy = jest
      .spyOn(conceptualFallbackService as any, 'requestQuestionSet')
      .mockResolvedValue([conceptualAiQuestion]);
    const verifySpy = jest
      .spyOn(conceptualFallbackService as any, 'verifyQuestionSet')
      .mockResolvedValue([conceptualAiQuestion]);

    const res = await conceptualFallbackService.generate({
      subject: 'Computer Science',
      topicLabel: 'Big O',
      mode: 'conceptBuilder',
      difficulty: 'medium',
      questionCount: 1,
    } as any);

    expect(requestSpy).toHaveBeenCalledTimes(1);
    expect(verifySpy).toHaveBeenCalledTimes(1);
    expect(res.questions).toHaveLength(1);
    expect(res.questions[0]).toMatchObject({
      subject: 'Computer Science',
      topicLabel: 'Big O',
      mode: 'conceptBuilder',
      difficulty: 'medium',
      prompt: conceptualAiQuestion.prompt,
      explanation: conceptualAiQuestion.explanation,
      recommendedTimeSeconds: conceptualAiQuestion.recommendedTimeSeconds,
    });
  });

  it('uses verified AI fallback when factual generation is not ready', async () => {
    const factualService = {
      buildFactPack: jest.fn(async () => ({
        ok: false,
        ready: false,
        subject: 'General Knowledge',
        topic: 'World Capitals',
        facts: [],
        evidence: [],
        gaps: ['factual_pack_not_ready'],
        needsClarification: false,
      })),
      buildQuestionSeeds: jest.fn(async () => ({
        ok: false,
        ready: false,
        subject: 'General Knowledge',
        topic: 'World Capitals',
        seeds: [],
        evidence: [],
        gaps: ['factual_pack_not_ready'],
        needsClarification: false,
      })),
    };

    const factualFallbackService = new PracticeService(
      engineRegistry as any,
      factualService as any,
    );

    const factualAiQuestion = {
      prompt: 'What is the capital of Japan?',
      options: ['Tokyo', 'Kyoto', 'Osaka', 'Nagoya'],
      correctIndex: 0,
      correctAnswerText: 'Tokyo',
      explanation: 'Tokyo is the capital of Japan.',
      recommendedTimeSeconds: 25,
      topicMatchNote: 'World Capitals',
    };

    const requestSpy = jest
      .spyOn(factualFallbackService as any, 'requestQuestionSet')
      .mockResolvedValue([factualAiQuestion]);
    const verifySpy = jest
      .spyOn(factualFallbackService as any, 'verifyQuestionSet')
      .mockResolvedValue([factualAiQuestion]);

    const res = await factualFallbackService.generate({
      subject: 'General Knowledge',
      topicLabel: 'World Capitals',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 1,
    } as any);

    expect(requestSpy).toHaveBeenCalledTimes(1);
    expect(verifySpy).toHaveBeenCalledTimes(1);
    expect(res.questions).toHaveLength(1);
    expect(res.questions[0]).toMatchObject({
      subject: 'General Knowledge',
      topicLabel: 'World Capitals',
      mode: 'practice',
      difficulty: 'medium',
      prompt: factualAiQuestion.prompt,
      explanation: factualAiQuestion.explanation,
      recommendedTimeSeconds: factualAiQuestion.recommendedTimeSeconds,
    });
  });

  it('uses verified AI fallback when symbolic generation is partial for the requested count', async () => {
    const symbolicService = {
      resolve: jest.fn(() => ({
        ok: true,
        ready: true,
        subject: 'Math',
        topic: 'Derivatives',
        confidence: 0.8,
        needsClarification: false,
        gaps: [],
        seeds: [
          {
            stem: 'What is the derivative of x^2?',
            options: ['2x', 'x', 'x^3', '2'],
            correctIndex: 0,
            explanation: 'Using the power rule, the derivative of x^2 is 2x.',
            recommendedTimeSeconds: 35,
          },
        ],
        intake: {
          rawSubject: 'Math',
          rawTopic: 'Derivatives',
          normalizedSubject: 'Math',
          normalizedTopic: 'Derivatives',
          effectiveSubject: 'Math',
          effectiveTopic: 'Derivatives',
          topicType: 'symbolic',
          breadth: 'medium',
          quizzability: 'high',
          confidence: 0.85,
          generationStrategy: 'symbolic',
          needsClarification: false,
          reasons: [],
        },
      })),
    };

    const symbolicFallbackService = new PracticeService(
      engineRegistry as any,
      undefined as any,
      undefined as any,
      symbolicService as any,
    );

    const symbolicAiQuestions = [
      {
        prompt: 'What is the derivative of x^2?',
        options: ['2x', 'x', 'x^3', '2'],
        correctIndex: 0,
        correctAnswerText: '2x',
        explanation: 'Using the power rule, the derivative of x^2 is 2x.',
        recommendedTimeSeconds: 35,
        topicMatchNote: 'Derivatives',
      },
      {
        prompt: 'What is the derivative of 3x?',
        options: ['3', 'x', '3x^2', '0'],
        correctIndex: 0,
        correctAnswerText: '3',
        explanation: 'The derivative of ax is a, so the derivative of 3x is 3.',
        recommendedTimeSeconds: 30,
        topicMatchNote: 'Derivatives',
      },
    ];

    const requestSpy = jest
      .spyOn(symbolicFallbackService as any, 'requestQuestionSet')
      .mockResolvedValue(symbolicAiQuestions);
    const verifySpy = jest
      .spyOn(symbolicFallbackService as any, 'verifyQuestionSet')
      .mockResolvedValue(symbolicAiQuestions);

    const res = await symbolicFallbackService.generate({
      subject: 'Math',
      topicLabel: 'Derivatives',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
    } as any);

    expect(requestSpy).toHaveBeenCalledTimes(1);
    expect(verifySpy).toHaveBeenCalledTimes(1);
    expect(res.questions).toHaveLength(2);
    expect(res.questions.every((q: any) => q.topicLabel === 'Derivatives')).toBe(true);
  });

  it('uses verified AI fallback when deterministic generation returns too few unique questions', async () => {
    const deterministicFallbackService = new PracticeService({
      generate: jest.fn(async () => [
        {
          prompt: 'If f(x) = x + 1, what is f(2)?',
          options: ['1', '2', '3', '4'],
          correctIndex: 2,
          explanation: 'Substitute x = 2, so f(2) = 3.',
          recommendedTimeSeconds: 25,
        },
      ]),
    } as any);

    const deterministicAiQuestions = [
      {
        prompt: 'If f(x) = x + 1, what is f(2)?',
        options: ['1', '2', '3', '4'],
        correctIndex: 2,
        correctAnswerText: '3',
        explanation: 'Substitute x = 2, so f(2) = 3.',
        recommendedTimeSeconds: 25,
        topicMatchNote: 'Functions',
      },
      {
        prompt: 'If f(x) = 2x, what is f(3)?',
        options: ['3', '5', '6', '9'],
        correctIndex: 2,
        correctAnswerText: '6',
        explanation: 'Substitute x = 3, so f(3) = 2 * 3 = 6.',
        recommendedTimeSeconds: 25,
        topicMatchNote: 'Functions',
      },
    ];

    const requestSpy = jest
      .spyOn(deterministicFallbackService as any, 'requestQuestionSet')
      .mockResolvedValue(deterministicAiQuestions);
    const verifySpy = jest
      .spyOn(deterministicFallbackService as any, 'verifyQuestionSet')
      .mockResolvedValue(deterministicAiQuestions);

    const res = await deterministicFallbackService.generate({
      subject: 'Math',
      topicLabel: 'Functions',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
    } as any);

    expect(requestSpy).toHaveBeenCalledTimes(1);
    expect(verifySpy).toHaveBeenCalledTimes(1);
    expect(res.questions).toHaveLength(2);
    expect(new Set(res.questions.map((q: any) => q.prompt)).size).toBe(2);
  });
});
