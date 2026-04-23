import {
  analyzeCustomPracticeTopic,
  normalizePracticeSubjectLoose,
  normalizeCustomTopicText,
} from '../../intake/custom-topic-intake';

describe('PHASE 8 — custom topic intake', () => {
  it('normalizes loose subject typos', () => {
    expect(normalizePracticeSubjectLoose('Elictronics')).toBe('Electronics');
    expect(normalizePracticeSubjectLoose('math')).toBe('Math');
    expect(normalizePracticeSubjectLoose('')).toBe('General Knowledge');
  });

  it('normalizes known free-text topic aliases', () => {
    expect(normalizeCustomTopicText('ohm law')).toBe('Ohm’s Law');
    expect(normalizeCustomTopicText('tennis history')).toBe('Tennis History');
    expect(normalizeCustomTopicText('motion')).toBe('Kinematics');
  });

  it('infers subject from typed custom topic when subject is broad', () => {
    const res = analyzeCustomPracticeTopic({
      subject: 'General Knowledge',
      topicLabel: 'tennis history',
    });

    expect(res.effectiveSubject).toBe('Sports');
    expect(res.effectiveTopic).toBe('Tennis History');
    expect(res.generationStrategy).toBe('grounded_factual');
    expect(res.topicType).toBe('factual_history');
  });

  it('infers structured subject from a strong catalog-style custom prompt', () => {
    const res = analyzeCustomPracticeTopic({
      subject: 'General Knowledge',
      topicLabel: 'periodic table trends',
    });

    expect(res.effectiveSubject).toBe('Chemistry');
    expect(res.effectiveTopic).toBe('Periodic Table Trends');
    expect(res.generationStrategy).toBe('deterministic');
    expect(res.topicType).toBe('school_stem');
  });

  it('keeps school symbolic topics on structured paths', () => {
    const res = analyzeCustomPracticeTopic({
      subject: 'math',
      topicLabel: 'polynomials',
    });

    expect(res.effectiveSubject).toBe('Math');
    expect(res.effectiveTopic).toBe('Polynomials');
    expect(['deterministic', 'symbolic']).toContain(res.generationStrategy);
    expect(res.needsClarification).toBe(false);
  });

  it('flags broad or weak topics for clarification', () => {
    const res = analyzeCustomPracticeTopic({
      subject: 'General Knowledge',
      topicLabel: 'history',
    });

    expect(res.needsClarification).toBe(true);
    expect(res.reasons).toContain('broad_topic');
  });

  it('flags unknown low-signal topics', () => {
    const res = analyzeCustomPracticeTopic({
      subject: 'General Knowledge',
      topicLabel: 'random thing maybe',
    });

    console.log('CUSTOM_TOPIC_FAIL_CASE', JSON.stringify(res, null, 2));
    expect(res.confidence).toBeLessThan(0.75);
    expect(res.generationStrategy).toBe('fallback');
  });

  it('keeps specific unknown topics answerable instead of low-signal', () => {
    const res = analyzeCustomPracticeTopic({
      subject: 'Business',
      topicLabel: 'coffee trade routes in the 1600s',
    });

    expect(res.topicType).toBe('unknown');
    expect(res.generationStrategy).toBe('fallback');
    expect(res.quizzability).toBe('medium');
    expect(res.needsClarification).toBe(false);
  });
});
