import { InternalServerErrorException } from '@nestjs/common';
import { PracticeService } from '../practice.service';

describe('PracticeService bad phrase hard rejection', () => {
  const engineRegistry = { generate: jest.fn(async () => null) };

  class TestPracticeService extends PracticeService {
    queue: any[] = [];

    async callResponsesJson(args: any): Promise<any> {
      if (args.schemaName === 'practice_questions') {
        const next = this.queue.shift();
        if (!next) return { questions: [] };
        return { questions: next };
      }

      if (args.schemaName === 'practice_verifier') {
        return {
          decisions: [{ index: 0, verdict: 'accept', reason: 'ok' }],
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

  it('hard-rejects reconsider/correction/adjust-options style content and refuses invalid finalization', async () => {
    service.queue.push([
      {
        prompt: 'If P(x)=x^3-4x^2+ax-6 has factor (x-2), what is a?',
        options: ['6', '7', '8', '9'],
        correctIndex: 1,
        correctAnswerText: '7',
        explanation:
          'Since (x-2) is a factor, P(2)=0. Correction: maybe 8. Reconsider the algebra and adjust options if needed.',
        recommendedTimeSeconds: 75,
        topicMatchNote: 'Polynomials',
      },
    ]);

    await expect(
      service.generate({
        subject: 'Math',
        topic: 'Polynomials',
        difficulty: 'hard',
        mode: 'examPrep',
        count: 1,
        timePreferenceSeconds: 75,
        useAiTiming: true,
        maxLives: 2,
      }),
    ).rejects.toThrow(InternalServerErrorException);
  });
});
