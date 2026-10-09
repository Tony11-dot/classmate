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

  it('opens on the form for a live link', () => {
    const html = buildResetPage('t', { state: 'ok' });
    expect(html).toContain('<div class="card" id="card">');
    expect(html).toContain('autofocus');
  });

  it('says a dead link is dead before any typing', () => {
    const html = buildResetPage('t', { state: 'expired' });
    expect(html).toContain('<div class="card is-problem" id="card">');
    expect(html).toContain('<h1 id="pTitle">This link has expired</h1>');
    expect(html).toContain('#/forgot-password');
    expect(html).not.toContain('autofocus');
  });

  it('treats a link without a token as broken', () => {
    expect(buildResetPage('', { state: 'ok' })).toContain('is-problem');
  });

  it('speaks Hebrew right to left', () => {
    const html = buildResetPage('t', { locale: 'he' });
    expect(html).toContain('<html lang="he" dir="rtl">');
    expect(html).toContain('בחירת סיסמה חדשה');
  });

  it('keeps every script string from closing the script tag', () => {
    const script = buildResetPage('t', { locale: 'ar' }).split('<script>')[1].split('</script>')[0];
    expect(script).not.toMatch(/<\/|<!--/);
  });
});
