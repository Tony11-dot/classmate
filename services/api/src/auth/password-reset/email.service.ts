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
}

function buildResetEmailText(args: { recipientName?: string | null; schoolName?: string | null; resetUrl: string; expiresInMinutes: number }): string {
  const greeting = args.recipientName ? `Hi ${args.recipientName},` : 'Hi,';
  const sender = args.schoolName ? `the ${args.schoolName} team on ClassMate` : 'the ClassMate team';
  return [
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
    `— ${sender}`,
  ].join('\n');
}

function buildResetEmailHtml(args: { recipientName?: string | null; schoolName?: string | null; resetUrl: string; expiresInMinutes: number }): string {
  const greeting = args.recipientName ? `Hi ${args.recipientName},` : 'Hi,';
  const schoolLabel = args.schoolName ?? 'ClassMate';
  const senderLine = args.schoolName ? `the ${args.schoolName} team on ClassMate` : 'the ClassMate team';

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

        <!-- Header w/ logo -->
        <tr><td align="center" style="padding:40px 24px 24px; background:linear-gradient(135deg,#1a1a2e 0%,#2563eb 100%);">
          <img src="${LOGO_DATA_URI}" alt="ClassMate" width="180" style="display:block; max-width:60%; height:auto; filter:brightness(0) invert(1);">
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

        <!-- Footer -->
        <tr><td align="center" style="padding:20px 32px 28px; border-top:1px solid #eee; font-size:12px; color:#888;">
          <p style="margin:0;">— ${escapeHtml(senderLine)}</p>
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
