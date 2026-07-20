import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { requireParentChild } from '../auth/scope';
import { PrismaService } from '../prisma/prisma.service';
import {
  parseSchoolSemesters,
  currentAcademicStartYear,
  semesterWindowsForYear,
  academicYearLabel,
  SemesterWindow,
} from '../common/semester';
import { CreateCertificateDto } from './dto/certificate.dto';
import { hasAnyRole } from '../auth/permissions';

/** Round to 2 decimals, keeping the client free to round-half-up or show 2dp. */
function round2(n: number): number {
  return Math.round(n * 100) / 100;
}

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

  private isAdmin(user: any): boolean {
    return hasAnyRole(user, ['ADMIN'] as any);
  }
  /// A teacher who is NOT also an admin — the homeroom-scoped case.
  private isTeacherScoped(user: any): boolean {
    return hasAnyRole(user, ['TEACHER'] as any) && !this.isAdmin(user);
  }
  /// Secretary who is neither admin nor teacher — read-only.
  private isSecretaryReadOnly(user: any): boolean {
    return hasAnyRole(user, ['SECRETARY'] as any) && !this.isAdmin(user) && !hasAnyRole(user, ['TEACHER'] as any);
  }

  /// Cohort ids the current user may act on. Admin/secretary → every homeroom
  /// cohort in the school (only homerooms carry certificates). Teacher → only
  /// the cohorts where THEY are the homeroom teacher.
  private async accessibleCohortIds(user: any): Promise<string[]> {
    const schoolId = this.schoolId(user);
    const where: any = { schoolId, homeroomTeacherId: { not: null } };
    if (this.isTeacherScoped(user)) where.homeroomTeacherId = this.userId(user);
    const rows = await this.prisma.cohort.findMany({ where, select: { id: true } });
    return rows.map((c) => c.id);
  }

  /// Guard a single cohort. Cross-school + homeroom-teacher scoping, and blocks
  /// writes for read-only secretaries.
  private async assertCohortAccess(user: any, cohortId: string, opts: { write?: boolean } = {}) {
    const schoolId = this.schoolId(user);
    const cohort = await this.prisma.cohort.findUnique({
      where: { id: cohortId },
      select: { schoolId: true, homeroomTeacherId: true },
    });
    if (!cohort) throw new NotFoundException('Cohort not found');
    if (cohort.schoolId && cohort.schoolId !== schoolId) throw new ForbiddenException('Cross-school access denied');
    if (opts.write && this.isSecretaryReadOnly(user)) {
      throw new ForbiddenException('Secretaries have read-only access to certificates.');
    }
    if (this.isTeacherScoped(user) && cohort.homeroomTeacherId !== this.userId(user)) {
      throw new ForbiddenException('You can only manage certificates for your homeroom class.');
    }
    return cohort;
  }

  // ── Prefill — everything the certificate form needs, computed server-side ──
  async prefill(user: any, cohortId: string, studentId?: string, semesterWeightsRaw?: string) {
    const schoolId = this.schoolId(user);
    if (!cohortId) throw new BadRequestException('cohortId is required');
    await this.assertCohortAccess(user, cohortId);

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
    // Semesters are admin-defined (School.semesters) — honor the real count
    // (a school can have 1, 2, 3, … semesters). Fall back to 2 only when the
    // school configured none at all.
    const semesterCount = windows.length > 0 ? windows.length : 2;
    const schoolYear = academicYearLabel(startYear);

    let weights = this.defaultWeights(semesterCount);
    if (semesterWeightsRaw) {
      const parsed = semesterWeightsRaw
        .split(',')
        .map((s) => Number(s.trim()))
        .filter((n) => Number.isFinite(n));
      if (parsed.length) weights = parsed;
    }

    const [cohorts, teacherNames, principalNames] = await Promise.all([
      this.prisma.cohort.findMany({
        where: { schoolId },
        select: { id: true, name: true, grade: true, homeroomTeacherId: true },
        orderBy: { name: 'asc' },
      }),
      this.teacherNames(schoolId),
      this.prisma.user
        .findMany({ where: { schoolId, isPrincipal: true }, select: { name: true }, orderBy: { name: 'asc' } })
        .then((rows) => Array.from(new Set(rows.map((r) => r.name).filter(Boolean)))),
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
      principalNames,
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
    const semesterCount = windows.length > 0 ? windows.length : Math.max(weights.length, 2);

    // The student's grades + the assessment meta needed to weight/bucket them.
    const records = await this.prisma.gradeRecord.findMany({
      where: { studentId },
      select: {
        grade: true,
        assessment: {
          select: {
            id: true,
            subject: true,
            date: true,
            semester: true,
            weightPercent: true,
            weightPercents: true,
            maxGrade: true,
            createdBy: true,
          },
        },
      },
    });

    // Group by subject (skip grades with no subject — they can't sit in the grid).
    const bySubject = new Map<string, { pct: number; weights: number[]; sem: number | null }[]>();
    // Subject teacher(s) = whoever recorded the grades in that subject.
    const bySubjectGraders = new Map<string, Set<string>>();
    for (const r of records) {
      const a = r.assessment;
      if (!a || !a.subject || !a.subject.trim()) continue;
      const max = a.maxGrade && a.maxGrade > 0 ? a.maxGrade : 100;
      const pct = (r.grade / max) * 100;
      const key = a.subject.trim();
      const weights = (a.weightPercents ?? []).length
        ? (a.weightPercents as number[])
        : a.weightPercent != null
          ? [a.weightPercent]
          : [];
      const arr = bySubject.get(key) ?? [];
      arr.push({ pct, weights, sem: this.semesterOf(a, windows) });
      bySubject.set(key, arr);
      if (a.createdBy) {
        const g = bySubjectGraders.get(key) ?? new Set<string>();
        g.add(a.createdBy);
        bySubjectGraders.set(key, g);
      }
    }

    // Resolve all grader ids → names once.
    const graderIds = Array.from(new Set(Array.from(bySubjectGraders.values()).flatMap((s) => Array.from(s))));
    const graderUsers = graderIds.length
      ? await this.prisma.user.findMany({ where: { id: { in: graderIds } }, select: { id: true, name: true } })
      : [];
    const graderName = new Map(graderUsers.map((u) => [u.id, u.name]));

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
      const graders = Array.from(bySubjectGraders.get(subject) ?? new Set<string>());
      const teachers = graders.map((id) => graderName.get(id)).filter((n): n is string => !!n);
      const i18n = i18nByKey.get(subject.toLowerCase()) ?? null;
      subjects.push({ subject, i18n, teachers, semesters: semAverages, final });
      if (final != null) finals.push(final);
    }

    subjects.sort((a, b) => a.subject.localeCompare(b.subject));
    const overall = finals.length ? round2(finals.reduce((s, x) => s + x, 0) / finals.length) : null;
    return { subjects, overall };
  }

  /**
   * %-weighted mean, renormalized. Supports multiple weight "formats": the
   * average is computed under each format and the BEST (highest) is returned
   * (student-favouring). Equal weights when no grade carries a weight.
   * Returns a 2-decimal number — the client rounds/formats per its toggle.
   */
  private weightedAverage(items: { pct: number; weights: number[] }[]): number | null {
    if (!items.length) return null;
    const formatCount = items.reduce((m, it) => Math.max(m, it.weights.length), 0);

    // No weights anywhere → simple mean.
    if (formatCount === 0) {
      const mean = items.reduce((s, it) => s + it.pct, 0) / items.length;
      return round2(mean);
    }

    let best: number | null = null;
    for (let f = 0; f < formatCount; f++) {
      let num = 0;
      let den = 0;
      for (const it of items) {
        // A grade with no weight for format f falls back to its last weight so
        // partially-configured formats still count it.
        const w = it.weights.length ? (it.weights[f] ?? it.weights[it.weights.length - 1]) : 0;
        if (w <= 0) continue;
        num += it.pct * w;
        den += w;
      }
      if (den === 0) continue;
      const avg = num / den;
      if (best == null || avg > best) best = avg;
    }
    if (best == null) {
      const mean = items.reduce((s, it) => s + it.pct, 0) / items.length;
      return round2(mean);
    }
    return round2(best);
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
    return round2(num / den);
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
  private validateWeights(weights: number[]) {
    if (weights.length) {
      const sum = weights.reduce((a, b) => a + b, 0);
      if (sum !== 100) throw new BadRequestException(`Semester weights must sum to 100 (got ${sum}).`);
    }
  }

  /// Build the frozen snapshot for a student (subjects/averages/attendance).
  private async buildSnapshot(user: any, dto: CreateCertificateDto, weights: number[]) {
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
    return snapshot;
  }

  async create(user: any, dto: CreateCertificateDto) {
    const schoolId = this.schoolId(user);
    const weights = dto.semesterWeights ?? [];
    this.validateWeights(weights);
    await this.assertCohortAccess(user, dto.cohortId, { write: true });

    const snapshot = await this.buildSnapshot(user, dto, weights);

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
        published: dto.published ?? false,
      },
    });
    return { ok: true, certificate: created };
  }

  /// Edit an existing certificate. Admin can edit any; a homeroom teacher only
  /// their own class's. Re-freezes the snapshot from the (possibly new) weights.
  async update(user: any, id: string, dto: CreateCertificateDto) {
    const schoolId = this.schoolId(user);
    const existing = await this.prisma.schoolCertificate.findUnique({ where: { id } });
    if (!existing || existing.schoolId !== schoolId) throw new NotFoundException('Certificate not found');
    const cohortId = dto.cohortId || existing.cohortId;
    // Authorize against the certificate's CURRENT cohort — otherwise a homeroom
    // teacher could pass their own cohort in the body to pass the check while
    // editing (and reassigning) another homeroom's certificate by id.
    await this.assertCohortAccess(user, existing.cohortId, { write: true });
    // If the edit reassigns the certificate to a different cohort, the caller
    // must also own the destination.
    if (cohortId !== existing.cohortId) {
      await this.assertCohortAccess(user, cohortId, { write: true });
    }

    const weights = dto.semesterWeights ?? (existing.semesterWeights as number[]) ?? [];
    this.validateWeights(weights);
    const snapshot = await this.buildSnapshot(user, { ...dto, cohortId }, weights);

    const updated = await this.prisma.schoolCertificate.update({
      where: { id },
      data: {
        studentId: dto.studentId ?? existing.studentId,
        studentDisplayName: dto.studentDisplayName,
        nationalId: dto.nationalId ?? null,
        cohortId,
        homeroomTeacher: dto.homeroomTeacher,
        principalName: dto.principalName,
        language: dto.language,
        publisherNote: dto.publisherNote ?? null,
        schoolYear: dto.schoolYear,
        semesterWeights: weights,
        snapshot,
        pdfUrl: dto.pdfUrl ?? existing.pdfUrl,
        published: dto.published ?? existing.published,
      },
    });
    return { ok: true, certificate: updated };
  }

  /// One certificate for the edit form (admin / owner teacher).
  async getOne(user: any, id: string) {
    const schoolId = this.schoolId(user);
    const cert = await this.prisma.schoolCertificate.findUnique({ where: { id } });
    if (!cert || cert.schoolId !== schoolId) throw new NotFoundException('Certificate not found');
    await this.assertCohortAccess(user, cert.cohortId); // read scope (teacher → own class)
    return { ok: true, certificate: cert };
  }

  async list(user: any, cohortId?: string) {
    const schoolId = this.schoolId(user);
    // Admin/secretary see all; a homeroom teacher only their own class(es).
    let where: any = { schoolId };
    if (this.isTeacherScoped(user)) {
      const ids = await this.accessibleCohortIds(user);
      where.cohortId = cohortId && ids.includes(cohortId) ? cohortId : { in: ids };
    } else if (cohortId) {
      where.cohortId = cohortId;
    }
    const certificates = await this.prisma.schoolCertificate.findMany({
      where,
      orderBy: { issuedAt: 'desc' },
    });
    return { ok: true, certificates };
  }

  /// Published certificates for a cohort, for the secretary/admin "print all"
  /// action (each carries its pdfUrl).
  async byCohortForPrint(user: any, cohortId: string) {
    if (!cohortId) throw new BadRequestException('cohortId is required');
    await this.assertCohortAccess(user, cohortId);
    const certificates = await this.prisma.schoolCertificate.findMany({
      where: { schoolId: this.schoolId(user), cohortId, published: true },
      orderBy: { studentDisplayName: 'asc' },
    });
    return { ok: true, certificates };
  }

  /// The logged-in student's own PUBLISHED certificates (downloadable).
  async studentCertificates(user: any) {
    const schoolId = this.schoolId(user);
    const studentId = this.userId(user);
    const certificates = await this.prisma.schoolCertificate.findMany({
      where: { schoolId, studentId, published: true },
      orderBy: { issuedAt: 'desc' },
    });
    return { ok: true, certificates };
  }

  /// A parent's view of one linked child's PUBLISHED certificates — gated
  /// by the APPROVED ParentChild link, same guard as the rest of the
  /// parent surface.
  async childCertificates(user: any, studentId: string) {
    await requireParentChild(this.prisma, this.userId(user), studentId);
    const certificates = await this.prisma.schoolCertificate.findMany({
      where: { studentId, published: true },
      orderBy: { issuedAt: 'desc' },
    });
    return { ok: true, certificates };
  }

  async cohorts(user: any) {
    // Only homeroom cohorts carry certificates. Teachers see just their own
    // homeroom(s); admin/secretary see every homeroom cohort in the school.
    const schoolId = this.schoolId(user);
    const where: any = { schoolId, homeroomTeacherId: { not: null } };
    if (this.isTeacherScoped(user)) where.homeroomTeacherId = this.userId(user);
    const cohorts = await this.prisma.cohort.findMany({
      where,
      select: { id: true, name: true, grade: true },
      orderBy: { name: 'asc' },
    });
    return { ok: true, cohorts };
  }

  async studentsInCohort(user: any, cohortId: string) {
    const schoolId = this.schoolId(user);
    if (!cohortId) throw new BadRequestException('cohortId is required');
    await this.assertCohortAccess(user, cohortId);
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
