import { ProgressSummaryService } from '../progress-summary.service';

describe('ProgressSummaryService', () => {
  const service = new ProgressSummaryService();

  it('builds weak and strong topic summaries', () => {
    const summary = service.summarize({
      topics: [
        {
          subject: 'Math',
          topic: 'Derivatives',
          accuracy: 0.25,
          streak: 0,
          attempts: 8,
          correct: 2,
        },
        {
          subject: 'Math',
          topic: 'Integrals',
          accuracy: 0.8,
          streak: 3,
          attempts: 10,
          correct: 8,
        },
        {
          subject: 'Physics',
          topic: 'Kinematics',
          accuracy: 0.9,
          streak: 4,
          attempts: 10,
          correct: 9,
        },
      ],
    });

    expect(summary.totalTopics).toBe(3);
    expect(summary.totalAttempts).toBe(28);
    expect(summary.totalCorrect).toBe(19);
    expect(summary.weakTopics[0].topic).toBe('Derivatives');
    expect(summary.strongTopics[0].topic).toBe('Kinematics');
    expect(summary.recommendedFocus).toContain('Math — Derivatives');
  });

  it('handles empty input safely', () => {
    const summary = service.summarize({ topics: [] });
    expect(summary.totalTopics).toBe(0);
    expect(summary.totalAttempts).toBe(0);
    expect(summary.totalCorrect).toBe(0);
    expect(summary.overallAccuracy).toBe(0);
    expect(summary.weakTopics).toEqual([]);
    expect(summary.strongTopics).toEqual([]);
    expect(summary.recommendedFocus).toEqual([]);
  });

  it('derives accuracy from attempts and correct answers', () => {
    const summary = service.summarize({
      topics: [
        {
          subject: 'Chemistry',
          topic: 'Matter Basics',
          accuracy: 0,
          streak: 1,
          attempts: 5,
          correct: 4,
        },
      ],
    });

    expect(summary.overallAccuracy).toBeCloseTo(0.8, 5);
    expect(summary.strongTopics[0].accuracy).toBeCloseTo(0.8, 5);
  });
});
