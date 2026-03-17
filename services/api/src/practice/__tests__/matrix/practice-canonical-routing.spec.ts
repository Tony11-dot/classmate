import { Test } from '@nestjs/testing';
import { PracticeService } from '../../practice.service';
import { PracticeEngineRegistry } from '../../engine/practice-engine.registry';

describe('practice canonical routing', () => {
  it('canonicalizes topic aliases before deterministic routing', async () => {
    const registry = {
      generate: jest.fn(async (req: any) => [
        {
          prompt: 'stub',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          correctAnswerText: 'A',
          explanation: 'ok',
          recommendedTimeSeconds: 40,
          topicMatchNote: 'stub',
        },
      ]),
    };

    const mod = await Test.createTestingModule({
      providers: [
        PracticeService,
        { provide: PracticeEngineRegistry, useValue: registry },
      ],
    }).compile();

    const service = mod.get(PracticeService);
    await service.generate({
      subject: 'Physics',
      topicLabel: 'motion',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 1,
      count: 1,
    } as any);

    expect(registry.generate).toHaveBeenCalled();
    const req = registry.generate.mock.calls[0][0];
    expect(req.topicLabel).toBe('Kinematics');
    expect(req.topicPathText).toBe('Kinematics');
  });
});
