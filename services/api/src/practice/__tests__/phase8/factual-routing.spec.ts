import { Test } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { PracticeService } from '../../practice.service';
import { FactualQuizService } from '../../factual/factual-quiz.service';

describe('PHASE 8 — factual routing', () => {
  it('returns explicit factual-not-ready payload before generic AI fallback', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);
    const factual = mod.get(FactualQuizService);

    jest.spyOn(factual, 'buildFactPack').mockResolvedValue({
      ok: false,
      subject: 'History',
      topic: 'Ancient Trade Routes',
      confidence: 0,
      needsClarification: true,
      facts: [],
      evidence: [],
      gaps: ['no_domain_fact_pack_yet'],
    });

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
