/**
 * School-year semester model + date partitioning (backend mirror of the Flutter
 * `lib/core/semester/school_semester.dart`). Kept byte-for-byte consistent with
 * the client so a date maps to the same semester on both sides.
 *
 * Semesters are stored as month-range pairs on `School.semesters`, e.g.
 * "9-1,2-6" → Semester 1 = Sep→Jan, Semester 2 = Feb→Jun. A record belongs to a
 * semester by its DATE (no per-record tagging), so existing data is covered.
 */

export interface SchoolSemester {
  number: number; // 1-based ("Semester N")
  startMonth: number; // 1-12
  endMonth: number; // 1-12
}

export interface SemesterWindow {
  number: number;
  start: Date; // inclusive
  end: Date; // inclusive
}

/** Parses "9-1,2-6" into ordered semesters (Semester 1, 2, … in author order). */
export function parseSchoolSemesters(raw: string | null | undefined): SchoolSemester[] {
  const s = String(raw ?? '').trim();
  if (!s) return [];
  const out: SchoolSemester[] = [];
  let n = 1;
  for (const part of s.split(/[,;]+/)) {
    const p = part.trim();
    if (!p) continue;
    const m = /^(\d{1,2})-(\d{1,2})$/.exec(p);
    if (!m) continue;
    const a = Number(m[1]);
    const b = Number(m[2]);
    if (a < 1 || a > 12 || b < 1 || b > 12) continue;
    out.push({ number: n++, startMonth: a, endMonth: b });
  }
  return out;
}

function endOfMonth(year: number, month: number): Date {
  // month is 1-based; last instant of that month.
  const firstNext = month === 12 ? new Date(year + 1, 0, 1) : new Date(year, month, 1);
  return new Date(firstNext.getTime() - 1000);
}

/** Academic-year start calendar year for [now] (anchored on the first semester's start month). */
export function currentAcademicStartYear(sems: SchoolSemester[], now: Date): number {
  const anchor = sems.length ? sems[0].startMonth : 9;
  const month = now.getMonth() + 1; // 1-based
  return month >= anchor ? now.getFullYear() : now.getFullYear() - 1;
}

/** Concrete semester windows for the academic year starting in [startYear]. */
export function semesterWindowsForYear(sems: SchoolSemester[], startYear: number): SemesterWindow[] {
  if (!sems.length) return [];
  const anchor = sems[0].startMonth;
  return sems.map((s) => {
    const startCalYear = s.startMonth >= anchor ? startYear : startYear + 1;
    const start = new Date(startCalYear, s.startMonth - 1, 1);
    const endCalYear = s.endMonth >= s.startMonth ? startCalYear : startCalYear + 1;
    const end = endOfMonth(endCalYear, s.endMonth);
    return { number: s.number, start, end };
  });
}

/** "2025/2026" label for the academic year starting in [startYear]. */
export function academicYearLabel(startYear: number): string {
  return `${startYear}/${startYear + 1}`;
}

/** The window for semester [number] within the academic year starting [startYear], or null. */
export function windowForSemester(
  sems: SchoolSemester[],
  startYear: number,
  number: number,
): SemesterWindow | null {
  return semesterWindowsForYear(sems, startYear).find((w) => w.number === number) ?? null;
}

/** True if [date] falls inside [window] (inclusive). */
export function dateInWindow(date: Date, window: SemesterWindow): boolean {
  return date.getTime() >= window.start.getTime() && date.getTime() <= window.end.getTime();
}
