import { Injectable, Logger } from '@nestjs/common';
import { Resend } from 'resend';

import { isRtl, MailLocale, mailCopy } from './mail-i18n';

/**
 * The one address people ever see or reach: every mail is sent from it and
 * replies land in it. Deliberately not configurable — support@ is the only
 * mailbox ClassMate runs.
 */
export const SUPPORT_EMAIL = 'support@classmateapp.org';
const FROM = `ClassMate <${SUPPORT_EMAIL}>`;

/**
 * Thin wrapper over the Resend HTTP API. The client is created lazily so the
 * service still boots in environments without RESEND_API_KEY (the call sites
 * detect this and degrade gracefully).
 */
@Injectable()
export class EmailService {
  private readonly logger = new Logger(EmailService.name);
  private _client: Resend | null = null;

  private get client(): Resend | null {
    if (this._client) return this._client;
    const key = process.env.RESEND_API_KEY?.trim();
    if (!key) return null;
    this._client = new Resend(key);
    return this._client;
  }

  /** True if Resend is configured. */
  get isConfigured(): boolean {
    return !!process.env.RESEND_API_KEY?.trim();
  }

  private async send(to: string, mail: RenderedMail): Promise<void> {
    await this.client!.emails.send({
      from: FROM,
      to,
      replyTo: SUPPORT_EMAIL,
      subject: mail.subject,
      html: mail.html,
      text: mail.text,
    });
  }

  async sendPasswordReset(args: {
    to: string;
    recipientName?: string | null;
    schoolName?: string | null;
    resetUrl: string;
    expiresInMinutes: number;
    /** The app the account belongs to; ClassNotes accounts reset here too. */
    product?: 'ClassMate' | 'ClassNotes';
    locale?: MailLocale;
  }): Promise<void> {
    if (!this.client) {
      this.logger.warn('Resend not configured; would have emailed a password reset link (recipient/link redacted)');
      return;
    }
    try {
      await this.send(args.to, passwordResetMail(args));
    } catch (err) {
      this.logger.error(`Failed to send reset email to ${args.to}: ${(err as Error).message}`);
      throw err;
    }
  }

  /**
   * Sent automatically after an admin directly changes a user's password.
   * Different copy from a self-initiated reset — leads with "your password
   * was changed by X" and offers a one-click link to set a new one yourself.
   */
  async sendPasswordChangedNotification(args: {
    to: string;
    recipientName?: string | null;
    schoolName?: string | null;
    byAdminName: string;
    resetUrl: string;
    expiresInMinutes: number;
    locale?: MailLocale;
  }): Promise<void> {
    if (!this.client) {
      this.logger.warn('Resend not configured; would have sent a password-change notification (recipient redacted)');
      return;
    }
    try {
      await this.send(args.to, passwordChangedMail(args));
    } catch (err) {
      this.logger.error(`Failed to send password-changed notice to ${args.to}: ${(err as Error).message}`);
      throw err;
    }
  }

  /**
   * Sends a short 6-digit verification code used by the email/phone verify
   * flow. The code leads the subject so it reads straight off the
   * notification. Returns false if Resend isn't configured so callers can
   * surface a "couldn't send" state.
   */
  async sendVerificationCode(args: {
    to: string;
    code: string;
    schoolName?: string | null;
    expiresInMinutes: number;
    locale?: MailLocale;
  }): Promise<boolean> {
    if (!this.client) {
      this.logger.warn('Resend not configured; would have emailed a verification code (recipient/code redacted)');
      return false;
    }
    try {
      await this.send(args.to, verificationCodeMail(args));
      return true;
    } catch (err) {
      this.logger.error(`Failed to send verify code to ${args.to}: ${(err as Error).message}`);
      return false;
    }
  }
}

// ── Templates ────────────────────────────────────────────────────────────────

export interface RenderedMail {
  subject: string;
  html: string;
  text: string;
}

const bold = (s: string) => `<strong>${escapeHtml(s)}</strong>`;
const plain = (s: string) => s;

export function passwordResetMail(args: {
  recipientName?: string | null;
  schoolName?: string | null;
  resetUrl: string;
  expiresInMinutes: number;
  product?: 'ClassMate' | 'ClassNotes';
  locale?: MailLocale;
}): RenderedMail {
  const locale = args.locale ?? 'en';
  const t = mailCopy(locale);
  const product = args.product ?? 'ClassMate';
  const account = args.schoolName ?? product;
  const greeting = t.hi(args.recipientName ?? null);
  const min = t.minutes(args.expiresInMinutes);
  return {
    subject: t.reset.subject(account),
    html: renderEmail(locale, {
      preheader: t.reset.preheader(min),
      eyebrow: account,
      title: t.reset.title,
      paragraphs: [
        escapeHtml(greeting),
        `${t.reset.intro(bold(account))} ${t.reset.useButton(bold, min)}`,
      ],
      button: { label: t.reset.button, url: args.resetUrl },
      note: t.reset.note,
    }),
    text: textEmail(locale, [greeting, t.reset.intro(account), t.reset.useLink(min), args.resetUrl, t.reset.note]),
  };
}

export function passwordChangedMail(args: {
  recipientName?: string | null;
  schoolName?: string | null;
  byAdminName: string;
  resetUrl: string;
  expiresInMinutes: number;
  locale?: MailLocale;
}): RenderedMail {
  const locale = args.locale ?? 'en';
  const t = mailCopy(locale);
  const account = args.schoolName ?? 'ClassMate';
  const greeting = t.hi(args.recipientName ?? null);
  const min = t.minutes(args.expiresInMinutes);
  return {
    subject: t.changed.subject(account),
    html: renderEmail(locale, {
      preheader: t.changed.preheader(args.byAdminName),
      eyebrow: account,
      title: t.changed.title,
      paragraphs: [
        escapeHtml(greeting),
        t.changed.who(bold(args.byAdminName), bold(account)),
        escapeHtml(t.changed.allSet),
        t.changed.useButton(bold, min),
      ],
      button: { label: t.changed.button, url: args.resetUrl },
    }),
    text: textEmail(locale, [
      greeting,
      t.changed.who(args.byAdminName, account),
      t.changed.allSet,
      t.changed.useLink(min),
      args.resetUrl,
    ]),
  };
}

export function verificationCodeMail(args: {
  code: string;
  schoolName?: string | null;
  expiresInMinutes: number;
  locale?: MailLocale;
}): RenderedMail {
  const locale = args.locale ?? 'en';
  const t = mailCopy(locale);
  const label = args.schoolName ?? 'ClassMate';
  const min = t.minutes(args.expiresInMinutes);
  return {
    subject: t.code.subject(args.code, label),
    html: renderEmail(locale, {
      preheader: t.code.preheader(args.code, min),
      eyebrow: label,
      title: t.code.title,
      paragraphs: [escapeHtml(t.code.enter)],
      code: args.code,
      after: t.code.after(bold, min),
      note: t.code.note,
    }),
    text: textEmail(locale, [t.code.textLine(label, args.code), t.code.textEnter(min), t.code.note]),
  };
}

// ── Layout ───────────────────────────────────────────────────────────────────

/**
 * Public URL the API is reachable at from the outside world. Brand images
 * are absolute links to /static (ServeStaticModule, assets/), since most
 * mail clients block embedded images.
 */
function emailBaseUrl(): string {
  const explicit = process.env.PUBLIC_APP_URL?.trim();
  if (explicit) return explicit.replace(/\/+$/, '');
  return 'https://pacific-enchantment-production-7a80.up.railway.app';
}

const FONT = "Inter,-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif";
const C = {
  paper: '#f3f5fb',
  card: '#ffffff',
  line: '#e3e8f4',
  ink: '#0e1630',
  body: '#2f3955',
  muted: '#5d6784',
  brand: '#0b2398',
  tint: '#eef2ff',
  tintLine: '#d5ddfb',
};

/**
 * Shared shell for every ClassMate email: app icon + name above a white
 * card, then a footer. Table layout and inline styles for Outlook/Gmail;
 * the <style> block only adds dark mode (Apple Mail, iOS Mail, Outlook.com)
 * and phone sizing on top. The header is the app icon plus live text, so it
 * stays legible when Gmail auto-inverts colours in dark mode.
 */
function renderEmail(
  locale: MailLocale,
  m: {
    preheader: string;
    eyebrow: string;
    title: string;
    paragraphs: string[];
    button?: { label: string; url: string };
    code?: string;
    after?: string;
    note?: string;
  },
): string {
  const t = mailCopy(locale);
  const base = emailBaseUrl();
  const rtl = isRtl(locale);
  const dir = rtl ? 'rtl' : 'ltr';
  const align = rtl ? 'right' : 'left';
  const end = rtl ? 'left' : 'right';
  // Letter-spacing pulls Arabic letters apart (and does nothing for Hebrew),
  // so the tracked eyebrow/title only stay tracked in Latin/Cyrillic.
  const track = (px: string) => (rtl ? '0' : px);
  const p = (html: string) =>
    `<p class="body" style="margin:0 0 14px;font:400 15.5px/1.6 ${FONT};color:${C.body};text-align:${align}">${html}</p>`;

  const button = m.button
    ? `<table role="presentation" cellpadding="0" cellspacing="0" border="0" style="margin:10px 0 6px">
        <tr><td class="btn" bgcolor="${C.brand}" style="border-radius:12px;background:${C.brand}">
          <a class="btn-a" href="${escapeAttr(m.button.url)}" target="_blank" style="display:inline-block;padding:14px 26px;font:700 15px/1 ${FONT};color:#ffffff;text-decoration:none;border-radius:12px">${escapeHtml(m.button.label)}</a>
        </td></tr>
      </table>
      <p class="muted" style="margin:18px 0 0;font:400 12.5px/1.55 ${FONT};color:${C.muted};text-align:${align}">${escapeHtml(t.buttonFallback)}<br>
        <a class="link" dir="ltr" href="${escapeAttr(m.button.url)}" style="color:${C.brand};word-break:break-all">${escapeHtml(m.button.url)}</a></p>`
    : '';

  const code = m.code
    ? `<table role="presentation" cellpadding="0" cellspacing="0" border="0" width="100%" style="margin:6px 0 18px">
        <tr><td class="code" align="center" dir="ltr" style="background:${C.tint};border:1px solid ${C.tintLine};border-radius:16px;padding:22px 12px">
          <span class="code-t" style="font:800 34px/1 'SF Mono',ui-monospace,Menlo,Consolas,monospace;letter-spacing:10px;color:${C.brand};padding-left:10px">${escapeHtml(m.code)}</span>
        </td></tr>
      </table>`
    : '';

  const note = m.note
    ? `<tr><td class="rule" style="border-top:1px solid ${C.line};padding:18px 0 0">
        <p class="muted" style="margin:0;font:400 13px/1.55 ${FONT};color:${C.muted};text-align:${align}">${escapeHtml(m.note)}</p>
      </td></tr>`
    : '';

  return `<!DOCTYPE html>
<html lang="${locale}" dir="${dir}" xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="x-apple-disable-message-reformatting">
<meta name="color-scheme" content="light dark">
<meta name="supported-color-schemes" content="light dark">
<title>${escapeHtml(m.title)}</title>
<style>
  :root { color-scheme: light dark; supported-color-schemes: light dark; }
  @media (max-width: 600px) {
    .card { padding: 28px 22px 24px !important; border-radius: 18px !important; }
    .title { font-size: 23px !important; }
    .code-t { font-size: 30px !important; letter-spacing: 8px !important; }
  }
  @media (prefers-color-scheme: dark) {
    .bg { background: #080d1e !important; }
    .card { background: #0f172e !important; border-color: #1f2a48 !important; }
    .ink, .title { color: #edf1fc !important; }
    .body { color: #c3cbe0 !important; }
    .muted { color: #8e99b8 !important; }
    .link { color: #93bfff !important; }
    .rule { border-color: #1f2a48 !important; }
    .btn { background: #83b5fe !important; }
    .btn-a { color: #071447 !important; }
    .code { background: #121f45 !important; border-color: #24366c !important; }
    .code-t { color: #93bfff !important; }
  }
</style>
</head>
<body class="bg" dir="${dir}" style="margin:0;padding:0;background:${C.paper};-webkit-text-size-adjust:100%">
<div style="display:none;max-height:0;overflow:hidden;opacity:0;mso-hide:all">${escapeHtml(m.preheader)}&#8199;&#65279;&#847;&#8199;&#65279;&#847;&#8199;&#65279;&#847;&#8199;&#65279;&#847;</div>
<table role="presentation" class="bg" dir="${dir}" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:${C.paper}">
  <tr><td align="center" style="padding:36px 14px 28px">
    <table role="presentation" dir="${dir}" width="100%" cellpadding="0" cellspacing="0" border="0" style="max-width:560px">
      <tr><td align="${align}" style="padding:0 6px 18px">
        <table role="presentation" dir="${dir}" cellpadding="0" cellspacing="0" border="0"><tr>
          <td style="padding-${end}:10px"><img src="${base}/static/brand/app-icon.png" width="36" height="36" alt="" style="display:block;border:0;border-radius:9px"></td>
          <td class="ink" dir="ltr" style="font:800 19px/1 ${FONT};letter-spacing:-0.2px;color:${C.ink}">ClassMate</td>
        </tr></table>
      </td></tr>
      <tr><td class="card" style="background:${C.card};border:1px solid ${C.line};border-radius:22px;padding:36px 36px 30px">
        <table role="presentation" dir="${dir}" width="100%" cellpadding="0" cellspacing="0" border="0">
          <tr><td align="${align}" style="text-align:${align}">
            <p class="muted" style="margin:0 0 10px;font:700 11.5px/1.3 ${FONT};letter-spacing:${track('1.4px')};text-transform:uppercase;color:${C.muted};text-align:${align}">${escapeHtml(m.eyebrow)}</p>
            <h1 class="title" style="margin:0 0 18px;font:800 26px/1.2 ${FONT};letter-spacing:${track('-0.5px')};color:${C.ink};text-align:${align}">${escapeHtml(m.title)}</h1>
            ${m.paragraphs.map(p).join('\n            ')}
            ${code}
            ${m.after ? p(m.after) : ''}
            ${button}
          </td></tr>
          ${note ? `<tr><td style="height:20px;line-height:20px;font-size:0">&nbsp;</td></tr>${note}` : ''}
        </table>
      </td></tr>
      <tr><td align="${align}" style="padding:22px 6px 0;text-align:${align}">
        <p class="muted" style="margin:0 0 6px;font:400 13px/1.6 ${FONT};color:${C.muted}">${escapeHtml(t.questions)} <a class="link" dir="ltr" href="mailto:${SUPPORT_EMAIL}" style="color:${C.brand};text-decoration:none">${SUPPORT_EMAIL}</a>.</p>
        <p class="muted" style="margin:0;font:400 12px/1.6 ${FONT};color:${C.muted}">ClassMate · ${escapeHtml(t.tagline)} ·
          <a class="link" href="https://tony11-dot.github.io/classmate-legal/privacy.html" style="color:${C.muted}">${escapeHtml(t.privacy)}</a> ·
          <a class="link" href="https://tony11-dot.github.io/classmate-legal/terms.html" style="color:${C.muted}">${escapeHtml(t.terms)}</a></p>
      </td></tr>
    </table>
  </td></tr>
</table>
</body>
</html>`;
}

/** Plain-text twin of every mail, with the same sign-off. */
function textEmail(locale: MailLocale, lines: string[]): string {
  const t = mailCopy(locale);
  return [
    ...lines.flatMap((l) => [l, '']),
    `${t.questions} ${SUPPORT_EMAIL}.`,
    `ClassMate · ${t.tagline}`,
  ].join('\n');
}

function escapeHtml(s: string): string {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function escapeAttr(s: string): string {
  return escapeHtml(s);
}
