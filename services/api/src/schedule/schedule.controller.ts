import {
  BadRequestException,
  Controller,
  Get,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';
import { ScheduleService } from './schedule.service';
import { resolveCohortIdForSchedule } from './schedule.auth';
import { hasAnyRole } from '../auth/permissions';

@UseGuards(JwtAuthGuard)
@Controller('schedule')
export class ScheduleController {
  constructor(
    private readonly schedule: ScheduleService,
    private readonly prisma: PrismaService,
  ) {}

  /**
   * Resolve cohortId based on role:
   * - STUDENT: from own StudentProfile
   * - PARENT: require childId, verify APPROVED link, use child's StudentProfile
   * - TEACHER/ADMIN/SECRETARY: require cohortId (fast MVP)
   */
  private async resolveCohortId(
    req: any,
    cohortId?: string,
    childId?: string,
  ): Promise<string> {
    const roles: string[] = req.user?.roles ?? [];

    if (hasAnyRole({ roles }, ['STUDENT'])) {
      const u = await this.prisma.user.findUnique({
        where: { id: req.user.id },
        select: { studentProfile: { select: { cohortId: true } } },
      });
      const cid = u?.studentProfile?.cohortId;
      if (!cid) throw new BadRequestException('Student is missing cohortId');
      return cid;
    }

    if (hasAnyRole({ roles }, ['PARENT'])) {
      if (!childId)
        throw new BadRequestException('childId is required for parents');

      const link = await this.prisma.parentChild.findFirst({
        where: { parentId: req.user.id, childId, status: 'APPROVED' },
        select: {
          child: { select: { studentProfile: { select: { cohortId: true } } } },
        },
      });

      const cid = link?.child?.studentProfile?.cohortId;
      if (!cid)
        throw new BadRequestException(
          'Child has no cohortId (no StudentProfile?)',
        );

      return cid;
    }

    if (!cohortId) throw new BadRequestException('cohortId is required');
    return cohortId;
  }

  @Get('today')
  async today(
    @Req() req: any,
    @Query('cohortId') cohortId?: string,
    @Query('childId') childId?: string,
  ) {
    const cid = await resolveCohortIdForSchedule({
      prisma: this.prisma,
      req,
      cohortId,
      childId,
    });

    const data = await this.schedule.getTodayForCohort(cid);
    return { ok: true, ...data };
  }

  @Get('week')
  async week(
    @Req() req: any,
    @Query('cohortId') cohortId?: string,
    @Query('childId') childId?: string,
    @Query('weekOf') weekOf?: string,
  ) {
    const cid = await resolveCohortIdForSchedule({
      prisma: this.prisma,
      req,
      cohortId,
      childId,
    });

    const data = await this.schedule.getWeekGridForCohort(cid, weekOf);

    return { ok: true, ...data };
  }

  @Get('week-grid')
  weekGrid(
    @Req() req: any,
    @Query('cohortId') cohortId?: string,
    @Query('childId') childId?: string,
    @Query('weekOf') weekOf?: string,
  ) {
    // Alias to /schedule/week (same output shape)
    return this.week(req, cohortId, childId, weekOf);
  }
}
