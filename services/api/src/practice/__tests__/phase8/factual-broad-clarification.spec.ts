import { analyzeCustomPracticeTopic } from '../../intake/custom-topic-intake';

describe('PHASE 8 — broad factual clarification', () => {
  it('flags raw broad factual topics for clarification', () => {
    const res = analyzeCustomPracticeTopic({
      subject: 'General Knowledge',
      topicLabel: 'flags',
    });

    expect(res.generationStrategy).toBe('grounded_factual');
    expect(res.needsClarification).toBe(true);
    expect(res.reasons).toContain('broad_factual_topic');
  });

  it('does not flag narrower factual topics like world capitals', () => {
    const res = analyzeCustomPracticeTopic({
      subject: 'General Knowledge',
      topicLabel: 'world capitals',
    });

    expect(res.generationStrategy).toBe('grounded_factual');
    expect(res.needsClarification).toBe(false);
  });
});
