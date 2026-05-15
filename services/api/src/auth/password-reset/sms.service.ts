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
    if (!this.client || !this.fromNumber) {
      this.logger.warn(`Twilio not configured; would have sent SMS to ${args.to} with reset link ${args.resetUrl}`);
      return;
    }
    const label = args.schoolName ?? 'ClassMate';
    // Keep the body terse — single SMS segment (160 chars) is cheaper.
    const body = `${label}: reset your password — ${args.resetUrl} (expires in ${args.expiresInMinutes} min). If you didn't ask, ignore this.`;

    try {
      await this.client.messages.create({
        from: this.fromNumber,
        to: args.to,
        body,
      });
    } catch (err) {
      this.logger.error(`Failed to send reset SMS to ${args.to}: ${(err as Error).message}`);
      throw err;
    }
  }
}
