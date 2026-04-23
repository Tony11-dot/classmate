import fs from 'node:fs';

describe('practice log summary script', () => {
  it('tracks fallback, reject, invalid set, and port collision signals', () => {
    const s = fs.readFileSync('scripts/practice-log-summary.sh', 'utf8');

    expect(s).toContain('generation_strict_local_fallback');
    expect(s).toContain('generation_topic_first_fallback');
    expect(s).toContain('reject_summary');
    expect(s).toContain('reject index=');
    expect(s).toContain('topic_drift');
    expect(s).toContain('topic_anchor_missing_from_body');
    expect(s).toContain('missing_topic_match_note');
    expect(s).toContain('difficulty_too_easy_for_hard');
    expect(s).toContain('invalid question set');
    expect(s).toContain('generation_failed');
    expect(s).toContain('EADDRINUSE');
  });
});
