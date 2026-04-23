import { PracticeService } from '../practice.service';

describe('PracticeService observability', () => {
  const engineRegistry = {
    generate: jest.fn(async () => null),
  };

  class TestPracticeService extends PracticeService {
    private calls = 0;

    async callResponsesJson(args: any): Promise<any> {
      if (args.schemaName === 'practice_questions') {
        this.calls += 1;
        if (this.calls === 1) {
          return {
            questions: [
              {
                prompt: 'Question one about optics and lenses.',
                options: ['A', 'B', 'C', 'D'],
                correctIndex: 1,
                correctAnswerText: 'B',
                explanation:
                  'This explanation is intentionally long enough to pass local validation safely.',
                recommendedTimeSeconds: 35,
                topicMatchNote: 'Optics',
              },
              {
                prompt: 'Question two about mirrors and images.',
                options: ['W', 'X', 'Y', 'Z'],
                correctIndex: 2,
                correctAnswerText: 'Y',
                explanation:
                  'This explanation is intentionally long enough to pass local validation safely.',
                recommendedTimeSeconds: 40,
                topicMatchNote: 'Optics',
              },
              {
                prompt: 'Question three about refraction in glass.',
                options: ['L', 'M', 'N', 'O'],
                correctIndex: 0,
                correctAnswerText: 'L',
                explanation:
                  'This explanation is intentionally long enough to pass local validation safely.',
                recommendedTimeSeconds: 45,
                topicMatchNote: 'Optics',
              },
            ],
          };
        }

        return {
          questions: [
            {
              prompt: 'Recovered question one about optics and lenses.',
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 1,
              correctAnswerText: 'B',
              explanation:
                'Recovered explanation is intentionally long enough to pass local validation safely.',
              recommendedTimeSeconds: 35,
              topicMatchNote: 'Optics',
            },
            {
              prompt: 'Recovered question two about mirrors and images.',
              options: ['W', 'X', 'Y', 'Z'],
              correctIndex: 2,
              correctAnswerText: 'Y',
              explanation:
                'Recovered explanation is intentionally long enough to pass local validation safely.',
              recommendedTimeSeconds: 40,
              topicMatchNote: 'Optics',
            },
            {
              prompt: 'Recovered question three about refraction in glass.',
              options: ['L', 'M', 'N', 'O'],
              correctIndex: 0,
              correctAnswerText: 'L',
              explanation:
                'Recovered explanation is intentionally long enough to pass local validation safely.',
              recommendedTimeSeconds: 45,
              topicMatchNote: 'Optics',
            },
          ],
        };
      }

      if (args.schemaName === 'practice_verifier') {
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
    jest.restoreAllMocks();
  });

  it('returns a strict local set when verifier rejects an otherwise valid set', async () => {
    const spy = jest.spyOn(console, 'log').mockImplementation(() => undefined);

    const res = await service.generate({
      subject: 'Physics',
      topic: 'Optics',
      difficulty: 'medium',
      mode: 'practice',
      count: 3,
    });

    expect(res.questions).toHaveLength(3);

    expect(
      spy.mock.calls.some((call) =>
        String(call[0]).includes('"event":"generation_strict_local_fallback"'),
      ),
    ).toBe(true);
    expect(
      spy.mock.calls.some((call) =>
        String(call[0]).includes('"event":"generation_failed"'),
      ),
    ).toBe(false);
  });

  it('logs verifier reject summary when verifier rejects answers', async () => {
    const spy = jest.spyOn(console, 'log').mockImplementation(() => undefined);

    const res = await service.generate({
      subject: 'Physics',
      topic: 'Optics',
      difficulty: 'medium',
      mode: 'practice',
      count: 3,
    });

    expect(res.questions).toHaveLength(3);

    expect(
      spy.mock.calls.some((call) =>
        String(call[0]).includes('[practice.verify] reject_summary'),
      ),
    ).toBe(true);
  });
});
