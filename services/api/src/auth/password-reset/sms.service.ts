import { Injectable, Logger } from '@nestjs/common';
import twilio from 'twilio';

/**
 * Twilio Programmable SMS wrapper. Lazy-instantiated so the app boots even
 * without TWILIO_* env vars (call sites check `isConfigured` and degrade).
 */
@Injectable()
export class SmsService {
  private readonly logger = new Logger(SmsService.name);
  private _client: ReturnType<typeof twilio> | null = null;

  private get client() {
    if (this._client) return this._client;
    const sid = process.env.TWILIO_ACCOUNT_SID?.trim();
    const token = process.env.TWILIO_AUTH_TOKEN?.trim();
    if (!sid || !token) return null;
    this._client = twilio(sid, token);
    return this._client;
  }

  private get fromNumber(): string | null {
    const n = process.env.TWILIO_FROM?.trim();
    return n && n.length > 0 ? n : null;
  }

  get isConfigured(): boolean {
    return !!(process.env.TWILIO_ACCOUNT_SID?.trim()
      && process.env.TWILIO_AUTH_TOKEN?.trim()
      && process.env.TWILIO_FROM?.trim());
  }

  async sendPasswordResetSms(args: {
    to: string;
    resetUrl: string;
    expiresInMinutes: number;
    schoolName?: string | null;
  }): Promise<void> {
    const label = args.schoolName ?? 'ClassMate';
    // Keep the body terse — single SMS segment (160 chars) is cheaper.
    const body = `${label}: reset your password — ${args.resetUrl} (expires in ${args.expiresInMinutes} min). If you didn't ask, ignore this.`;
    await this.send(args.to, body);
  }

  /**
   * Notifies an admin via SMS that a user filed a password-change request
   * waiting for their approval.
   */
  async sendPasswordChangeRequestToAdmin(args: {
    to: string;
    requesterName: string;
    schoolName?: string | null;
  }): Promise<void> {
    const label = args.schoolName ?? 'ClassMate';
    const body = `${label}: ${args.requesterName} requested a password reset. Open the admin app → Password Requests to approve or reject. Expires in 24h.`;
    await this.send(args.to, body);
  }

  /**
   * Heads-up sent to the TARGET of an admin-mediated password change
   * request. One-tap reject link lets them cancel before the admin acts —
   * defends against someone filing a request with their identifier.
   */
  async sendPasswordChangeRequestToTarget(args: {
    to: string;
    rejectUrl: string;
    schoolName?: string | null;
  }): Promise<void> {
    const label = args.schoolName ?? 'ClassMate';
    const body = `${label}: someone asked your admin to reset your password. If this wasn't you, reject it: ${args.rejectUrl} (expires in 24h)`;
    await this.send(args.to, body);
  }

  /**
   * Sent automatically after an admin directly changes a user's password.
   */
  async sendPasswordChangedSms(args: {
    to: string;
    byAdminName: string;
    resetUrl: string;
    expiresInMinutes: number;
    schoolName?: string | null;
  }): Promise<void> {
    const label = args.schoolName ?? 'ClassMate';
    const body = `${label}: your password was changed by ${args.byAdminName}. Set your own here: ${args.resetUrl} (expires in ${args.expiresInMinutes} min).`;
    await this.send(args.to, body);
  }

  /**
   * Generic outbound SMS. Returns silently (and logs a warning) if Twilio
   * env vars aren't set — callers can still rely on isConfigured to surface
   * that to the end user.
   */
  async send(to: string, body: string): Promise<void> {
    if (!this.client || !this.fromNumber) {
      this.logger.warn(`Twilio not configured; would have sent SMS to ${to}: ${body.slice(0, 60)}…`);
      return;
    }
    try {
      await this.client.messages.create({ from: this.fromNumber, to, body });
    } catch (err) {
      this.logger.error(`Failed to send SMS to ${to}: ${(err as Error).message}`);
      throw err;
    }
  }
}
