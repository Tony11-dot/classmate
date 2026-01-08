import {
  Body,
  Controller,
  Get,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { TeacherService } from './teacher.service';

@UseGuards(JwtAuthGuard)
@Controller('teacher')
export class TeacherController {
  constructor(private readonly teacher: TeacherService) {}

  @Get('schedule/today')
  today(@Req() req: any) {
    return this.teacher.todaySchedule(req.user);
  }

  @Get('attendance/session')
  session(
    @Req() req: any,
    @Query('cohortId') cohortId: string,
    @Query('date') date: string | undefined,
    @Query('period') period: string,
  ) {
    return this.teacher.getAttendanceSession(req.user, {
      cohortId,
      date,
      period: Number(period),
    });
  }

  @Post('attendance/mark')
  mark(@Req() req: any, @Body() body: any) {
    return this.teacher.markAttendance(req.user, body);
  }

  @Post('attendance/bulk')
  bulk(@Req() req: any, @Body() body: any) {
    return this.teacher.bulkAttendance(req.user, body);
  }

  // ---- Grades ----

  @Post('grades/assessment')
  createAssessment(@Req() req: any, @Body() body: any) {
    return this.teacher.createAssessment(req.user, body);
  }

  @Post('grades/bulk')
  bulkGrades(@Req() req: any, @Body() body: any) {
    return this.teacher.bulkGrades(req.user, body);
  }
}
