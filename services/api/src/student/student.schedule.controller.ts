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

  private async studentContext(req: any): Promise<{
    schoolId: string;
    studentId: string;
    cohortId: string;
  }> {
    const uid = String(req?.user?.sub ?? req?.user?.id ?? '');
    if (!uid) throw new Error('Missing user id');
    const user = await this.prisma.user.findUnique({
      where: { id: uid },
      select: {
        schoolId: true,
        studentProfile: { select: { cohortId: true } },
      } as any,
    }) as any;
    const schoolId = String(user?.schoolId ?? '');
    if (!schoolId) throw new Error('Student not onboarded');
    return {
      schoolId,
      studentId: uid,
      // Cohort is optional — students with only a grade still see grade-mode
      // slots via the audienceGrade lookup in resolveTemplateSlotsForStudent.
      cohortId: String(user?.studentProfile?.cohortId ?? ''),
    };
  }

  @SkipThrottle()
  @Get('today')
  async today(@Req() req: any) {
    const ctx = await this.studentContext(req);
    return this.schedule.getTodayForStudent(ctx);
  }

  @SkipThrottle()
  @Get('week')
  async week(@Req() req: any, @Query('weekOf') weekOf?: string) {
    const ctx = await this.studentContext(req);
    return this.schedule.getWeekForStudent({ ...ctx, weekOf });
  }
}
