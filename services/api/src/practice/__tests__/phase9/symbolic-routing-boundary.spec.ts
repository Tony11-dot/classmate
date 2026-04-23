import { Test } from '@nestjs/testing';
import { PracticeService } from '../../practice.service';
import { PracticeEngineRegistry } from '../../engine/practice-engine.registry';
import { FactualQuizService } from '../../factual/factual-quiz.service';
import { ConceptualTopicService } from '../../conceptual/conceptual-topic.service';

describe('PHASE 9 — symbolic routing boundary', () => {
  beforeEach(() => {
    process.env.OPENAI_API_KEY = 'test-key';
    jest.clearAllMocks();
  });

  it('does not use AI fallback for supported symbolic topics', async () => {
    const registry = { generate: jest.fn(async () => []) };

    class TestPracticeService extends PracticeService {
      requestQuestionSet = jest.fn(async () => {
        throw new Error('AI fallback should not be called for symbolic topics');
      }) as any;

      verifyQuestionSet = jest.fn(async () => []) as any;
    }

    const mod = await Test.createTestingModule({
      providers: [
        { provide: PracticeEngineRegistry, useValue: registry },
        {
          provide: FactualQuizService,
          useValue: {
            buildFactPack: jest.fn(),
            buildQuestionSeeds: jest.fn(),
          },
        },
        {
          provide: ConceptualTopicService,
          useValue: {
            resolve: jest.fn(() => ({
              ok: false,
              ready: false,
              subject: 'Math',
              topic: 'Derivatives',
              confidence: 0,
              needsClarification: false,
              gaps: ['not_conceptual'],
              seeds: [],
              intake: {},
            })),
          },
        },
        {
          provide: PracticeService,
          useFactory: (
            engineRegistry: PracticeEngineRegistry,
            factualQuizService: FactualQuizService,
            conceptualTopicService: ConceptualTopicService,
          ) =>
            new TestPracticeService(
              engineRegistry,
              factualQuizService as any,
              conceptualTopicService as any,
            ),
          inject: [PracticeEngineRegistry, FactualQuizService, ConceptualTopicService],
        },
      ],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'Math',
      topicLabel: 'derivatives',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
    } as any);

    expect(res.questions).toHaveLength(2);
    expect(registry.generate).toHaveBeenCalled();
  });

  it('uses AI fallback for specific symbolic topics when the seed bank is too generic', async () => {
    const registry = { generate: jest.fn(async () => []) };
    const aiQuestion = {
      prompt:
        'Which improper integral best supports the integral comparison test for $\\int_1^\\infty \\frac{1}{x^2} \\; dx$?',
      options: ['A convergent p-series comparison', 'A linear approximation', 'A midpoint sum only', 'A determinant identity'],
      correctIndex: 0,
      correctAnswerText: 'A convergent p-series comparison',
      explanation:
        'Comparing against a known convergent p-series keeps the exact topic on integral comparison tests rather than falling back to generic antiderivative drills.',
      recommendedTimeSeconds: 45,
      topicMatchNote: 'integral comparison test',
    };

    class TestPracticeService extends PracticeService {
      async callResponsesJson(args: any): Promise<any> {
        if (args.schemaName === 'practice_questions') {
          return { questions: [aiQuestion] };
        }

        if (args.schemaName === 'practice_self_verify') {
          return {
            audits: [
              {
                index: 0,
                final_answer: aiQuestion.correctAnswerText,
                steps: aiQuestion.explanation,
                confidence: 1,
                type: 'symbolic',
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

    const mod = await Test.createTestingModule({
      providers: [
        { provide: PracticeEngineRegistry, useValue: registry },
        {
          provide: FactualQuizService,
          useValue: {
            buildFactPack: jest.fn(),
            buildQuestionSeeds: jest.fn(),
          },
        },
        {
          provide: ConceptualTopicService,
          useValue: {
            resolve: jest.fn(() => ({
              ok: false,
              ready: false,
              subject: 'Math',
              topic: 'integral comparison test',
              confidence: 0,
              needsClarification: false,
              gaps: ['not_conceptual'],
              seeds: [],
              intake: {},
            })),
          },
        },
        {
          provide: PracticeService,
          useFactory: (
            engineRegistry: PracticeEngineRegistry,
            factualQuizService: FactualQuizService,
            conceptualTopicService: ConceptualTopicService,
          ) =>
            new TestPracticeService(
              engineRegistry,
              factualQuizService as any,
              conceptualTopicService as any,
            ),
          inject: [PracticeEngineRegistry, FactualQuizService, ConceptualTopicService],
        },
      ],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'Math',
      topicLabel: 'integral comparison test',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 1,
    } as any);

    expect(res.questions).toHaveLength(1);
    expect(res.questions[0].topicLabel).toBe('integral comparison test');
    expect(String(res.questions[0].prompt)).toContain('integral comparison test');
  });
});
