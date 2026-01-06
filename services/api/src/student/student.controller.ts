import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { StudentService } from './student.service';

@UseGuards(JwtAuthGuard)
@Controller('student')
export class StudentController {
  constructor(private readonly student: StudentService) {}

  @Post('onboard')
  onboard(@Req() req: any, @Body() body: any) {
    return this.student.onboard(req.user, body);
  }

  @Post('parent-link-code')
  parentLinkCode(@Req() req: any, @Body() body: any) {
    return this.student.generateParentLinkCode(req.user, body);
  }

  @Get('schedule/today')
  today(@Req() req: any) {
    return this.student.todaySchedule(req.user);
  }

  @Get('schedule/week')
  week(@Req() req: any) {
    return this.student.weekSchedule(req.user);
  }

  @Get('grades')
  grades(@Req() req: any) {
    return this.student.myGrades(req.user);
  }
}
