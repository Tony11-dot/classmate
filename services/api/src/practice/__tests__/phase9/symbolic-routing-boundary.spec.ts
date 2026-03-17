import { Test } from '@nestjs/testing';
import { PracticeService } from '../../practice.service';
import { PracticeEngineRegistry } from '../../engine/practice-engine.registry';
import { FactualQuizService } from '../../factual/factual-quiz.service';
import { ConceptualTopicService } from '../../conceptual/conceptual-topic.service';

describe('PHASE 9 — symbolic routing boundary', () => {
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

  it('does not use AI fallback for unsupported symbolic topics either', async () => {
    const registry = { generate: jest.fn(async () => []) };

    class TestPracticeService extends PracticeService {
      requestQuestionSet = jest.fn(async () => {
        throw new Error('AI fallback should not be called for unsupported symbolic topics');
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
              topic: 'Tensor Calculus',
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
      topicLabel: 'tensor calculus',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
    } as any);

    expect(res.questions).toEqual([]);
    expect(res.symbolic.ready).toBe(false);
  });
});
