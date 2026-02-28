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
    const t = String(x ?? '').trim();
    if (t) out.push(t);
  }
  return Array.from(new Set(out));
}

export function defaultsKey(schoolId: string, grade: number): SubjectDefaultsKey {
  return `${schoolId}::${grade}`;
}
