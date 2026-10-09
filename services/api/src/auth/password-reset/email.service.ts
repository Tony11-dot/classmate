import { Injectable, Logger } from '@nestjs/common';
import { Resend } from 'resend';

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

export function passwordResetMail(args: {
  recipientName?: string | null;
  schoolName?: string | null;
  resetUrl: string;
  expiresInMinutes: number;
  product?: 'ClassMate' | 'ClassNotes';
}): RenderedMail {
  const product = args.product ?? 'ClassMate';
  const account = args.schoolName ?? product;
  const greeting = args.recipientName ? `Hi ${args.recipientName},` : 'Hi,';
  return {
    subject: `Reset your ${account} password`,
    html: renderEmail({
      preheader: `Choose a new password. The link works for ${args.expiresInMinutes} minutes.`,
      eyebrow: account,
      title: 'Reset your password',
      paragraphs: [
        escapeHtml(greeting),
        `We received a request to reset the password on your <strong>${escapeHtml(account)}</strong> account. ` +
          `Use the button below to choose a new one. It works for the next <strong>${args.expiresInMinutes} minutes</strong>, once.`,
      ],
      button: { label: 'Choose a new password', url: args.resetUrl },
      note: "Didn't ask for this? Ignore this email. Your password stays the same.",
    }),
    text: textEmail([
      greeting,
      `We received a request to reset the password on your ${account} account.`,
      `Open this link to choose a new one. It works for the next ${args.expiresInMinutes} minutes, once:`,
      args.resetUrl,
      "Didn't ask for this? Ignore this email. Your password stays the same.",
    ]),
  };
}

export function passwordChangedMail(args: {
  recipientName?: string | null;
  schoolName?: string | null;
  byAdminName: string;
  resetUrl: string;
  expiresInMinutes: number;
}): RenderedMail {
  const account = args.schoolName ?? 'ClassMate';
  const greeting = args.recipientName ? `Hi ${args.recipientName},` : 'Hi,';
  return {
    subject: `Your ${account} password was changed`,
    html: renderEmail({
      preheader: `${args.byAdminName} changed your password. Not expecting it? Set your own.`,
      eyebrow: account,
      title: 'Your password was changed',
      paragraphs: [
        escapeHtml(greeting),
        `<strong>${escapeHtml(args.byAdminName)}</strong>, an administrator at <strong>${escapeHtml(account)}</strong>, just changed your password.`,
        'If you asked them to, you’re all set. Sign in with the new password they gave you.',
        `<strong>Wasn’t expecting this,</strong> or want to pick your own? Use the button below within the next <strong>${args.expiresInMinutes} minutes</strong>.`,
      ],
      button: { label: 'Set my own password', url: args.resetUrl },
    }),
    text: textEmail([
      greeting,
      `${args.byAdminName}, an administrator at ${account}, just changed your password.`,
      "If you asked them to, you're all set. Sign in with the new password they gave you.",
      `Wasn't expecting this, or want to pick your own? Use this link within the next ${args.expiresInMinutes} minutes:`,
      args.resetUrl,
    ]),
  };
}

export function verificationCodeMail(args: {
  code: string;
  schoolName?: string | null;
  expiresInMinutes: number;
}): RenderedMail {
  const label = args.schoolName ?? 'ClassMate';
  return {
    subject: `${args.code} is your ${label} verification code`,
    html: renderEmail({
      preheader: `Your code is ${args.code}. It expires in ${args.expiresInMinutes} minutes.`,
      eyebrow: label,
      title: 'Your verification code',
      paragraphs: ['Enter this code in the app to confirm it’s you.'],
      code: args.code,
      after: `It expires in <strong>${args.expiresInMinutes} minutes</strong>. Asked for more than one? Any of your last three codes works.`,
      note: "Didn't ask for a code? Ignore this email. Nothing changes until the code is entered.",
    }),
    text: textEmail([
      `Your ${label} verification code is: ${args.code}`,
      `Enter it in the app. It expires in ${args.expiresInMinutes} minutes.`,
      "Didn't ask for a code? Ignore this email. Nothing changes until the code is entered.",
    ]),
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
function renderEmail(m: {
  preheader: string;
  eyebrow: string;
  title: string;
  paragraphs: string[];
  button?: { label: string; url: string };
  code?: string;
  after?: string;
  note?: string;
}): string {
  const base = emailBaseUrl();
  const p = (html: string) =>
    `<p class="body" style="margin:0 0 14px;font:400 15.5px/1.6 ${FONT};color:${C.body}">${html}</p>`;

  const button = m.button
    ? `<table role="presentation" cellpadding="0" cellspacing="0" border="0" style="margin:10px 0 6px">
        <tr><td class="btn" bgcolor="${C.brand}" style="border-radius:12px;background:${C.brand}">
          <a class="btn-a" href="${escapeAttr(m.button.url)}" target="_blank" style="display:inline-block;padding:14px 26px;font:700 15px/1 ${FONT};color:#ffffff;text-decoration:none;border-radius:12px">${escapeHtml(m.button.label)}</a>
        </td></tr>
      </table>
      <p class="muted" style="margin:18px 0 0;font:400 12.5px/1.55 ${FONT};color:${C.muted}">Button not working? Copy this link into your browser:<br>
        <a class="link" href="${escapeAttr(m.button.url)}" style="color:${C.brand};word-break:break-all">${escapeHtml(m.button.url)}</a></p>`
    : '';

  const code = m.code
    ? `<table role="presentation" cellpadding="0" cellspacing="0" border="0" width="100%" style="margin:6px 0 18px">
        <tr><td class="code" align="center" style="background:${C.tint};border:1px solid ${C.tintLine};border-radius:16px;padding:22px 12px">
          <span class="code-t" style="font:800 34px/1 'SF Mono',ui-monospace,Menlo,Consolas,monospace;letter-spacing:10px;color:${C.brand};padding-left:10px">${escapeHtml(m.code)}</span>
        </td></tr>
      </table>`
    : '';

  const note = m.note
    ? `<tr><td class="rule" style="border-top:1px solid ${C.line};padding:18px 0 0">
        <p class="muted" style="margin:0;font:400 13px/1.55 ${FONT};color:${C.muted}">${escapeHtml(m.note)}</p>
      </td></tr>`
    : '';

  return `<!DOCTYPE html>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
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
<body class="bg" style="margin:0;padding:0;background:${C.paper};-webkit-text-size-adjust:100%">
<div style="display:none;max-height:0;overflow:hidden;opacity:0;mso-hide:all">${escapeHtml(m.preheader)}&#8199;&#65279;&#847;&#8199;&#65279;&#847;&#8199;&#65279;&#847;&#8199;&#65279;&#847;</div>
<table role="presentation" class="bg" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:${C.paper}">
  <tr><td align="center" style="padding:36px 14px 28px">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="max-width:560px">
      <tr><td style="padding:0 6px 18px">
        <table role="presentation" cellpadding="0" cellspacing="0" border="0"><tr>
          <td style="padding-right:10px"><img src="${base}/static/brand/app-icon.png" width="36" height="36" alt="" style="display:block;border:0;border-radius:9px"></td>
          <td class="ink" style="font:800 19px/1 ${FONT};letter-spacing:-0.2px;color:${C.ink}">ClassMate</td>
        </tr></table>
      </td></tr>
      <tr><td class="card" style="background:${C.card};border:1px solid ${C.line};border-radius:22px;padding:36px 36px 30px">
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
          <tr><td>
            <p class="muted" style="margin:0 0 10px;font:700 11.5px/1.3 ${FONT};letter-spacing:1.4px;text-transform:uppercase;color:${C.muted}">${escapeHtml(m.eyebrow)}</p>
            <h1 class="title" style="margin:0 0 18px;font:800 26px/1.2 ${FONT};letter-spacing:-0.5px;color:${C.ink}">${escapeHtml(m.title)}</h1>
            ${m.paragraphs.map(p).join('\n            ')}
            ${code}
            ${m.after ? p(m.after) : ''}
            ${button}
          </td></tr>
          ${note ? `<tr><td style="height:20px;line-height:20px;font-size:0">&nbsp;</td></tr>${note}` : ''}
        </table>
      </td></tr>
      <tr><td style="padding:22px 6px 0">
        <p class="muted" style="margin:0 0 6px;font:400 13px/1.6 ${FONT};color:${C.muted}">Questions? Reply to this email or write to <a class="link" href="mailto:${SUPPORT_EMAIL}" style="color:${C.brand};text-decoration:none">${SUPPORT_EMAIL}</a>.</p>
        <p class="muted" style="margin:0;font:400 12px/1.6 ${FONT};color:${C.muted}">ClassMate · One app. Your whole school. ·
          <a class="link" href="https://tony11-dot.github.io/classmate-legal/privacy.html" style="color:${C.muted}">Privacy</a> ·
          <a class="link" href="https://tony11-dot.github.io/classmate-legal/terms.html" style="color:${C.muted}">Terms</a></p>
      </td></tr>
    </table>
  </td></tr>
</table>
</body>
</html>`;
}

/** Plain-text twin of every mail, with the same sign-off. */
function textEmail(lines: string[]): string {
  return [
    ...lines.flatMap((l) => [l, '']),
    `Questions? Reply to this email or write to ${SUPPORT_EMAIL}.`,
    'ClassMate · One app. Your whole school.',
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
