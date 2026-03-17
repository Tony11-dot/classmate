describe('practice optics live canary scaffold', () => {
  it('documents the canonical live payload used by smoke scripts', () => {
    const payload = {
      subject: 'Physics',
      topic: 'Optics',
      difficulty: 'medium',
      mode: 'practice',
      count: 5,
    };

    expect(payload.subject).toBe('Physics');
    expect(payload.topic).toBe('Optics');
    expect(payload.difficulty).toBe('medium');
    expect(payload.mode).toBe('practice');
    expect(payload.count).toBe(5);
  });
});
