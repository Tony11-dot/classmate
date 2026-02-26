import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { Controller, Get, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { StudentService } from './student.service';

@UseGuards(JwtAuthGuard)
@Roles(Role.STUDENT, Role.ADMIN)
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
