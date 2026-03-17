import { PracticeService } from '../practice.service';

describe('PracticeService topic integrity', () => {
  const engineRegistry = {
    generate: jest.fn(async () => null),
  };

  class TestPracticeService extends PracticeService {
    public calls: any[] = [];

    async callResponsesJson(args: any): Promise<any> {
      this.calls.push(args);

      if (args.schemaName === 'practice_questions') {
        return {
          questions: [
            {
              prompt: 'What is the union of sets A and B?',
              options: ['Elements in A or B', 'Elements in both only', 'Elements in neither', 'Only elements in A'],
              correctIndex: 0,
              correctAnswerText: 'Elements in A or B',
              explanation: 'The union contains every element that appears in A or in B or in both.',
              recommendedTimeSeconds: 18,
              topicMatchNote: 'Set theory',
            },
            {
              prompt: 'What is the intersection of sets A and B?',
              options: ['Elements in both A and B', 'Elements only in A', 'Elements only in B', 'All subsets of A'],
              correctIndex: 0,
              correctAnswerText: 'Elements in both A and B',
              explanation: 'The intersection contains exactly the elements common to both sets.',
              recommendedTimeSeconds: 18,
              topicMatchNote: 'Set theory',
            },
            {
              prompt: 'If A = {1,2,3} and B = {2,3,4}, what is A \\ B?',
              options: ['{1}', '{4}', '{2,3}', '{1,4}'],
              correctIndex: 0,
              correctAnswerText: '{1}',
              explanation: 'A \\ B means elements in A that are not in B, so only 1 remains.',
              recommendedTimeSeconds: 18,
              topicMatchNote: 'Set theory',
            },
          ],
        };
      }

      if (args.schemaName === 'practice_verifier') {
        return {
          decisions: [
            { index: 0, verdict: 'accept', reason: 'ok' },
            { index: 1, verdict: 'accept', reason: 'ok' },
            { index: 2, verdict: 'accept', reason: 'ok' },
          ],
        };
      }

      return {};
    }
  }

  const service = new TestPracticeService(engineRegistry as any);

  beforeEach(() => {
    jest.clearAllMocks();
    service.calls = [];
    process.env.OPENAI_API_KEY = 'test-key';
  });

  it('sends exact topic fields for fallback generation', async () => {
    await service.generate({
      subject: 'Math',
      topic: 'Set theory',
      difficulty: 'medium',
      mode: 'flashcards',
      count: 3,
      timePreferenceSeconds: 18,
      useAiTiming: true,
      maxLives: 1,
    });

    const questionCall = service.calls.find((x) => x.schemaName === 'practice_questions');
    expect(questionCall).toBeTruthy();

    const payload = JSON.parse(questionCall.user);
    expect(payload.subject).toBe('Math');
    expect(payload.topicLabel).toBe('Set theory');
    expect(payload.topicPathText).toBe('Set theory');
    expect(payload.mode).toBe('flashcards');
    expect(payload.difficulty).toBe('medium');
    expect(payload.timePreferenceSeconds).toBe(18);
    expect(payload.maxLives).toBe(1);
    expect(payload.constraints.exactTopicMatch).toBe(true);
    expect(payload.constraints.noTopicDrift).toBe(true);
  });

  it('demands exact-topic wording in the system prompt', async () => {
    await service.generate({
      subject: 'Physics',
      topic: 'Relativity',
      difficulty: 'medium',
      mode: 'conceptBuilder',
      count: 3,
      timePreferenceSeconds: 45,
      useAiTiming: false,
      maxLives: 3,
    });

    const questionCall = service.calls.find((x) => x.schemaName === 'practice_questions');
    const system = String(questionCall.system);

    expect(system).toContain('Generate questions EXACTLY for the requested subject and EXACT requested topic. Do not drift.');
    expect(system).toContain('The topicLabel, topicPathText, topicPath, and strictPromptSummary are all hard constraints.');
    expect(system).toContain('topicMatchNote must be a very short phrase naming the exact requested topic only.');
    expect(system).toContain('Mode shaping: conceptBuilder must emphasize understanding, interpretation, and why/when a concept applies.');
  });
});
