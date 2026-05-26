import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

/// Thin wrapper around the Firebase HTTP v1 send API. Uses the
/// `firebase-admin` SDK so we don't have to hand-roll OAuth token
/// refreshes. The SDK reads `GOOGLE_APPLICATION_CREDENTIALS` (a JSON
/// file path) or `FIREBASE_SERVICE_ACCOUNT_JSON` (the JSON content
/// inlined as an env var) — Railway's environment doesn't have a
/// filesystem we control, so prefer the inline form there.
///
/// The whole service is a no-op when Firebase isn't configured: the
/// app boots, the notification hub keeps SSE working, and a single
/// startup warning tells ops what's missing. This way push is purely
/// additive — turning it off doesn't break in-app banners.
@Injectable()
export class PushService {
  private readonly logger = new Logger(PushService.name);
  private _messaging: any | null = null;
  private _configured: boolean | null = null;

  constructor(private readonly prisma: PrismaService) {}

  /// Lazy init so the service still boots when firebase-admin isn't
  /// installed yet (during the rollout before Firebase is configured).
  private async getMessaging(): Promise<any | null> {
    if (this._messaging) return this._messaging;
    if (this._configured === false) return null;

    let admin: any;
    try {
      admin = await import('firebase-admin');
    } catch {
      this._configured = false;
      this.logger.warn('firebase-admin not installed — push disabled.');
      return null;
    }

    try {
      if (admin.apps?.length === 0 || !admin.apps) {
        const inline = process.env.FIREBASE_SERVICE_ACCOUNT_JSON?.trim();
        const gac = process.env.GOOGLE_APPLICATION_CREDENTIALS?.trim();
        if (inline) {
          const credentials = JSON.parse(inline);
          admin.initializeApp({
            credential: admin.credential.cert(credentials),
          });
        } else if (gac) {
          admin.initializeApp({
            credential: admin.credential.applicationDefault(),
          });
        } else {
          this._configured = false;
          this.logger.warn(
            'Firebase service account not configured (set FIREBASE_SERVICE_ACCOUNT_JSON or GOOGLE_APPLICATION_CREDENTIALS) — push disabled.',
          );
          return null;
        }
      }
      this._messaging = admin.messaging();
      this._configured = true;
      this.logger.log('Firebase messaging initialized.');
      return this._messaging;
    } catch (err) {
      this._configured = false;
      this.logger.error(`Firebase init failed: ${(err as Error).message}`);
      return null;
    }
  }

  /// Register (or refresh) a device's push token. One row per token —
  /// if the same physical device signs in as a different user, the
  /// existing token row gets its userId rewritten so only the current
  /// account receives pushes for that device.
  async registerToken(args: {
    userId: string;
    token: string;
    platform: 'ios' | 'android';
    appVersion?: string;
  }): Promise<void> {
    const userId = String(args.userId ?? '').trim();
    const token = String(args.token ?? '').trim();
    const platform = (args.platform ?? '').toLowerCase();
    if (!userId || !token) return;
    if (platform !== 'ios' && platform !== 'android') return;

    await this.prisma.deviceToken.upsert({
      where: { token },
      create: {
        userId,
        token,
        platform,
        appVersion: args.appVersion ?? null,
      },
      update: {
        userId,
        platform,
        appVersion: args.appVersion ?? null,
      },
    });
  }

  /// Remove a token (called on sign-out from the app).
  async unregisterToken(token: string): Promise<void> {
    const t = String(token ?? '').trim();
    if (!t) return;
    await this.prisma.deviceToken
      .delete({ where: { token: t } })
      .catch(() => undefined);
  }

  /// Send a push to every device registered to the given users.
  /// Silent no-op when Firebase isn't configured.
  async sendToUsers(args: {
    userIds: string[];
    title: string;
    body?: string;
    data?: Record<string, string>;
  }): Promise<void> {
    const ids = (args.userIds ?? [])
      .map((u) => String(u ?? '').trim())
      .filter((u) => !!u);
    if (ids.length === 0) return;

    const messaging = await this.getMessaging();
    if (!messaging) return;

    const tokens = await this.prisma.deviceToken.findMany({
      where: { userId: { in: Array.from(new Set(ids)) } },
      select: { token: true },
    });
    if (tokens.length === 0) return;

    // sendEachForMulticast caps at 500 tokens/call. Chunk if we ever
    // grow past that (school-wide announcement fan-out could).
    const tokenList = tokens.map((t) => t.token);
    const data: Record<string, string> = { ...(args.data ?? {}) };
    // Notifications are most useful when the tap lands somewhere — pack
    // a minimal "type" hint so the client deep-link router can route
    // without needing extra fields.
    if (!data.type && args.data?.type) data.type = String(args.data.type);

    const chunks: string[][] = [];
    for (let i = 0; i < tokenList.length; i += 500) {
      chunks.push(tokenList.slice(i, i + 500));
    }

    for (const chunk of chunks) {
      try {
        const result = await messaging.sendEachForMulticast({
          tokens: chunk,
          notification: {
            title: args.title,
            body: args.body ?? '',
          },
          data,
          apns: {
            payload: {
              aps: {
                sound: 'default',
                badge: 1,
              },
            },
          },
          android: {
            priority: 'high',
            notification: { sound: 'default' },
          },
        });
        // Reap tokens FCM tells us are dead (uninstall, expired) so we
        // stop fanning out to them on the next call.
        const dead: string[] = [];
        result.responses?.forEach((r: any, idx: number) => {
          if (r.success) return;
          const code = r.error?.code ?? r.error?.errorInfo?.code ?? '';
          if (
            code === 'messaging/registration-token-not-registered' ||
            code === 'messaging/invalid-argument' ||
            code === 'messaging/invalid-registration-token'
          ) {
            dead.push(chunk[idx]);
          }
        });
        if (dead.length) {
          await this.prisma.deviceToken
            .deleteMany({ where: { token: { in: dead } } })
            .catch(() => undefined);
        }
      } catch (err) {
        this.logger.error(
          `Push send failed for ${chunk.length} tokens: ${(err as Error).message}`,
        );
      }
    }
  }
}
