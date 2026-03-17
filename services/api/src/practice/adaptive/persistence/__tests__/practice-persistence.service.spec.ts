import { PracticePersistenceService } from '../practice-persistence.service';

describe('PracticePersistenceService', () => {
  let service: PracticePersistenceService;

  beforeEach(() => {
    service = new PracticePersistenceService();
  });

  it('starts and reuses a session', () => {
    const a = service.startSession({
      userId: 'u1',
      sessionId: 's1',
      subject: 'Math',
      topicLabel: 'Polynomials',
      mode: 'practice',
    });

    const b = service.startSession({
      userId: 'u1',
      sessionId: 's1',
      subject: 'Math',
      topicLabel: 'Polynomials',
      mode: 'practice',
    });

    expect(a.id).toBe('s1');
    expect(b.id).toBe('s1');
    expect(a).toBe(b);
  });

  it('records attempts and updates mastery', () => {
    service.recordAttempt({
      userId: 'u1',
      sessionId: 's1',
      subject: 'Math',
      topicLabel: 'Polynomials',
      mode: 'practice',
      difficulty: 'medium',
      questionId: 'q1',
      isCorrect: true,
      selectedIndex: 2,
      correctIndex: 2,
    });

    service.recordAttempt({
      userId: 'u1',
      sessionId: 's1',
      subject: 'Math',
      topicLabel: 'Polynomials',
      mode: 'practice',
      difficulty: 'medium',
      questionId: 'q2',
      isCorrect: false,
      selectedIndex: 1,
      correctIndex: 2,
    });

    const session = service.getSession('s1');
    const mastery = service.getTopicMastery({
      userId: 'u1',
      subject: 'Math',
      topicLabel: 'Polynomials',
    });

    expect(session?.attempts).toHaveLength(2);
    expect(mastery?.totalAnswered).toBe(2);
    expect(mastery?.correctAnswered).toBe(1);
    expect(mastery?.accuracy).toBe(0.5);
    expect(mastery?.streak).toBe(0);
  });

  it('builds progress summary with weak and strong topics', () => {
    service.recordAttempt({
      userId: 'u1',
      sessionId: 's1',
      subject: 'Math',
      topicLabel: 'Polynomials',
      mode: 'practice',
      difficulty: 'medium',
      questionId: 'q1',
      isCorrect: false,
    });

    service.recordAttempt({
      userId: 'u1',
      sessionId: 's2',
      subject: 'Physics',
      topicLabel: 'Waves',
      mode: 'practice',
      difficulty: 'easy',
      questionId: 'q2',
      isCorrect: true,
    });

    const summary = service.getProgressSummary('u1');

    expect(summary.totalSessions).toBe(2);
    expect(summary.totalAttempts).toBe(2);
    expect(summary.totalCorrect).toBe(1);
    expect(summary.overallAccuracy).toBe(0.5);
    expect(summary.weakTopics[0].topicLabel).toBe('Polynomials');
    expect(summary.strongestTopics[0].topicLabel).toBe('Waves');
  });
});
