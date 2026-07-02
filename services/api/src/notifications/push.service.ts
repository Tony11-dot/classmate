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

  /// Register (or refresh) a device's push token under a specific
  /// account. One row per (user, token) — several accounts logged in on
  /// the SAME physical device each register the same FCM token, so each
  /// receives its own pushes. Registering under one account never steals
  /// the token from the others.
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
      where: { userId_token: { userId, token } },
      create: {
        userId,
        token,
        platform,
        appVersion: args.appVersion ?? null,
      },
      update: {
        platform,
        appVersion: args.appVersion ?? null,
      },
    });
  }

  /// Remove a token (called on sign-out from the app). When `userId` is
  /// provided, only THIS account's registration for the token is removed
  /// so other accounts logged in on the same device keep their pushes.
  /// When omitted, every row for the token is removed (back-compat).
  async unregisterToken(token: string, userId?: string): Promise<void> {
    const t = String(token ?? '').trim();
    if (!t) return;
    const uid = String(userId ?? '').trim();
    if (uid) {
      await this.prisma.deviceToken
        .deleteMany({ where: { token: t, userId: uid } })
        .catch(() => undefined);
      return;
    }
    await this.prisma.deviceToken
      .deleteMany({ where: { token: t } })
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

    const uniqueIds = Array.from(new Set(ids));
    // Each (userId, token) row is one delivery target — the same physical
    // device can appear multiple times (one row per logged-in account).
    const rows = await this.prisma.deviceToken.findMany({
      where: { userId: { in: uniqueIds } },
      select: { userId: true, token: true },
    });
    if (rows.length === 0) return;

    const recipientTokens = Array.from(new Set(rows.map((r) => r.token)));

    // A token is "multi-account" when the SAME token value is registered
    // under 2+ distinct users anywhere in the table (not just among the
    // current recipients) — that's a shared device where we should prefix
    // the notification with the account's first name to disambiguate.
    const distinctUserCountByToken = new Map<string, number>();
    const grouped = await this.prisma.deviceToken.groupBy({
      by: ['token', 'userId'],
      where: { token: { in: recipientTokens } },
    });
    for (const g of grouped) {
      distinctUserCountByToken.set(
        g.token,
        (distinctUserCountByToken.get(g.token) ?? 0) + 1,
      );
    }
    const isMultiAccount = (token: string) =>
      (distinctUserCountByToken.get(token) ?? 0) >= 2;

    // First name per recipient, for the shared-device prefix.
    const users = await this.prisma.user.findMany({
      where: { id: { in: uniqueIds } },
      select: { id: true, name: true, legalName: true },
    });
    const firstNameById = new Map<string, string>();
    for (const u of users) {
      const first = String(u.name || u.legalName || '')
        .trim()
        .split(/\s+/)[0];
      firstNameById.set(u.id, first ?? '');
    }

    const data: Record<string, string> = { ...(args.data ?? {}) };
    // Notifications are most useful when the tap lands somewhere — pack
    // a minimal "type" hint so the client deep-link router can route
    // without needing extra fields.
    if (!data.type && args.data?.type) data.type = String(args.data.type);
    const body = args.body ?? '';

    // Compute the final title for each token, then group tokens by title
    // so we still send with as few multicast calls as possible. Body is
    // constant across recipients.
    const tokensByTitle = new Map<string, Set<string>>();
    for (const r of rows) {
      let title = args.title;
      if (isMultiAccount(r.token)) {
        const first = firstNameById.get(r.userId) ?? '';
        if (first) title = `${first} · ${args.title}`;
      }
      let set = tokensByTitle.get(title);
      if (!set) {
        set = new Set<string>();
        tokensByTitle.set(title, set);
      }
      set.add(r.token);
    }

    for (const [title, tokenSet] of tokensByTitle) {
      const tokenList = Array.from(tokenSet);
      // sendEachForMulticast caps at 500 tokens/call. Chunk if we ever
      // grow past that (school-wide announcement fan-out could).
      const chunks: string[][] = [];
      for (let i = 0; i < tokenList.length; i += 500) {
        chunks.push(tokenList.slice(i, i + 500));
      }

      for (const chunk of chunks) {
        try {
          const result = await messaging.sendEachForMulticast({
            tokens: chunk,
            notification: {
              title,
              body,
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
}
