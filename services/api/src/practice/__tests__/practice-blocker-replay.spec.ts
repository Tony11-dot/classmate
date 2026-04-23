import { PracticeService } from '../practice.service';

describe('PracticeService blocker replay coverage', () => {
  const originalGenerateBudgetMs = process.env.PRACTICE_GENERATE_BUDGET_MS;
  const originalOpenAiTimeoutMs = process.env.PRACTICE_OPENAI_TIMEOUT_MS;
  const engineRegistry = {
    generate: jest.fn(async () => null),
  };

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

  let service: TestPracticeService;

  beforeEach(() => {
    service = new TestPracticeService(engineRegistry as any);
    process.env.OPENAI_API_KEY = 'test-key';
    delete process.env.PRACTICE_GENERATE_BUDGET_MS;
    delete process.env.PRACTICE_OPENAI_TIMEOUT_MS;
  });

  afterAll(() => {
    process.env.PRACTICE_GENERATE_BUDGET_MS = originalGenerateBudgetMs;
    process.env.PRACTICE_OPENAI_TIMEOUT_MS = originalOpenAiTimeoutMs;
  });

  it('keeps live blocker payload fields intact for polynomials examPrep hard', async () => {
    service.queue.push([
      {
        prompt: 'Find the degree of the polynomial \\(3x^5 - 7x^3 + 4x^2 - x + 9\\).',
        options: ['5', '3', '4', '9'],
        correctIndex: 0,
        correctAnswerText: '5',
        explanation: 'The degree of a polynomial is the highest exponent with a nonzero coefficient, so the degree is 5.',
        recommendedTimeSeconds: 75,
        topicMatchNote: 'Polynomials',
      },
      {
        prompt: 'Which of the following is the factorization of \\(x^3 - 3x^2 - 4x + 12\\)?',
        options: ['(x-3)(x-2)(x+2)', '(x+3)(x-2)^2', '(x-4)(x-1)(x+3)', '(x-3)(x+2)^2'],
        correctIndex: 0,
        correctAnswerText: '(x-3)(x-2)(x+2)',
        explanation: 'Grouping or testing simple roots shows the cubic factors as (x-3)(x-2)(x+2).',
        recommendedTimeSeconds: 75,
        topicMatchNote: 'Polynomials',
      },
      {
        prompt: 'Given \\(P(x) = 2x^4 - 3x^3 + x - 5\\), what is the coefficient of \\(x^3\\) in \\(P(-x)\\)?',
        options: ['-3', '3', '2', '-2'],
        correctIndex: 1,
        correctAnswerText: '3',
        explanation: 'Replacing x with -x flips the sign of odd-power terms, so -3x^3 becomes +3x^3.',
        recommendedTimeSeconds: 75,
        topicMatchNote: 'Polynomials',
      },
    ]);

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
      expect(q.recommendedTimeSeconds).toBe(75);
      expect(typeof q.prompt).toBe('string');
      expect(q.prompt.length).toBeGreaterThan(0);
      expect(typeof q.explanation).toBe('string');
      expect(q.explanation.length).toBeGreaterThan(0);
    }
  });

  it('normalizes preview-facing latex wrappers but preserves meaning', async () => {
    service.queue.push([
      {
        prompt: 'Find the fraction \\(\\frac{7}{2}\\) as a decimal.',
        options: ['3', '3.5', '4', '2.5'],
        correctIndex: 1,
        correctAnswerText: '3.5',
        explanation: 'Since the fraction \\(\\frac{7}{2}\\) = 7/2, the decimal value is 3.5.',
        recommendedTimeSeconds: 30,
        topicMatchNote: 'Fractions',
      },
    ]);

    const res = await service.generate({
      subject: 'Math',
      topic: 'Fractions',
      difficulty: 'medium',
      mode: 'practice',
      count: 1,
    });

    expect(res.questions[0].prompt).toContain('\\frac{7}{2}');
    expect(res.questions[0].explanation).toContain('\\frac{7}{2}');
  });

  it('preserves multiline fenced code blocks in sanitized prompts', async () => {
    service.queue.push([
      {
        prompt:
          'What does this print?\n\n```dart\nif (score >= 90) {\n  print("A");\n} else {\n  print("B");\n}\n```',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 1,
        correctAnswerText: 'B',
        explanation:
          'Check the branch order.\n\n```dart\nif (score >= 90) {\n  print("A");\n} else {\n  print("B");\n}\n```',
        recommendedTimeSeconds: 30,
        topicMatchNote: 'Nested Conditions',
      },
    ]);

    const res = await service.generate({
      subject: 'Computer Science',
      topic: 'Nested Conditions',
      difficulty: 'medium',
      mode: 'practice',
      count: 1,
    });

    expect(res.questions[0].prompt).toContain('```dart');
    expect(res.questions[0].prompt).toContain('\nif (score >= 90) {\n');
    expect(res.questions[0].explanation).toContain('```dart');
    expect(res.questions[0].explanation).toContain('\n} else {\n');
  });

  it('fails fast when the AI generation budget is exhausted', async () => {
    process.env.PRACTICE_GENERATE_BUDGET_MS = '20';
    process.env.PRACTICE_OPENAI_TIMEOUT_MS = '20';

    class SlowPracticeService extends PracticeService {
      async callResponsesJson(args: any): Promise<any> {
        await new Promise((resolve) => setTimeout(resolve, 30));
        if (args.schemaName === 'practice_questions') {
          return {
            questions: [
              {
                prompt: 'What is 2 + 2?',
                options: ['3', '4', '5', '6'],
                correctIndex: 1,
                correctAnswerText: '4',
                explanation: '2 + 2 = 4.',
                recommendedTimeSeconds: 20,
                topicMatchNote: 'Arithmetic',
              },
            ],
          };
        }

        return {
          audits: [
            {
              index: 0,
              final_answer: '4',
              steps: '2 + 2 = 4.',
              confidence: 1,
              type: 'math',
              validation_passed: true,
              reason: 'ok',
            },
          ],
        };
      }
    }

    const slowService = new SlowPracticeService(engineRegistry as any);

    await expect(
      slowService.generate({
        subject: 'Math',
        topic: 'Arithmetic',
        difficulty: 'easy',
        mode: 'practice',
        count: 1,
      }),
    ).rejects.toThrow(/invalid question set/i);
  });
});
