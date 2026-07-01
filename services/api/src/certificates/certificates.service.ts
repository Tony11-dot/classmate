import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
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
  constructor(private readonly prisma: PrismaService) {}

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
      select: { id: true, name: true, grade: true, schoolId: true, homeroomTeacherId: true },
    });
    if (!cohort) throw new NotFoundException('Cohort not found');
    if (cohort.schoolId && cohort.schoolId !== schoolId) throw new ForbiddenException('Cross-school access denied');

    const school = await this.prisma.school.findUnique({
      where: { id: schoolId },
      select: { name: true, logoUrl: true, semesters: true },
    });
    const sems = parseSchoolSemesters(school?.semesters ?? null);
    const startYear = currentAcademicStartYear(
      sems.length ? sems : [{ number: 1, startMonth: 9, endMonth: 6 }],
      new Date(),
    );
    const windows: SemesterWindow[] = semesterWindowsForYear(sems, startYear);
    const semesterCount = Math.max(windows.length, 2); // grid shows ≥2 columns
    const schoolYear = academicYearLabel(startYear);

    let weights = this.defaultWeights(semesterCount);
    if (semesterWeightsRaw) {
      const parsed = semesterWeightsRaw
        .split(',')
        .map((s) => Number(s.trim()))
        .filter((n) => Number.isFinite(n));
      if (parsed.length) weights = parsed;
    }

    const [cohorts, teacherNames] = await Promise.all([
      this.prisma.cohort.findMany({
        where: { schoolId },
        select: { id: true, name: true, grade: true, homeroomTeacherId: true },
        orderBy: { name: 'asc' },
      }),
      this.teacherNames(schoolId),
    ]);

    // Homeroom teacher default from the cohort, else the current user.
    let defaultHomeroomTeacher = (user?.name ?? '') as string;
    if (cohort.homeroomTeacherId) {
      const hr = await this.prisma.user.findUnique({
        where: { id: cohort.homeroomTeacherId },
        select: { name: true },
      });
      if (hr?.name) defaultHomeroomTeacher = hr.name;
    }

    let student: { id: string; name: string; nationalId: string | null } | null = null;
    let subjects: any[] = [];
    let overall: number | null = null;
    let attendance = { absences: 0, lates: 0 };
    let defaultPrincipalName = '';

    if (studentId) {
      const u = await this.prisma.user.findUnique({
        where: { id: studentId },
        select: { id: true, name: true, nationalId: true, schoolId: true, studentProfile: { select: { grade: true } } },
      });
      if (!u) throw new NotFoundException('Student not found');
      if (u.schoolId && u.schoolId !== schoolId) throw new ForbiddenException('Cross-school access denied');
      student = { id: u.id, name: u.name, nationalId: u.nationalId };

      const grade = u.studentProfile?.grade ?? cohort.grade;
      const computed = await this.computeSubjects(schoolId, cohortId, grade, studentId, windows, weights);
      subjects = computed.subjects;
      overall = computed.overall;
      attendance = await this.attendanceCounts(studentId, windows, startYear);
      defaultPrincipalName = await this.resolvePrincipalName(schoolId, grade);
    }

    return {
      ok: true,
      schoolName: school?.name ?? '',
      schoolLogoUrl: school?.logoUrl ?? null,
      schoolYear,
      semesterCount,
      semesterWeights: weights,
      defaultHomeroomTeacher,
      defaultPrincipalName,
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
    out[out.length - 1] = 100 - base * (count - 1);
    return out;
  }

  /** Which semester (1-based) an assessment counts toward. */
  private semesterOf(a: { semester: number | null; date: Date }, windows: SemesterWindow[]): number | null {
    if (a.semester && a.semester >= 1) return a.semester;
    const t = a.date.getTime();
    const w = windows.find((win) => t >= win.start.getTime() && t <= win.end.getTime());
    return w?.number ?? null;
  }

  /**
   * Per-subject semester averages + weighted final + overall, computed from the
   * student's graded assessments. Each grade's weight = its weightPercent (if
   * any in the subject/semester are weighted), else equal weights; averages are
   * renormalized over the grades the student actually has.
   */
  private async computeSubjects(
    schoolId: string,
    cohortId: string,
    grade: number | null,
    studentId: string,
    windows: SemesterWindow[],
    weights: number[],
  ) {
    const semesterCount = Math.max(windows.length, weights.length, 2);

    // The student's grades + the assessment meta needed to weight/bucket them.
    const records = await this.prisma.gradeRecord.findMany({
      where: { studentId },
      select: {
        grade: true,
        assessment: {
          select: { id: true, subject: true, date: true, semester: true, weightPercent: true, maxGrade: true },
        },
      },
    });

    // Group by subject (skip grades with no subject — they can't sit in the grid).
    const bySubject = new Map<string, { pct: number; weight: number | null; sem: number | null }[]>();
    for (const r of records) {
      const a = r.assessment;
      if (!a || !a.subject || !a.subject.trim()) continue;
      const max = a.maxGrade && a.maxGrade > 0 ? a.maxGrade : 100;
      const pct = (r.grade / max) * 100;
      const key = a.subject.trim();
      const arr = bySubject.get(key) ?? [];
      arr.push({ pct, weight: a.weightPercent ?? null, sem: this.semesterOf(a, windows) });
      bySubject.set(key, arr);
    }

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
    const finals: number[] = [];

    for (const [subject, items] of bySubject.entries()) {
      const semAverages: (number | null)[] = [];
      for (let n = 1; n <= semesterCount; n++) {
        const inSem = items.filter((it) => it.sem === n);
        semAverages.push(this.weightedAverage(inSem));
      }
      const final = this.weightedFinal(semAverages, weights);
      const teachers = await this.subjectTeachers(cohortId, subject);
      const i18n = i18nByKey.get(subject.toLowerCase()) ?? null;
      subjects.push({ subject, i18n, teachers, semesters: semAverages, final });
      if (final != null) finals.push(final);
    }

    subjects.sort((a, b) => a.subject.localeCompare(b.subject));
    const overall = finals.length ? Math.round(finals.reduce((s, x) => s + x, 0) / finals.length) : null;
    return { subjects, overall };
  }

  /** %-weighted mean, renormalized; equal weights when none are set. */
  private weightedAverage(items: { pct: number; weight: number | null }[]): number | null {
    if (!items.length) return null;
    const anyWeighted = items.some((it) => (it.weight ?? 0) > 0);
    let num = 0;
    let den = 0;
    for (const it of items) {
      const w = anyWeighted ? (it.weight ?? 0) : 1;
      if (w <= 0) continue;
      num += it.pct * w;
      den += w;
    }
    if (den === 0) return null;
    return Math.round(num / den);
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

  /** Teacher name(s) for a subject in a cohort, derived from the schedule. */
  private async subjectTeachers(cohortId: string, subject: string): Promise<string[]> {
    const slots = await this.prisma.scheduleSlot.findMany({
      where: { cohorts: { some: { cohortId } }, subject, teacherId: { not: null } },
      select: { teacher: { select: { name: true } } },
      distinct: ['teacherId'],
    });
    const names = slots.map((s) => s.teacher?.name).filter((n): n is string => !!n);
    return Array.from(new Set(names));
  }

  /** Name of the principal responsible for [grade], or ''. */
  private async resolvePrincipalName(schoolId: string, grade: number | null): Promise<string> {
    const principals = await this.prisma.user.findMany({
      where: { schoolId, isPrincipal: true },
      select: { name: true, principalGrades: true },
      orderBy: { name: 'asc' },
    });
    if (!principals.length) return '';
    if (grade != null) {
      const forGrade = principals.find((p) => (p.principalGrades ?? []).includes(grade));
      if (forGrade) return forGrade.name;
    }
    const anyAll = principals.find((p) => !(p.principalGrades ?? []).length);
    return (anyAll ?? principals[0]).name;
  }

  private async attendanceCounts(studentId: string, windows: SemesterWindow[], startYear: number) {
    let start: Date;
    let end: Date;
    if (windows.length) {
      start = windows.reduce((a, w) => (w.start < a ? w.start : a), windows[0].start);
      end = windows.reduce((a, w) => (w.end > a ? w.end : a), windows[0].end);
    } else {
      start = new Date(startYear, 8, 1);
      end = new Date(startYear + 1, 7, 31, 23, 59, 59);
    }
    const records = await this.prisma.attendanceRecord.findMany({
      where: { studentId, status: { in: ['ABSENT', 'LATE'] }, session: { date: { gte: start, lte: end } } },
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

    const cohort = await this.prisma.cohort.findUnique({ where: { id: dto.cohortId }, select: { schoolId: true } });
    if (!cohort) throw new NotFoundException('Cohort not found');
    if (cohort.schoolId && cohort.schoolId !== schoolId) throw new ForbiddenException('Cross-school access denied');

    let snapshot: any = dto.snapshot ?? {};
    if (dto.studentId) {
      const pre = await this.prefill(user, dto.cohortId, dto.studentId, weights.length ? weights.join(',') : undefined);
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
