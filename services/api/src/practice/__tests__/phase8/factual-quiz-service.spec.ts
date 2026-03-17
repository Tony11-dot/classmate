import { Test } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { FactualQuizService } from '../../factual/factual-quiz.service';

describe('PHASE 8 — factual quiz service', () => {
  it('reports ready for supported tennis history factual topics', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(FactualQuizService);

    const res = service.resolve({
      subject: 'General Knowledge',
      topicLabel: 'tennis history',
    });

    console.log('FACTUAL_DEBUG_READY', JSON.stringify(res, null, 2));
    expect(res.ready).toBe(true);
    expect(res.needsClarification).toBe(false);
    expect(res.facts.length).toBeGreaterThanOrEqual(3);
    expect(res.intake.effectiveSubject).toBe('Sports');
    expect(res.intake.effectiveTopic).toBe('Tennis History');
  });

  it('reports not ready for unsupported factual topics', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(FactualQuizService);

    const res = service.resolve({
      subject: 'General Knowledge',
      topicLabel: 'ancient trade routes',
    });

    console.log('FACTUAL_DEBUG_NOT_READY', JSON.stringify(res, null, 2));
    expect(res.ready).toBe(false);
    expect(res.needsClarification).toBe(true);
    expect(res.gaps).toContain('no_domain_fact_pack_yet');
  });
});
