import { PracticeService } from '../practice.service';

describe('PracticeService polynomial blocker replays', () => {
  const engineRegistry = { generate: jest.fn(async () => null) };

  class TestPracticeService extends PracticeService {
    queue: any[] = [];
    verifierDecisions: any[] = [];

    async callResponsesJson(args: any): Promise<any> {
      if (args.schemaName === 'practice_questions') {
        const next = this.queue.shift();
        if (!next) return { questions: [] };
        return { questions: next };
      }

      if (args.schemaName === 'practice_verifier') {
        return {
          decisions:
            this.verifierDecisions.shift() ?? [
              { index: 0, verdict: 'accept', reason: 'ok' },
              { index: 1, verdict: 'accept', reason: 'ok' },
              { index: 2, verdict: 'accept', reason: 'ok' },
            ],
        };
      }

      return {};
    }
  }

  let service: TestPracticeService;

  beforeEach(() => {
    service = new TestPracticeService(engineRegistry as any);
    process.env.OPENAI_API_KEY = 'test-key';
  });

  it('survives bad first-pass polynomial questions and still returns a clean set', async () => {
    service.queue.push(
      [
        {
          prompt: 'Find coefficient of x^3 in (2x-3)^4.',
          options: ['72', '84', '96', '-72'],
          correctIndex: 0,
          correctAnswerText: '72',
          explanation:
            'Use the binomial theorem. The x^3 term works out to 96, even though the keyed answer here says 72.',
          recommendedTimeSeconds: 75,
          topicMatchNote: 'Polynomials',
        },
        {
          prompt: 'If P(x)=x^3-4x^2+ax-6 has factor (x-2), what is a?',
          options: ['6', '7', '8', '9'],
          correctIndex: 2,
          correctAnswerText: '8',
          explanation:
            'P(2)=0 gives 8-16+2a-6=0 so 2a-14=0 and a=8.',
          recommendedTimeSeconds: 75,
          topicMatchNote: 'Polynomials',
        },
        {
          prompt: 'What is the coefficient of x^4 in (4x^3-3x^2+2x-7)(x^2-5x+6)?',
          options: ['-20', '-23', '-3', '23'],
          correctIndex: 1,
          correctAnswerText: '-23',
          explanation:
            'The x^4 terms come from 4x^3(-5x) and -3x^2(x^2), totaling -23.',
          recommendedTimeSeconds: 75,
          topicMatchNote: 'Polynomials',
        },
      ],
      [
        {
          prompt: 'Find the coefficient of x^3 in the expansion of (2x - 3)^4.',
          options: ['-96', '96', '-48', '48'],
          correctIndex: 0,
          correctAnswerText: '-96',
          explanation:
            'Using the binomial theorem, the x^3 term is C(4,3)(2x)^3(-3)=4·8x^3·(-3)=-96x^3.',
          recommendedTimeSeconds: 75,
          topicMatchNote: 'Polynomials',
        },
        {
          prompt: 'If P(x)=x^3-4x^2+ax-6 has factor (x-2), what is a?',
          options: ['5', '6', '7', '8'],
          correctIndex: 2,
          correctAnswerText: '7',
          explanation:
            'Since x-2 is a factor, P(2)=0. Then 8-16+2a-6=0, so 2a-14=0 and a=7.',
          recommendedTimeSeconds: 75,
          topicMatchNote: 'Polynomials',
        },
        {
          prompt: 'What is the coefficient of x^4 in (4x^3-3x^2+2x-7)(x^2-5x+6)?',
          options: ['-23', '-20', '20', '23'],
          correctIndex: 0,
          correctAnswerText: '-23',
          explanation:
            'The x^4 terms come from 4x^3(-5x) and -3x^2(x^2), so the coefficient is -20-3=-23.',
          recommendedTimeSeconds: 75,
          topicMatchNote: 'Polynomials',
        },
      ],
    );

    service.verifierDecisions.push(
      [
        { index: 0, verdict: 'reject', reason: 'Explanation calculation sums to 96, not 72 as keyed.' },
        { index: 1, verdict: 'reject', reason: 'a value calculation incorrect, a=7 not 8.' },
        { index: 2, verdict: 'accept', reason: 'ok' },
      ],
      [
        { index: 0, verdict: 'accept', reason: 'ok' },
        { index: 1, verdict: 'accept', reason: 'ok' },
        { index: 2, verdict: 'accept', reason: 'ok' },
      ],
    );

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
      expect(String(q.explanation).toLowerCase()).not.toContain('correction');
      expect(String(q.explanation).toLowerCase()).not.toContain('reconsider');
      expect(String(q.explanation).toLowerCase()).not.toContain('adjust options');
    }
  });
});
