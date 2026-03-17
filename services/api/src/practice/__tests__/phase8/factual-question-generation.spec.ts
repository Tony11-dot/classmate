import { Test } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { PracticeService } from '../../practice.service';

describe('PHASE 8 — factual question generation', () => {
  it('returns actual quiz questions for supported grounded factual topics', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'General Knowledge',
      topicLabel: 'tennis history',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 3,
      useAiTiming: true,
      maxLives: 3,
    });

    expect(Array.isArray(res.questions)).toBe(true);
    expect(res.questions).toHaveLength(3);

    for (const q of res.questions) {
      expect(q.subject).toBe('Sports');
      expect(q.topicLabel).toBe('Tennis History');
      expect(Array.isArray(q.options)).toBe(true);
      expect(q.options).toHaveLength(4);
      expect(q.correctIndex).toBeGreaterThanOrEqual(0);
      expect(q.correctIndex).toBeLessThan(4);
      expect(String(q.prompt).trim()).toBeTruthy();
      expect(String(q.explanation).trim()).toBeTruthy();
    }
  });

  it('still returns explicit factual-not-ready state for unsupported grounded topics', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'General Knowledge',
      topicLabel: 'ancient trade routes',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
      useAiTiming: true,
      maxLives: 3,
    });

    expect(res.questions).toEqual([]);
    expect(res.factual.ready).toBe(false);
    expect(res.factual.gaps).toContain('no_domain_fact_pack_yet');
  });
});
