export type PracticeSubjectCatalogRow = {
  canonicalSubject: string;
  aliases: string[];
};

export const PRACTICE_SUBJECT_CATALOG: PracticeSubjectCatalogRow[] = [
  { canonicalSubject: 'Math', aliases: ['math', 'mathematics', 'maths'] },
  { canonicalSubject: 'Physics', aliases: ['physics', 'phys'] },
  {
    canonicalSubject: 'Electronics',
    aliases: ['electronics', 'electronic', 'elictronics', 'electronis', 'eletronics'],
  },
];

function norm(x: string): string {
  return String(x ?? '')
    .toLowerCase()
    .replace(/[’']/g, "'")
    .replace(/\s+/g, ' ')
    .trim();
}

export function resolveCanonicalPracticeSubject(subjectLike: string): string {
  const s = norm(subjectLike);
  const row = PRACTICE_SUBJECT_CATALOG.find((r) =>
    r.aliases.some((a) => norm(a) === s),
  );
  return row?.canonicalSubject ?? String(subjectLike ?? '').trim();
}
