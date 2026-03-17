import { Test } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { PracticeEngineRegistry } from '../../engine/practice-engine.registry';

describe('practice gap closures', () => {
  it(
    'covers the highest-priority unsupported topics deterministically',
    async () => {
      const mod = await Test.createTestingModule({
        imports: [PracticeModule],
      }).compile();

      const registry = mod.get(PracticeEngineRegistry);

      const cases = [
        { subject: 'Physics', topicLabel: 'Magnetism' },
        { subject: 'Physics', topicLabel: 'Relativity' },
        { subject: 'Math', topicLabel: 'Polynomials' },
        { subject: 'Math', topicLabel: 'Set theory' },
      ];

      for (const c of cases) {
        const questions = await registry.generate({
          subject: c.subject,
          topicLabel: c.topicLabel,
          topicPath: [],
          topicPathText: c.topicLabel,
          strictPromptSummary: '',
          questionCount: 2,
          mode: 'practice',
          difficulty: 'medium',
          timePreferenceSeconds: 30,
          useAiTiming: true,
          maxLives: 2,
        });

        expect(Array.isArray(questions)).toBe(true);
        expect(questions?.length).toBe(2);
      }
    },
    30000,
  );
});
