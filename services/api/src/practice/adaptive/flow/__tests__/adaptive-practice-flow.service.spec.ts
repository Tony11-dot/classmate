import { AdaptivePracticeFlowService } from '../adaptive-practice-flow.service';

describe('AdaptivePracticeFlowService', () => {
  const service = new AdaptivePracticeFlowService();

  it('records an attempt and returns adaptive next-step guidance', () => {
    const result = service.submitAttempt({
      sessionId: 'sess-1',
      subject: 'Math',
      topicLabel: 'Polynomials',
      questionId: 'q1',
      selectedIndex: 2,
      correctIndex: 2,
      difficulty: 'medium',
      responseTimeMs: 12000,
    });

    expect(result.sessionId).toBe('sess-1');
    expect(result.topicKey).toBe('Math::Polynomials');
    expect(result.isCorrect).toBe(true);
    expect(['easy', 'medium', 'hard']).toContain(result.targetDifficulty);
  });

  it('builds a session summary after multiple attempts', () => {
    service.submitAttempt({
      sessionId: 'sess-2',
      subject: 'Math',
      topicLabel: 'Polynomials',
      questionId: 'q1',
      selectedIndex: 1,
      correctIndex: 1,
      difficulty: 'medium',
    });

    service.submitAttempt({
      sessionId: 'sess-2',
      subject: 'Math',
      topicLabel: 'Polynomials',
      questionId: 'q2',
      selectedIndex: 0,
      correctIndex: 2,
      difficulty: 'medium',
    });

    const summary = service.getSessionSummary({
      sessionId: 'sess-2',
      subject: 'Math',
      topicLabel: 'Polynomials',
    });

    expect(summary.sessionId).toBe('sess-2');
    expect(summary.attempts).toBe(2);
    expect(summary.correct).toBe(1);
    expect(['easy', 'medium', 'hard']).toContain(summary.currentDifficulty);
    expect(Array.isArray(summary.weakAreas)).toBe(true);
    expect(Array.isArray(summary.strengths)).toBe(true);
  });
});
