export function clampTime(
  overrideSeconds: number | null,
  fallback: number,
): number {
  if (overrideSeconds != null && Number.isFinite(overrideSeconds)) {
    return Math.max(5, Math.min(900, Math.round(overrideSeconds)));
  }
  return Math.max(5, Math.min(900, Math.round(fallback)));
}

export function rotateBySeed<T>(arr: T[], seed: number): T[] {
  if (arr.length <= 1) return arr.slice();
  const k = ((seed % arr.length) + arr.length) % arr.length;
  return arr.slice(k).concat(arr.slice(0, k));
}

export function uniqueFirst<T>(items: T[], take: number): T[] {
  const out: T[] = [];
  for (const item of items) {
    if (!out.includes(item)) out.push(item);
    if (out.length === take) break;
  }
  return out;
}

export function gcd(a: number, b: number): number {
  let x = Math.abs(a);
  let y = Math.abs(b);
  while (y !== 0) {
    const t = x % y;
    x = y;
    y = t;
  }
  return x || 1;
}

export function reduceFraction(n: number, d: number): { n: number; d: number } {
  const g = gcd(n, d);
  return { n: n / g, d: d / g };
}

export function fillOptionsWithSafeFallback(existing: string[], answer: string, seed: number): string[] {
  const out = uniqueFirst(existing, 4);
  const trimmed = String(answer ?? '').trim();

  const numericMatch = trimmed.match(/^(-?\d+(?:\.\d+)?)(\s*.*)$/);
  if (numericMatch) {
    const rawValue = numericMatch[1];
    const unit = numericMatch[2] ?? '';
    const value = Number(rawValue);
    const decimals = rawValue.includes('.') ? rawValue.split('.')[1].length : 0;
    const deltas = [1, 2, 3, 4, 5, 10, 0.5, 1.5, 2.5];

    for (let i = 0; out.length < 4 && i < deltas.length * 2; i++) {
      const delta = deltas[i % deltas.length];
      const sign = i < deltas.length ? 1 : -1;
      const candidateValue = Number((value + sign * delta).toFixed(decimals));
      const candidate = `${candidateValue}${unit}`;
      if (!out.includes(candidate) && candidate !== trimmed) {
        out.push(candidate);
      }
    }
  }

  const textFallbacks = [
    `${trimmed} (alternative)`,
    `${trimmed} only`,
    `Not ${trimmed}`,
    `Not enough information`,
    `A different value`,
    `${trimmed} (approx.)`,
  ];

  for (const candidate of textFallbacks) {
    if (out.length >= 4) break;
    if (!out.includes(candidate) && candidate !== trimmed) {
      out.push(candidate);
    }
  }

  while (out.length < 4) {
    const candidate = `Option ${seed + out.length + 1}`;
    if (!out.includes(candidate) && candidate !== trimmed) {
      out.push(candidate);
    }
  }

  return out.slice(0, 4);
}
