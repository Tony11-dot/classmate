import {
  PRACTICE_TOPIC_CATALOG,
  resolveCanonicalPracticeTopic,
  resolveCanonicalPracticeTopicLoose,
} from '../../catalog/practice-topic-catalog';

describe('practice topic catalog', () => {
  it('has no duplicate exact catalog entries', () => {
    const seen = new Set<string>();
    for (const row of PRACTICE_TOPIC_CATALOG) {
      const key = `${row.subject}__${row.canonicalTopic}__${row.aliases
        .slice()
        .sort()
        .join('|')}`;
      expect(seen.has(key)).toBe(false);
      seen.add(key);
    }
  });

  it('resolves canonical aliases', () => {
    expect(resolveCanonicalPracticeTopic('Physics', 'motion')?.canonicalTopic).toBe('Kinematics');
    expect(resolveCanonicalPracticeTopic('Math', 'quadratics')?.canonicalTopic).toBe('Quadratic equations');
    expect(resolveCanonicalPracticeTopic('Electronics', 'ohms law')?.canonicalTopic).toBe('Ohm’s Law');
  });

  it('resolves longer custom prompts to owned canonical topics', () => {
    expect(
      resolveCanonicalPracticeTopicLoose(
        'English',
        'reading comprehension passages about climate',
      )?.canonicalTopic,
    ).toBe('Reading Comprehension');
    expect(
      resolveCanonicalPracticeTopicLoose(
        'Biology',
        'dna and genetics basics',
      )?.canonicalTopic,
    ).toBe('Genetics');
    expect(
      resolveCanonicalPracticeTopicLoose(
        'Physics',
        'laws of thermodynamics and heat transfer',
      )?.canonicalTopic,
    ).toBe('Thermodynamics');
    expect(
      resolveCanonicalPracticeTopicLoose(
        'Physics',
        'reflection and refraction basics',
      )?.canonicalTopic,
    ).toBe('Optics');
    expect(
      resolveCanonicalPracticeTopicLoose(
        'Computer Science',
        'time complexity of loops',
      )?.canonicalTopic,
    ).toBe('Algorithms');
  });
});
