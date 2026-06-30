import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateGradeFormulaDto, UpdateGradeFormulaDto, FormulaVariantDto } from './dto/grade-formula.dto';
import {
  SemesterWindow,
  parseSchoolSemesters,
  currentAcademicStartYear,
  windowForSemester,
} from '../common/semester';

/** Per-student computed average result. */
export interface StudentAverage {
  studentId: string;
  average: number | null; // 0..100, rounded; null when no covered components
  variantUsed: string | null; // variant id
  variantLabel: string | null;
  coverage: { covered: number; total: number }; // components matched vs variant size
}

type LoadedFormula = {
  id: string;
  schoolId: string;
  createdBy: string;
  cohortId: string;
  subject: string;
  title: string;
  units: number;
  variants: {
    id: string;
    label: string | null;
    sortOrder: number;
    components: { id: string; assessmentId: string; weight: number }[];
  }[];
};

@Injectable()
export class AveragesService {
  constructor(private readonly prisma: PrismaService) {}

  private userId(user: any): string {
    return (user?.id ?? user?.sub ?? '') as string;
  }
  private schoolId(user: any): string | null {
    return (user?.schoolId ?? null) as string | null;
  }
  private roles(user: any): string[] {
    return (user?.roles ?? []) as string[];
  }
  private isAdmin(user: any): boolean {
    const r = this.roles(user);
    return r.includes('ADMIN') || r.includes('SECRETARY');
  }

  // ── Subject canonicalization ───────────────────────────────────────────────
  /**
   * Map a free-text subject to the school's canonical localized name for the
   * cohort's grade, if it matches any of the i18n names. Returns null when no
   * match (caller passes the raw string through).
   */
  private async canonicalSubjectsForGrade(
    schoolId: string | null,
    grade: number | null,
  ): Promise<Array<{ nameEn?: string; nameAr?: string; nameHe?: string; nameFr?: string; nameRu?: string }>> {
    if (!schoolId || grade == null) return [];
    const row = await this.prisma.schoolGradeSubjectDefault.findFirst({
      where: { schoolId, grade },
      select: { subjectsI18n: true },
    });
    const arr = (row?.subjectsI18n as any[]) ?? [];
    return Array.isArray(arr) ? arr : [];
  }

  private normKey(s: string): string {
    return s.trim().toLowerCase().replace(/\s+/g, ' ');
  }

  // ── Cohorts the teacher teaches (schedule-derived) ─────────────────────────
  async cohorts(user: any) {
    const teacherId = this.userId(user);
    // Admins generating certificates may pass through; they read all school cohorts.
    if (this.isAdmin(user)) {
      const schoolId = this.schoolId(user);
      const cohorts = await this.prisma.cohort.findMany({
        where: schoolId ? { schoolId } : {},
        select: { id: true, name: true, grade: true },
        orderBy: { name: 'asc' },
      });
      return { ok: true, cohorts };
    }
    const slotCohorts = await this.prisma.scheduleSlotCohort.findMany({
      where: { slot: { teacherId } },
      select: { cohortId: true, cohort: { select: { id: true, name: true, grade: true } } },
      distinct: ['cohortId'],
    });
    return { ok: true, cohorts: slotCohorts.map((sc) => sc.cohort) };
  }

  // ── Subjects the teacher teaches in a cohort (schedule-derived, deduped) ────
  async options(user: any, cohortId: string) {
    if (!cohortId) throw new BadRequestException('cohortId is required');
    const teacherId = this.userId(user);
    const admin = this.isAdmin(user);

    const cohort = await this.prisma.cohort.findUnique({
      where: { id: cohortId },
      select: { id: true, grade: true, schoolId: true },
    });
    if (!cohort) throw new NotFoundException('Cohort not found');

    // Schedule slots for this cohort taught by the signed-in teacher (admins: any).
    const slots = await this.prisma.scheduleSlot.findMany({
      where: {
        ...(admin ? {} : { teacherId }),
        cohorts: { some: { cohortId } },
        subject: { not: null },
      },
      select: { subject: true },
    });

    const canon = await this.canonicalSubjectsForGrade(cohort.schoolId ?? this.schoolId(user), cohort.grade);
    // Build a lookup from any localized name → canonical display (prefer the
    // viewer-agnostic English/native name; we expose all names so the client
    // can localize, plus a default display string).
    const canonByKey = new Map<string, any>();
    for (const c of canon) {
      for (const v of [c.nameEn, c.nameAr, c.nameHe, c.nameFr, c.nameRu]) {
        if (v && v.trim()) canonByKey.set(this.normKey(v), c);
      }
    }

    const seen = new Map<string, { value: string; display: string; i18n: any | null }>();
    for (const s of slots) {
      const raw = (s.subject ?? '').trim();
      if (!raw) continue;
      const key = this.normKey(raw);
      const match = canonByKey.get(key) ?? null;
      // Dedup key: canonical English name if matched, else normalized raw.
      const dedupKey = match?.nameEn ? this.normKey(match.nameEn) : key;
      if (seen.has(dedupKey)) continue;
      seen.set(dedupKey, {
        value: raw, // raw string is what matches Assessment.subject
        display: match?.nameEn ?? raw,
        i18n: match,
      });
    }

    return { ok: true, subjects: Array.from(seen.values()) };
  }

  // ── Assessments for a cohort+subject (populate the grade DDL) ──────────────
  async grades(user: any, cohortId: string, subject: string, semesterNumber?: number | null) {
    if (!cohortId || !subject) throw new BadRequestException('cohortId and subject are required');
    const teacherId = this.userId(user);
    const admin = this.isAdmin(user);
    // Optional semester scoping — filter assessments to the chosen semester's
    // window (in the school's current academic year).
    let dateFilter: { gte: Date; lte: Date } | undefined;
    if (semesterNumber) {
      const schoolId = this.schoolId(user);
      if (schoolId) {
        const w = await this.resolveCurrentWindow(schoolId, semesterNumber);
        if (w) dateFilter = { gte: w.start, lte: w.end };
      }
    }
    const assessments = await this.prisma.assessment.findMany({
      where: {
        cohortId,
        subject,
        ...(admin ? {} : { createdBy: teacherId }),
        ...(dateFilter ? { date: dateFilter } : {}),
      },
      select: { id: true, title: true, date: true, maxGrade: true },
      orderBy: { date: 'desc' },
    });
    return { ok: true, grades: assessments };
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────
  private validateVariants(variants: FormulaVariantDto[]) {
    if (!variants?.length) throw new BadRequestException('At least one format is required.');
    for (const v of variants) {
      if (!v.components?.length) throw new BadRequestException('Each format needs at least one grade.');
      const sum = v.components.reduce((acc, c) => acc + (c.weight ?? 0), 0);
      if (sum !== 100) {
        throw new BadRequestException(
          `Each format's percentages must sum to 100 (got ${sum}${v.label ? ` for "${v.label}"` : ''}).`,
        );
      }
    }
  }

  private async assertTeachesCohortSubject(user: any, cohortId: string, subject: string) {
    if (this.isAdmin(user)) return;
    const teacherId = this.userId(user);
    const slot = await this.prisma.scheduleSlot.findFirst({
      where: { teacherId, subject, cohorts: { some: { cohortId } } },
      select: { id: true },
    });
    // Fallback: allow if teacher has any slot in the cohort (co-taught/free-text).
    if (slot) return;
    const anySlot = await this.prisma.scheduleSlot.findFirst({
      where: { teacherId, cohorts: { some: { cohortId } } },
      select: { id: true },
    });
    if (!anySlot) throw new ForbiddenException('You do not teach this cohort.');
  }

  async create(user: any, dto: CreateGradeFormulaDto) {
    this.validateVariants(dto.variants);
    await this.assertTeachesCohortSubject(user, dto.cohortId, dto.subject);
    const schoolId = this.schoolId(user);
    if (!schoolId) throw new ForbiddenException('No school context.');
    const created = await this.prisma.gradeFormula.create({
      data: {
        schoolId,
        createdBy: this.userId(user),
        cohortId: dto.cohortId,
        subject: dto.subject,
        title: dto.title,
        units: dto.units ?? 0,
        variants: {
          create: dto.variants.map((v, i) => ({
            label: v.label ?? null,
            sortOrder: v.sortOrder ?? i,
            components: { create: v.components.map((c) => ({ assessmentId: c.assessmentId, weight: c.weight })) },
          })),
        },
      },
      include: { variants: { include: { components: true }, orderBy: { sortOrder: 'asc' } } },
    });
    return { ok: true, formula: created };
  }

  async update(user: any, id: string, dto: UpdateGradeFormulaDto) {
    const existing = await this.requireFormula(user, id);
    if (dto.variants) this.validateVariants(dto.variants);
    const updated = await this.prisma.$transaction(async (tx) => {
      await tx.gradeFormula.update({
        where: { id },
        data: {
          ...(dto.title !== undefined ? { title: dto.title } : {}),
          ...(dto.units !== undefined ? { units: dto.units } : {}),
        },
      });
      if (dto.variants) {
        // Replace variants wholesale (cascade deletes components).
        await tx.gradeFormulaVariant.deleteMany({ where: { formulaId: id } });
        for (let i = 0; i < dto.variants.length; i++) {
          const v = dto.variants[i];
          await tx.gradeFormulaVariant.create({
            data: {
              formulaId: id,
              label: v.label ?? null,
              sortOrder: v.sortOrder ?? i,
              components: { create: v.components.map((c) => ({ assessmentId: c.assessmentId, weight: c.weight })) },
            },
          });
        }
      }
      return tx.gradeFormula.findUnique({
        where: { id },
        include: { variants: { include: { components: true }, orderBy: { sortOrder: 'asc' } } },
      });
    });
    return { ok: true, formula: updated };
  }

  async remove(user: any, id: string) {
    await this.requireFormula(user, id);
    await this.prisma.gradeFormula.delete({ where: { id } });
    return { ok: true };
  }

  async list(user: any, cohortId?: string, subject?: string) {
    const schoolId = this.schoolId(user);
    const admin = this.isAdmin(user);
    const formulas = await this.prisma.gradeFormula.findMany({
      where: {
        ...(schoolId ? { schoolId } : {}),
        ...(admin ? {} : { createdBy: this.userId(user) }),
        ...(cohortId ? { cohortId } : {}),
        ...(subject ? { subject } : {}),
      },
      include: { variants: { include: { components: true }, orderBy: { sortOrder: 'asc' } } },
      orderBy: { createdAt: 'desc' },
    });
    return { ok: true, formulas };
  }

  private async requireFormula(user: any, id: string): Promise<LoadedFormula> {
    const f = (await this.prisma.gradeFormula.findUnique({
      where: { id },
      include: { variants: { include: { components: true }, orderBy: { sortOrder: 'asc' } } },
    })) as LoadedFormula | null;
    if (!f) throw new NotFoundException('Formula not found');
    const schoolId = this.schoolId(user);
    if (schoolId && f.schoolId !== schoolId) throw new ForbiddenException('Cross-school access denied');
    if (!this.isAdmin(user) && f.createdBy !== this.userId(user)) {
      throw new ForbiddenException('Not your formula');
    }
    return f;
  }

  // ── Compute (reused by the certificate generator) ──────────────────────────
  /**
   * Compute each student's average for a loaded formula. Auto-picks the
   * best-covered variant per student (most components present; tiebreak highest
   * covered weight). Renormalizes present weights to 100 when a variant is
   * partially covered. When [window] is given, only assessments whose date falls
   * in that semester window are considered.
   */
  async computeForFormula(
    formula: LoadedFormula,
    studentIds: string[],
    window?: SemesterWindow | null,
  ): Promise<StudentAverage[]> {
    if (!studentIds.length) return [];
    const allAssessmentIds = Array.from(
      new Set(formula.variants.flatMap((v) => v.components.map((c) => c.assessmentId))),
    );
    if (!allAssessmentIds.length) {
      return studentIds.map((studentId) => ({
        studentId,
        average: null,
        variantUsed: null,
        variantLabel: null,
        coverage: { covered: 0, total: 0 },
      }));
    }

    const assessments = await this.prisma.assessment.findMany({
      where: { id: { in: allAssessmentIds } },
      select: { id: true, date: true, maxGrade: true },
    });
    const assessmentById = new Map(assessments.map((a) => [a.id, a]));

    const records = await this.prisma.gradeRecord.findMany({
      where: { assessmentId: { in: allAssessmentIds }, studentId: { in: studentIds } },
      select: { assessmentId: true, studentId: true, grade: true },
    });
    // studentId → assessmentId → percentage grade
    const byStudent = new Map<string, Map<string, number>>();
    for (const r of records) {
      const a = assessmentById.get(r.assessmentId);
      if (!a) continue;
      if (window && !this.inWindow(a.date, window)) continue;
      const max = a.maxGrade && a.maxGrade > 0 ? a.maxGrade : 100;
      const pct = (r.grade / max) * 100;
      let m = byStudent.get(r.studentId);
      if (!m) {
        m = new Map();
        byStudent.set(r.studentId, m);
      }
      m.set(r.assessmentId, pct);
    }

    return studentIds.map((studentId) => {
      const grades = byStudent.get(studentId) ?? new Map<string, number>();
      let best: {
        variantId: string;
        label: string | null;
        average: number;
        covered: number;
        total: number;
        coveredWeight: number;
      } | null = null;

      for (const v of formula.variants) {
        // Components valid in this window (assessment exists & in window).
        const validComps = v.components.filter((c) => {
          const a = assessmentById.get(c.assessmentId);
          if (!a) return false;
          return !window || this.inWindow(a.date, window);
        });
        const total = validComps.length;
        const present = validComps.filter((c) => grades.has(c.assessmentId));
        const coveredWeight = present.reduce((acc, c) => acc + c.weight, 0);
        if (present.length === 0) continue;
        // Renormalize present weights to 100.
        const weighted = present.reduce((acc, c) => acc + grades.get(c.assessmentId)! * c.weight, 0);
        const average = weighted / coveredWeight;
        const candidate = {
          variantId: v.id,
          label: v.label,
          average,
          covered: present.length,
          total,
          coveredWeight,
        };
        if (
          !best ||
          candidate.covered > best.covered ||
          (candidate.covered === best.covered && candidate.coveredWeight > best.coveredWeight)
        ) {
          best = candidate;
        }
      }

      if (!best) {
        return { studentId, average: null, variantUsed: null, variantLabel: null, coverage: { covered: 0, total: 0 } };
      }
      return {
        studentId,
        average: Math.round(best.average),
        variantUsed: best.variantId,
        variantLabel: best.label,
        coverage: { covered: best.covered, total: best.total },
      };
    });
  }

  private inWindow(date: Date, w: SemesterWindow): boolean {
    const t = date.getTime();
    return t >= w.start.getTime() && t <= w.end.getTime();
  }

  /** Public compute endpoint: resolve a formula by id, then compute for students. */
  async compute(user: any, id: string, studentIds: string[], semesterNumber?: number | null) {
    const formula = await this.requireFormula(user, id);
    let window: SemesterWindow | null = null;
    if (semesterNumber) {
      window = await this.resolveCurrentWindow(formula.schoolId, semesterNumber);
    }
    const results = await this.computeForFormula(formula, studentIds, window);
    return { ok: true, results, window };
  }

  /** Resolve a concrete window for [semesterNumber] in the school's current academic year. */
  async resolveCurrentWindow(schoolId: string, semesterNumber: number): Promise<SemesterWindow | null> {
    const school = await this.prisma.school.findUnique({ where: { id: schoolId }, select: { semesters: true } });
    const sems = parseSchoolSemesters(school?.semesters ?? null);
    if (!sems.length) return null;
    const startYear = currentAcademicStartYear(sems, new Date());
    return windowForSemester(sems, startYear, semesterNumber);
  }

  /** Helper for the certificate service: load a formula for a cohort+subject in-school. */
  async findFormulaForCohortSubject(schoolId: string, cohortId: string, subject: string): Promise<LoadedFormula | null> {
    return (await this.prisma.gradeFormula.findFirst({
      where: { schoolId, cohortId, subject },
      include: { variants: { include: { components: true }, orderBy: { sortOrder: 'asc' } } },
      orderBy: { updatedAt: 'desc' },
    })) as LoadedFormula | null;
  }
}
