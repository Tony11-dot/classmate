import { Injectable, Logger } from '@nestjs/common';
import { Resend } from 'resend';

import { LOGO_DATA_URI } from '../../setup/logo';

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

  /** Visible "From" address. Defaults to Resend's sandbox sender. */
  private get fromAddress(): string {
    return process.env.RESEND_FROM_EMAIL?.trim() || 'ClassMate <onboarding@resend.dev>';
  }

  private get replyTo(): string {
    return process.env.RESEND_REPLY_TO?.trim() || 'aboudtony22@gmail.com';
  }

  /** True if Resend is configured. */
  get isConfigured(): boolean {
    return !!process.env.RESEND_API_KEY?.trim();
  }

  async sendPasswordReset(args: {
    to: string;
    recipientName?: string | null;
    schoolName?: string | null;
    resetUrl: string;
    expiresInMinutes: number;
  }): Promise<void> {
    if (!this.client) {
      this.logger.warn(`Resend not configured; would have emailed ${args.to} with reset link ${args.resetUrl}`);
      return;
    }
    const html = buildResetEmailHtml(args);
    const text = buildResetEmailText(args);
    const subject = args.schoolName
      ? `Reset your ${args.schoolName} password`
      : 'Reset your ClassMate password';

    try {
      await this.client.emails.send({
        from: this.fromAddress,
        to: args.to,
        replyTo: this.replyTo,
        subject,
        html,
        text,
      });
    } catch (err) {
      this.logger.error(`Failed to send reset email to ${args.to}: ${(err as Error).message}`);
      throw err;
    }
  }

  /**
   * Notifies an admin that a user wants a password change. No reset link —
   * the admin is expected to open the admin app and approve/reject there.
   */
  async sendPasswordChangeRequestToAdmin(args: {
    to: string;
    adminName: string;
    requesterName: string;
    requesterIdentifier: string;
    schoolName?: string | null;
  }): Promise<void> {
    if (!this.client) {
      this.logger.warn(`Resend not configured; would have notified admin ${args.to} of password request from ${args.requesterName}`);
      return;
    }
    const subject = args.schoolName
      ? `${args.schoolName}: ${args.requesterName} wants a password reset`
      : `${args.requesterName} wants a password reset`;
    try {
      await this.client.emails.send({
        from: this.fromAddress,
        to: args.to,
        replyTo: this.replyTo,
        subject,
        html: buildPasswordRequestAdminHtml(args),
        text: buildPasswordRequestAdminText(args),
      });
    } catch (err) {
      this.logger.error(`Failed to send admin-request notice to ${args.to}: ${(err as Error).message}`);
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
      this.logger.warn(`Resend not configured; would have notified ${args.to} of password change by ${args.byAdminName}`);
      return;
    }
    const html = buildPasswordChangedHtml(args);
    const text = buildPasswordChangedText(args);
    const subject = args.schoolName
      ? `Your ${args.schoolName} password was changed`
      : 'Your ClassMate password was changed';

    try {
      await this.client.emails.send({
        from: this.fromAddress,
        to: args.to,
        replyTo: this.replyTo,
        subject,
        html,
        text,
      });
    } catch (err) {
      this.logger.error(`Failed to send password-changed notice to ${args.to}: ${(err as Error).message}`);
      throw err;
    }
  }
}

function buildResetEmailText(args: { recipientName?: string | null; schoolName?: string | null; resetUrl: string; expiresInMinutes: number }): string {
  const greeting = args.recipientName ? `Hi ${args.recipientName},` : 'Hi,';
  return [
    'ClassMate — One app. Your whole school.',
    '',
    greeting,
    '',
    `We received a request to reset the password on your ${args.schoolName ?? 'ClassMate'} account.`,
    'Tap the link below to set a new one. The link is good for the next ' +
      `${args.expiresInMinutes} minutes and can only be used once.`,
    '',
    args.resetUrl,
    '',
    "If you didn't request this, you can ignore this email — your password won't change.",
    '',
    'Tony Aboud',
    'Founder, ClassMate',
  ].join('\n');
}

function buildResetEmailHtml(args: { recipientName?: string | null; schoolName?: string | null; resetUrl: string; expiresInMinutes: number }): string {
  const greeting = args.recipientName ? `Hi ${args.recipientName},` : 'Hi,';
  const schoolLabel = args.schoolName ?? 'ClassMate';

  // Inline CSS — most email clients strip <style> tags.
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>Reset your ${escapeHtml(schoolLabel)} password</title>
</head>
<body style="margin:0; padding:0; background:#f4f5f9; font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Arial,sans-serif; color:#1a1a2e;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background:#f4f5f9;">
    <tr><td align="center" style="padding:40px 16px;">
      <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="max-width:520px; background:#ffffff; border-radius:20px; box-shadow:0 4px 18px rgba(0,0,0,0.04); overflow:hidden;">

        <!-- Header w/ logo + tagline -->
        <tr><td align="center" style="padding:40px 24px 28px; background:linear-gradient(135deg,#1a1a2e 0%,#2563eb 100%);">
          <img src="${LOGO_DATA_URI}" alt="ClassMate" width="180" style="display:block; max-width:60%; height:auto; filter:brightness(0) invert(1);">
          <p style="margin:14px 0 0; font-size:13px; font-weight:500; color:rgba(255,255,255,0.78); letter-spacing:.3px;">One app. Your whole school.</p>
        </td></tr>

        <!-- Body -->
        <tr><td style="padding:32px 32px 8px;">
          <h1 style="margin:0 0 8px; font-size:22px; font-weight:800; color:#1a1a2e;">Reset your password</h1>
          <p style="margin:0 0 4px; font-size:13px; color:#6868a0; text-transform:uppercase; letter-spacing:.5px; font-weight:700;">${escapeHtml(schoolLabel)}</p>
        </td></tr>

        <tr><td style="padding:16px 32px 24px; font-size:15px; line-height:1.6; color:#333;">
          <p style="margin:0 0 14px;">${escapeHtml(greeting)}</p>
          <p style="margin:0 0 14px;">
            We received a request to reset the password on your <strong>${escapeHtml(schoolLabel)}</strong> account.
            Tap the button below to choose a new one. The link is good for the next
            <strong>${args.expiresInMinutes} minutes</strong> and can only be used once.
          </p>
        </td></tr>

        <!-- CTA Button -->
        <tr><td align="center" style="padding:8px 32px 32px;">
          <a href="${args.resetUrl}"
             style="display:inline-block; padding:14px 32px; background:#2563eb; color:#ffffff; text-decoration:none; border-radius:12px; font-weight:700; font-size:15px; letter-spacing:.2px;">
            Set new password
          </a>
        </td></tr>

        <!-- Plain link fallback -->
        <tr><td style="padding:0 32px 24px; font-size:12px; color:#888; line-height:1.5;">
          <p style="margin:0 0 6px;">Or copy and paste this link into your browser:</p>
          <p style="margin:0; word-break:break-all;"><a href="${args.resetUrl}" style="color:#2563eb; text-decoration:underline;">${args.resetUrl}</a></p>
        </td></tr>

        <!-- Safety note -->
        <tr><td style="padding:0 32px 32px; font-size:13px; color:#666; line-height:1.5;">
          <p style="margin:0;">If you didn't request this, you can safely ignore this email — your password won't change.</p>
        </td></tr>

        <!-- Signature footer -->
        <tr><td style="padding:22px 32px 28px; border-top:1px solid #eee;">
          <p style="margin:0 0 4px; font-size:14px; font-weight:700; color:#1a1a2e;">Tony Aboud</p>
          <p style="margin:0; font-size:12px; color:#888;">Founder, ClassMate</p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;
}

function escapeHtml(s: string): string {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function buildPasswordRequestAdminText(args: {
  adminName: string; requesterName: string; requesterIdentifier: string;
  schoolName?: string | null;
}): string {
  return [
    'ClassMate — One app. Your whole school.',
    '',
    `Hi ${args.adminName},`,
    '',
    `${args.requesterName}${args.requesterIdentifier ? ` (${args.requesterIdentifier})` : ''} has requested a password reset on their ${args.schoolName ?? 'ClassMate'} account.`,
    '',
    'They picked you to approve it. Open the admin app, head to Password Requests, and approve (or reject) the request. The password they want is hidden from you — you just approve the change.',
    '',
    'The request expires in 24 hours.',
    '',
    'Tony Aboud',
    'Founder, ClassMate',
  ].join('\n');
}

function buildPasswordRequestAdminHtml(args: {
  adminName: string; requesterName: string; requesterIdentifier: string;
  schoolName?: string | null;
}): string {
  const schoolLabel = args.schoolName ?? 'ClassMate';
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>${escapeHtml(args.requesterName)} wants a password reset</title>
</head>
<body style="margin:0; padding:0; background:#f4f5f9; font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Arial,sans-serif; color:#1a1a2e;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background:#f4f5f9;">
    <tr><td align="center" style="padding:40px 16px;">
      <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="max-width:520px; background:#ffffff; border-radius:20px; box-shadow:0 4px 18px rgba(0,0,0,0.04); overflow:hidden;">

        <tr><td align="center" style="padding:40px 24px 28px; background:linear-gradient(135deg,#1a1a2e 0%,#2563eb 100%);">
          <img src="${LOGO_DATA_URI}" alt="ClassMate" width="180" style="display:block; max-width:60%; height:auto; filter:brightness(0) invert(1);">
          <p style="margin:14px 0 0; font-size:13px; font-weight:500; color:rgba(255,255,255,0.78); letter-spacing:.3px;">One app. Your whole school.</p>
        </td></tr>

        <tr><td style="padding:32px 32px 8px;">
          <h1 style="margin:0 0 8px; font-size:22px; font-weight:800; color:#1a1a2e;">Password reset request</h1>
          <p style="margin:0 0 4px; font-size:13px; color:#6868a0; text-transform:uppercase; letter-spacing:.5px; font-weight:700;">${escapeHtml(schoolLabel)}</p>
        </td></tr>

        <tr><td style="padding:16px 32px 24px; font-size:15px; line-height:1.6; color:#333;">
          <p style="margin:0 0 14px;">Hi ${escapeHtml(args.adminName)},</p>
          <p style="margin:0 0 14px;">
            <strong>${escapeHtml(args.requesterName)}</strong>${args.requesterIdentifier ? ` <span style="color:#888;">(${escapeHtml(args.requesterIdentifier)})</span>` : ''} has requested a password reset on their <strong>${escapeHtml(schoolLabel)}</strong> account.
          </p>
          <p style="margin:0 0 14px;">
            They picked you to approve it. Open the admin app and head to <strong>Password Requests</strong> to approve or reject. The new password they typed is hidden from you — you just authorize the change.
          </p>
          <p style="margin:0 0 14px; color:#888; font-size:13px;">
            The request expires in 24 hours.
          </p>
        </td></tr>

        <tr><td style="padding:22px 32px 28px; border-top:1px solid #eee;">
          <p style="margin:0 0 4px; font-size:14px; font-weight:700; color:#1a1a2e;">Tony Aboud</p>
          <p style="margin:0; font-size:12px; color:#888;">Founder, ClassMate</p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;
}

function buildPasswordChangedText(args: {
  recipientName?: string | null; schoolName?: string | null; byAdminName: string;
  resetUrl: string; expiresInMinutes: number;
}): string {
  const greeting = args.recipientName ? `Hi ${args.recipientName},` : 'Hi,';
  return [
    'ClassMate — One app. Your whole school.',
    '',
    greeting,
    '',
    `Heads up — your ${args.schoolName ?? 'ClassMate'} password was just changed by ${args.byAdminName}, an administrator on your account.`,
    '',
    'If you asked them to do this, you can ignore this email — sign in with the new password they gave you.',
    '',
    `If this wasn't you, or you want to pick a different password, use the link below within the next ${args.expiresInMinutes} minutes:`,
    '',
    args.resetUrl,
    '',
    'Tony Aboud',
    'Founder, ClassMate',
  ].join('\n');
}

function buildPasswordChangedHtml(args: {
  recipientName?: string | null; schoolName?: string | null; byAdminName: string;
  resetUrl: string; expiresInMinutes: number;
}): string {
  const greeting = args.recipientName ? `Hi ${args.recipientName},` : 'Hi,';
  const schoolLabel = args.schoolName ?? 'ClassMate';

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>Your ${escapeHtml(schoolLabel)} password was changed</title>
</head>
<body style="margin:0; padding:0; background:#f4f5f9; font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Arial,sans-serif; color:#1a1a2e;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background:#f4f5f9;">
    <tr><td align="center" style="padding:40px 16px;">
      <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="max-width:520px; background:#ffffff; border-radius:20px; box-shadow:0 4px 18px rgba(0,0,0,0.04); overflow:hidden;">

        <tr><td align="center" style="padding:40px 24px 28px; background:linear-gradient(135deg,#1a1a2e 0%,#2563eb 100%);">
          <img src="${LOGO_DATA_URI}" alt="ClassMate" width="180" style="display:block; max-width:60%; height:auto; filter:brightness(0) invert(1);">
          <p style="margin:14px 0 0; font-size:13px; font-weight:500; color:rgba(255,255,255,0.78); letter-spacing:.3px;">One app. Your whole school.</p>
        </td></tr>

        <tr><td style="padding:32px 32px 8px;">
          <h1 style="margin:0 0 8px; font-size:22px; font-weight:800; color:#1a1a2e;">Your password was changed</h1>
          <p style="margin:0 0 4px; font-size:13px; color:#6868a0; text-transform:uppercase; letter-spacing:.5px; font-weight:700;">${escapeHtml(schoolLabel)}</p>
        </td></tr>

        <tr><td style="padding:16px 32px 12px; font-size:15px; line-height:1.6; color:#333;">
          <p style="margin:0 0 14px;">${escapeHtml(greeting)}</p>
          <p style="margin:0 0 14px;">
            Heads up — your <strong>${escapeHtml(schoolLabel)}</strong> password was just changed by
            <strong>${escapeHtml(args.byAdminName)}</strong>, an administrator on your account.
          </p>
          <p style="margin:0 0 14px;">
            If you asked them to do this, you're all set — sign in with the new password.
          </p>
          <p style="margin:0 0 14px; color:#555;">
            <strong>If this wasn't you</strong> — or you'd like to pick a different password yourself —
            tap the button below within the next <strong>${args.expiresInMinutes} minutes</strong>:
          </p>
        </td></tr>

        <tr><td align="center" style="padding:8px 32px 32px;">
          <a href="${args.resetUrl}"
             style="display:inline-block; padding:14px 32px; background:#2563eb; color:#ffffff; text-decoration:none; border-radius:12px; font-weight:700; font-size:15px; letter-spacing:.2px;">
            Set my own password
          </a>
        </td></tr>

        <tr><td style="padding:0 32px 24px; font-size:12px; color:#888; line-height:1.5;">
          <p style="margin:0 0 6px;">Or copy and paste this link into your browser:</p>
          <p style="margin:0; word-break:break-all;"><a href="${args.resetUrl}" style="color:#2563eb; text-decoration:underline;">${args.resetUrl}</a></p>
        </td></tr>

        <tr><td style="padding:22px 32px 28px; border-top:1px solid #eee;">
          <p style="margin:0 0 4px; font-size:14px; font-weight:700; color:#1a1a2e;">Tony Aboud</p>
          <p style="margin:0; font-size:12px; color:#888;">Founder, ClassMate</p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;
}
