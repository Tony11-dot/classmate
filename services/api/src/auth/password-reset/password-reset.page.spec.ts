import { buildResetPage } from './password-reset.controller';

describe('reset password page', () => {
  it('embeds a normal token', () => {
    expect(buildResetPage('Qm9y1xS6s-Jp2_VZk3')).toContain('const token = "Qm9y1xS6s-Jp2_VZk3";');
  });

  it('cannot be used to inject script through the token', () => {
    const html = buildResetPage('abc</script><script>alert(1)</script>');
    expect(html).not.toContain('<script>alert(1)');
    expect(html).toContain('const token = "abcscriptscriptalert1script";');
  });

  it('shows the new brand and the support address', () => {
    const html = buildResetPage('t');
    expect(html).toContain('/static/brand/wordmark.png');
    expect(html).toContain('support@classmateapp.org');
  });
});
