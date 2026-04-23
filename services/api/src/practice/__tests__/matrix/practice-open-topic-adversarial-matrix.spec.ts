import { PracticeService } from '../../practice.service';

const CASES = [
  {
    subject: 'General Knowledge',
    inputTopic: 'coffee-trade routes in the 1600s???',
    returnedTopic: 'coffee-trade routes in the 1600s???',
    returnedSubject: 'General Knowledge',
    prompt: 'Which statement best describes coffee-trade routes in the 1600s?',
    topicMatchNote: 'coffee-trade routes in the 1600s???',
    promptNeedle: 'coffee-trade routes',
  },
  {
    subject: 'Math',
    inputTopic: 'sigma telescoping trick with weird notation',
    returnedTopic: 'sigma telescoping trick with weird notation',
    returnedSubject: 'Math',
    prompt: 'Which identity helps simplify Σ_{k=1}^n (1/(k(k+1)))?',
    topicMatchNote: 'sigma telescoping trick with weird notation',
    promptNeedle: 'Σ_{k=1}^n',
  },
  {
    subject: 'Computer Science',
    inputTopic: 'python recursion base case confusion',
    returnedTopic: 'python recursion base case confusion',
    returnedSubject: 'Computer Science',
    prompt: 'What does this recursion snippet show? ```python\ndef f(n):\n    if n == 0:\n        return 1\n    return n * f(n-1)\n```',
    topicMatchNote: 'python recursion base case confusion',
    promptNeedle: '```python',
  },
  {
    subject: 'Physics',
    inputTopic: 'piecewise electric potential wall',
    returnedTopic: 'piecewise electric potential wall',
    returnedSubject: 'Physics',
    prompt: 'Which piecewise model fits the electric potential wall best: \\begin{cases}V_0 & x < a \\ 0 & x \ge a\\end{cases}?',
    topicMatchNote: 'piecewise electric potential wall',
    promptNeedle: '\\begin{cases}',
  },
  {
    subject: 'Math',
    inputTopic: 'integral comparison test with weird notation ∫_1^∞ 1/x^2',
    returnedTopic: 'integral comparison test with weird notation ∫_1^∞ 1/x^2',
    returnedSubject: 'Math',
    prompt:
      'Which improper integral best supports the integral comparison test for $\\int_1^\\infty \\frac{1}{x^2} \\; dx$?',
    topicMatchNote: 'integral comparison test with weird notation ∫_1^∞ 1/x^2',
    promptNeedle: '$\\int_1^\\infty',
  },
  {
    subject: 'Math',
    inputTopic: 'matrix-rank by row-reduction???',
    returnedTopic: 'matrix-rank by row-reduction???',
    returnedSubject: 'Math',
    prompt:
      'Which row operation best preserves rank for the matrix $\\begin{bmatrix}1 & 2 \\\\ 2 & 4\\end{bmatrix}$ during row reduction?',
    topicMatchNote: 'matrix-rank by row-reduction???',
    promptNeedle: 'row reduction',
  },
] as const;

describe('practice open-topic adversarial matrix', () => {
  class TestPracticeService extends PracticeService {
    async callResponsesJson(args: any): Promise<any> {
      if (args.schemaName === 'practice_questions') {
        const payload = JSON.parse(String(args.user ?? '{}'));
        const topicLabel = String(payload.topicLabel ?? 'General');
        const matched =
          CASES.find(
            (item) =>
              item.inputTopic === topicLabel || item.returnedTopic === topicLabel,
          ) ?? CASES[0];

        return {
          questions: [
            {
              prompt: matched.prompt,
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 0,
              correctAnswerText: 'A',
              explanation: `Teacher-style explanation for ${matched.returnedTopic} that stays tightly on topic and is long enough to pass validation cleanly.`,
              recommendedTimeSeconds: 40,
              topicMatchNote: matched.topicMatchNote,
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

  const service = new TestPracticeService({ generate: jest.fn(async () => null) } as any);

  beforeEach(() => {
    process.env.OPENAI_API_KEY = 'test-key';
    jest.clearAllMocks();
  });

  it.each(CASES)('keeps adversarial free-text input anchored for $subject / $inputTopic', async (testCase) => {
    const res = await service.generate({
      subject: testCase.subject,
      topicLabel: testCase.inputTopic,
      topicPathText: testCase.inputTopic,
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 1,
      count: 1,
    } as any);

    expect(res.questions).toHaveLength(1);
    expect(res.questions[0]).toMatchObject({
      subject: testCase.returnedSubject,
      topicLabel: testCase.returnedTopic,
      mode: 'practice',
      difficulty: 'medium',
    });
    expect(String(res.questions[0].prompt)).toContain(testCase.promptNeedle);
  });
});