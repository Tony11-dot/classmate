import { Test } from '@nestjs/testing';
import { PracticeService } from '../../practice.service';
import { PracticeEngineRegistry } from '../../engine/practice-engine.registry';
import { FactualQuizService } from '../../factual/factual-quiz.service';
import { ConceptualTopicService } from '../../conceptual/conceptual-topic.service';

describe('PHASE 8 — routing pipeline order', () => {
  it('prefers deterministic before factual and conceptual', async () => {
    const registry = {
      generate: jest.fn(async () => [
        {
          prompt: 'Deterministic prompt',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          correctAnswerText: 'A',
          explanation: 'ok',
          recommendedTimeSeconds: 30,
        },
      ]),
    };

    const factual = {
      buildFactPack: jest.fn(),
      buildQuestionSeeds: jest.fn(),
    };

    const conceptual = {
      resolve: jest.fn(() => ({
        ok: true,
        ready: true,
        subject: 'Computer Science',
        topic: 'Big O notation',
        confidence: 0.8,
        needsClarification: false,
        gaps: [],
        seeds: [
          {
            stem: 'Conceptual prompt',
            acceptedAnswers: ['Growth behavior'],
            explanation: 'ok',
          },
        ],
        intake: {} as any,
      })),
    };

    const mod = await Test.createTestingModule({
      providers: [
        PracticeService,
        { provide: PracticeEngineRegistry, useValue: registry },
        { provide: FactualQuizService, useValue: factual },
        { provide: ConceptualTopicService, useValue: conceptual },
      ],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'Physics',
      topicLabel: 'motion',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 1,
    } as any);

    expect(res.questions).toHaveLength(1);
    expect(res.questions[0].prompt).toBe('Deterministic prompt');
    expect(factual.buildFactPack).not.toHaveBeenCalled();
  });

  it('prefers grounded factual before AI fallback', async () => {
    const registry = { generate: jest.fn(async () => []) };

    const factual = {
      buildFactPack: jest.fn().mockResolvedValue({
        ok: true,
        subject: 'General Knowledge',
        topic: 'World Capitals',
        confidence: 0.8,
        needsClarification: false,
        facts: ['Paris is the capital of France.'],
        evidence: [{ sourceId: 'a', title: 'a', snippet: 'a' }],
        gaps: [],
      }),
      buildQuestionSeeds: jest.fn().mockResolvedValue({
        ok: true,
        subject: 'General Knowledge',
        topic: 'World Capitals',
        confidence: 0.8,
        needsClarification: false,
        seeds: [
          {
            stem: 'What is the capital of France?',
            acceptedAnswers: ['Paris'],
            explanation: 'Paris is the capital of France.',
            factSourceIds: ['a'],
          },
        ],
        evidence: [{ sourceId: 'a', title: 'a', snippet: 'a' }],
        gaps: [],
      }),
    };

    const conceptual = {
      resolve: jest.fn(() => ({
        ok: false,
        ready: false,
        subject: 'General Knowledge',
        topic: 'World Capitals',
        confidence: 0,
        needsClarification: true,
        gaps: ['not_conceptual'],
        seeds: [],
        intake: {} as any,
      })),
    };

    const mod = await Test.createTestingModule({
      providers: [
        PracticeService,
        { provide: PracticeEngineRegistry, useValue: registry },
        { provide: FactualQuizService, useValue: factual },
        { provide: ConceptualTopicService, useValue: conceptual },
      ],
    }).compile();

    const service = mod.get(PracticeService);
    const requestSpy = jest.spyOn(service as any, 'requestQuestionSet');

    const res = await service.generate({
      subject: 'General Knowledge',
      topicLabel: 'world capitals',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 1,
    } as any);

    expect(res.questions).toHaveLength(1);
    expect(res.factual.ready).toBe(true);
    expect(requestSpy).not.toHaveBeenCalled();
  });

  it('prefers conceptual before AI fallback', async () => {
    const registry = { generate: jest.fn(async () => []) };
    const factual = {
      buildFactPack: jest.fn(),
      buildQuestionSeeds: jest.fn(),
    };
    const conceptual = {
      resolve: jest.fn(() => ({
        ok: true,
        ready: true,
        subject: 'Computer Science',
        topic: 'Big O notation',
        confidence: 0.8,
        needsClarification: false,
        gaps: [],
        seeds: [
          {
            stem: 'What does Big O notation describe?',
            acceptedAnswers: ['Growth behavior'],
            explanation: 'Big O describes growth behavior.',
          },
        ],
        intake: {} as any,
      })),
    };

    const mod = await Test.createTestingModule({
      providers: [
        PracticeService,
        { provide: PracticeEngineRegistry, useValue: registry },
        { provide: FactualQuizService, useValue: factual },
        { provide: ConceptualTopicService, useValue: conceptual },
      ],
    }).compile();

    const service = mod.get(PracticeService);
    const requestSpy = jest.spyOn(service as any, 'requestQuestionSet');

    const res = await service.generate({
      subject: 'Computer Science',
      topicLabel: 'Big O notation',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 1,
    } as any);

    expect(res.questions).toHaveLength(1);
    expect(res.conceptual.ready).toBe(true);
    expect(requestSpy).not.toHaveBeenCalled();
  });
});
