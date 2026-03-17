import { Test } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { FactualQuizService } from '../../factual/factual-quiz.service';

describe('PHASE 8 — factual question seeds', () => {
  it('builds quiz-ready seeds for supported factual topics', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(FactualQuizService);

    const res = await service.buildQuestionSeeds({
      subject: 'General Knowledge',
      topic: 'tennis history',
      questionCount: 3,
      mode: 'practice',
      difficulty: 'medium',
    });

    expect(res.ok).toBe(true);
    expect(res.subject).toBe('Sports');
    expect(res.topic).toBe('Tennis History');
    expect(res.seeds).toHaveLength(3);

    for (const seed of res.seeds) {
      expect(seed.stem).toBeTruthy();
      expect(Array.isArray(seed.acceptedAnswers)).toBe(true);
      expect(seed.acceptedAnswers.length).toBeGreaterThan(0);
      expect(seed.explanation).toBeTruthy();
      expect(seed.factSourceIds.length).toBeGreaterThan(0);
    }
  });

  it('stays explicit when no grounded fact-pack exists yet', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(FactualQuizService);

    const res = await service.buildQuestionSeeds({
      subject: 'General Knowledge',
      topic: 'ancient trade routes',
      questionCount: 3,
      mode: 'practice',
      difficulty: 'medium',
    });

    expect(res.ok).toBe(false);
    expect(res.seeds).toEqual([]);
    expect(res.gaps).toContain('no_domain_fact_pack_yet');
  });
});
