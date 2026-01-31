import { Roles } from '../auth/roles.decorator';
import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  Req,
  ParseIntPipe,
  UseGuards,
} from '@nestjs/common';
import { RolesGuard } from '../auth/roles.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { TeacherService } from './teacher.service';

@UseGuards(JwtAuthGuard)
@Roles('TEACHER', 'ADMIN')
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
    @Query('period', ParseIntPipe) period: number,
  ) {
    return this.teacher.getAttendanceSession(req.user, {
      cohortId,
      date,
      period,
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

  @Get('cohort/:cohortId/students')
  cohortStudents(@Req() req: any, @Param('cohortId') cohortId: string) {
    return this.teacher.cohortStudents(req.user, cohortId);
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

  @Get('grades/assessments')
  listAssessments(@Req() req: any, @Query('courseId') courseId?: string) {
    return this.teacher.listAssessments(req.user, { courseId });
  }

  @Get('grades/assessment/:id/grades')
  assessmentGrades(@Req() req: any, @Param('id') id: string) {
    return this.teacher.assessmentGrades(req.user, id);
  }

  @Patch('grades/assessment/:id')
  updateAssessment(
    @Req() req: any,
    @Param('id') id: string,
    @Body() body: any,
  ) {
    return this.teacher.updateAssessment(req.user, id, body);
  }

  @Delete('grades/assessment/:id')
  deleteAssessment(@Req() req: any, @Param('id') id: string) {
    return this.teacher.deleteAssessment(req.user, id);
  }
}
