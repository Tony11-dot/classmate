import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

/// Runs the annual "Sept-1 grade bump" for each school, at most once per
/// year per school.  Every student's `studentProfile.grade` increments by 1;
/// any student whose new grade exceeds the school's `maxGrade` (typically
/// 12 → 13) has their account deleted.  School.lastGradeBumpYear tracks the
/// most recent successful run so reruns within the same year are no-ops.
///
/// Triggering: a check fires on application boot and then every 24 hours via
/// setInterval.  No @nestjs/schedule dependency is needed.  An admin can
/// also call `runForSchool` directly if a manual catch-up is needed.
@Injectable()
export class GradeBumpService implements OnApplicationBootstrap {
  private readonly logger = new Logger(GradeBumpService.name);
  private timer: NodeJS.Timeout | null = null;
  /// Bump anniversary — Sept 1 (school year start in IL).
  private static readonly BUMP_MONTH = 9;
  private static readonly BUMP_DAY = 1;

  constructor(private readonly prisma: PrismaService) {}

  onApplicationBootstrap() {
    // Grade promotion is MANUAL by default — admins press "Upgrade grades" in
    // Users → Students (admin.promoteAllGrades), which is safer than a silent
    // date trigger (schools start on different days; held-back students; no
    // accidental account deletion). The automatic Sept-1 sweep stays available
    // but OFF unless AUTO_GRADE_BUMP=true is set in the environment.
    if ((process.env.AUTO_GRADE_BUMP ?? '').toLowerCase() !== 'true') {
      this.logger.log('Auto grade-bump disabled (manual promotion only). Set AUTO_GRADE_BUMP=true to re-enable.');
      return;
    }
    // First check ~5s after boot so we don't block startup; then every 24h.
    setTimeout(() => this.checkAll().catch((e) => this.logger.error('initial check failed', e as any)), 5_000);
    this.timer = setInterval(() => {
      this.checkAll().catch((e) => this.logger.error('periodic check failed', e as any));
    }, 24 * 60 * 60 * 1000);
  }

  onModuleDestroy() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }

  /// Returns true when today (local time) is on or after Sept 1 of [year].
  private isPastSeptFirst(now: Date, year: number): boolean {
    const target = new Date(year, GradeBumpService.BUMP_MONTH - 1, GradeBumpService.BUMP_DAY);
    return now.getTime() >= target.getTime();
  }

  /// Sweep every school and run the bump where it's due.
  async checkAll(): Promise<{ schoolsBumped: number; studentsBumped: number; accountsDeleted: number }> {
    const now = new Date();
    const currentYear = now.getFullYear();
    const schools = await this.prisma.school.findMany({
      select: { id: true, name: true, maxGrade: true, lastGradeBumpYear: true } as any,
    });

    let schoolsBumped = 0;
    let studentsBumped = 0;
    let accountsDeleted = 0;

    for (const school of schools as any[]) {
      const lastYear = school.lastGradeBumpYear ?? null;
      if (lastYear === currentYear) continue;            // already bumped this year
      if (!this.isPastSeptFirst(now, currentYear)) continue; // not yet Sept 1

      try {
        const result = await this.runForSchool(school.id);
        schoolsBumped++;
        studentsBumped += result.bumped;
        accountsDeleted += result.deleted;
        this.logger.log(
          `Grade bump for school ${school.name} (${school.id}): bumped=${result.bumped} deleted=${result.deleted}`,
        );
      } catch (e) {
        this.logger.error(`Grade bump failed for school ${school.id}`, e as any);
      }
    }

    return { schoolsBumped, studentsBumped, accountsDeleted };
  }

  /// Runs the bump for a single school regardless of date — used by the
  /// scheduler when conditions are met, and exposed for admin retries.
  /// Idempotent within the same calendar year via lastGradeBumpYear.
  async runForSchool(schoolId: string): Promise<{ bumped: number; deleted: number }> {
    const school = await this.prisma.school.findUnique({
      where: { id: schoolId },
      select: { id: true, maxGrade: true, lastGradeBumpYear: true } as any,
    });
    if (!school) throw new Error(`School ${schoolId} not found`);

    const maxGrade: number = (school as any).maxGrade ?? 12;
    const year = new Date().getFullYear();

    // Pull every student in this school with a grade set on their profile.
    const students = await this.prisma.studentProfile.findMany({
      where: { user: { schoolId } },
      select: { userId: true, grade: true },
    });

    let bumped = 0;
    let deleted = 0;
    const toDelete: string[] = [];

    // Run inside a transaction so a partial failure doesn't leave the
    // school half-bumped and the marker un-updated.
    await this.prisma.$transaction(async (tx) => {
      for (const s of students) {
        const oldGrade = s.grade ?? null;
        if (oldGrade == null) continue;
        const newGrade = oldGrade + 1;
        if (newGrade > maxGrade) {
          toDelete.push(s.userId);
          continue;
        }
        await tx.studentProfile.update({
          where: { userId: s.userId },
          data: { grade: newGrade },
        });
        bumped++;
      }
      if (toDelete.length) {
        // Cascade rules on User delete most relations; password reset
        // tokens etc. fall over via onDelete: Cascade.
        await tx.user.deleteMany({ where: { id: { in: toDelete } } });
        deleted = toDelete.length;
      }
      await tx.school.update({
        where: { id: schoolId },
        data: { lastGradeBumpYear: year } as any,
      });
    });

    return { bumped, deleted };
  }
}
