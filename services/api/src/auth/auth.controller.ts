import { BadRequestException, Body, ConflictException, Controller, Get, HttpException, HttpStatus, Patch, Post, Req, UnauthorizedException, UseGuards } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { Public } from './decorators/public.decorator';
import { Throttle } from '@nestjs/throttler';
import { JwtAuthGuard } from './jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';
import { AuthService } from './auth.service';
import { ChangePasswordDto } from './dto/change-password.dto';
import { deriveUsernameCandidate, ensureUniqueUsername } from '../common/username';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auth: AuthService,
  ) {}

  @Public()
  @Throttle({ auth: { limit: 5, ttl: 15 * 60_000 } })
  @Post('login')
  async login(@Body() body: any) {
    const identifier = String(body?.identifier ?? body?.email ?? body?.username ?? '').trim().toLowerCase();
    const password = String(body?.password ?? '');
    if (!identifier) throw new BadRequestException('identifier (email or username) required');
    if (!password) throw new BadRequestException('password required');

    const result = await this.auth.login(identifier, password);
    if (!result) throw new UnauthorizedException('Incorrect email/username or password.');
    return result;
  }

  @Public()
  @Throttle({ auth: { limit: 5, ttl: 15 * 60_000 } })
  @Post('register')
  async register(@Body() body: any) {
    const email = String(body?.email ?? '').trim().toLowerCase();
    const name = String(body?.name ?? '').trim();
    const password = String(body?.password ?? '').trim();
    const schoolId: string | null = body?.schoolId ? String(body.schoolId).trim() : null;

    if (!email || !email.includes('@')) throw new BadRequestException('Valid email required');
    if (!name) throw new BadRequestException('Name required');
    if (!password || password.length < 3) throw new BadRequestException('Password must be at least 3 characters');

    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) throw new ConflictException('Email already registered');

    const hash = await bcrypt.hash(password, 10);
    // Every user must have a username (the app's primary login identifier).
    // If the caller supplied one, sanitize + uniquify it; otherwise derive
    // from the email local-part.
    const suppliedUsername = String(body?.username ?? '').trim().toLowerCase();
    const usernameCandidate = suppliedUsername.length > 0
        ? suppliedUsername.replace(/[^a-z0-9_.-]/g, '')
        : deriveUsernameCandidate(email, name);
    const username = await ensureUniqueUsername(this.prisma, usernameCandidate);
    await this.prisma.user.create({
      data: {
        email,
        username,
        name,
        password: hash,
        plainPassword: password,
        status: 'ACTIVE',
        ...(schoolId ? { schoolId } : {}),
        roles: { create: [{ role: 'STUDENT' }] },
      } as any,
    });

    // Auth system uses dev-token pattern — token = 'dev-token-{email}'
    // The DevOverrideGuard handles user provisioning on first request
    return { token: `dev-token-${email}` };
  }

  /**
   * Self-service username change with GLOBAL uniqueness. Returns 409 when
   * another account already owns the requested username. Empty/null wipes
   * the username (account becomes email-only).
   */
  @UseGuards(JwtAuthGuard)
  @Patch('me/username')
  async updateMyUsername(@Req() req: any, @Body() body: { username?: string | null }) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) throw new BadRequestException('Not authenticated');

    const raw = body?.username == null ? null : String(body.username).trim().toLowerCase();
    const un = raw === '' ? null : raw;

    if (un) {
      // Mirror admin updateUser logic — global uniqueness, not per-school.
      // Usernames are login identifiers; two users sharing one would break
      // login. Conflict against THIS user's row is fine (no-op rename).
      const conflict = await this.prisma.user.findFirst({ where: { username: un } as any });
      if (conflict && conflict.id !== userId) {
        throw new HttpException('Username already in use', HttpStatus.CONFLICT);
      }
    }

    await this.prisma.user.update({ where: { id: userId }, data: { username: un } as any });
    return { ok: true, username: un };
  }

  @UseGuards(JwtAuthGuard)
  @Patch('profile/name')
  async updateProfileName(@Req() req: any, @Body() body: any) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) return { ok: false };
    const data: any = {};
    if (body?.nameEn !== undefined) data.nameEn = body.nameEn ? String(body.nameEn).trim() : null;
    if (body?.nameAr !== undefined) data.nameAr = body.nameAr ? String(body.nameAr).trim() : null;
    if (body?.nameHe !== undefined) data.nameHe = body.nameHe ? String(body.nameHe).trim() : null;
    if (body?.nameFr !== undefined) data.nameFr = body.nameFr ? String(body.nameFr).trim() : null;
    if (body?.nameRu !== undefined) data.nameRu = body.nameRu ? String(body.nameRu).trim() : null;
    if (body?.displayNameLang !== undefined) data.displayNameLang = body.displayNameLang ? String(body.displayNameLang).trim() : null;
    if (body?.displayName !== undefined) data.displayName = body.displayName ? String(body.displayName).trim() : null;
    if (Object.keys(data).length === 0) return { ok: true };
    await this.prisma.user.update({ where: { id: userId }, data });
    return { ok: true };
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  async me(@Req() req: any) {
    const u = req.user ?? null;
    if (!u) return null;

    const userId = u.sub ?? u.id ?? null;
    const schoolId = u.schoolId ?? null;
    let schoolName: string | null = null;
    let schoolLogoUrl: string | null = null;
    let cohortName: string | null = null;
    let fullName: string | null = null;
    let nameEn: string | null = null;
    let nameAr: string | null = null;
    let nameHe: string | null = null;
    let nameFr: string | null = null;
    let nameRu: string | null = null;
    let displayNameLang: string | null = null;
    let displayName: string | null = null;
    let username: string | null = null;
    let phone: string | null = null;
    let emailVerifiedAt: string | null = null;
    let phoneVerifiedAt: string | null = null;

    // Fetch up-to-date user fields from DB (the JWT only carries the claim snapshot)
    if (userId) {
      try {
        const dbUser = await this.prisma.user.findUnique({
          where: { id: userId },
          select: {
            name: true,
            displayName: true,
            legalName: true,
            username: true,
            nameEn: true,
            nameAr: true,
            nameHe: true,
            nameFr: true,
            nameRu: true,
            displayNameLang: true,
            phone: true,
            emailVerifiedAt: true,
            phoneVerifiedAt: true,
          } as any,
        }) as any;
        if (dbUser) {
          fullName = dbUser.legalName ?? dbUser.displayName ?? dbUser.name ?? null;
          displayName = dbUser.displayName ?? null;
          username = dbUser.username ?? null;
          nameEn = dbUser.nameEn ?? null;
          nameAr = dbUser.nameAr ?? null;
          nameHe = dbUser.nameHe ?? null;
          nameFr = dbUser.nameFr ?? null;
          nameRu = dbUser.nameRu ?? null;
          displayNameLang = dbUser.displayNameLang ?? null;
          phone = dbUser.phone ?? null;
          emailVerifiedAt = dbUser.emailVerifiedAt
            ? new Date(dbUser.emailVerifiedAt).toISOString()
            : null;
          phoneVerifiedAt = dbUser.phoneVerifiedAt
            ? new Date(dbUser.phoneVerifiedAt).toISOString()
            : null;
        }
      } catch {}
    }

    let schoolMinGrade: number | null = null;
    let schoolMaxGrade: number | null = null;
    let schoolGradeRanges: string | null = null;
    let schoolSemesters: string | null = null;
    if (schoolId) {
      try {
        const school = await this.prisma.school.findUnique({
          where: { id: schoolId },
          select: { name: true, logoUrl: true, minGrade: true, maxGrade: true, gradeRanges: true, semesters: true } as any,
        }) as any;
        schoolName = school?.name ?? null;
        schoolLogoUrl = school?.logoUrl ?? null;
        schoolMinGrade = school?.minGrade ?? null;
        schoolMaxGrade = school?.maxGrade ?? null;
        schoolGradeRanges = school?.gradeRanges ?? null;
        schoolSemesters = school?.semesters ?? null;
      } catch {}
    }

    // Cohort name lookup
    const cohortId = u.cohortId ?? null;
    if (cohortId) {
      try {
        const cohort = await this.prisma.cohort.findUnique({
          where: { id: cohortId },
          select: { name: true },
        });
        cohortName = cohort?.name ?? null;
      } catch {}
    }

    return require('../contracts/auth.contract').AuthMeResponseSchema.parse({
      id: u.id ?? null,
      email: u.email ?? null,
      username,
      roles: u.roles ?? [],
      actingStudentId: u.actingStudentId ?? null,
      schoolId,
      cohortId,
      cohortName,
      schoolName,
      schoolLogoUrl,
      schoolMinGrade,
      schoolMaxGrade,
      schoolGradeRanges,
      schoolSemesters,
      fullName,
      displayName,
      nameEn,
      nameAr,
      nameHe,
      nameFr,
      nameRu,
      displayNameLang,
      phone,
      emailVerifiedAt,
      phoneVerifiedAt,
    });
  }

  /**
   * Returns the current user's school's subject list (multi-language).
   * Available to any authenticated role so the Solutions screen and other
   * student-facing surfaces can render the school-owned subject selector.
   */
  @UseGuards(JwtAuthGuard)
  @Get('me/subjects')
  async meSubjects(@Req() req: any) {
    const schoolId = (req.user as any)?.schoolId;
    if (!schoolId) return { ok: true, subjects: [] };

    // Single canonical row at grade=0 (school-wide). Per-grade overrides not
    // surfaced here yet — solutions UI just needs the school's master list.
    const row = await this.prisma.schoolGradeSubjectDefault.findUnique({
      where: { schoolId_grade_unique: { schoolId, grade: 0 } } as any,
      select: { subjects: true, subjectsI18n: true } as any,
    }) as any;
    if (!row) return { ok: true, subjects: [] };

    // Same fallback rule as getSubjectDefaults: prefer i18n, derive from
    // legacy String[] if i18n is empty.
    const i18nRaw = Array.isArray(row.subjectsI18n) ? row.subjectsI18n : [];
    const i18n = i18nRaw.length
      ? i18nRaw
      : (row.subjects ?? []).map((s: string) => ({ nameEn: s }));
    return { ok: true, subjects: i18n };
  }

  @UseGuards(JwtAuthGuard)
  @Throttle({ auth: { limit: 5, ttl: 15 * 60_000 } })
  @Post('me/password')
  async changePassword(@Req() req: any, @Body() body: ChangePasswordDto) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) throw new BadRequestException('Not authenticated');

    // class-validator + global ValidationPipe (whitelist + forbidNonWhitelisted)
    // has already enforced length + type. We just trim defensively.
    const currentPassword = body.currentPassword.trim();
    const newPassword = body.newPassword.trim();

    const user = await this.prisma.user.findUnique({ where: { id: userId }, select: { password: true } });
    if (!user) throw new BadRequestException('User not found');

    const isValid = await bcrypt.compare(currentPassword, user.password);
    if (!isValid) throw new BadRequestException('WRONG_PASSWORD');

    const hash = await bcrypt.hash(newPassword, 10);
    await this.prisma.user.update({ where: { id: userId }, data: { password: hash, plainPassword: newPassword } });
    return { ok: true };
  }
}
