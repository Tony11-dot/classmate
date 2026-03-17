import { analyzeCustomPracticeTopic } from '../../intake/custom-topic-intake';

describe('PHASE 9 — symbolic topic resolution', () => {
  it('treats derivatives as symbolic', () => {
    const res = analyzeCustomPracticeTopic({
      subject: 'Math',
      topicLabel: 'derivatives',
    });

    expect(res.topicType).toBe('symbolic');
    expect(res.generationStrategy).toBe('symbolic');
  });

  it('treats limits as symbolic', () => {
    const res = analyzeCustomPracticeTopic({
      subject: 'Math',
      topicLabel: 'limits',
    });

    expect(res.topicType).toBe('symbolic');
    expect(res.generationStrategy).toBe('symbolic');
  });

  it('treats matrices as symbolic', () => {
    const res = analyzeCustomPracticeTopic({
      subject: 'Math',
      topicLabel: 'matrices',
    });

    expect(res.topicType).toBe('symbolic');
    expect(res.generationStrategy).toBe('symbolic');
  });

  it('treats integrals as symbolic', () => {
    const res = analyzeCustomPracticeTopic({
      subject: 'Math',
      topicLabel: 'integrals',
    });

    expect(res.topicType).toBe('symbolic');
    expect(res.generationStrategy).toBe('symbolic');
  });
});
