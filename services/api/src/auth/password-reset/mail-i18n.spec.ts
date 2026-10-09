import { passwordChangedMail, passwordResetMail, verificationCodeMail } from './email.service';
import { localeFromAcceptLanguage, mailCopy, mailLocale } from './mail-i18n';

describe('mail language', () => {
  it('picks the first supported language', () => {
    expect(mailLocale(null, 'he')).toBe('he');
    expect(mailLocale('ps', 'ar')).toBe('ar'); // Pashto is a pseudo locale in the app
    expect(mailLocale('de', undefined)).toBe('en');
    expect(mailLocale('fr-CA')).toBe('fr');
  });

  it('reads Accept-Language in the browser order', () => {
    expect(localeFromAcceptLanguage('he-IL,he;q=0.9,en-US;q=0.8')).toBe('he');
    expect(localeFromAcceptLanguage('de-DE,de;q=0.9,ru;q=0.5')).toBe('ru');
    expect(localeFromAcceptLanguage('en;q=0.2, ar;q=0.8')).toBe('ar');
    expect(localeFromAcceptLanguage('de')).toBeNull();
    expect(localeFromAcceptLanguage(undefined)).toBeNull();
  });

  it('counts minutes the way each language does', () => {
    const ru = mailCopy('ru').minutes;
    expect([1, 3, 12, 15, 21, 60].map(ru)).toEqual(['1 минуту', '3 минуты', '12 минут', '15 минут', '21 минуту', '60 минут']);
    const ar = mailCopy('ar').minutes;
    expect([1, 2, 10, 15, 60].map(ar)).toEqual(['دقيقة واحدة', 'دقيقتين', '10 دقائق', '15 دقيقة', '60 دقيقة']);
    expect(mailCopy('he').minutes(60)).toBe('60 דקות');
  });
});

describe('account emails', () => {
  const reset = {
    recipientName: 'Dana',
    schoolName: 'Herzliya High',
    resetUrl: 'https://x.test/reset-password?token=abc&lang=he',
    expiresInMinutes: 60,
  };

  it('keeps the English email as it was', () => {
    const m = passwordResetMail(reset);
    expect(m.subject).toBe('Reset your Herzliya High password');
    expect(m.html).toContain('<html lang="en" dir="ltr"');
    expect(m.text).toContain('Questions? Reply to this email or write to support@classmateapp.org.');
  });

  it('writes Hebrew right to left, with the link and code left to right', () => {
    const m = passwordResetMail({ ...reset, locale: 'he' });
    expect(m.subject).toBe('איפוס הסיסמה לחשבון Herzliya High');
    expect(m.html).toContain('<html lang="he" dir="rtl"');
    expect(m.html).toContain('text-align:right');
    expect(m.html).toContain('<a class="link" dir="ltr" href="https://x.test/reset-password?token=abc&amp;lang=he"');
    expect(m.text).toContain('שלום Dana,');
  });

  it('does not track Arabic letters apart', () => {
    const m = verificationCodeMail({ code: '482913', expiresInMinutes: 15, locale: 'ar' });
    expect(m.subject.startsWith('482913 ')).toBe(true);
    expect(m.html).toContain('letter-spacing:0;text-transform:uppercase');
    expect(m.html).toContain('class="code" align="center" dir="ltr"');
  });

  it('escapes the admin name in every language', () => {
    for (const locale of ['en', 'he', 'ar', 'fr', 'ru'] as const) {
      const m = passwordChangedMail({ ...reset, byAdminName: '<b>Eve</b>', locale });
      expect(m.html).not.toContain('<b>Eve</b>');
      expect(m.html).toContain('&lt;b&gt;Eve&lt;/b&gt;');
    }
  });
});
