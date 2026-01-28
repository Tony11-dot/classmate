import { Roles } from '../auth/roles.decorator';
import { Controller, Get, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ScheduleService } from '../schedule/schedule.service';

@UseGuards(JwtAuthGuard)
@Roles('STUDENT','ADMIN')
@Controller('student/schedule')
export class StudentScheduleController {
  constructor(private readonly schedule: ScheduleService) {}

  private cohortIdFromUser(req: any): string {
    const cohortId = req?.user?.studentProfile?.cohortId;
    if (!cohortId) throw new Error('No studentProfile/cohortId on user');
    return cohortId;
  }

  @Get('today')
  today(@Req() req: any) {
    const cohortId = this.cohortIdFromUser(req);
    return this.schedule.getTodayForCohort(cohortId);
  }

  @Get('week')
  week(@Req() req: any, @Query('weekOf') weekOf?: string) {
    const cohortId = this.cohortIdFromUser(req);
    return this.schedule.getWeekForCohort(cohortId, weekOf);
  }
}
