import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { Controller, Get, Query, Req, UseGuards } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ScheduleService } from '../schedule/schedule.service';
import { PrismaService } from '../prisma/prisma.service';

@UseGuards(JwtAuthGuard)
@Roles(Role.STUDENT, Role.ADMIN)
@Controller('student/schedule')
export class StudentScheduleController {
  constructor(
    private readonly schedule: ScheduleService,
    private readonly prisma: PrismaService,
  ) {}

  private async cohortIdFromUser(req: any): Promise<string> {
    const uid = String(req?.user?.sub ?? req?.user?.id ?? '');
    if (!uid) throw new Error('Missing user id');
    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: uid },
      select: { cohortId: true },
    });
    if (!sp?.cohortId) throw new Error('Student not onboarded');
    return String(sp.cohortId);
  }

  @SkipThrottle()
  @Get('today')
  async today(@Req() req: any) {
    const cohortId = await this.cohortIdFromUser(req);
    return this.schedule.getTodayForCohort(cohortId);
  }

  @SkipThrottle()
  @Get('week')
  async week(@Req() req: any, @Query('weekOf') weekOf?: string) {
    const cohortId = await this.cohortIdFromUser(req);
    return this.schedule.getWeekForCohort(cohortId, weekOf);
  }
}
