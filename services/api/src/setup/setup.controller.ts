/**
 * Platform-owner-only school management UI.
 *   GET  /cms           → full school creation UI
 *   POST /cms/upload    → logo upload (protected by x-setup-secret)
 *   POST /cms/school    → create school with all settings
 */

import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  ForbiddenException,
  Get,
  Headers,
  HttpCode,
  NotFoundException,
  Param,
  Patch,
  Post,
  Req,
  Res,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { Throttle } from '@nestjs/throttler';
import { diskStorage } from 'multer';
import { extname, join } from 'path';
import { mkdirSync } from 'fs';
import { createHash, randomInt } from 'crypto';
import * as bcrypt from 'bcrypt';
import type { Request, Response } from 'express';
import { Public } from '../auth/decorators/public.decorator';
import { deriveUsernameCandidate, ensureUniqueUsername } from '../common/username';
import { PrismaService } from '../prisma/prisma.service';
import { SmsService } from '../auth/password-reset/sms.service';
import { EmailService } from '../auth/password-reset/email.service';
import { LOGO_DATA_URI } from './logo';

// In-memory store for the "Reset All Data" confirmation code. Sufficient for a
// single API instance; if Railway ever scales to >1 replica this needs Redis.
// Map key is a random session id we return to the caller; value is the hash of
// the code we SMS'd, plus its expiry.
const RESET_CODE_TTL_MIN = 15;
const resetCodeStore = new Map<string, { codeHash: string; expiresAt: number }>();

function defaultOwnerPhone(): string {
  return process.env.PLATFORM_OWNER_PHONE?.trim() || '+972525488441';
}

function defaultOwnerEmail(): string {
  return process.env.PLATFORM_OWNER_EMAIL?.trim() || 'support@classmateapp.org';
}

function maskPhone(p: string): string {
  if (p.length <= 4) return p;
  return `${p.slice(0, 4)}…${p.slice(-2)}`;
}

function maskEmail(e: string): string {
  const at = e.indexOf('@');
  if (at < 2) return e;
  return `${e.slice(0, 2)}…${e.slice(at)}`;
}

function ensureUploadsDir() {
  mkdirSync(join(process.cwd(), 'uploads', 'setup'), { recursive: true });
}

function checkSecret(provided: string | undefined): void {
  const expected = process.env.SETUP_SECRET;
  // Both "missing" and "wrong" return the same generic error so a
  // probing attacker can't tell whether SETUP_SECRET is unset on the
  // server (info disclosure) vs whether they guessed wrong.
  // Operators see the missing-secret case in server logs instead.
  if (!expected || expected.length < 16) {
    // eslint-disable-next-line no-console
    console.error('[setup] SETUP_SECRET missing or too short on this server — all /cms mutating routes will 403.');
    throw new ForbiddenException('Forbidden');
  }
  if (provided !== expected) throw new ForbiddenException('Forbidden');
}

@Controller('cms')
export class SetupController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly sms: SmsService,
    private readonly email: EmailService,
  ) {}

  // ── Page UI ────────────────────────────────────────────────────────────────

  @Public()
  @Get()
  ui(@Res() res: Response) {
    res.setHeader('Content-Type', 'text/html');
    res.send(buildPage());
  }

  // ── Logo upload ────────────────────────────────────────────────────────────
  // All mutating /cms routes are throttled on the strict 'auth' bucket
  // (5 attempts per 15 min per IP) so even a leaked-secret scenario
  // can't be brute-forced from one box.

  @Public()
  @Throttle({ auth: { limit: 5, ttl: 15 * 60_000 } })
  @Post('upload')
  @HttpCode(200)
  @UseInterceptors(FileInterceptor('file', {
    storage: diskStorage({
      destination: (_req, _file, cb) => {
        ensureUploadsDir();
        cb(null, join(process.cwd(), 'uploads', 'setup'));
      },
      filename: (_req, file, cb) => {
        const stamp = Date.now();
        const ext = extname(file.originalname) || '.png';
        cb(null, `logo-${stamp}${ext}`);
      },
    }),
    limits: { fileSize: 5 * 1024 * 1024 },
    fileFilter: (_req, file, cb) => {
      if (!file.mimetype.startsWith('image/'))
        return cb(new BadRequestException('Only image files are allowed'), false);
      cb(null, true);
    },
  }))
  async uploadLogo(
    @Headers('x-setup-secret') secret: string,
    @Req() req: Request,
    @UploadedFile() file: Express.Multer.File,
  ) {
    checkSecret(secret);
    if (!file) throw new BadRequestException('No file provided');
    const proto = (req.headers['x-forwarded-proto'] as string)?.split(',')[0].trim() || req.protocol;
    const host = (req.headers['x-forwarded-host'] as string) || req.get('host');
    return { ok: true, url: `${proto}://${host}/uploads/setup/${file.filename}` };
  }

  // ── Create school ──────────────────────────────────────────────────────────

  @Public()
  @Throttle({ auth: { limit: 5, ttl: 15 * 60_000 } })
  @Post('school')
  @HttpCode(200)
  async createSchool(
    @Headers('x-setup-secret') secret: string,
    @Body() body: {
      schoolName: string;
      logoUrl?: string;
      minGrade?: number;
      maxGrade?: number;
      gradeRanges?: string;
      semesters?: string;
      subjects?: { nameEn: string; nameAr?: string; nameHe?: string; nameFr?: string; nameRu?: string }[];
      bellSchedule?: { period: number; startTime: string; endTime: string }[];
      adminName: string;
      adminEmail?: string;
      adminUsername?: string;
      adminPassword: string;
    },
  ) {
    checkSecret(secret);

    // ── Validate inputs ──────────────────────────────────────────────────────
    const schoolName    = String(body?.schoolName    ?? '').trim();
    const adminName     = String(body?.adminName     ?? '').trim();
    const adminEmail    = body?.adminEmail    ? String(body.adminEmail).trim().toLowerCase()    : undefined;
    const adminUsername = body?.adminUsername ? String(body.adminUsername).trim().toLowerCase() : undefined;
    const adminPassword = String(body?.adminPassword ?? '').trim();

    const errors: string[] = [];
    if (!schoolName)  errors.push('School name is required.');
    if (!adminName)   errors.push('Admin full name is required.');
    if (!adminEmail && !adminUsername) errors.push('Admin email or username is required.');
    if (!adminPassword || adminPassword.length < 6) errors.push('Password must be at least 6 characters.');
    if (errors.length) throw new BadRequestException(errors.join(' '));

    // ── Check for duplicates ─────────────────────────────────────────────────
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

    // ── Grade ranges (multi) ──────────────────────────────────────────────────
    // Parse "5-8,9-12" → validated pairs; derive min/max for back-compat.
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
        if (lo < 1 || hi > 20) {
          throw new BadRequestException(`Invalid grade range ${a}–${b}. Grades must be 1..20.`);
        }
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

    // ── Semesters (optional) — "9-1,2-6", months 1..12, author order kept ──────
    let semestersCsv: string | undefined;
    const rawSems = String(body?.semesters ?? '').trim();
    if (rawSems) {
      const sems: string[] = [];
      for (const part of rawSems.split(',')) {
        const [s, e] = part.split('-').map((x) => parseInt(x.trim(), 10));
        if (!Number.isFinite(s) || !Number.isFinite(e)) continue;
        if (s < 1 || s > 12 || e < 1 || e > 12) {
          throw new BadRequestException(`Invalid semester ${s}–${e}. Months must be 1..12.`);
        }
        sems.push(`${s}-${e}`);
      }
      if (sems.length) semestersCsv = sems.join(',');
    }

    // ── Create / update school ───────────────────────────────────────────────
    let school = await this.prisma.school.findFirst({ where: { name: schoolName } });
    const schoolData: any = { name: schoolName, minGrade, maxGrade };
    if (gradeRangesCsv !== undefined) schoolData.gradeRanges = gradeRangesCsv;
    if (semestersCsv !== undefined) schoolData.semesters = semestersCsv;
    if (body?.logoUrl) schoolData.logoUrl = body.logoUrl;

    school = school
      ? await this.prisma.school.update({ where: { id: school.id }, data: schoolData })
      : await this.prisma.school.create({ data: schoolData });

    // ── Subjects ─────────────────────────────────────────────────────────────
    // Authoritative store is `subjectsI18n` (multilang objects). The legacy
    // `subjects` String[] is kept in sync (each entry = the i18n row's nameEn)
    // for backward compatibility with clients that still read it.
    const subjectsI18n = (body?.subjects ?? [])
      .map(s => ({
        nameEn: String(s?.nameEn ?? '').trim(),
        nameAr: s?.nameAr?.trim() || null,
        nameHe: s?.nameHe?.trim() || null,
        nameFr: s?.nameFr?.trim() || null,
        nameRu: s?.nameRu?.trim() || null,
      }))
      .filter(s => s.nameEn.length > 0);
    if (subjectsI18n.length) {
      const flat = subjectsI18n.map(s => s.nameEn);
      await this.prisma.schoolGradeSubjectDefault.upsert({
        where: { schoolId_grade_unique: { schoolId: school.id, grade: 0 } },
        update: { subjects: flat, subjectsI18n: subjectsI18n as any },
        create: { schoolId: school.id, grade: 0, subjects: flat, subjectsI18n: subjectsI18n as any },
      });
    }

    // ── Bell schedule ─────────────────────────────────────────────────────────
    if (body?.bellSchedule?.length) {
      for (const d of body.bellSchedule) {
        await this.prisma.schoolPeriodDefault.upsert({
          where: { schoolId_period: { schoolId: school.id, period: d.period } },
          update: { startTime: d.startTime, endTime: d.endTime },
          create: { schoolId: school.id, period: d.period, startTime: d.startTime, endTime: d.endTime },
        }).catch(() => null);
      }
    }

    // ── Create / update admin ────────────────────────────────────────────────
    const hash = await bcrypt.hash(adminPassword, 10);
    const whereAdmin: any = adminEmail ? { email: adminEmail } : { username: adminUsername };
    let adminUser = await this.prisma.user.findFirst({ where: whereAdmin });

    if (!adminUser) {
      // Username is required for every user. Use the caller-supplied one
      // when present, otherwise derive from the admin email.
      const usernameCandidate = adminUsername
          ? String(adminUsername).toLowerCase().replace(/[^a-z0-9_.-]/g, '')
          : deriveUsernameCandidate(adminEmail, adminName);
      const username = await ensureUniqueUsername(this.prisma, usernameCandidate);
      adminUser = await this.prisma.user.create({
        data: {
          name: adminName, nameEn: adminName,
          ...(adminEmail ? { email: adminEmail } : {}),
          username,
          password: hash,
          plainPassword: adminPassword,
          schoolId: school.id,
          status: 'ACTIVE',
          roles: { create: [{ role: 'ADMIN' }] },
        } as any,
      });
    } else {
      await this.prisma.user.update({
        where: { id: adminUser.id },
        data: { schoolId: school.id, name: adminName, nameEn: adminName, password: hash, plainPassword: adminPassword } as any,
      });
      await this.prisma.userRole.upsert({
        where: { userId_role: { userId: adminUser.id, role: 'ADMIN' as any } },
        update: {}, create: { userId: adminUser.id, role: 'ADMIN' as any },
      });
    }

    return {
      ok: true,
      school:  { id: school.id, name: school.name, logoUrl: (school as any).logoUrl ?? null },
      admin:   { id: adminUser.id, email: adminUser.email, username: (adminUser as any).username },
      loginWith: adminEmail ?? adminUsername,
      note: 'School created. Log in to the admin app with the credentials above.',
    };
  }

  // ── List schools with stats ────────────────────────────────────────────────

  @Public()
  @Get('schools')
  async listSchools(@Headers('x-setup-secret') secret: string) {
    checkSecret(secret);
    const schools = await this.prisma.school.findMany({ orderBy: { createdAt: 'desc' } });

    const out = await Promise.all(schools.map(async (s: any) => {
      const [
        userRows,
        admins,
        cohortCount,
        classroomCount,
        subjectsRow,
      ] = await Promise.all([
        // Per-role user counts. UserRole has (userId, role); we count distinct
        // userId per role for users belonging to this school.
        this.prisma.userRole.groupBy({
          by: ['role'],
          where: { user: { schoolId: s.id } } as any,
          _count: { userId: true },
        }) as any,
        this.prisma.user.findMany({
          where: { schoolId: s.id, roles: { some: { role: 'ADMIN' as any } } } as any,
          select: { id: true, email: true, username: true, name: true, nameEn: true } as any,
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
      for (const row of userRows as any[]) {
        userCounts[row.role] = row._count?.userId ?? 0;
      }

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
        admins: (admins as any[]).map((a: any) => ({
          id: a.id,
          name: a.nameEn || a.name,
          email: a.email,
          username: a.username,
        })),
      };
    }));

    return { ok: true, schools: out };
  }

  // ── Single school detail ───────────────────────────────────────────────────

  @Public()
  @Get('schools/:id')
  async getSchool(@Headers('x-setup-secret') secret: string, @Param('id') id: string) {
    checkSecret(secret);
    const school = await this.prisma.school.findUnique({ where: { id } });
    if (!school) throw new NotFoundException('School not found');

    // Re-use listSchools' aggregation shape for one row.
    const [userRows, admins, cohortCount, classroomCount, subjectsRow] = await Promise.all([
      this.prisma.userRole.groupBy({
        by: ['role'],
        where: { user: { schoolId: id } } as any,
        _count: { userId: true },
      }) as any,
      this.prisma.user.findMany({
        where: { schoolId: id, roles: { some: { role: 'ADMIN' as any } } } as any,
        select: { id: true, email: true, username: true, name: true, nameEn: true } as any,
      }) as any,
      this.prisma.cohort.count({ where: { schoolId: id } } as any),
      this.prisma.classroom.count({ where: { schoolId: id } } as any),
      this.prisma.schoolGradeSubjectDefault.findUnique({
        where: { schoolId_grade_unique: { schoolId: id, grade: 0 } } as any,
        select: { subjects: true, subjectsI18n: true } as any,
      }) as any,
    ]);

    const userCounts: Record<string, number> = {};
    for (const row of userRows as any[]) {
      userCounts[row.role] = row._count?.userId ?? 0;
    }
    const subjectsI18n = Array.isArray(subjectsRow?.subjectsI18n) ? subjectsRow.subjectsI18n : [];

    return {
      ok: true,
      school: {
        ...school,
        userCounts,
        cohortCount,
        classroomCount,
        admins,
        subjects: subjectsI18n,
      },
    };
  }

  // ── Update school ──────────────────────────────────────────────────────────

  @Public()
  @Throttle({ auth: { limit: 5, ttl: 15 * 60_000 } })
  @Patch('schools/:id')
  async updateSchool(
    @Headers('x-setup-secret') secret: string,
    @Param('id') id: string,
    @Body() body: { name?: string; logoUrl?: string | null; minGrade?: number; maxGrade?: number },
  ) {
    checkSecret(secret);
    const target = await this.prisma.school.findUnique({ where: { id } });
    if (!target) throw new NotFoundException('School not found');

    const data: any = {};
    if (body.name !== undefined) {
      const n = String(body.name).trim();
      if (!n) throw new BadRequestException('Name cannot be empty.');
      data.name = n;
    }
    if (body.logoUrl !== undefined) {
      data.logoUrl = body.logoUrl ? String(body.logoUrl).trim() : null;
    }
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

  // ── Delete one school (cascade) ────────────────────────────────────────────

  @Public()
  @Throttle({ auth: { limit: 5, ttl: 15 * 60_000 } })
  @Delete('schools/:id')
  async deleteSchool(@Headers('x-setup-secret') secret: string, @Param('id') id: string) {
    checkSecret(secret);
    const target = await this.prisma.school.findUnique({ where: { id } });
    if (!target) throw new NotFoundException('School not found');

    // Delete child tables that don't auto-cascade. Most relations are
    // `onDelete: Cascade` from School, so the final School delete will
    // sweep most rows. Users have `schoolId: SetNull` so we want to remove
    // them explicitly along with the school.
    await this.prisma.$transaction([
      // Subjects + period defaults — auto cascade from School, but explicit
      // for clarity.
      this.prisma.schoolGradeSubjectDefault.deleteMany({ where: { schoolId: id } } as any),
      this.prisma.schoolPeriodDefault.deleteMany({ where: { schoolId: id } } as any),
      // Cohorts and classrooms cascade from School. ScheduleSlot too.
      // Users belonging to this school — delete entirely.
      this.prisma.user.deleteMany({ where: { schoolId: id } } as any),
      this.prisma.school.delete({ where: { id } }),
    ]);

    return { ok: true };
  }

  // ── Request reset-all confirmation code (sends SMS) ────────────────────────

  @Public()
  @Throttle({ auth: { limit: 5, ttl: 15 * 60_000 } })
  @Post('reset-all/request-code')
  @HttpCode(200)
  async requestResetCode(@Headers('x-setup-secret') secret: string) {
    checkSecret(secret);

    const phone = defaultOwnerPhone();
    const emailAddr = defaultOwnerEmail();

    // Need at least one channel configured. Email is the easier fallback —
    // it doesn't require Twilio or a confirmed phone number.
    if (!this.sms.isConfigured && !this.email.isConfigured) {
      throw new BadRequestException(
        'Neither Twilio nor Resend is configured on the server. Add at least one set of env vars (TWILIO_* or RESEND_API_KEY) before triggering a database reset.',
      );
    }

    // Random 6-digit code, zero-padded.
    const code = String(randomInt(0, 1_000_000)).padStart(6, '0');
    const codeHash = createHash('sha256').update(code).digest('hex');
    const sessionId = createHash('sha256').update(`${Date.now()}:${code}`).digest('hex').slice(0, 24);

    resetCodeStore.set(sessionId, {
      codeHash,
      expiresAt: Date.now() + RESET_CODE_TTL_MIN * 60_000,
    });

    // Fire both channels in parallel. At least one needs to succeed; if both
    // fail we delete the session so the caller can retry cleanly.
    const smsMessage = `ClassMate: your platform reset code is ${code}. This will DELETE ALL DATA. Code expires in ${RESET_CODE_TTL_MIN} min. If you didn't request this, ignore.`;

    const results = await Promise.allSettled([
      this.sms.isConfigured ? this.sms.send(phone, smsMessage) : Promise.resolve(),
      this.email.isConfigured
        ? this.email.sendPlatformResetCode({ to: emailAddr, code, expiresInMinutes: RESET_CODE_TTL_MIN })
        : Promise.resolve(),
    ]);

    const sentChannels: string[] = [];
    const failures: string[] = [];
    if (this.sms.isConfigured) {
      if (results[0].status === 'fulfilled') sentChannels.push(`phone ${maskPhone(phone)}`);
      else failures.push(`SMS: ${(results[0].reason as Error)?.message ?? 'unknown'}`);
    }
    if (this.email.isConfigured) {
      if (results[1].status === 'fulfilled') sentChannels.push(`email ${maskEmail(emailAddr)}`);
      else failures.push(`Email: ${(results[1].reason as Error)?.message ?? 'unknown'}`);
    }

    if (sentChannels.length === 0) {
      resetCodeStore.delete(sessionId);
      throw new BadRequestException(`Failed to send code on every channel: ${failures.join(' · ')}`);
    }

    return {
      ok: true,
      sessionId,
      sentTo: sentChannels.join(' and '),
      partialFailures: failures.length ? failures : undefined,
      expiresInMinutes: RESET_CODE_TTL_MIN,
    };
  }

  // ── Execute the reset (validates code + RESET text + nukes DB) ─────────────

  @Public()
  @Throttle({ auth: { limit: 5, ttl: 15 * 60_000 } })
  @Post('reset-all/execute')
  @HttpCode(200)
  async executeReset(
    @Headers('x-setup-secret') secret: string,
    @Body() body: { sessionId?: string; code?: string; confirm?: string },
  ) {
    checkSecret(secret);

    const sessionId = String(body?.sessionId ?? '').trim();
    const code = String(body?.code ?? '').trim();
    const confirm = String(body?.confirm ?? '');

    if (!sessionId || !code) throw new BadRequestException('sessionId and code are required.');
    if (confirm !== 'RESET') throw new BadRequestException("Confirmation text must be exactly 'RESET'.");

    const entry = resetCodeStore.get(sessionId);
    if (!entry) throw new BadRequestException('No active reset session. Request a new code.');
    if (entry.expiresAt < Date.now()) {
      resetCodeStore.delete(sessionId);
      throw new BadRequestException('Reset code expired. Request a new one.');
    }
    const codeHash = createHash('sha256').update(code).digest('hex');
    if (codeHash !== entry.codeHash) {
      throw new BadRequestException('Wrong code.');
    }

    // Single-use: consume the session whether or not the wipe succeeds.
    resetCodeStore.delete(sessionId);

    // Wipe every user table. The `_prisma_migrations` table is preserved so
    // the schema isn't re-bootstrapped on next deploy. Order doesn't matter
    // because TRUNCATE … CASCADE handles FK chains automatically.
    const tables = await this.prisma.$queryRaw<{ tablename: string }[]>`
      SELECT tablename FROM pg_tables
      WHERE schemaname = 'public' AND tablename != '_prisma_migrations'
    `;
    const truncated: string[] = [];
    for (const t of tables) {
      try {
        await this.prisma.$executeRawUnsafe(`TRUNCATE TABLE "${t.tablename}" RESTART IDENTITY CASCADE`);
        truncated.push(t.tablename);
      } catch (err) {
        // Some tables may already be empty / vacuum'd; continue.
        // Surface the error in the response so the UI can show it.
        truncated.push(`${t.tablename} (failed: ${(err as Error).message})`);
      }
    }

    return { ok: true, truncated, message: `Truncated ${truncated.length} tables.` };
  }
}

// ── Page HTML ──────────────────────────────────────────────────────────────

function buildPage(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ClassMate — School Setup</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
      /* Light palette — admin chrome only. The dark variant existed
         before the marketing site landed; now that the rest of the
         brand is light cream + teal, the setup page reads as the same
         family. Brand-blue accent stays the same. */
      --bg:#f4efe5; --surface:#ffffff; --surface2:#f8f4ec; --border:#e2e1d8;
      --blue:#2563eb; --blue2:#1d4fd7; --text:#1e293b; --muted:#64748b;
      --err-bg:#fef2f2; --err-border:#fecaca; --ok-bg:#f0fdf4; --ok-border:#bbf7d0;
      --red:#dc2626; --green:#16a34a;
    }
    body { font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;
           background:var(--bg); color:var(--text); min-height:100vh;
           display:flex; align-items:flex-start; justify-content:center; padding:40px 20px 100px; }
    .wrap { width:100%; max-width:600px; }

    /* header — always vertical, centred. Logo renders in its native
       blue against the light cream background. */
    .hdr { display:block; text-align:center; margin-bottom:44px; }
    .hdr img { display:block; width:200px; max-width:70%; height:auto;
               margin:0 auto 16px; }
    .hdr-info h1 { font-size:13px; font-weight:700; color:var(--muted);
                   text-transform:uppercase; letter-spacing:1px; }
    .hdr-info p  { font-size:12px; color:var(--muted); margin-top:4px; }

    /* cards */
    .card { background:var(--surface); border:1px solid var(--border);
            border-radius:20px; padding:28px; margin-bottom:18px; }
    .card-hdr { font-size:11px; font-weight:800; color:var(--blue);
                text-transform:uppercase; letter-spacing:.7px; margin-bottom:20px;
                display:flex; align-items:center; gap:10px; }
    .card-hdr::after { content:''; flex:1; height:1px; background:var(--border); }

    /* fields */
    .row2 { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
    .field { margin-bottom:16px; }
    .field:last-child { margin-bottom:0; }
    label { display:block; font-size:11px; font-weight:700; color:var(--muted);
            text-transform:uppercase; letter-spacing:.5px; margin-bottom:6px; }
    .req { color:var(--blue); }
    input, textarea {
      width:100%; padding:11px 14px; background:var(--bg); border:1.5px solid var(--border);
      border-radius:10px; color:var(--text); font-size:14px; font-family:inherit; outline:none;
      transition:border-color .15s;
    }
    input:focus, textarea:focus { border-color:var(--blue); }
    input::placeholder, textarea::placeholder { color:#a3a39a; }
    textarea { resize:vertical; min-height:70px; }
    .hint { font-size:11px; color:var(--muted); margin-top:5px; line-height:1.5; }

    /* password field with show/hide toggle */
    .pw-wrap { position:relative; }
    .pw-wrap input { padding-right:42px; }
    .pw-eye { position:absolute; right:12px; top:50%; transform:translateY(-50%);
              background:none; border:none; cursor:pointer; color:var(--muted);
              font-size:16px; padding:0; line-height:1; }

    /* logo upload */
    .logo-zone { border:2px dashed var(--border); border-radius:14px; padding:24px;
                 text-align:center; cursor:pointer; transition:border-color .15s; position:relative; }
    .logo-zone:hover { border-color:var(--blue); }
    .logo-zone input { position:absolute; inset:0; opacity:0; cursor:pointer; }
    .logo-preview { display:none; max-height:80px; margin:0 auto 12px; border-radius:8px; }
    .logo-zone.has-file .logo-preview { display:block; }
    .logo-zone.has-file .logo-placeholder { display:none; }
    .logo-placeholder { color:var(--muted); font-size:13px; }
    .logo-placeholder span { display:block; font-size:24px; margin-bottom:6px; }
    .logo-status { font-size:12px; margin-top:8px; }
    .logo-status.ok  { color:var(--green); }
    .logo-status.err { color:var(--red); }

    /* chips */
    .chips { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:10px; min-height:4px; }
    .chip { display:flex; align-items:center; gap:6px; padding:6px 10px 6px 12px;
            background:var(--surface2); border:1px solid var(--border); border-radius:20px;
            font-size:13px; font-weight:600; }
    .chip-del { background:none; border:none; color:var(--muted); cursor:pointer;
                font-size:16px; line-height:1; padding:0; transition:color .1s; }
    .chip-del:hover { color:var(--red); }

    /* add row */
    .add-row { display:flex; gap:10px; }
    .add-row input { flex:1; }
    .add-btn { padding:10px 18px; background:var(--blue); color:#fff; border:none;
               border-radius:10px; font-size:13px; font-weight:700; cursor:pointer;
               white-space:nowrap; transition:background .15s; flex-shrink:0; }
    .add-btn:hover { background:var(--blue2); }

    /* period rows */
    .period-row { display:flex; align-items:center; gap:10px; padding:10px 14px;
                  background:var(--bg); border:1px solid var(--border); border-radius:12px;
                  margin-bottom:8px; }
    .period-badge { min-width:32px; font-size:12px; font-weight:900; color:var(--blue); }
    .period-row input[type=time] { flex:1; padding:8px 10px; font-size:13px; }
    .period-sep { color:var(--muted); font-size:13px; flex-shrink:0; }
    .period-del { background:none; border:none; color:var(--muted); cursor:pointer;
                  font-size:18px; padding:0 4px; transition:color .1s; }
    .period-del:hover { color:var(--red); }

    /* secret */
    .secret-card { background:var(--err-bg); border:1px solid var(--err-border);
                   border-radius:14px; padding:18px; margin-bottom:18px;
                   display:flex; gap:14px; align-items:flex-start; }
    .secret-icon { font-size:22px; }
    .secret-inner { flex:1; }
    .secret-inner label { color:var(--red); }

    /* submit */
    .btn { width:100%; padding:15px; background:var(--blue); color:#fff; border:none;
           border-radius:14px; font-size:16px; font-weight:800; cursor:pointer;
           transition:background .15s; margin-top:4px; }
    .btn:hover:not(:disabled) { background:var(--blue2); }
    .btn:disabled { background:var(--surface2); color:var(--muted); cursor:not-allowed; }

    /* result */
    .result { margin-top:20px; padding:20px; border-radius:14px;
              font-size:13px; line-height:1.7; display:none; }
    .result.ok  { background:var(--ok-bg);  border:1px solid var(--ok-border);  color:var(--green); }
    .result.err { background:var(--err-bg); border:1px solid var(--err-border); color:var(--red); }
    .result pre { font-family:monospace; font-size:12px; white-space:pre-wrap;
                  background:var(--surface2); border:1px solid var(--border);
                  border-radius:8px; padding:12px; margin-top:10px; color:var(--text); }

    /* subject list */
    .subj-item { display:flex; align-items:flex-start; gap:12px; padding:12px 14px;
                 background:var(--bg); border:1px solid var(--border); border-radius:12px;
                 margin-bottom:8px; }
    .subj-names { flex:1; }
    .subj-en { font-size:14px; font-weight:700; }
    .subj-langs { font-size:12px; color:var(--muted); margin-top:2px; }
    .subj-del { background:none; border:none; color:var(--muted); cursor:pointer;
                font-size:18px; padding:0; transition:color .1s; flex-shrink:0; }
    .subj-del:hover { color:var(--red); }
    .subj-form { background:var(--surface2); border:1px solid var(--border);
                 border-radius:14px; padding:16px; margin-bottom:10px; }
    .subj-lang-row { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:0; }
    .subj-lang-row .field { margin-bottom:12px; }

    @media(max-width:500px) {
      .row2, .periods, .subj-lang-row { grid-template-columns:1fr; }
    }

    /* ── tabs ─────────────────────────────────────────────────────────── */
    .tabs { display:flex; gap:6px; background:var(--surface); border:1px solid var(--border);
            border-radius:14px; padding:6px; margin-bottom:24px; }
    .tabs button { flex:1; padding:10px 12px; background:transparent; border:none;
                   border-radius:9px; color:var(--muted); font-weight:700; font-size:13px;
                   letter-spacing:.3px; cursor:pointer; transition:all .15s; font-family:inherit; }
    .tabs button:hover { color:var(--text); }
    .tabs button.active { background:var(--blue); color:#fff; }
    .pane { display:none; }
    .pane.active { display:block; }

    /* ── schools list ─────────────────────────────────────────────────── */
    .school-card { background:var(--surface); border:1px solid var(--border);
                   border-radius:16px; padding:18px 20px; margin-bottom:12px; }
    .school-card-hdr { display:flex; align-items:center; gap:12px; }
    /* Real uploaded school logos render as-is (could be color/transparent).
       Fallback uses the ClassMate mark — needs the white filter to be readable. */
    .school-card-hdr img { width:36px; height:36px; border-radius:8px; object-fit:cover; }
    .school-card-hdr img.fallback-logo {
      filter: brightness(0) invert(1); background:var(--blue); padding:2px;
    }
    .school-card-hdr h3 { font-size:16px; font-weight:800; flex:1; min-width:0;
                          overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
    .school-card-hdr .school-actions { display:flex; gap:6px; flex-shrink:0; }
    .school-card-hdr .school-actions button { padding:7px 12px; border-radius:8px;
        border:1px solid var(--border); background:var(--surface2); color:var(--text);
        font-size:12px; font-weight:600; cursor:pointer; font-family:inherit; }
    .school-card-hdr .school-actions button:hover { border-color:var(--blue); color:var(--blue); }
    .school-card-hdr .school-actions button.danger:hover { border-color:var(--red); color:var(--red); }
    .school-stats { display:grid; grid-template-columns:repeat(4, 1fr); gap:8px; margin-top:14px; }
    .school-stat { background:var(--bg); border:1px solid var(--border); border-radius:10px;
                   padding:10px 12px; text-align:center; }
    .school-stat .num { font-size:18px; font-weight:800; color:var(--text); }
    .school-stat .lbl { font-size:10px; color:var(--muted); text-transform:uppercase;
                        letter-spacing:.4px; font-weight:700; margin-top:2px; }
    .school-admins { margin-top:12px; font-size:12px; color:var(--muted); }
    .school-empty { text-align:center; color:var(--muted); padding:60px 20px;
                    background:var(--surface); border:1px dashed var(--border); border-radius:14px; }

    @media(max-width:500px) {
      .school-stats { grid-template-columns:repeat(2, 1fr); }
    }

    /* ── danger zone ──────────────────────────────────────────────────── */
    .danger-card { background:var(--err-bg); border:1px solid var(--err-border); border-radius:16px;
                   padding:24px; }
    .danger-card h3 { color:var(--red); font-size:18px; font-weight:800; margin-bottom:6px; }
    .danger-card p  { color:#8b5050; font-size:13px; line-height:1.55; margin-bottom:6px; }
    .danger-btn { width:100%; padding:14px; background:var(--red); color:#fff; border:none;
                  border-radius:12px; font-size:14px; font-weight:800; cursor:pointer;
                  margin-top:18px; font-family:inherit; letter-spacing:.3px; }
    .danger-btn:hover:not(:disabled) { background:#dc2626; }
    .danger-btn:disabled { opacity:.5; cursor:not-allowed; }

    /* ── modal ────────────────────────────────────────────────────────── */
    .modal-overlay { position:fixed; inset:0; background:rgba(0,0,0,0.7); display:none;
                     align-items:center; justify-content:center; z-index:100; padding:20px; }
    .modal-overlay.show { display:flex; }
    .modal { background:var(--surface); border:1px solid var(--border); border-radius:20px;
             padding:28px; max-width:480px; width:100%; max-height:90vh; overflow:auto; }
    .modal h3 { font-size:18px; font-weight:800; margin-bottom:8px; }
    .modal p  { font-size:13px; color:var(--muted); line-height:1.55; margin-bottom:14px; }
    .modal-row { display:flex; gap:10px; margin-top:16px; }
    .modal-row button { flex:1; padding:11px 14px; border-radius:10px; border:none;
                        font-size:13px; font-weight:700; cursor:pointer; font-family:inherit; }
    .modal-row .secondary { background:var(--surface2); color:var(--text); border:1px solid var(--border); }
    .modal-row .primary   { background:var(--blue); color:#fff; }
    .modal-row .primary:disabled { opacity:.5; cursor:not-allowed; }
    .modal-row .danger    { background:var(--red); color:#fff; }
    .modal-row .danger:disabled { opacity:.5; cursor:not-allowed; }
    .modal-status { margin-top:12px; padding:10px 12px; border-radius:8px; font-size:12px;
                    display:none; }
    .modal-status.show { display:block; }
    .modal-status.err  { background:var(--err-bg); border:1px solid var(--err-border); color:var(--red); }
    .modal-status.ok   { background:var(--ok-bg);  border:1px solid var(--ok-border); color:var(--green); }
  </style>
</head>
<body>
<div class="wrap">

  <div class="hdr">
    <img src="/static/logo_light.png" alt="ClassMate" onerror="this.src='${LOGO_DATA_URI}';">
    <div class="hdr-info">
      <h1>Platform Console</h1>
      <p>Platform admin only · manage every school</p>
    </div>
  </div>

  <!-- Tab nav -->
  <div class="tabs" role="tablist">
    <button type="button" class="tab-btn active" data-tab="create">Create</button>
    <button type="button" class="tab-btn" data-tab="schools">Schools</button>
    <button type="button" class="tab-btn" data-tab="danger">Danger Zone</button>
  </div>

  <!-- Create tab (existing form) -->
  <div id="tab-create" class="pane active">
  <form id="form">

    <!-- School Info -->
    <div class="card">
      <div class="card-hdr">School Info</div>
      <div class="field">
        <label>School Name <span class="req">*</span></label>
        <input id="schoolName" type="text" placeholder="e.g. Greenwood Academy" required autocomplete="off">
      </div>
      <div class="field">
        <label>Grade Ranges <span class="req">*</span></label>
        <div style="font-size:12px;color:var(--muted);margin-bottom:6px">The grades this school spans. Add more than one for gaps (e.g. 4–6 and 9–12).</div>
        <div id="rangeList"></div>
        <button type="button" class="add-btn" id="addRange" style="margin-top:6px">+ Add range</button>
      </div>
      <div class="field">
        <label>Semesters</label>
        <div style="font-size:12px;color:var(--muted);margin-bottom:6px">Optional. Define the school-year terms by start → end month. Students get "This semester / Previous" filters.</div>
        <div id="semesterList"></div>
        <button type="button" class="add-btn" id="addSemester" style="margin-top:6px">+ Add semester</button>
      </div>
      <div class="field">
        <label>School Logo</label>
        <div class="logo-zone" id="logoZone">
          <input type="file" id="logoFile" accept="image/*">
          <img id="logoPreview" class="logo-preview" alt="Logo preview">
          <div class="logo-placeholder">
            <span>🖼️</span>Upload logo image (PNG, JPG)
          </div>
        </div>
        <div class="logo-status" id="logoStatus"></div>
        <input type="hidden" id="logoUrl">
      </div>
    </div>

    <!-- Subjects -->
    <div class="card">
      <div class="card-hdr">Subjects <span style="font-weight:400;color:var(--muted);text-transform:none;letter-spacing:0">(optional)</span></div>
      <div id="subjectList"></div>
      <button type="button" class="add-btn" id="showAddSubject" style="margin-bottom:8px">+ Add Subject</button>
      <!-- inline add form, hidden by default -->
      <div id="subjectForm" class="subj-form" style="display:none">
        <div class="subj-lang-row">
          <div class="field">
            <label>English <span class="req">*</span></label>
            <input id="sEn" type="text" placeholder="Mathematics" autocomplete="off">
          </div>
          <div class="field">
            <label>Arabic</label>
            <input id="sAr" type="text" placeholder="رياضيات" autocomplete="off" dir="auto">
          </div>
        </div>
        <div class="subj-lang-row">
          <div class="field">
            <label>Hebrew</label>
            <input id="sHe" type="text" placeholder="מתמטיקה" autocomplete="off" dir="auto">
          </div>
          <div class="field">
            <label>French</label>
            <input id="sFr" type="text" placeholder="Mathématiques" autocomplete="off">
          </div>
        </div>
        <div class="field" style="max-width:50%">
          <label>Russian</label>
          <input id="sRu" type="text" placeholder="Математика" autocomplete="off">
        </div>
        <div style="display:flex;gap:8px;margin-top:4px">
          <button type="button" class="add-btn" id="confirmAddSubject">Add Subject</button>
          <button type="button" class="add-btn" id="cancelAddSubject"
            style="background:var(--surface2);color:var(--muted);border:1px solid var(--border)">Cancel</button>
        </div>
      </div>
      <div class="hint" style="margin-top:8px">Visible to all teachers when creating assignments and assessments.</div>
    </div>

    <!-- Bell Schedule -->
    <div class="card">
      <div class="card-hdr">Bell Schedule <span style="font-weight:400;color:var(--muted);text-transform:none;letter-spacing:0">(optional)</span></div>
      <div class="hint" style="margin-bottom:14px">Set default start/end times per period. Can be changed later in the app.</div>
      <div id="periodList"></div>
      <button type="button" class="add-btn" id="addPeriod" style="margin-top:8px">+ Add Period</button>
    </div>

    <!-- Admin Account -->
    <div class="card">
      <div class="card-hdr">Admin Account <span class="req">*</span></div>
      <div class="hint" style="margin-bottom:16px">This person can manage the school in the ClassMate app. At least email or username is required.</div>
      <div class="row2">
        <div class="field">
          <label>Full Name <span class="req">*</span></label>
          <input id="adminName" type="text" placeholder="e.g. Sarah Ahmed" required autocomplete="off">
        </div>
        <div class="field">
          <label>Username</label>
          <input id="adminUsername" type="text" placeholder="sarah.ahmed" autocomplete="off">
        </div>
      </div>
      <div class="field">
        <label>Email</label>
        <input id="adminEmail" type="email" placeholder="admin@school.com" autocomplete="off">
      </div>
      <div class="field">
        <label>Password <span class="req">*</span></label>
        <div class="pw-wrap">
          <input id="adminPassword" type="password" placeholder="Min 6 characters" required autocomplete="new-password">
          <button type="button" class="pw-eye" id="pwToggle" title="Show/hide password">👁</button>
        </div>
        <div class="hint">This is the admin's initial login password. They can change it after logging in.</div>
      </div>
    </div>

    <!-- Setup Secret -->
    <div class="secret-card">
      <div class="secret-icon">🔑</div>
      <div class="secret-inner">
        <label style="display:block;margin-bottom:6px">Setup Secret <span class="req">*</span></label>
        <div class="pw-wrap">
          <input id="secret" type="password" placeholder="SETUP_SECRET from Railway" required autocomplete="off">
          <button type="button" class="pw-eye" id="secretToggle" title="Show/hide">👁</button>
        </div>
        <div class="hint" style="margin-top:6px">The SETUP_SECRET you set in Railway environment variables.</div>
      </div>
    </div>

    <button type="submit" class="btn" id="btn">Create School</button>
  </form>

  <div class="result" id="result"></div>
  </div><!-- /tab-create -->

  <!-- Schools tab -->
  <div id="tab-schools" class="pane">
    <div class="card">
      <div class="card-hdr">All Schools <span style="font-weight:400;color:var(--muted);text-transform:none;letter-spacing:0" id="schoolsCount"></span></div>
      <div id="schoolsList">
        <div class="school-empty">Loading…</div>
      </div>
    </div>
  </div>

  <!-- Danger Zone tab -->
  <div id="tab-danger" class="pane">
    <div class="danger-card">
      <h3>⚠️  Reset all platform data</h3>
      <p>This deletes <strong>every school, every user, every cohort, classroom, schedule slot, message, assignment, exam, attendance record, password-reset token</strong> — everything.</p>
      <p>The database schema stays intact. Resend / Twilio / Apple / your custom domain are untouched.</p>
      <p>You'll receive a 6-digit code by SMS to <strong id="ownerPhoneLabel">your platform owner phone</strong>. Enter that code, then type <code>RESET</code> to confirm.</p>
      <button type="button" class="danger-btn" id="resetStartBtn">Reset all data</button>
    </div>
  </div>

  <!-- Edit-school modal -->
  <div class="modal-overlay" id="editModal">
    <div class="modal">
      <h3 id="editModalTitle">Edit school</h3>
      <div class="field">
        <label>School name</label>
        <input id="editName" type="text">
      </div>
      <div class="row2">
        <div class="field">
          <label>Lowest grade</label>
          <input id="editMin" type="number" min="1" max="20">
        </div>
        <div class="field">
          <label>Highest grade</label>
          <input id="editMax" type="number" min="1" max="20">
        </div>
      </div>
      <div class="modal-status err" id="editErr"></div>
      <div class="modal-row">
        <button type="button" class="secondary" id="editCancel">Cancel</button>
        <button type="button" class="primary" id="editSave">Save</button>
      </div>
    </div>
  </div>

  <!-- View-school modal -->
  <div class="modal-overlay" id="viewModal">
    <div class="modal">
      <h3 id="viewModalTitle">School details</h3>
      <div id="viewModalBody"></div>
      <div class="modal-row">
        <button type="button" class="primary" id="viewClose">Close</button>
      </div>
    </div>
  </div>

  <!-- Delete-one-school modal — styled to match the Danger Zone card. -->
  <div class="modal-overlay" id="deleteModal">
    <div class="modal danger-modal">
      <div class="danger-card" style="margin:0 0 14px 0;">
        <h3>⚠️  Delete this school</h3>
        <p id="deleteModalBody">This permanently removes the school and <strong>every user, cohort, classroom, schedule slot, message, assignment, exam, attendance record, and grade</strong> associated with it.</p>
        <p>This action <strong>cannot be undone</strong>. Make sure you have an export of any data you still need.</p>
      </div>
      <div class="field">
        <label>Type the school's name <em id="deleteSchoolNameHint" style="color:var(--red); font-style:normal; font-weight:700;"></em> to confirm</label>
        <input id="deleteConfirmInput" type="text" autocomplete="off" spellcheck="false">
      </div>
      <div class="modal-status err" id="deleteErr"></div>
      <div class="modal-row">
        <button type="button" class="secondary" id="deleteCancel">Cancel</button>
        <button type="button" class="danger" id="deleteGo" disabled>Delete forever</button>
      </div>
    </div>
  </div>

  <!-- Reset-all modal (2-step: code, then RESET text) -->
  <div class="modal-overlay" id="resetModal">
    <div class="modal">
      <h3 id="resetModalTitle">Reset all data</h3>
      <p id="resetModalBody">Click "Send code" to receive a 6-digit code by SMS. The code expires in 15 minutes.</p>
      <div id="resetStep1">
        <div class="modal-row">
          <button type="button" class="secondary" id="resetCancel1">Cancel</button>
          <button type="button" class="danger" id="resetSendCode">Send code</button>
        </div>
      </div>
      <div id="resetStep2" style="display:none">
        <div class="field">
          <label>6-digit code from SMS</label>
          <input id="resetCode" type="text" inputmode="numeric" maxlength="6" autocomplete="off">
        </div>
        <div class="field">
          <label>Type <code>RESET</code> to confirm</label>
          <input id="resetConfirmText" type="text" autocomplete="off" placeholder="RESET">
        </div>
        <div class="modal-status err" id="resetErr"></div>
        <div class="modal-row">
          <button type="button" class="secondary" id="resetCancel2">Cancel</button>
          <button type="button" class="danger" id="resetGo" disabled>Nuke everything</button>
        </div>
      </div>
      <div class="modal-status ok" id="resetOk"></div>
    </div>
  </div>

</div>
<script>
  // ── Subjects (multi-lang) ──────────────────────────────────────────────────
  const subjects = []; // each: { nameEn, nameAr, nameHe, nameFr, nameRu }
  const subjectList = document.getElementById('subjectList');
  const subjectForm = document.getElementById('subjectForm');

  function renderSubjects() {
    subjectList.innerHTML = subjects.map((s, i) => {
      const langs = [s.nameAr, s.nameHe, s.nameFr, s.nameRu].filter(Boolean).join(' · ');
      return '<div class="subj-item">' +
        '<div class="subj-names">' +
          '<div class="subj-en">' + s.nameEn + '</div>' +
          (langs ? '<div class="subj-langs">' + langs + '</div>' : '') +
        '</div>' +
        '<button type="button" class="subj-del" data-i="'+i+'">×</button>' +
      '</div>';
    }).join('');
    subjectList.querySelectorAll('.subj-del').forEach(b =>
      b.addEventListener('click', () => { subjects.splice(+b.dataset.i, 1); renderSubjects(); })
    );
  }

  document.getElementById('showAddSubject').addEventListener('click', () => {
    subjectForm.style.display = 'block';
    document.getElementById('sEn').focus();
  });
  document.getElementById('cancelAddSubject').addEventListener('click', () => {
    subjectForm.style.display = 'none';
    ['sEn','sAr','sHe','sFr','sRu'].forEach(id => document.getElementById(id).value = '');
  });
  document.getElementById('confirmAddSubject').addEventListener('click', () => {
    const nameEn = document.getElementById('sEn').value.trim();
    if (!nameEn) { document.getElementById('sEn').focus(); return; }
    subjects.push({
      nameEn,
      nameAr: document.getElementById('sAr').value.trim() || undefined,
      nameHe: document.getElementById('sHe').value.trim() || undefined,
      nameFr: document.getElementById('sFr').value.trim() || undefined,
      nameRu: document.getElementById('sRu').value.trim() || undefined,
    });
    ['sEn','sAr','sHe','sFr','sRu'].forEach(id => document.getElementById(id).value = '');
    subjectForm.style.display = 'none';
    renderSubjects();
  });
  document.getElementById('sEn').addEventListener('keydown', e => {
    if (e.key === 'Enter') { e.preventDefault(); document.getElementById('confirmAddSubject').click(); }
  });

  // ── Bell Schedule ──────────────────────────────────────────────────────────
  let periodCount = 0;
  const periodList = document.getElementById('periodList');

  function addPeriod(startTime, endTime) {
    periodCount++;
    const n = periodCount;
    const row = document.createElement('div');
    row.className = 'period-row'; row.dataset.n = n;
    row.innerHTML =
      '<span class="period-badge">P'+n+'</span>' +
      '<input type="time" class="ps" value="'+(startTime||'')+'">' +
      '<span class="period-sep">→</span>' +
      '<input type="time" class="pe" value="'+(endTime||'')+'">' +
      '<button type="button" class="period-del" title="Remove">×</button>';
    row.querySelector('.period-del').addEventListener('click', () => {
      row.remove();
      // Renumber remaining periods
      periodList.querySelectorAll('.period-row').forEach((r,i) => {
        r.querySelector('.period-badge').textContent = 'P'+(i+1);
      });
    });
    periodList.appendChild(row);
  }

  document.getElementById('addPeriod').addEventListener('click', () => addPeriod());
  // Seed with P1–P5 to start
  for (let i = 0; i < 5; i++) addPeriod();

  // ── Grade ranges ───────────────────────────────────────────────────────────
  const rangeList = document.getElementById('rangeList');
  function addRange(lo, hi) {
    const row = document.createElement('div');
    row.className = 'range-row';
    row.style.cssText = 'display:flex;gap:8px;align-items:center;margin-bottom:6px';
    row.innerHTML =
      '<input type="number" class="rlo" min="1" max="20" value="'+(lo||5)+'" style="width:90px"> ' +
      '<span class="period-sep">→</span> ' +
      '<input type="number" class="rhi" min="1" max="20" value="'+(hi||12)+'" style="width:90px"> ' +
      '<button type="button" class="period-del" title="Remove">×</button>';
    row.querySelector('.period-del').addEventListener('click', () => {
      if (rangeList.querySelectorAll('.range-row').length > 1) row.remove();
    });
    rangeList.appendChild(row);
  }
  document.getElementById('addRange').addEventListener('click', () => addRange());
  addRange(5, 12);

  // ── Semesters ────────────────────────────────────────────────────────────
  const MONTHS = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  const semesterList = document.getElementById('semesterList');
  function monthSelect(cls, val) {
    let opts = '';
    for (let m = 1; m <= 12; m++) opts += '<option value="'+m+'"'+(m===val?' selected':'')+'>'+MONTHS[m-1]+'</option>';
    return '<select class="'+cls+'" style="padding:6px;border-radius:8px">'+opts+'</select>';
  }
  function renumberSemesters() {
    semesterList.querySelectorAll('.sem-row').forEach((r,i) => {
      r.querySelector('.sem-label').textContent = 'Semester '+(i+1);
    });
  }
  function addSemester(start, end) {
    const row = document.createElement('div');
    row.className = 'sem-row';
    row.style.cssText = 'display:flex;gap:8px;align-items:center;margin-bottom:6px';
    row.innerHTML =
      '<span class="sem-label" style="font-weight:700;min-width:90px"></span> ' +
      monthSelect('ss', start||9) + ' <span class="period-sep">→</span> ' +
      monthSelect('se', end||1) +
      ' <button type="button" class="period-del" title="Remove">×</button>';
    row.querySelector('.period-del').addEventListener('click', () => { row.remove(); renumberSemesters(); });
    semesterList.appendChild(row);
    renumberSemesters();
  }
  document.getElementById('addSemester').addEventListener('click', () => addSemester());

  // ── Show/hide password toggles ─────────────────────────────────────────────
  // Show/hide password toggles
  function togglePw(inputId, btnId) {
    const inp = document.getElementById(inputId);
    const btn = document.getElementById(btnId);
    btn.addEventListener('click', () => {
      inp.type = inp.type === 'password' ? 'text' : 'password';
      btn.textContent = inp.type === 'password' ? '👁' : '🙈';
    });
  }
  togglePw('adminPassword', 'pwToggle');
  togglePw('secret', 'secretToggle');

  // Logo — show preview immediately on file select, upload at submit time
  const logoFile = document.getElementById('logoFile');
  const logoZone = document.getElementById('logoZone');
  const logoPreview = document.getElementById('logoPreview');
  const logoStatus = document.getElementById('logoStatus');
  const logoUrl = document.getElementById('logoUrl');

  logoFile.addEventListener('change', () => {
    const file = logoFile.files[0];
    if (!file) return;
    // Show local preview immediately — no secret needed yet
    const reader = new FileReader();
    reader.onload = e => { logoPreview.src = e.target.result; };
    reader.readAsDataURL(file);
    logoZone.classList.add('has-file');
    logoStatus.textContent = 'Ready to upload'; logoStatus.className = 'logo-status';
    logoUrl.value = ''; // cleared until actual upload at submit
  });

  async function uploadLogoIfPending(secret) {
    const file = logoFile.files[0];
    if (!file) return true; // no file selected — ok
    logoStatus.textContent = 'Uploading logo…'; logoStatus.className = 'logo-status';
    const fd = new FormData();
    fd.append('file', file);
    const res = await fetch('/cms/upload', { method:'POST', headers:{'x-setup-secret':secret}, body:fd });
    const data = await res.json();
    if (res.ok) {
      logoUrl.value = data.url;
      logoStatus.textContent = '✓ Logo uploaded'; logoStatus.className = 'logo-status ok';
      return true;
    } else {
      logoStatus.textContent = '✗ ' + (data.message || 'Upload failed'); logoStatus.className = 'logo-status err';
      return false;
    }
  }

  // Form submit
  document.getElementById('form').addEventListener('submit', async e => {
    e.preventDefault();
    const btn = document.getElementById('btn');
    const result = document.getElementById('result');
    btn.disabled = true; btn.textContent = 'Creating…';
    result.style.display = 'none';

    // Collect bell schedule from dynamic rows
    const bell = [];
    document.querySelectorAll('#periodList .period-row').forEach((row, i) => {
      const s = row.querySelector('.ps').value;
      const en = row.querySelector('.pe').value;
      if (s && en) bell.push({ period: i+1, startTime: s, endTime: en });
    });

    // Upload logo first if a file was picked
    const secret = document.getElementById('secret').value;
    const logoOk = await uploadLogoIfPending(secret);
    if (!logoOk) { btn.disabled = false; btn.textContent = 'Create School'; return; }

    // Collect grade ranges → CSV "5-8,9-12" and derive min/max for back-compat
    const rangePairs = [];
    document.querySelectorAll('#rangeList .range-row').forEach((row) => {
      const lo = Number(row.querySelector('.rlo').value);
      const hi = Number(row.querySelector('.rhi').value);
      if (lo >= 1 && hi >= 1) rangePairs.push([Math.min(lo,hi), Math.max(lo,hi)]);
    });
    const gradeRanges = rangePairs.map((p) => p[0]+'-'+p[1]).join(',');
    const allLows = rangePairs.map((p) => p[0]);
    const allHighs = rangePairs.map((p) => p[1]);
    const derivedMin = allLows.length ? Math.min.apply(null, allLows) : 5;
    const derivedMax = allHighs.length ? Math.max.apply(null, allHighs) : 12;

    // Collect semesters → CSV "9-1,2-6" (author order, no swap)
    const semPairs = [];
    document.querySelectorAll('#semesterList .sem-row').forEach((row) => {
      const s = Number(row.querySelector('.ss').value);
      const e = Number(row.querySelector('.se').value);
      if (s >= 1 && s <= 12 && e >= 1 && e <= 12) semPairs.push(s+'-'+e);
    });
    const semesters = semPairs.join(',');

    const payload = {
      schoolName:     document.getElementById('schoolName').value.trim(),
      logoUrl:        document.getElementById('logoUrl').value || undefined,
      minGrade:       derivedMin,
      maxGrade:       derivedMax,
      gradeRanges:    gradeRanges || undefined,
      semesters:      semesters || undefined,
      subjects: subjects.length ? subjects : undefined,
      bellSchedule: bell.length ? bell : undefined,
      adminName:      document.getElementById('adminName').value.trim(),
      adminUsername:  document.getElementById('adminUsername').value.trim() || undefined,
      adminEmail:     document.getElementById('adminEmail').value.trim() || undefined,
      adminPassword:  document.getElementById('adminPassword').value,
    };

    try {
      const res = await fetch('/cms/school', {
        method:'POST',
        headers:{'Content-Type':'application/json','x-setup-secret':secret},
        body:JSON.stringify(payload),
      });
      const data = await res.json();
      result.style.display = 'block';
      if (res.ok) {
        result.className = 'result ok';
        result.innerHTML = '<strong>✓ School created!</strong><pre>' + JSON.stringify(data, null, 2) + '</pre>';
        document.getElementById('form').reset();
        logoZone.classList.remove('has-file');
        logoStatus.textContent = ''; logoUrl.value = '';
      } else {
        result.className = 'result err';
        // Show the real error message from the server
        const msg = Array.isArray(data.message) ? data.message.join('<br>') : (data.message || 'Unknown error');
        result.innerHTML = '<strong>✗ ' + (data.error || 'Error') + '</strong><br>' + msg;
      }
    } catch(err) {
      result.className = 'result err';
      result.style.display = 'block';
      result.innerHTML = '<strong>✗ Network error</strong><br>' + err.message;
    } finally {
      btn.disabled = false; btn.textContent = 'Create School';
    }
  });

  // ── Tab switcher ──────────────────────────────────────────────────────────
  function showTab(name) {
    document.querySelectorAll('.tab-btn').forEach(b =>
      b.classList.toggle('active', b.dataset.tab === name));
    document.querySelectorAll('.pane').forEach(p =>
      p.classList.toggle('active', p.id === 'tab-' + name));
    if (name === 'schools') loadSchools();
  }
  document.querySelectorAll('.tab-btn').forEach(b =>
    b.addEventListener('click', () => showTab(b.dataset.tab)));

  // ── Schools list ──────────────────────────────────────────────────────────
  async function loadSchools() {
    const secret = document.getElementById('secret').value.trim();
    if (!secret) {
      document.getElementById('schoolsList').innerHTML =
        '<div class="school-empty">Enter your setup secret in the Create tab first.</div>';
      return;
    }
    const list = document.getElementById('schoolsList');
    list.innerHTML = '<div class="school-empty">Loading…</div>';
    try {
      const res = await fetch('/cms/schools', { headers: { 'x-setup-secret': secret } });
      const data = await res.json();
      if (!res.ok) {
        list.innerHTML = '<div class="school-empty">' + (data.message || 'Failed to load.') + '</div>';
        return;
      }
      const schools = data.schools || [];
      document.getElementById('schoolsCount').textContent =
        '(' + schools.length + ' school' + (schools.length === 1 ? '' : 's') + ')';
      if (!schools.length) {
        list.innerHTML = '<div class="school-empty">No schools yet — create one in the Create tab.</div>';
        return;
      }
      list.innerHTML = schools.map(renderSchool).join('');
      // Hook up actions
      list.querySelectorAll('[data-view]').forEach(el =>
        el.addEventListener('click', () => openView(el.dataset.view)));
      list.querySelectorAll('[data-edit]').forEach(el =>
        el.addEventListener('click', () => openEdit(JSON.parse(decodeURIComponent(el.dataset.edit)))));
      list.querySelectorAll('[data-delete]').forEach(el =>
        el.addEventListener('click', () => openDelete(JSON.parse(decodeURIComponent(el.dataset.delete)))));
    } catch (err) {
      list.innerHTML = '<div class="school-empty">' + err.message + '</div>';
    }
  }

  function escapeHtml(s) {
    return String(s ?? '').replace(/&/g, '&amp;').replace(/</g, '&lt;')
      .replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }

  function renderSchool(s) {
    const adminLine = s.admins && s.admins.length
      ? s.admins.map(a => escapeHtml(a.name || a.email || a.username || '?')).join(', ')
      : '<em>No admins</em>';
    const u = s.userCounts || {};
    const total = (u.STUDENT||0)+(u.TEACHER||0)+(u.SECRETARY||0)+(u.PARENT||0)+(u.ADMIN||0);
    // Real uploaded logo renders untouched; fallback ClassMate mark gets the
    // white-on-blue treatment for readability against the card background.
    const fallback = ${JSON.stringify(LOGO_DATA_URI)};
    const logo = s.logoUrl
      ? '<img src="' + escapeHtml(s.logoUrl) + '" onerror="this.classList.add(\\'fallback-logo\\'); this.src=\\'' + fallback + '\\';">'
      : '<img class="fallback-logo" src="' + fallback + '">';
    const payload = encodeURIComponent(JSON.stringify(s));
    return ''
      + '<div class="school-card">'
      +   '<div class="school-card-hdr">'
      +     logo
      +     '<h3>' + escapeHtml(s.name) + '</h3>'
      +     '<div class="school-actions">'
      +       '<button data-view="' + s.id + '">View</button>'
      +       '<button data-edit="' + payload + '">Edit</button>'
      +       '<button class="danger" data-delete="' + payload + '">Delete</button>'
      +     '</div>'
      +   '</div>'
      +   '<div class="school-stats">'
      +     '<div class="school-stat"><div class="num">' + total + '</div><div class="lbl">Users</div></div>'
      +     '<div class="school-stat"><div class="num">' + (u.STUDENT || 0) + '</div><div class="lbl">Students</div></div>'
      +     '<div class="school-stat"><div class="num">' + (s.cohortCount || 0) + '</div><div class="lbl">Cohorts</div></div>'
      +     '<div class="school-stat"><div class="num">' + (s.subjectCount || 0) + '</div><div class="lbl">Subjects</div></div>'
      +   '</div>'
      +   '<div class="school-admins">Grades ' + s.minGrade + '–' + s.maxGrade
      +     ' · Admins: ' + adminLine + '</div>'
      + '</div>';
  }

  // ── View modal ────────────────────────────────────────────────────────────
  async function openView(id) {
    const secret = document.getElementById('secret').value.trim();
    const body = document.getElementById('viewModalBody');
    body.innerHTML = 'Loading…';
    document.getElementById('viewModal').classList.add('show');
    try {
      const res = await fetch('/cms/schools/' + encodeURIComponent(id),
        { headers: { 'x-setup-secret': secret } });
      const data = await res.json();
      if (!res.ok) { body.textContent = data.message || 'Failed.'; return; }
      const s = data.school;
      const u = s.userCounts || {};
      const adminRows = (s.admins || []).map(a =>
        '<tr><td>' + escapeHtml(a.nameEn || a.name || '?') + '</td><td>'
        + escapeHtml(a.email || a.username || '—') + '</td></tr>').join('');
      document.getElementById('viewModalTitle').textContent = s.name;
      body.innerHTML = ''
        + '<p>Created ' + new Date(s.createdAt).toLocaleString()
        + ' · Grades ' + s.minGrade + '–' + s.maxGrade + '</p>'
        + '<div class="row2">'
        + '<div class="school-stat"><div class="num">' + (u.STUDENT||0) + '</div><div class="lbl">Students</div></div>'
        + '<div class="school-stat"><div class="num">' + (u.TEACHER||0) + '</div><div class="lbl">Teachers</div></div>'
        + '<div class="school-stat"><div class="num">' + (u.SECRETARY||0) + '</div><div class="lbl">Secretaries</div></div>'
        + '<div class="school-stat"><div class="num">' + (u.PARENT||0)   + '</div><div class="lbl">Parents</div></div>'
        + '<div class="school-stat"><div class="num">' + (u.ADMIN||0)    + '</div><div class="lbl">Admins</div></div>'
        + '<div class="school-stat"><div class="num">' + (s.cohortCount||0) + '</div><div class="lbl">Cohorts</div></div>'
        + '<div class="school-stat"><div class="num">' + (s.classroomCount||0) + '</div><div class="lbl">Classrooms</div></div>'
        + '<div class="school-stat"><div class="num">' + (s.subjects?.length||0) + '</div><div class="lbl">Subjects</div></div>'
        + '</div>'
        + (adminRows
            ? '<h3 style="margin-top:18px; font-size:13px;">Admins</h3>'
              + '<table style="width:100%; font-size:13px; color:var(--muted);"><tbody>' + adminRows + '</tbody></table>'
            : '');
    } catch (err) {
      body.textContent = err.message;
    }
  }
  document.getElementById('viewClose').addEventListener('click', () =>
    document.getElementById('viewModal').classList.remove('show'));

  // ── Edit modal ────────────────────────────────────────────────────────────
  let editingId = null;
  function openEdit(s) {
    editingId = s.id;
    document.getElementById('editModalTitle').textContent = 'Edit ' + s.name;
    document.getElementById('editName').value = s.name;
    document.getElementById('editMin').value = s.minGrade;
    document.getElementById('editMax').value = s.maxGrade;
    document.getElementById('editErr').classList.remove('show');
    document.getElementById('editModal').classList.add('show');
  }
  document.getElementById('editCancel').addEventListener('click', () =>
    document.getElementById('editModal').classList.remove('show'));
  document.getElementById('editSave').addEventListener('click', async () => {
    const secret = document.getElementById('secret').value.trim();
    const errEl = document.getElementById('editErr');
    const btn = document.getElementById('editSave');
    btn.disabled = true; btn.textContent = 'Saving…';
    try {
      const res = await fetch('/cms/schools/' + encodeURIComponent(editingId), {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', 'x-setup-secret': secret },
        body: JSON.stringify({
          name: document.getElementById('editName').value,
          minGrade: Number(document.getElementById('editMin').value),
          maxGrade: Number(document.getElementById('editMax').value),
        }),
      });
      const data = await res.json();
      if (!res.ok) { errEl.textContent = data.message || 'Failed.'; errEl.classList.add('show'); return; }
      document.getElementById('editModal').classList.remove('show');
      loadSchools();
    } catch (err) {
      errEl.textContent = err.message; errEl.classList.add('show');
    } finally {
      btn.disabled = false; btn.textContent = 'Save';
    }
  });

  // ── Delete-one modal ──────────────────────────────────────────────────────
  let deletingSchool = null;
  function openDelete(s) {
    deletingSchool = s;
    document.getElementById('deleteModalBody').innerHTML =
      'This permanently removes <strong>' + escapeHtml(s.name) + '</strong> and every user, cohort, classroom, schedule slot, message, assignment, exam, attendance record, and grade associated with it.';
    document.getElementById('deleteSchoolNameHint').textContent = '(' + s.name + ')';
    document.getElementById('deleteConfirmInput').value = '';
    document.getElementById('deleteGo').disabled = true;
    document.getElementById('deleteErr').classList.remove('show');
    document.getElementById('deleteModal').classList.add('show');
  }
  document.getElementById('deleteConfirmInput').addEventListener('input', e => {
    document.getElementById('deleteGo').disabled =
      !deletingSchool || e.target.value.trim() !== deletingSchool.name;
  });
  document.getElementById('deleteCancel').addEventListener('click', () =>
    document.getElementById('deleteModal').classList.remove('show'));
  document.getElementById('deleteGo').addEventListener('click', async () => {
    const secret = document.getElementById('secret').value.trim();
    const errEl = document.getElementById('deleteErr');
    const btn = document.getElementById('deleteGo');
    btn.disabled = true; btn.textContent = 'Deleting…';
    try {
      const res = await fetch('/cms/schools/' + encodeURIComponent(deletingSchool.id), {
        method: 'DELETE', headers: { 'x-setup-secret': secret },
      });
      const data = await res.json();
      if (!res.ok) { errEl.textContent = data.message || 'Failed.'; errEl.classList.add('show'); btn.disabled = false; btn.textContent = 'Delete forever'; return; }
      document.getElementById('deleteModal').classList.remove('show');
      loadSchools();
    } catch (err) {
      errEl.textContent = err.message; errEl.classList.add('show');
      btn.disabled = false; btn.textContent = 'Delete forever';
    }
  });

  // ── Reset-all (danger zone) ───────────────────────────────────────────────
  let resetSessionId = null;
  function resetModalReset() {
    document.getElementById('resetStep1').style.display = '';
    document.getElementById('resetStep2').style.display = 'none';
    document.getElementById('resetCode').value = '';
    document.getElementById('resetConfirmText').value = '';
    document.getElementById('resetGo').disabled = true;
    document.getElementById('resetErr').classList.remove('show');
    document.getElementById('resetOk').classList.remove('show');
    resetSessionId = null;
  }
  document.getElementById('resetStartBtn').addEventListener('click', () => {
    resetModalReset();
    document.getElementById('resetModal').classList.add('show');
  });
  document.getElementById('resetCancel1').addEventListener('click', () =>
    document.getElementById('resetModal').classList.remove('show'));
  document.getElementById('resetCancel2').addEventListener('click', () =>
    document.getElementById('resetModal').classList.remove('show'));

  document.getElementById('resetSendCode').addEventListener('click', async () => {
    const secret = document.getElementById('secret').value.trim();
    const errEl = document.getElementById('resetErr');
    const btn = document.getElementById('resetSendCode');
    if (!secret) { alert('Enter your setup secret in the Create tab first.'); return; }
    btn.disabled = true; btn.textContent = 'Sending…';
    try {
      const res = await fetch('/cms/reset-all/request-code', {
        method: 'POST', headers: { 'x-setup-secret': secret },
      });
      const data = await res.json();
      if (!res.ok) {
        errEl.textContent = data.message || 'Failed.'; errEl.classList.add('show');
        return;
      }
      resetSessionId = data.sessionId;
      document.getElementById('resetModalBody').textContent =
        'Code sent to ' + data.sentTo + '. Enter it below, then type RESET. Code expires in ' + data.expiresInMinutes + ' min.';
      document.getElementById('resetStep1').style.display = 'none';
      document.getElementById('resetStep2').style.display = '';
      errEl.classList.remove('show');
    } catch (err) {
      errEl.textContent = err.message; errEl.classList.add('show');
    } finally {
      btn.disabled = false; btn.textContent = 'Send code';
    }
  });

  function updateResetGoEnabled() {
    const code = document.getElementById('resetCode').value.trim();
    const confirm = document.getElementById('resetConfirmText').value;
    document.getElementById('resetGo').disabled =
      !(code.length === 6 && confirm === 'RESET' && resetSessionId);
  }
  document.getElementById('resetCode').addEventListener('input', updateResetGoEnabled);
  document.getElementById('resetConfirmText').addEventListener('input', updateResetGoEnabled);

  document.getElementById('resetGo').addEventListener('click', async () => {
    const secret = document.getElementById('secret').value.trim();
    const errEl = document.getElementById('resetErr');
    const okEl = document.getElementById('resetOk');
    const btn = document.getElementById('resetGo');
    btn.disabled = true; btn.textContent = 'Nuking…';
    try {
      const res = await fetch('/cms/reset-all/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'x-setup-secret': secret },
        body: JSON.stringify({
          sessionId: resetSessionId,
          code: document.getElementById('resetCode').value.trim(),
          confirm: document.getElementById('resetConfirmText').value,
        }),
      });
      const data = await res.json();
      if (!res.ok) {
        errEl.textContent = data.message || 'Failed.'; errEl.classList.add('show');
        btn.disabled = false; btn.textContent = 'Nuke everything';
        return;
      }
      okEl.textContent = '✓ Done. ' + data.message + ' Reload the page to start fresh.';
      okEl.classList.add('show');
      errEl.classList.remove('show');
      btn.textContent = 'Done';
    } catch (err) {
      errEl.textContent = err.message; errEl.classList.add('show');
      btn.disabled = false; btn.textContent = 'Nuke everything';
    }
  });
</script>
</body>
</html>`;
}
