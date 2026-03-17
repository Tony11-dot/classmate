import { readFileSync } from 'node:fs';
import { join } from 'node:path';

describe('practice live smoke scripts', () => {
  it('phase4 live script asserts topic/style shape fields', () => {
    const p = join(process.cwd(), 'scripts', 'smoke-practice-phase4-live.sh');
    const s = readFileSync(p, 'utf8');

    expect(s).toContain('[.questions[].topicLabel]');
    expect(s).toContain('[.questions[].mode]');
    expect(s).toContain('[.questions[].difficulty]');
    expect(s).toContain('FAIL_TOPIC_STYLE');
  });

  it('full live canary script covers blocker fallback topics', () => {
    const p = join(process.cwd(), 'scripts', 'smoke-practice-live-full.sh');
    const s = readFileSync(p, 'utf8');

    expect(s).toContain('"topic":"Magnetism"');
    expect(s).toContain('"topic":"Polynomials"');
    expect(s).toContain('"topic":"Relativity"');
    expect(s).toContain('"topic":"Set theory"');
    expect(s).toContain('practice-live-full-ok');
  });
});
