export function basicTutorSafetyCheck(content: string) {
  const text = String(content ?? '');
  const low = text.toLowerCase();

  // Hard contract markers
  const okBagrut = low.includes('bagrut');
  const okQuiz = low.includes('mini-quiz');

  // Very rough "too advanced" / out-of-scope heuristics
  const looksUniversity =
    low.includes('epsilon') ||
    low.includes('delta-epsilon') ||
    low.includes('measure theory') ||
    low.includes('laplace transform') ||
    low.includes('fourier transform') ||
    low.includes('lagrangian') ||
    low.includes('schrodinger') ||
    low.includes('tensor') ||
    low.includes('riemann') ||
    low.includes('manifold');

  // High-risk topics (keep simple)
  const looksMedical = low.includes('diagnos') || low.includes('treatment') || low.includes('dose');
  const looksLegal = low.includes('lawsuit') || low.includes('contract law') || low.includes('criminal');

  return {
    ok: okBagrut && okQuiz && !looksUniversity && !looksMedical && !looksLegal,
    reasons: {
      okBagrut,
      okQuiz,
      looksUniversity,
      looksMedical,
      looksLegal,
    },
  };
}

export function rateLimitTutor(opts: {
  key: string;
  now: number;
  windowMs?: number;
  max?: number;
  store: Map<string, number[]>;
}) {
  const windowMs = opts.windowMs ?? 60_000;
  const max = opts.max ?? 10;
  const arr = opts.store.get(opts.key) ?? [];
  const fresh = arr.filter(t => opts.now - t < windowMs);
  if (fresh.length >= max) {
    return { ok: false, retryAfterMs: windowMs - (opts.now - fresh[0]) };
  }
  fresh.push(opts.now);
  opts.store.set(opts.key, fresh);
  return { ok: true };
}
