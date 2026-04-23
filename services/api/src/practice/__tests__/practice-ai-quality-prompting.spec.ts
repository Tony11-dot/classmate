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
        const payload = JSON.parse(String(args.user ?? '{}'));
        const topicLabel = String(payload.topicLabel ?? 'Optics');
        const difficulty = String(payload.difficulty ?? 'medium');
        const mode = String(payload.mode ?? 'practice');
        const recommendedTimeSeconds =
          mode === 'flashcards'
            ? 25
            : mode === 'speedRound'
              ? 20
              : difficulty === 'olympiad'
                ? 65
                : difficulty === 'hard'
                  ? 45
                  : 35;

        return {
          questions: [
            {
              prompt: `Fallback prompt about ${topicLabel}`,
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 1,
              correctAnswerText: 'B',
              explanation: `Fallback explanation about ${topicLabel} that is long enough to pass validation cleanly.`,
              recommendedTimeSeconds,
              topicMatchNote: topicLabel,
            },
          ],
        };
      }

      if (args.schemaName === 'practice_verifier') {
        return {
          decisions: [{ index: 0, verdict: 'accept', reason: 'ok' }],
        };
      }

      if (args.schemaName === 'practice_self_verify') {
        return {
          audits: [
            {
              index: 0,
              final_answer: 'B',
              steps: 'Fallback explanation about Functions that is long enough to pass validation cleanly.',
              confidence: 0.96,
              type: 'text',
              validation_passed: true,
              reason: 'ok',
            },
          ],
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
      difficulty: 'medium',
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
    expect(system).toContain('Render symbolic math cleanly and conventionally when needed: fractions, powers, roots, trig functions, logs, limits, derivatives, integrals, summations, matrices, vectors, set notation, subscripts, and superscripts should use proper LaTeX inside math delimiters.');
    expect(system).toContain('If code spans multiple lines, it must still be fenced as a markdown code block. Never leave raw multi-line code unfenced.');
    expect(system).toContain('For matrices, determinants, or vectors, prefer standard LaTeX structures such as bmatrix, pmatrix, vmatrix, or aligned inline vector notation when appropriate. For piecewise definitions, prefer LaTeX cases notation.');
    expect(system).toContain('Mode shaping: flashcards must be concept-first, recognition-heavy, short, memory-oriented, and definition/relationship focused.');
  });

  it('tells the verifier to reject difficulty mismatches', async () => {
    await service.generate({
      subject: 'Math',
      topic: 'Functions',
      difficulty: 'hard',
      mode: 'practice',
      count: 1,
    });

    const verifierCall = service.captured.find((x) => x.schemaName === 'practice_verifier');
    const system = String(verifierCall.system);

    expect(system).toContain('Reject any item whose actual complexity or recommendedTimeSeconds clearly does not match the requested difficulty.');
    expect(system).toContain('Easy should feel direct and short; hard should materially increase reasoning or time demand; olympiad should require genuinely harder insight, not cosmetic difficulty.');
  });

  it('tells the verifier to reject mode mismatches', async () => {
    await service.generate({
      subject: 'Math',
      topic: 'Functions',
      difficulty: 'medium',
      mode: 'flashcards',
      count: 1,
    });

    const verifierCall = service.captured.find((x) => x.schemaName === 'practice_verifier');
    const system = String(verifierCall.system);

    expect(system).toContain('Reject any item whose reading load, pacing, or style clearly does not match the requested mode.');
    expect(system).toContain('Flashcards should be short and recognition-oriented. speedRound should be especially fast and low-reading-load. examPrep should feel more formal and substantial than a quick drill item.');
  });

  it('adds a structured self-verification contract with confidence gating', async () => {
    await service.generate({
      subject: 'Math',
      topic: 'Functions',
      difficulty: 'hard',
      mode: 'practice',
      count: 1,
    });

    const selfVerifyCall = service.captured.find((x) => x.schemaName === 'practice_self_verify');
    const system = String(selfVerifyCall.system);

    expect(system).toContain('Use the following structured contract for every item:');
    expect(system).toContain('{ "final_answer": string, "steps": string, "confidence": number, "type": "math" | "physics" | "text" | "code", "validation_passed": boolean }');
    expect(system).toContain('Do not emit confident approvals for uncertain items. Low-confidence or inconsistent items must fail validation.');
    expect(system).toContain('Math steps and final_answer must use proper LaTeX when symbolic notation is needed.');
    expect(system).toContain('Code in steps must be inside fenced markdown code blocks with a language tag when obvious.');
  });
});
