import { Test } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { PracticeService } from '../../practice.service';

describe('practice runtime regressions', () => {
  it(
    'normalizes subject typos and preserves exact electronics topic fidelity',
    async () => {
      const mod = await Test.createTestingModule({
        imports: [PracticeModule],
      }).compile();

      const service = mod.get(PracticeService);

      const res = await service.generate({
        subject: 'Elictronics',
        topicLabel: 'Kirchhoff Laws',
        topicPathText: 'Kirchhoff Laws',
        mode: 'practice',
        difficulty: 'hard',
        questionCount: 2,
        count: 2,
        useAiTiming: true,
        maxLives: 3,
      } as any);

      expect(res.questions).toHaveLength(2);
      expect(res.questions.every((q: any) => q.subject === 'Electronics')).toBe(true);
      expect(res.questions.every((q: any) => q.topicLabel === 'Kirchhoff Laws')).toBe(true);
      expect(res.questions.every((q: any) => Number(q.recommendedTimeSeconds) >= 25)).toBe(true);
    },
    30000,
  );
});
