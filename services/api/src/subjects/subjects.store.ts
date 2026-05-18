/**
 * Session 10 storage (dev/e2e): in-memory maps.
 * NOTE: This is intentionally non-persistent until DB migrations are available.
 */

export type SubjectDefaultsKey = `${string}::${number}`;

export const subjectDefaultsBySchoolGrade = new Map<SubjectDefaultsKey, string[]>();
export const studentSubjectOverrides = new Map<string, { enabled: boolean; subjects: string[] }>();

export function normalizeSubjects(v: any): string[] {
  const arr = Array.isArray(v) ? v : [];
  const out: string[] = [];
  for (const x of arr) {
    // Accept either a plain string or { nameEn, ... } objects.
    const t = typeof x === 'string'
      ? x.trim()
      : String((x as any)?.nameEn ?? '').trim();
    if (t) out.push(t);
  }
  return Array.from(new Set(out));
}

export type SubjectI18n = {
  nameEn: string;
  nameAr?: string | null;
  nameHe?: string | null;
  nameFr?: string | null;
  nameRu?: string | null;
  /// Hex `#RRGGBB`. Optional; clients render a deterministic fallback when null.
  color?: string | null;
};

/**
 * Normalizes input to the authoritative SubjectI18n[] shape. Accepts both
 * legacy flat string arrays (each becomes { nameEn }) and arrays of partial
 * objects (missing fields default to null). Deduplicates by nameEn.
 */
export function normalizeSubjectsI18n(v: any): SubjectI18n[] {
  const arr = Array.isArray(v) ? v : [];
  const out: SubjectI18n[] = [];
  const seen = new Set<string>();
  for (const x of arr) {
    let row: SubjectI18n | null = null;
    if (typeof x === 'string') {
      const t = x.trim();
      if (t) row = { nameEn: t };
    } else if (x && typeof x === 'object') {
      const nameEn = String((x as any).nameEn ?? '').trim();
      if (nameEn) {
        row = {
          nameEn,
          nameAr: trimOrNull((x as any).nameAr),
          nameHe: trimOrNull((x as any).nameHe),
          nameFr: trimOrNull((x as any).nameFr),
          nameRu: trimOrNull((x as any).nameRu),
          color: normalizeColor((x as any).color),
        };
      }
    }
    if (row && !seen.has(row.nameEn)) {
      seen.add(row.nameEn);
      out.push(row);
    }
  }
  return out;
}

function trimOrNull(v: any): string | null {
  const t = String(v ?? '').trim();
  return t.length ? t : null;
}

/// Accepts `#RRGGBB`, `RRGGBB`, `#AARRGGBB`, or `0xAARRGGBB` and normalizes
/// to `#RRGGBB` (uppercase, no alpha).  Returns null for empty / invalid.
function normalizeColor(v: any): string | null {
  let h = String(v ?? '').trim();
  if (!h) return null;
  if (h.startsWith('#')) h = h.slice(1);
  if (h.toLowerCase().startsWith('0x')) h = h.slice(2);
  if (h.length === 8) h = h.slice(2); // drop alpha
  if (h.length !== 6) return null;
  if (!/^[0-9A-Fa-f]{6}$/.test(h)) return null;
  return `#${h.toUpperCase()}`;
}

export function defaultsKey(schoolId: string, grade: number): SubjectDefaultsKey {
  return `${schoolId}::${grade}`;
}
