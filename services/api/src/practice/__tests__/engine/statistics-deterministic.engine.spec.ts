import { StatisticsDeterministicEngine } from '../../engine/statistics-deterministic.engine';

describe('StatisticsDeterministicEngine', () => {
  const engine = new StatisticsDeterministicEngine();

  it('produces multiple statistics families for generic Statistics requests', async () => {
    const questions = await engine.generate({
      subject: 'Math',
      topicLabel: 'Statistics',
      topicPath: ['Math', 'Statistics'],
      topicPathText: 'Statistics',
      strictPromptSummary: 'Generate school-level statistics practice.',
      questionCount: 6,
      mode: 'practice',
      difficulty: 'medium',
      timePreferenceSeconds: null,
      useAiTiming: true,
      maxLives: 3,
    });

    expect(questions).toHaveLength(6);

    const families = new Set(
      questions.map((q) => {
        const prompt = q.prompt.toLowerCase();
        if (prompt.includes('mean')) return 'mean';
        if (prompt.includes('median')) return 'median';
        if (prompt.includes('mode')) return 'mode';
        if (prompt.includes('range')) return 'range';
        return 'other';
      }),
    );

    expect(families.has('median')).toBe(true);
    expect(families.has('mode')).toBe(true);
    expect(families.has('mean')).toBe(true);
    expect(families.has('range')).toBe(true);
  });

  it('honors a specific statistics subtopic prompt', async () => {
    const questions = await engine.generate({
      subject: 'Math',
      topicLabel: 'median practice',
      topicPath: ['Math', 'Statistics'],
      topicPathText: 'median practice',
      strictPromptSummary: 'Focus on medians of data sets.',
      questionCount: 3,
      mode: 'practice',
      difficulty: 'hard',
      timePreferenceSeconds: null,
      useAiTiming: true,
      maxLives: 3,
    });

    expect(questions).toHaveLength(3);
    expect(
      questions.every((q) => q.prompt.toLowerCase().includes('median')),
    ).toBe(true);
  });
});