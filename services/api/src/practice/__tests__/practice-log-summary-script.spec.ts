import fs from 'node:fs';

describe('practice log summary script', () => {
  it('tracks fallback, reject, invalid set, and port collision signals', () => {
    const s = fs.readFileSync('scripts/practice-log-summary.sh', 'utf8');

    expect(s).toContain('verifier_fallback_using_local_valid');
    expect(s).toContain('reject_summary');
    expect(s).toContain('reject index=');
    expect(s).toContain('invalid question set');
    expect(s).toContain('EADDRINUSE');
  });
});
