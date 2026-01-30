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
