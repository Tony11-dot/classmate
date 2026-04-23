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

  it(
    'does not let quadratic requests get hijacked by statistics mode matching',
    async () => {
      const mod = await Test.createTestingModule({
        imports: [PracticeModule],
      }).compile();

      const service = mod.get(PracticeService);

      const res = await service.generate({
        subject: 'Math',
        topicLabel: 'Algebra · Quadratic equations',
        topicPath: ['Algebra', 'Quadratic equations'],
        topicPathText: 'Algebra > Quadratic equations',
        mode: 'practice',
        difficulty: 'olympiad',
        questionCount: 3,
        count: 3,
        useAiTiming: true,
        maxLives: 3,
        strictPromptSummary:
          'STRICT_FILTER_SECTION_DO_NOT_IGNORE\n\nSubject: Math\nTopic: Algebra > Quadratic equations\nMode: practice\nDifficulty: olympiad',
      } as any);

      expect(res.questions).toHaveLength(3);
      expect(
        res.questions.every((q: any) => q.topicLabel === 'Quadratic equations'),
      ).toBe(true);
      expect(
        res.questions.every((q: any) =>
          String(q.prompt).toLowerCase().includes('quadratic equation'),
        ),
      ).toBe(true);

      await mod.close();
    },
    30000,
  );

  it(
    'does not let non-topic strict-summary text hijack requests into limits generation',
    async () => {
      const mod = await Test.createTestingModule({
        imports: [PracticeModule],
      }).compile();

      const service = mod.get(PracticeService);

      const res = await service.generate({
        subject: 'Math',
        topicLabel: 'Quadratic equations',
        topicPath: ['Algebra', 'Quadratic equations'],
        topicPathText: 'Algebra > Quadratic equations',
        mode: 'practice',
        difficulty: 'hard',
        questionCount: 2,
        count: 2,
        useAiTiming: true,
        maxLives: 3,
        strictPromptSummary:
          'STRICT_FILTER_SECTION_DO_NOT_IGNORE\n\nSubject: Math\nTopic: Algebra > Quadratic equations\nTeacher note: explain why the value approaches a limit in real-world graphs only as contrast, but keep the exercise on quadratics.\nMode: practice\nDifficulty: hard',
      } as any);

      expect(res.questions).toHaveLength(2);
      expect(
        res.questions.every((q: any) => q.topicLabel === 'Quadratic equations'),
      ).toBe(true);
      expect(
        res.questions.every((q: any) =>
          !String(q.prompt).toLowerCase().includes('limit of'),
        ),
      ).toBe(true);
      expect(
        res.questions.every((q: any) =>
          String(q.prompt).toLowerCase().includes('quadratic'),
        ),
      ).toBe(true);

      await mod.close();
    },
    30000,
  );

  it(
    'routes custom integral requests to symbolic integral content instead of deterministic drift',
    async () => {
      const mod = await Test.createTestingModule({
        imports: [PracticeModule],
      }).compile();

      const service = mod.get(PracticeService);

      const res = await service.generate({
        subject: 'Math',
        topicLabel: 'Calculus · integral',
        topicPath: ['Calculus', 'integral'],
        topicPathText: 'Calculus > integral',
        mode: 'practice',
        difficulty: 'olympiad',
        questionCount: 3,
        count: 3,
        useAiTiming: true,
        maxLives: 3,
        strictPromptSummary:
          'STRICT_FILTER_SECTION_DO_NOT_IGNORE\n\nSubject: Math\nTopic: Calculus > integral\nMode: practice\nDifficulty: olympiad',
      } as any);

      expect(res.questions).toHaveLength(3);
      expect(
        res.questions.every((q: any) => {
          const text = `${q.prompt} ${q.explanation}`.toLowerCase();
          return text.includes('∫') || text.includes('integral');
        }),
      ).toBe(true);
      expect(
        res.questions.every((q: any) => {
          const text = `${q.prompt} ${q.explanation} ${q.topicLabel}`.toLowerCase();
          return !text.includes('statistics') && !text.includes('median');
        }),
      ).toBe(true);

      await mod.close();
    },
    30000,
  );
});
