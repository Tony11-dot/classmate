import { PracticeService } from '../../practice.service';

describe('PracticeService adaptive integration', () => {
  const service = new PracticeService();

  it('submits adaptive attempt through practice service', () => {
    const res = (service as any).submitAdaptiveAttempt({
      sessionId: 'adaptive-s1',
      subject: 'Math',
      topicLabel: 'Polynomials',
      questionId: 'q1',
      selectedIndex: 2,
      correctIndex: 2,
      difficulty: 'medium',
      responseTimeMs: 12000,
    });

    expect(res.sessionId).toBe('adaptive-s1');
    expect(res.isCorrect).toBe(true);
    expect(['easy', 'medium', 'hard']).toContain(res.targetDifficulty);
  });

  it('returns adaptive session summary through practice service', () => {
    (service as any).submitAdaptiveAttempt({
      sessionId: 'adaptive-s2',
      subject: 'Physics',
      topicLabel: 'Waves',
      questionId: 'q1',
      selectedIndex: 1,
      correctIndex: 1,
      difficulty: 'medium',
    });

    (service as any).submitAdaptiveAttempt({
      sessionId: 'adaptive-s2',
      subject: 'Physics',
      topicLabel: 'Waves',
      questionId: 'q2',
      selectedIndex: 0,
      correctIndex: 2,
      difficulty: 'medium',
    });

    const summary = (service as any).getAdaptiveSessionSummary({
      sessionId: 'adaptive-s2',
      subject: 'Physics',
      topicLabel: 'Waves',
    });

    expect(summary.sessionId).toBe('adaptive-s2');
    expect(summary.attempts).toBe(2);
    expect(summary.correct).toBe(1);
    expect(['easy', 'medium', 'hard']).toContain(summary.currentDifficulty);
  });
});
