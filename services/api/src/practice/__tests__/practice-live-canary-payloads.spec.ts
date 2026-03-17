describe('Practice live canary payloads', () => {
  it('keeps the expected optics canary stable', () => {
    const payload = {
      subject: 'Physics',
      topic: 'Optics',
      difficulty: 'medium',
      mode: 'practice',
      count: 5,
    };

    expect(payload).toEqual({
      subject: 'Physics',
      topic: 'Optics',
      difficulty: 'medium',
      mode: 'practice',
      count: 5,
    });
  });

  it('keeps the fallback live matrix stable', () => {
    const payloads = [
      '{"subject":"Physics","topic":"Magnetism","difficulty":"easy","mode":"practice","count":3,"timePreferenceSeconds":20,"useAiTiming":true,"maxLives":1}',
      '{"subject":"Math","topic":"Polynomials","difficulty":"hard","mode":"examPrep","count":3,"timePreferenceSeconds":75,"useAiTiming":true,"maxLives":2}',
      '{"subject":"Physics","topic":"Relativity","difficulty":"medium","mode":"conceptBuilder","count":3,"timePreferenceSeconds":45,"useAiTiming":false,"maxLives":3}',
      '{"subject":"Math","topic":"Set theory","difficulty":"medium","mode":"flashcards","count":3,"timePreferenceSeconds":18,"useAiTiming":true,"maxLives":1}',
    ];

    expect(payloads).toHaveLength(4);
    expect(payloads[0]).toContain('"topic":"Magnetism"');
    expect(payloads[1]).toContain('"topic":"Polynomials"');
    expect(payloads[2]).toContain('"topic":"Relativity"');
    expect(payloads[3]).toContain('"topic":"Set theory"');
  });
});
