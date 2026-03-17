import fs from 'node:fs';

describe('practice live blocker smoke script', () => {
  it('contains all blocker payloads and core shape checks', () => {
    const s = fs.readFileSync('scripts/smoke-practice-live-full.sh', 'utf8');

    expect(s).toContain('"topic":"Magnetism"');
    expect(s).toContain('"topic":"Polynomials"');
    expect(s).toContain('"topic":"Relativity"');
    expect(s).toContain('"topic":"Set theory"');
    expect(s).toContain('[.questions[].topicLabel]');
    expect(s).toContain('[.questions[].mode]');
    expect(s).toContain('[.questions[].difficulty]');
    expect(s).toContain('practice-live-full-ok');
  });
});
