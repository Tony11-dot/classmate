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

@UseGuards(JwtAuthGuard)
@Controller('schedule')
export class ScheduleController {
  constructor(
    private readonly schedule: ScheduleService,
    private readonly prisma: PrismaService,
  ) {}

  @Get('today')
  async today(
    @Req() req: any,
    @Query('cohortId') cohortId?: string,
    @Query('childId') childId?: string,
  ) {
    const roles: string[] = req.user?.roles ?? [];

    // STUDENT: from own StudentProfile -> cohortId
    if (roles.includes('STUDENT')) {
      const u = await this.prisma.user.findUnique({
        where: { id: req.user.id },
        select: { studentProfile: { select: { cohortId: true } } },
      });
      const cid = u?.studentProfile?.cohortId;
      if (!cid) throw new BadRequestException('Student is missing cohortId');
      return this.schedule.getTodayForCohort(cid);
    }

    // PARENT: require childId and verify APPROVED link
    if (roles.includes('PARENT')) {
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
      return this.schedule.getTodayForCohort(cid);
    }

    // TEACHER/ADMIN/SECRETARY: for now require cohortId (fast MVP)
    if (!cohortId) throw new BadRequestException('cohortId is required');
    return this.schedule.getTodayForCohort(cohortId);
  }

  @Get('week')
  async week(
    @Query('cohortId') cohortId?: string,
    @Query('weekOf') weekOf?: string,
  ) {
    if (!cohortId) throw new BadRequestException('cohortId is required');
    return this.schedule.getWeekForCohort(cohortId, weekOf);
  }
}
