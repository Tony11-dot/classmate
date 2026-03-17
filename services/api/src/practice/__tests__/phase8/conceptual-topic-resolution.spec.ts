import { ConceptualTopicService } from '../../conceptual/conceptual-topic.service';

describe('PHASE 8 — conceptual topic resolution', () => {
  const service = new ConceptualTopicService();

  it('treats Big O notation as a valid conceptual/custom topic', () => {
    const res = service.resolve({
      subject: 'Computer Science',
      topicLabel: 'Big O notation',
      questionCount: 2,
    });

    expect(res.ok).toBe(true);
    expect(res.seeds).toHaveLength(2);
    expect(res.needsClarification).toBe(false);
  });

  it('treats music theory as a valid conceptual/custom topic', () => {
    const res = service.resolve({
      subject: 'General Knowledge',
      topicLabel: 'music theory',
      questionCount: 2,
    });

    expect(res.ok).toBe(true);
    expect(res.seeds).toHaveLength(2);
  });

  it('treats conditionals as a valid conceptual/custom topic', () => {
    const res = service.resolve({
      subject: 'Computer Science',
      topicLabel: 'conditional statements',
      questionCount: 2,
    });

    expect(res.ok).toBe(true);
    expect(res.seeds).toHaveLength(2);
  });

  it('still clarifies overly broad conceptual prompts', () => {
    const res = service.resolve({
      subject: 'General Knowledge',
      topicLabel: 'music',
      questionCount: 2,
    });

    expect(res.ready).toBe(false);
    expect(res.needsClarification).toBe(true);
    expect(res.gaps).toContain('broad_conceptual_topic');
  });
});
