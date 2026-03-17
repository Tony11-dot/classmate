import { PracticeService } from '../practice.service';

describe('PracticeService AI quality prompt shaping', () => {
  const engineRegistry = {
    generate: jest.fn(async () => null),
  };

  class TestPracticeService extends PracticeService {
    public captured: any[] = [];

    async callResponsesJson(args: any): Promise<any> {
      this.captured.push(args);
      if (args.schemaName === 'practice_questions') {
        return {
          questions: [
            {
              prompt: 'Fallback prompt 1',
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 1,
              correctAnswerText: 'B',
              explanation: 'Fallback explanation 1',
              recommendedTimeSeconds: 35,
              topicMatchNote: 'Optics',
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
    jest.clearAllMocks();
    service.captured = [];
    process.env.OPENAI_API_KEY = 'test-key';
  });

  it('injects mode, difficulty, timing, and lives into request payload', async () => {
    await service.generate({
      subject: 'Physics',
      topic: 'Optics',
      difficulty: 'hard',
      mode: 'examPrep',
      count: 1,
      timePreferenceSeconds: 52,
      useAiTiming: true,
      maxLives: 2,
    });

    const questionCall = service.captured.find((x) => x.schemaName === 'practice_questions');
    expect(questionCall).toBeTruthy();

    const payload = JSON.parse(questionCall.user);
    expect(payload.subject).toBe('Physics');
    expect(payload.topicLabel).toBe('Optics');
    expect(payload.mode).toBe('examPrep');
    expect(payload.difficulty).toBe('hard');
    expect(payload.timePreferenceSeconds).toBe(52);
    expect(payload.useAiTiming).toBe(true);
    expect(payload.maxLives).toBe(2);
  });

  it('puts explicit shaping instructions into the system prompt', async () => {
    await service.generate({
      subject: 'Math',
      topic: 'Functions',
      difficulty: 'olympiad',
      mode: 'flashcards',
      count: 1,
      timePreferenceSeconds: 20,
      useAiTiming: false,
      maxLives: 1,
    });

    const questionCall = service.captured.find((x) => x.schemaName === 'practice_questions');
    const system = String(questionCall.system);

    expect(system).toContain('Generate questions EXACTLY for the requested subject and EXACT requested topic.');
    expect(system).toContain('Difficulty must materially affect complexity.');
    expect(system).toContain('Mode shaping: flashcards must be concept-first, recognition-heavy, short, memory-oriented, and definition/relationship focused.');
  });
});
