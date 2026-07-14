import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { deriveUsernameCandidate, ensureUniqueUsername } from '../common/username';

// Platform-owner allowlist — mirrors jwt.strategy.ts. The owner account is
// always a manager and can never be revoked (lockout guard). Kept in lower
// case for comparison.
const ALLOWLIST_EMAILS = new Set(['aboudtony22@gmail.com']);
const ALLOWLIST_USERNAMES = new Set(['rafanadal22']);

function isAllowlisted(email?: string | null, username?: string | null): boolean {
  if (email && ALLOWLIST_EMAILS.has(String(email).trim().toLowerCase())) return true;
  if (username && ALLOWLIST_USERNAMES.has(String(username).trim().toLowerCase())) return true;
  return false;
}

type SubjectI18n = { nameEn: string; nameAr?: string; nameHe?: string; nameFr?: string; nameRu?: string };

@Injectable()
export class ManagerService {
  constructor(private readonly prisma: PrismaService) {}

  // ── Schools: list with stats ───────────────────────────────────────────────
  async listSchools() {
    const schools = await this.prisma.school.findMany({ orderBy: { createdAt: 'desc' } });

    const out = await Promise.all(schools.map(async (s: any) => {
      const [userRows, admins, cohortCount, classroomCount, subjectsRow] = await Promise.all([
        this.prisma.userRole.groupBy({
          by: ['role'],
          where: { user: { schoolId: s.id } } as any,
          _count: { userId: true },
        }) as any,
        this.prisma.user.findMany({
          where: { schoolId: s.id, roles: { some: { role: 'ADMIN' as any } } } as any,
          select: { id: true, email: true, username: true, name: true } as any,
          take: 20,
        }) as any,
        this.prisma.cohort.count({ where: { schoolId: s.id } } as any),
        this.prisma.classroom.count({ where: { schoolId: s.id } } as any),
        this.prisma.schoolGradeSubjectDefault.findUnique({
          where: { schoolId_grade_unique: { schoolId: s.id, grade: 0 } } as any,
          select: { subjects: true, subjectsI18n: true } as any,
        }) as any,
      ]);

      const userCounts: Record<string, number> = {};
      for (const row of userRows as any[]) userCounts[row.role] = row._count?.userId ?? 0;

      const subjectsI18n = Array.isArray(subjectsRow?.subjectsI18n) ? subjectsRow.subjectsI18n : [];
      const subjectCount = subjectsI18n.length || (subjectsRow?.subjects?.length ?? 0);

      return {
        id: s.id,
        name: s.name,
        logoUrl: s.logoUrl,
        minGrade: s.minGrade,
        maxGrade: s.maxGrade,
        createdAt: s.createdAt,
        userCounts,
        cohortCount,
        classroomCount,
        subjectCount,
        admins: (admins as any[]).map((a: any) => ({ id: a.id, name: a.name, email: a.email, username: a.username })),
      };
    }));

    return { ok: true, schools: out };
  }

  // ── Schools: single detail ─────────────────────────────────────────────────
  async getSchool(id: string) {
    const school = await this.prisma.school.findUnique({ where: { id } });
    if (!school) throw new NotFoundException('School not found');

    const [userRows, admins, cohortCount, classroomCount, subjectsRow] = await Promise.all([
      this.prisma.userRole.groupBy({
        by: ['role'],
        where: { user: { schoolId: id } } as any,
        _count: { userId: true },
      }) as any,
      this.prisma.user.findMany({
        where: { schoolId: id, roles: { some: { role: 'ADMIN' as any } } } as any,
        select: { id: true, email: true, username: true, name: true } as any,
      }) as any,
      this.prisma.cohort.count({ where: { schoolId: id } } as any),
      this.prisma.classroom.count({ where: { schoolId: id } } as any),
      this.prisma.schoolGradeSubjectDefault.findUnique({
        where: { schoolId_grade_unique: { schoolId: id, grade: 0 } } as any,
        select: { subjects: true, subjectsI18n: true } as any,
      }) as any,
    ]);

    const userCounts: Record<string, number> = {};
    for (const row of userRows as any[]) userCounts[row.role] = row._count?.userId ?? 0;
    const subjectsI18n = Array.isArray(subjectsRow?.subjectsI18n) ? subjectsRow.subjectsI18n : [];

    return {
      ok: true,
      school: { ...school, userCounts, cohortCount, classroomCount, admins, subjects: subjectsI18n },
    };
  }

  // ── Schools: create (or update-in-place by name) ───────────────────────────
  async createSchool(body: {
    schoolName: string;
    logoUrl?: string;
    minGrade?: number;
    maxGrade?: number;
    gradeRanges?: string;
    semesters?: string;
    subjects?: SubjectI18n[];
    bellSchedule?: { period: number; startTime: string; endTime: string }[];
    adminName: string;
    adminEmail?: string;
    adminUsername?: string;
    adminPassword: string;
  }) {
    const schoolName = String(body?.schoolName ?? '').trim();
    const adminName = String(body?.adminName ?? '').trim();
    const adminEmail = body?.adminEmail ? String(body.adminEmail).trim().toLowerCase() : undefined;
    const adminUsername = body?.adminUsername ? String(body.adminUsername).trim().toLowerCase() : undefined;
    const adminPassword = String(body?.adminPassword ?? '').trim();

    const errors: string[] = [];
    if (!schoolName) errors.push('School name is required.');
    if (!adminName) errors.push('Admin full name is required.');
    if (!adminEmail && !adminUsername) errors.push('Admin email or username is required.');
    if (!adminPassword || adminPassword.length < 6) errors.push('Password must be at least 6 characters.');
    if (errors.length) throw new BadRequestException(errors.join(' '));

    if (adminEmail) {
      const existing = await this.prisma.user.findFirst({ where: { email: adminEmail } });
      if (existing && (existing as any).schoolId) {
        throw new BadRequestException(`A user with email "${adminEmail}" already exists and belongs to another school. Use a different email or update the existing account.`);
      }
    }
    if (adminUsername) {
      const existing = await this.prisma.user.findFirst({ where: { username: adminUsername } } as any);
      if (existing && (existing as any).schoolId) {
        throw new BadRequestException(`Username "${adminUsername}" is already taken by a user in another school. Choose a different username.`);
      }
    }

    // Grade ranges (multi) → derive min/max.
    let gradeRangesCsv: string | undefined;
    let minGrade: number;
    let maxGrade: number;
    const rawRanges = String(body?.gradeRanges ?? '').trim();
    if (rawRanges) {
      const pairs: [number, number][] = [];
      for (const part of rawRanges.split(',')) {
        const [a, b] = part.split('-').map((x) => parseInt(x.trim(), 10));
        if (!Number.isFinite(a) || !Number.isFinite(b)) continue;
        const lo = Math.min(a, b), hi = Math.max(a, b);
        if (lo < 1 || hi > 20) throw new BadRequestException(`Invalid grade range ${a}–${b}. Grades must be 1..20.`);
        pairs.push([lo, hi]);
      }
      if (!pairs.length) throw new BadRequestException('At least one valid grade range is required.');
      gradeRangesCsv = pairs.map((p) => `${p[0]}-${p[1]}`).join(',');
      minGrade = Math.min(...pairs.map((p) => p[0]));
      maxGrade = Math.max(...pairs.map((p) => p[1]));
    } else {
      minGrade = Number.isFinite(body?.minGrade) ? Number(body!.minGrade) : 5;
      maxGrade = Number.isFinite(body?.maxGrade) ? Number(body!.maxGrade) : 12;
      if (minGrade < 1 || maxGrade > 20 || minGrade > maxGrade) {
        throw new BadRequestException(`Invalid grade range ${minGrade}–${maxGrade}. Must be 1..20 and min ≤ max.`);
      }
    }

    // Semesters (optional).
    let semestersCsv: string | undefined;
    const rawSems = String(body?.semesters ?? '').trim();
    if (rawSems) {
      const sems: string[] = [];
      for (const part of rawSems.split(',')) {
        const [s, e] = part.split('-').map((x) => parseInt(x.trim(), 10));
        if (!Number.isFinite(s) || !Number.isFinite(e)) continue;
        if (s < 1 || s > 12 || e < 1 || e > 12) throw new BadRequestException(`Invalid semester ${s}–${e}. Months must be 1..12.`);
        sems.push(`${s}-${e}`);
      }
      if (sems.length) semestersCsv = sems.join(',');
    }

    // Create / update school.
    let school = await this.prisma.school.findFirst({ where: { name: schoolName } });
    const schoolData: any = { name: schoolName, minGrade, maxGrade };
    if (gradeRangesCsv !== undefined) schoolData.gradeRanges = gradeRangesCsv;
    if (semestersCsv !== undefined) schoolData.semesters = semestersCsv;
    if (body?.logoUrl) schoolData.logoUrl = body.logoUrl;

    school = school
      ? await this.prisma.school.update({ where: { id: school.id }, data: schoolData })
      : await this.prisma.school.create({ data: schoolData });

    // Subjects.
    const subjectsI18n = (body?.subjects ?? [])
      .map((s) => ({
        nameEn: String(s?.nameEn ?? '').trim(),
        nameAr: s?.nameAr?.trim() || null,
        nameHe: s?.nameHe?.trim() || null,
        nameFr: s?.nameFr?.trim() || null,
        nameRu: s?.nameRu?.trim() || null,
      }))
      .filter((s) => s.nameEn.length > 0);
    if (subjectsI18n.length) {
      const flat = subjectsI18n.map((s) => s.nameEn);
      await this.prisma.schoolGradeSubjectDefault.upsert({
        where: { schoolId_grade_unique: { schoolId: school.id, grade: 0 } },
        update: { subjects: flat, subjectsI18n: subjectsI18n as any },
        create: { schoolId: school.id, grade: 0, subjects: flat, subjectsI18n: subjectsI18n as any },
      });
    }

    // Bell schedule.
    if (body?.bellSchedule?.length) {
      for (const d of body.bellSchedule) {
        await this.prisma.schoolPeriodDefault.upsert({
          where: { schoolId_period: { schoolId: school.id, period: d.period } },
          update: { startTime: d.startTime, endTime: d.endTime },
          create: { schoolId: school.id, period: d.period, startTime: d.startTime, endTime: d.endTime },
        }).catch(() => null);
      }
    }

    // Create / update admin.
    const hash = await bcrypt.hash(adminPassword, 12);
    const whereAdmin: any = adminEmail ? { email: adminEmail } : { username: adminUsername };
    let adminUser = await this.prisma.user.findFirst({ where: whereAdmin });

    if (!adminUser) {
      const usernameCandidate = adminUsername
        ? String(adminUsername).toLowerCase().replace(/[^a-z0-9_.-]/g, '')
        : deriveUsernameCandidate(adminEmail, adminName);
      const username = await ensureUniqueUsername(this.prisma, usernameCandidate);
      adminUser = await this.prisma.user.create({
        data: {
          name: adminName,
          ...(adminEmail ? { email: adminEmail } : {}),
          username,
          password: hash,
          schoolId: school.id,
          status: 'ACTIVE',
          roles: { create: [{ role: 'ADMIN' }] },
        } as any,
      });
    } else {
      await this.prisma.user.update({
        where: { id: adminUser.id },
        data: { schoolId: school.id, name: adminName, password: hash } as any,
      });
      await this.prisma.userRole.upsert({
        where: { userId_role: { userId: adminUser.id, role: 'ADMIN' as any } },
        update: {}, create: { userId: adminUser.id, role: 'ADMIN' as any },
      });
    }

    return {
      ok: true,
      school: { id: school.id, name: school.name, logoUrl: (school as any).logoUrl ?? null },
      admin: { id: adminUser.id, email: adminUser.email, username: (adminUser as any).username },
      loginWith: adminEmail ?? adminUsername,
    };
  }

  // ── Schools: update ────────────────────────────────────────────────────────
  async updateSchool(id: string, body: { name?: string; logoUrl?: string | null; minGrade?: number; maxGrade?: number }) {
    const target = await this.prisma.school.findUnique({ where: { id } });
    if (!target) throw new NotFoundException('School not found');

    const data: any = {};
    if (body.name !== undefined) {
      const n = String(body.name).trim();
      if (!n) throw new BadRequestException('Name cannot be empty.');
      data.name = n;
    }
    if (body.logoUrl !== undefined) data.logoUrl = body.logoUrl ? String(body.logoUrl).trim() : null;
    if (body.minGrade !== undefined || body.maxGrade !== undefined) {
      const min = body.minGrade !== undefined ? Number(body.minGrade) : (target as any).minGrade ?? 5;
      const max = body.maxGrade !== undefined ? Number(body.maxGrade) : (target as any).maxGrade ?? 12;
      if (!Number.isFinite(min) || !Number.isFinite(max) || min < 1 || max > 20 || min > max) {
        throw new BadRequestException(`Invalid grade range ${min}–${max}. Must be 1..20 and min ≤ max.`);
      }
      data.minGrade = min;
      data.maxGrade = max;
    }

    const updated = await this.prisma.school.update({ where: { id }, data });
    return { ok: true, school: updated };
  }

  // ── Schools: delete (cascade) ──────────────────────────────────────────────
  async deleteSchool(id: string) {
    const target = await this.prisma.school.findUnique({ where: { id } });
    if (!target) throw new NotFoundException('School not found');

    await this.prisma.$transaction([
      this.prisma.schoolGradeSubjectDefault.deleteMany({ where: { schoolId: id } } as any),
      this.prisma.schoolPeriodDefault.deleteMany({ where: { schoolId: id } } as any),
      this.prisma.user.deleteMany({ where: { schoolId: id } } as any),
      this.prisma.school.delete({ where: { id } }),
    ]);

    return { ok: true };
  }

  // ── Managers: list ─────────────────────────────────────────────────────────
  async listManagers() {
    const rows = await this.prisma.user.findMany({
      where: { roles: { some: { role: 'MANAGER' as any } } } as any,
      select: { id: true, name: true, email: true, username: true, createdAt: true } as any,
      orderBy: { createdAt: 'asc' } as any,
    }) as any[];

    const managers = rows.map((u) => ({
      id: u.id,
      name: u.name,
      email: u.email,
      username: u.username,
      isOwner: isAllowlisted(u.email, u.username),
    }));

    // The allowlisted owner is always a manager even if the DB has no MANAGER
    // role row for them yet — surface them so the list is never empty.
    const hasOwner = managers.some((m) => m.isOwner);
    if (!hasOwner) {
      const owner = await this.prisma.user.findFirst({
        where: { OR: [{ email: 'aboudtony22@gmail.com' }, { username: 'rafanadal22' }] } as any,
        select: { id: true, name: true, email: true, username: true } as any,
      }) as any;
      if (owner) {
        managers.unshift({ id: owner.id, name: owner.name, email: owner.email, username: owner.username, isOwner: true });
      }
    }

    return { ok: true, managers };
  }

  // ── Managers: add (grant to existing user, or create a new one) ─────────────
  async addManager(body: { name?: string; email?: string; username?: string; password?: string }) {
    const email = body?.email ? String(body.email).trim().toLowerCase() : undefined;
    const username = body?.username ? String(body.username).trim().toLowerCase() : undefined;
    const name = String(body?.name ?? '').trim();
    const password = String(body?.password ?? '').trim();

    if (!email && !username) throw new BadRequestException('Email or username is required.');

    // Find an existing user by email or username.
    const existing = await this.prisma.user.findFirst({
      where: {
        OR: [
          ...(email ? [{ email }] : []),
          ...(username ? [{ username }] : []),
        ],
      } as any,
    }) as any;

    if (existing) {
      await this.prisma.userRole.upsert({
        where: { userId_role: { userId: existing.id, role: 'MANAGER' as any } },
        update: {}, create: { userId: existing.id, role: 'MANAGER' as any },
      });
      return { ok: true, granted: true, user: { id: existing.id, name: existing.name, email: existing.email, username: existing.username } };
    }

    // Create a brand-new manager account.
    if (!name) throw new BadRequestException('Full name is required for a new manager.');
    if (!password || password.length < 6) throw new BadRequestException('Password must be at least 6 characters.');

    const hash = await bcrypt.hash(password, 12);
    const usernameCandidate = username
      ? username.replace(/[^a-z0-9_.-]/g, '')
      : deriveUsernameCandidate(email, name);
    const finalUsername = await ensureUniqueUsername(this.prisma, usernameCandidate);

    const created = await this.prisma.user.create({
      data: {
        name,
        ...(email ? { email } : {}),
        username: finalUsername,
        password: hash,
        status: 'ACTIVE',
        roles: { create: [{ role: 'MANAGER' }] },
      } as any,
    }) as any;

    return { ok: true, created: true, user: { id: created.id, name: created.name, email: created.email, username: created.username } };
  }

  // ── Managers: revoke ───────────────────────────────────────────────────────
  async revokeManager(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, email: true, username: true } as any,
    }) as any;
    if (!user) throw new NotFoundException('User not found');
    if (isAllowlisted(user.email, user.username)) {
      throw new BadRequestException('The platform owner cannot be removed as a manager.');
    }
    await this.prisma.userRole.deleteMany({ where: { userId, role: 'MANAGER' as any } } as any);
    return { ok: true };
  }
}
