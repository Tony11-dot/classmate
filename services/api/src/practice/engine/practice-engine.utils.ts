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
