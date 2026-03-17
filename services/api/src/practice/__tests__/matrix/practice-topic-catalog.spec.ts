import {
  PRACTICE_TOPIC_CATALOG,
  resolveCanonicalPracticeTopic,
} from '../../catalog/practice-topic-catalog';

describe('practice topic catalog', () => {
  it('has no duplicate subject/topic pairs', () => {
    const seen = new Set<string>();
    for (const row of PRACTICE_TOPIC_CATALOG) {
      const key = `${row.subject}__${row.canonicalTopic}`;
      expect(seen.has(key)).toBe(false);
      seen.add(key);
    }
  });

  it('resolves canonical aliases', () => {
    expect(resolveCanonicalPracticeTopic('Physics', 'motion')?.canonicalTopic).toBe('Kinematics');
    expect(resolveCanonicalPracticeTopic('Math', 'quadratics')?.canonicalTopic).toBe('Quadratic equations');
    expect(resolveCanonicalPracticeTopic('Electronics', 'ohms law')?.canonicalTopic).toBe('Ohm’s Law');
  });
});
