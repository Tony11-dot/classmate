import { FactualFactPackBuilder } from '../../factual/factual-fact-pack.builder';
import { analyzeCustomPracticeTopic } from '../../intake/custom-topic-intake';

describe('PHASE 8 — factual fact-pack builder', () => {
  const builder = new FactualFactPackBuilder();

  it('builds a usable tennis history fact pack', () => {
    const intake = analyzeCustomPracticeTopic({
      subject: 'General Knowledge',
      topicLabel: 'tennis history',
    });

    const res = builder.build({
      intake,
      subject: intake.effectiveSubject,
      topic: intake.effectiveTopic,
    });

    expect(res.subject).toBe('Sports');
    expect(res.topic).toBe('Tennis History');
    expect(res.facts.length).toBeGreaterThanOrEqual(3);
    expect(res.evidence.length).toBeGreaterThanOrEqual(3);
    expect(res.gaps).toEqual([]);
    expect(res.needsClarification).toBe(false);
  });

  it('keeps unsupported factual topics explicit', () => {
    const intake = analyzeCustomPracticeTopic({
      subject: 'General Knowledge',
      topicLabel: 'ancient trade routes',
    });

    const res = builder.build({
      intake,
      subject: intake.effectiveSubject,
      topic: intake.effectiveTopic,
    });

    expect(res.facts.length).toBe(0);
    expect(res.gaps).toContain('no_domain_fact_pack_yet');
    expect(res.needsClarification).toBe(true);
  });
});
