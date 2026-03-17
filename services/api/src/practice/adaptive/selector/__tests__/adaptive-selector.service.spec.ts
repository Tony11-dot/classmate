import { AdaptiveSelectorService } from '../adaptive-selector.service';

describe('AdaptiveSelectorService', () => {
  const service = new AdaptiveSelectorService();

  it('chooses hard for strong performance', () => {
    const r = service.choose({
      masteryScore: 0.9,
      streak: 4,
      recentAccuracy: 0.9,
    });

    expect(r.targetDifficulty).toBe('hard');
    expect(r.shouldRepeatTopic).toBe(false);
  });

  it('chooses easy for weak performance', () => {
    const r = service.choose({
      masteryScore: 0.2,
      streak: 0,
      recentAccuracy: 0.25,
    });

    expect(r.targetDifficulty).toBe('easy');
    expect(r.shouldRepeatTopic).toBe(true);
  });

  it('chooses medium for middle state', () => {
    const r = service.choose({
      masteryScore: 0.55,
      streak: 1,
      recentAccuracy: 0.6,
    });

    expect(r.targetDifficulty).toBe('medium');
  });
});
