import { Controller, Get, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { StudentService } from './student.service';

@UseGuards(JwtAuthGuard)
@Controller('student')
export class StudentAttendanceController {
  constructor(private readonly student: StudentService) {}

  @Get('attendance')
  attendance(
    @Req() req: any,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    return this.student.getMyAttendance(req.user, { from, to });
  }
}
