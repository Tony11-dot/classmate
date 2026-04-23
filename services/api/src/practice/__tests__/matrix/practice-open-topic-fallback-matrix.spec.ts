import { PracticeService } from '../../practice.service';

const CASES = [
  {
    subject: 'General Knowledge',
    expectedSubject: 'History',
    topic: 'history of coffee trade',
    expectedTopicLabel: 'history of coffee trade',
    prompt: 'Which statement best matches the history of coffee trade?',
    topicMatchNote: 'history of coffee trade',
    expectedPromptNeedle: 'coffee trade',
  },
  {
    subject: 'Physics',
    expectedSubject: 'Physics',
    topic: 'muon decay experiments',
    expectedTopicLabel: 'muon decay experiments',
    prompt: 'Which statement best matches muon decay experiments?',
    topicMatchNote: 'muon decay experiments',
    expectedPromptNeedle: 'muon decay',
  },
  {
    subject: 'Math',
    expectedSubject: 'Math',
    topic: 'stirling approximation',
    expectedTopicLabel: 'stirling approximation',
    prompt: 'Which expression matches Stirling approximation best: sqrt(n)(n/e)^n?',
    topicMatchNote: 'stirling approximation',
    expectedPromptNeedle: 'Stirling approximation',
    expectedRenderNeedle: '$sqrt(n)$',
  },
  {
    subject: 'Math',
    expectedSubject: 'Math',
    topic: 'integral comparison test',
    expectedTopicLabel: 'integral comparison test',
    prompt:
      'Which improper integral best supports the integral comparison test for $\\int_1^\\infty \\frac{1}{x^2} \\; dx$?',
    topicMatchNote: 'integral comparison test',
    expectedPromptNeedle: 'integral comparison test',
    expectedRenderNeedle: '$\\int_1^\\infty',
  },
  {
    subject: 'Math',
    expectedSubject: 'Math',
    topic: 'matrix rank by row reduction',
    expectedTopicLabel: 'matrix rank by row reduction',
    prompt:
      'Which row operation best preserves rank for the matrix $\\begin{bmatrix}1 & 2 \\\\ 2 & 4\\end{bmatrix}$ during row reduction?',
    topicMatchNote: 'matrix rank by row reduction',
    expectedPromptNeedle: 'row reduction',
    expectedRenderNeedle: '\\begin{bmatrix}',
  },
  {
    subject: 'Computer Science',
    expectedSubject: 'Computer Science',
    topic: 'javascript microtask starvation',
    expectedTopicLabel: 'javascript microtask starvation',
    prompt: 'What does this snippet show about javascript microtasks: console.log("start"); Promise.resolve().then(() => console.log("microtask")); console.log("end");',
    topicMatchNote: 'javascript microtask starvation',
    expectedPromptNeedle: 'microtask',
    expectedRenderNeedle: '```javascript',
  },
  {
    subject: 'Computer Science',
    expectedSubject: 'Computer Science',
    topic: 'sql left join null filtering',
    expectedTopicLabel: 'sql left join null filtering',
    prompt:
      'What does this query show about sql left join null filtering? ```sql\nSELECT u.id\nFROM users u\nLEFT JOIN payments p ON p.user_id = u.id\nWHERE p.id IS NULL;\n```',
    topicMatchNote: 'sql left join null filtering',
    expectedPromptNeedle: 'left join',
    expectedRenderNeedle: '```sql',
  },
  {
    subject: 'Biology',
    expectedSubject: 'Biology',
    topic: 'membrane transport in neurons',
    expectedTopicLabel: 'membrane transport in neurons',
    prompt: 'Which statement best explains membrane transport in neurons?',
    topicMatchNote: 'membrane transport in neurons',
    expectedPromptNeedle: 'membrane transport',
  },
] as const;

describe('practice open-topic fallback matrix', () => {
  class TestPracticeService extends PracticeService {
    async callResponsesJson(args: any): Promise<any> {
      if (args.schemaName === 'practice_questions') {
        const payload = JSON.parse(String(args.user ?? '{}'));
        const topicLabel = String(payload.topicLabel ?? 'General');
        const matched = CASES.find((item) => item.topic === topicLabel) ?? CASES[0];

        return {
          questions: [
            {
              prompt: matched.prompt,
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 0,
              correctAnswerText: 'A',
              explanation: `Teacher-style explanation for ${matched.topic} that stays on topic and is long enough to pass validation cleanly.`,
              recommendedTimeSeconds: 35,
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

  it.each(CASES)(
    'accepts arbitrary custom topic fallback for $subject / $topic',
    async (testCase) => {
      const res = await service.generate({
        subject: testCase.subject,
        topicLabel: testCase.topic,
        topicPathText: testCase.topic,
        mode: 'practice',
        difficulty: 'medium',
        questionCount: 1,
        count: 1,
      } as any);

      expect(res.questions).toHaveLength(1);
      expect(res.questions[0]).toMatchObject({
        subject: testCase.expectedSubject,
        topicLabel: testCase.expectedTopicLabel,
        mode: 'practice',
        difficulty: 'medium',
      });
      expect(String(res.questions[0].prompt)).toContain(testCase.expectedPromptNeedle);

      if (testCase.expectedRenderNeedle) {
        expect(String(res.questions[0].prompt)).toContain(testCase.expectedRenderNeedle);
      }
    },
  );
});