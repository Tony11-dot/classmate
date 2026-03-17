import fs from 'node:fs';

describe('practice golden smoke script', () => {
  it('runs clean restart, blocker smoke, live full canary, deterministic regression, and log summary', () => {
    const s = fs.readFileSync('scripts/smoke-practice-golden.sh', 'utf8');

    expect(s).toContain('./scripts/restart-api-clean.sh');
    expect(s).toContain('./scripts/smoke-practice-blockers.sh');
    expect(s).toContain('./scripts/smoke-practice-live-full.sh');
    expect(s).toContain('./scripts/smoke-practice-all-deterministic.sh');
    expect(s).toContain('./scripts/practice-log-summary.sh');
    expect(s).toContain('FAIL_EADDRINUSE');
    expect(s).toContain('practice-golden-ok');
  });
});
