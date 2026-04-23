import { PracticeService } from '../practice.service';

describe('PracticeService topic-first fallback', () => {
  const engineRegistry = {
    generate: jest.fn(async () => null),
  };

  class TestPracticeService extends PracticeService {
    async callResponsesJson(args: any): Promise<any> {
      if (args.schemaName === 'practice_questions') {
        return {
          questions: [
            {
              prompt:
                'In Computer Science, which statement best explains the difference between HTTP and HTTPS when sending a login request?',
              options: [
                'HTTPS encrypts the request with TLS while HTTP sends it without transport encryption',
                'HTTP encrypts the request while HTTPS removes encryption',
                'HTTP and HTTPS are identical except for the browser icon',
                'HTTPS is only used for images while HTTP is only used for forms',
              ],
              correctIndex: 0,
              correctAnswerText:
                'HTTPS encrypts the request with TLS while HTTP sends it without transport encryption',
              explanation:
                'HTTPS adds TLS protection around the HTTP exchange, so credentials sent over HTTPS are encrypted in transit while plain HTTP traffic is not.',
              recommendedTimeSeconds: 20,
              topicMatchNote: 'http vs https',
            },
          ],
        };
      }

      if (args.schemaName === 'practice_self_verify') {
        return {
          audits: [
            {
              index: 0,
              final_answer:
                'HTTPS encrypts the request with TLS while HTTP sends it without transport encryption',
              steps:
                'HTTPS uses TLS to protect the HTTP exchange, while plain HTTP does not provide transport encryption.',
              confidence: 1,
              type: 'conceptual',
              validation_passed: true,
              reason: 'ok',
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

  const service = new TestPracticeService(engineRegistry as any);

  beforeEach(() => {
    process.env.OPENAI_API_KEY = 'test-key';
    jest.restoreAllMocks();
  });

  it('returns an exact-topic set when only difficulty or mode shaping blocks the strict validator', async () => {
    const spy = jest.spyOn(console, 'log').mockImplementation(() => undefined);

    const res = await service.generate({
      subject: 'Computer Science',
      topicLabel: 'http vs https',
      topicPath: ['http vs https'],
      topicPathText: 'http vs https',
      difficulty: 'hard',
      mode: 'conceptBuilder',
      questionCount: 1,
      useAiTiming: false,
      timePreferenceSeconds: 15,
      maxLives: 3,
    } as any);

    expect(res.questions).toHaveLength(1);
    expect(res.questions[0].topicLabel).toBe('http vs https');
    expect(res.questions[0].prompt.toLowerCase()).toContain('http');
    expect(res.questions[0].prompt.toLowerCase()).toContain('https');
    expect(res.questions[0].options).toHaveLength(4);
    expect(
      spy.mock.calls.some((call) =>
        String(call[0]).includes('"event":"generation_topic_first_fallback"'),
      ),
    ).toBe(true);
  });
});