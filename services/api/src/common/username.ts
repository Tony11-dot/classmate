import { PrismaService } from '../prisma/prisma.service';

/// Builds a candidate username from an email or name. Lowercases, strips
/// non-alphanumeric chars, falls back to a generic prefix if the input has
/// nothing usable. Caller is responsible for uniqueness — wrap in
/// [ensureUniqueUsername] if you need collision handling.
export function deriveUsernameCandidate(email?: string | null, name?: string | null): string {
  const fromEmail = (email ?? '').trim().toLowerCase().split('@')[0];
  const fromName = (name ?? '').trim().toLowerCase();
  const raw = (fromEmail || fromName || 'user').replace(/[^a-z0-9]/g, '');
  // Empty after sanitisation (e.g. all non-Latin characters) → fall back
  // so we always return something non-empty.
  return raw.length === 0 ? 'user' : raw;
}

/// Returns a username derived from [candidate] that is not already taken
/// in the User table. Appends an incrementing suffix on collision.
export async function ensureUniqueUsername(
  prisma: PrismaService,
  candidate: string,
): Promise<string> {
  const base = candidate.length > 0 ? candidate : 'user';
  let attempt = base;
  let n = 1;
  // 99-attempt cap protects against pathological data; in practice we
  // never hit double digits.
  while (n < 100) {
    const taken = await prisma.user.findUnique({ where: { username: attempt } });
    if (!taken) return attempt;
    n += 1;
    attempt = `${base}${n}`;
  }
  // If even base99 collides (extremely unlikely), salt with a short random
  // suffix instead of looping forever.
  return `${base}${Date.now().toString(36).slice(-5)}`;
}
