import { FactualQuizService } from '../../factual/factual-quiz.service';

describe('PHASE 8 — factual quiz skeleton', () => {
  it('returns a typed ready fact-pack for supported grounded topics', async () => {
    const service = new FactualQuizService();

    const res = await service.buildFactPack({
      subject: 'General Knowledge',
      topic: 'tennis history',
      questionCount: 4,
    });

    expect(res.ok).toBe(true);
    expect(res.subject).toBe('Sports');
    expect(res.topic).toBe('Tennis History');
    expect(Array.isArray(res.facts)).toBe(true);
    expect(Array.isArray(res.evidence)).toBe(true);
    expect(Array.isArray(res.gaps)).toBe(true);
    expect(res.needsClarification).toBe(false);
    expect(res.facts.length).toBeGreaterThanOrEqual(3);
    expect(res.gaps).toEqual([]);
  });

  it('returns a typed unresolved fact-pack for unsupported grounded topics', async () => {
    const service = new FactualQuizService();

    const res = await service.buildFactPack({
      subject: 'General Knowledge',
      topic: 'ancient trade routes',
      questionCount: 4,
    });

    expect(res.ok).toBe(false);
    expect(res.subject).toBe('History');
    expect(res.topic).toBe('Ancient Trade Routes');
    expect(Array.isArray(res.facts)).toBe(true);
    expect(Array.isArray(res.evidence)).toBe(true);
    expect(Array.isArray(res.gaps)).toBe(true);
    expect(res.needsClarification).toBe(true);
    expect(res.gaps).toContain('no_domain_fact_pack_yet');
  });
});
