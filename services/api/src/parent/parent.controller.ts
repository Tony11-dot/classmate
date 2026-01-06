import { Body, Controller, Get, Post, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ParentService } from './parent.service';

@UseGuards(JwtAuthGuard)
@Controller('parent')
export class ParentController {
  constructor(private readonly parent: ParentService) {}

  @Post('link')
  link(@Req() req: any, @Body() body: { code: string }) {
    return this.parent.link(req.user, body);
  }

  @Get('children')
  children(@Req() req: any) {
    return this.parent.children(req.user);
  }

  @Get('grades')
  grades(@Req() req: any) {
    return this.parent.grades(req.user);
  }

  @Get('schedule/today')
  scheduleToday(@Req() req: any, @Query('studentId') studentId: string) {
    return this.parent.scheduleToday(req.user, studentId);
  }

  @Get('attendance/today')
  attendanceToday(@Req() req: any, @Query('studentId') studentId: string) {
    return this.parent.attendanceToday(req.user, studentId);
  }

  @Get('attendance/week')
  attendanceWeek(@Req() req: any, @Query('studentId') studentId: string) {
    return this.parent.attendanceWeek(req.user, studentId);
  }
}
