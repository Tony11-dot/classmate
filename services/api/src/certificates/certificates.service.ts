import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AveragesService } from '../averages/averages.service';
import {
  parseSchoolSemesters,
  currentAcademicStartYear,
  semesterWindowsForYear,
  academicYearLabel,
  SemesterWindow,
} from '../common/semester';
import { CreateCertificateDto } from './dto/certificate.dto';

@Injectable()
export class CertificatesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly averages: AveragesService,
  ) {}

  private userId(user: any): string {
    return (user?.id ?? user?.sub ?? '') as string;
  }
  private schoolId(user: any): string {
    const s = (user?.schoolId ?? null) as string | null;
    if (!s) throw new ForbiddenException('No school context.');
    return s;
  }

  // ── Prefill — everything the certificate form needs, computed server-side ──
  async prefill(user: any, cohortId: string, studentId?: string, semesterWeightsRaw?: string) {
    const schoolId = this.schoolId(user);
    if (!cohortId) throw new BadRequestException('cohortId is required');

    const cohort = await this.prisma.cohort.findUnique({
      where: { id: cohortId },
      select: { id: true, name: true, grade: true, schoolId: true },
    });
    if (!cohort) throw new NotFoundException('Cohort not found');
    if (cohort.schoolId && cohort.schoolId !== schoolId) throw new ForbiddenException('Cross-school access denied');

    // School + semester setup.
    const school = await this.prisma.school.findUnique({
      where: { id: schoolId },
      select: { name: true, logoUrl: true, semesters: true },
    });
    const sems = parseSchoolSemesters(school?.semesters ?? null);
    const startYear = currentAcademicStartYear(sems.length ? sems : [{ number: 1, startMonth: 9, endMonth: 6 }], new Date());
    const windows: SemesterWindow[] = semesterWindowsForYear(sems, startYear);
    const semesterCount = Math.max(windows.length, 1);
    const schoolYear = academicYearLabel(startYear);

    // Default semester weights (even split) unless provided.
    let weights = this.defaultWeights(semesterCount);
    if (semesterWeightsRaw) {
      const parsed = semesterWeightsRaw
        .split(',')
        .map((s) => Number(s.trim()))
        .filter((n) => Number.isFinite(n));
      if (parsed.length) weights = parsed;
    }

    // Cohorts (homerooms) for the picker + teacher names for the DDL.
    const [cohorts, teacherNames] = await Promise.all([
      this.prisma.cohort.findMany({
        where: { schoolId },
        select: { id: true, name: true, grade: true },
        orderBy: { name: 'asc' },
      }),
      this.teacherNames(schoolId),
    ]);

    // Resolve the student (if chosen) + per-subject averages.
    let student: { id: string; name: string; nationalId: string | null } | null = null;
    let subjects: any[] = [];
    let overall: number | null = null;
    let attendance = { absences: 0, lates: 0 };

    if (studentId) {
      const u = await this.prisma.user.findUnique({
        where: { id: studentId },
        select: { id: true, name: true, nationalId: true, schoolId: true },
      });
      if (!u) throw new NotFoundException('Student not found');
      if (u.schoolId && u.schoolId !== schoolId) throw new ForbiddenException('Cross-school access denied');
      student = { id: u.id, name: u.name, nationalId: u.nationalId };

      const computed = await this.computeSubjects(schoolId, cohortId, cohort.grade, studentId, windows, weights);
      subjects = computed.subjects;
      overall = computed.overall;
      attendance = await this.attendanceCounts(studentId, windows, startYear);
    }

    return {
      ok: true,
      schoolName: school?.name ?? '',
      schoolLogoUrl: school?.logoUrl ?? null,
      schoolYear,
      semesterCount,
      semesterWeights: weights,
      defaultHomeroomTeacher: (user?.name ?? '') as string,
      defaultPrincipalName: '',
      cohorts,
      teacherNames,
      cohort: { id: cohort.id, name: cohort.name, grade: cohort.grade },
      student,
      subjects,
      overall,
      attendance,
    };
  }

  private defaultWeights(count: number): number[] {
    if (count <= 1) return [100];
    const base = Math.floor(100 / count);
    const out = new Array(count).fill(base);
    out[out.length - 1] = 100 - base * (count - 1); // remainder on last
    return out;
  }

  /** Per-subject semester averages + weighted final + overall (units-aware). */
  private async computeSubjects(
    schoolId: string,
    cohortId: string,
    grade: number | null,
    studentId: string,
    windows: SemesterWindow[],
    weights: number[],
  ) {
    // Subjects that have a formula for this cohort.
    const formulas = await this.prisma.gradeFormula.findMany({
      where: { schoolId, cohortId },
      select: { subject: true },
      distinct: ['subject'],
    });

    // i18n display names for the cohort's grade.
    const defaultRow = grade == null
      ? null
      : await this.prisma.schoolGradeSubjectDefault.findFirst({
          where: { schoolId, grade },
          select: { subjectsI18n: true },
        });
    const i18nList = ((defaultRow?.subjectsI18n as any[]) ?? []).filter(Boolean);
    const i18nByKey = new Map<string, any>();
    for (const c of i18nList) {
      for (const v of [c.nameEn, c.nameAr, c.nameHe, c.nameFr, c.nameRu]) {
        if (v && String(v).trim()) i18nByKey.set(String(v).trim().toLowerCase(), c);
      }
    }

    const subjects: any[] = [];
    const finals: { final: number; units: number }[] = [];

    for (const f of formulas) {
      const formula = await this.averages.findFormulaForCohortSubject(schoolId, cohortId, f.subject);
      if (!formula) continue;

      const semAverages: (number | null)[] = [];
      for (const w of windows) {
        const [res] = await this.averages.computeForFormula(formula, [studentId], w);
        semAverages.push(res?.average ?? null);
      }
      // Whole-year (no window) fallback when there are no configured semesters.
      if (windows.length === 0) {
        const [res] = await this.averages.computeForFormula(formula, [studentId], null);
        semAverages.push(res?.average ?? null);
      }

      const final = this.weightedFinal(semAverages, weights);
      const i18n = i18nByKey.get(f.subject.trim().toLowerCase()) ?? null;
      subjects.push({
        subject: f.subject,
        i18n,
        units: formula.units ?? 0,
        semesters: semAverages,
        final,
      });
      if (final != null) finals.push({ final, units: formula.units ?? 0 });
    }

    // Overall: units-weighted when any subject carries units, else simple mean.
    let overall: number | null = null;
    if (finals.length) {
      const anyUnits = finals.some((x) => x.units > 0);
      if (anyUnits) {
        const totUnits = finals.reduce((a, x) => a + (x.units > 0 ? x.units : 0), 0);
        if (totUnits > 0) {
          overall = Math.round(finals.reduce((a, x) => a + x.final * (x.units > 0 ? x.units : 0), 0) / totUnits);
        }
      }
      if (overall == null) {
        overall = Math.round(finals.reduce((a, x) => a + x.final, 0) / finals.length);
      }
    }

    return { subjects, overall };
  }

  private weightedFinal(semAverages: (number | null)[], weights: number[]): number | null {
    let num = 0;
    let den = 0;
    for (let i = 0; i < semAverages.length; i++) {
      const v = semAverages[i];
      if (v == null) continue;
      const w = weights[i] ?? (semAverages.length ? 100 / semAverages.length : 0);
      num += v * w;
      den += w;
    }
    if (den === 0) return null;
    return Math.round(num / den);
  }

  /** Absence/late counts for a student across the school year. */
  private async attendanceCounts(studentId: string, windows: SemesterWindow[], startYear: number) {
    // Year window = union of semester windows, or a Sep→Aug fallback.
    let start: Date;
    let end: Date;
    if (windows.length) {
      start = windows.reduce((a, w) => (w.start < a ? w.start : a), windows[0].start);
      end = windows.reduce((a, w) => (w.end > a ? w.end : a), windows[0].end);
    } else {
      start = new Date(startYear, 8, 1); // Sep 1
      end = new Date(startYear + 1, 7, 31, 23, 59, 59); // Aug 31
    }
    const records = await this.prisma.attendanceRecord.findMany({
      where: {
        studentId,
        status: { in: ['ABSENT', 'LATE'] },
        session: { date: { gte: start, lte: end } },
      },
      select: { status: true },
    });
    let absences = 0;
    let lates = 0;
    for (const r of records) {
      if (r.status === 'ABSENT') absences++;
      else if (r.status === 'LATE') lates++;
    }
    return { absences, lates };
  }

  private async teacherNames(schoolId: string): Promise<string[]> {
    const teachers = await this.prisma.user.findMany({
      where: { schoolId, roles: { some: { role: 'TEACHER' } } },
      select: { name: true },
      orderBy: { name: 'asc' },
    });
    return Array.from(new Set(teachers.map((t) => t.name).filter(Boolean)));
  }

  // ── Create / list ──────────────────────────────────────────────────────────
  async create(user: any, dto: CreateCertificateDto) {
    const schoolId = this.schoolId(user);
    const weights = dto.semesterWeights ?? [];
    if (weights.length) {
      const sum = weights.reduce((a, b) => a + b, 0);
      if (sum !== 100) throw new BadRequestException(`Semester weights must sum to 100 (got ${sum}).`);
    }

    // Validate cohort in-school.
    const cohort = await this.prisma.cohort.findUnique({ where: { id: dto.cohortId }, select: { schoolId: true } });
    if (!cohort) throw new NotFoundException('Cohort not found');
    if (cohort.schoolId && cohort.schoolId !== schoolId) throw new ForbiddenException('Cross-school access denied');

    // Re-compute and freeze a snapshot at issue time (server-authoritative).
    let snapshot: any = dto.snapshot ?? {};
    if (dto.studentId) {
      const pre = await this.prefill(
        user,
        dto.cohortId,
        dto.studentId,
        weights.length ? weights.join(',') : undefined,
      );
      snapshot = {
        subjects: pre.subjects,
        overall: pre.overall,
        attendance: pre.attendance,
        schoolYear: pre.schoolYear,
        schoolName: pre.schoolName,
        ...(dto.snapshot ?? {}),
      };
    }

    const created = await this.prisma.schoolCertificate.create({
      data: {
        schoolId,
        issuedBy: this.userId(user),
        studentId: dto.studentId ?? null,
        studentDisplayName: dto.studentDisplayName,
        nationalId: dto.nationalId ?? null,
        cohortId: dto.cohortId,
        homeroomTeacher: dto.homeroomTeacher,
        principalName: dto.principalName,
        language: dto.language,
        publisherNote: dto.publisherNote ?? null,
        schoolYear: dto.schoolYear,
        semesterWeights: weights,
        snapshot,
        pdfUrl: dto.pdfUrl ?? null,
      },
    });
    return { ok: true, certificate: created };
  }

  async list(user: any, cohortId?: string) {
    const schoolId = this.schoolId(user);
    const certificates = await this.prisma.schoolCertificate.findMany({
      where: { schoolId, ...(cohortId ? { cohortId } : {}) },
      orderBy: { issuedAt: 'desc' },
    });
    return { ok: true, certificates };
  }

  async cohorts(user: any) {
    const schoolId = this.schoolId(user);
    const cohorts = await this.prisma.cohort.findMany({
      where: { schoolId },
      select: { id: true, name: true, grade: true },
      orderBy: { name: 'asc' },
    });
    return { ok: true, cohorts };
  }

  async studentsInCohort(user: any, cohortId: string) {
    const schoolId = this.schoolId(user);
    if (!cohortId) throw new BadRequestException('cohortId is required');
    const links = await this.prisma.studentCohort.findMany({
      where: { cohortId },
      select: { student: { select: { userId: true, user: { select: { name: true, schoolId: true } } } } },
    });
    const students = links
      .map((l) => ({ id: l.student.userId, name: l.student.user?.name ?? '', schoolId: l.student.user?.schoolId }))
      .filter((s) => !s.schoolId || s.schoolId === schoolId)
      .map((s) => ({ id: s.id, name: s.name }))
      .sort((a, b) => a.name.localeCompare(b.name));
    return { ok: true, students };
  }
}
