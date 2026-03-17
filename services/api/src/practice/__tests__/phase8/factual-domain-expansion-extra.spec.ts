import { FactualQuizService } from '../../factual/factual-quiz.service';

describe('PHASE 8 — factual domain expansion extra', () => {
  const service = new FactualQuizService();

  it('supports Ancient Trade Routes', () => {
    const res = service.resolve({ subject: 'History', topic: 'Ancient Trade Routes' } as any);
    expect(res.ready).toBe(true);
    expect(res.facts.length).toBeGreaterThanOrEqual(3);
  });

  it('supports Space Basics', () => {
    const res = service.resolve({ subject: 'Science', topic: 'Space Basics' } as any);
    expect(res.ready).toBe(true);
    expect(res.facts.length).toBeGreaterThanOrEqual(3);
  });

  it('supports General Sports', () => {
    const res = service.resolve({ subject: 'Sports', topic: 'General Sports' } as any);
    expect(res.ready).toBe(true);
    expect(res.facts.length).toBeGreaterThanOrEqual(3);
  });

  it('supports Cells Basics', () => {
    const res = service.resolve({ subject: 'Biology', topic: 'Cells Basics' } as any);
    expect(res.ready).toBe(true);
    expect(res.facts.length).toBeGreaterThanOrEqual(3);
  });

  it('supports Matter Basics', () => {
    const res = service.resolve({ subject: 'Chemistry', topic: 'Matter Basics' } as any);
    expect(res.ready).toBe(true);
    expect(res.facts.length).toBeGreaterThanOrEqual(3);
  });

  it('supports Earth Basics', () => {
    const res = service.resolve({ subject: 'Geography', topic: 'Earth Basics' } as any);
    expect(res.ready).toBe(true);
    expect(res.facts.length).toBeGreaterThanOrEqual(3);
  });
});
