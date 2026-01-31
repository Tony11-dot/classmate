import type { PrismaClient } from '@prisma/client';

export function normalizeQuestion(q: string) {
  return String(q ?? '')
    .trim()
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .slice(0, 400);
}

export function cacheTtlMs() {
  // default 24h
  const hours = Number(process.env.TUTOR_REPLY_CACHE_HOURS ?? 24);
  const ms = Math.max(1, hours) * 60 * 60 * 1000;
  return ms;
}

/**
 * NOTE:
 * TutorService already bakes studentId/characterId/topic/refs/excerpt into `key`
 * via replyCacheKey(...). So we can store a single row namespace and let the key
 * do the separation.
 *
 * Prisma model requires (userId, normalizedQuestion, mode) for uniqueness,
 * but `userId` is not a foreign key here — so we use a stable namespace.
 */
const CACHE_NAMESPACE_USER = 'tutor-cache';
const CACHE_NAMESPACE_CHARACTER = '__none__';
const CACHE_MODE: 'deterministic' = 'deterministic';

export async function getCachedReply(prisma: PrismaClient, key: string) {
  const now = new Date();
  const row = await prisma.tutorReplyCache.findFirst({
    where: {
      userId: CACHE_NAMESPACE_USER,
      characterId: CACHE_NAMESPACE_CHARACTER,
      normalizedQuestion: String(key),
      mode: CACHE_MODE,
      expiresAt: { gt: now },
    },
    select: { content: true, expiresAt: true },
  });

  return row ?? null;
}

export async function setCachedReply(
  prisma: PrismaClient,
  key: string,
  content: string,
) {
  const expiresAt = new Date(Date.now() + cacheTtlMs());

  await prisma.tutorReplyCache.upsert({
    where: {
      userId_characterId_normalizedQuestion_mode: {
        userId: CACHE_NAMESPACE_USER,
        characterId: CACHE_NAMESPACE_CHARACTER,
        normalizedQuestion: String(key),
        mode: CACHE_MODE,
      },
    },
    update: {
      content: String(content ?? ''),
      expiresAt,
    },
    create: {
      userId: CACHE_NAMESPACE_USER,
      characterId: CACHE_NAMESPACE_CHARACTER,
      normalizedQuestion: String(key),
      mode: CACHE_MODE,
      content: String(content ?? ''),
      expiresAt,
    },
  });

  return { ok: true, expiresAt };
}
