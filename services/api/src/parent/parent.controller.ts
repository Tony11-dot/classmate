import { Controller, Get, Post, Body, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ParentService } from './parent.service';

@UseGuards(JwtAuthGuard)
@Controller('parent')
export class ParentController {
  constructor(private readonly parent: ParentService) {}

  @Post('link')
  link(@Req() req: any, @Body() body: any) {
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

  @Get('schedule/week')
  scheduleWeek(
    @Req() req: any,
    @Query('studentId') studentId: string,
    @Query('weekOf') weekOf?: string,
  ) {
    return this.parent.scheduleWeek(req.user, studentId, weekOf);
  }

  @Get('attendance/today')
  attendanceToday(@Req() req: any, @Query('studentId') studentId: string) {
    return this.parent.attendanceToday(req.user, studentId);
  }

  @Get('attendance/week')
  attendanceWeek(
    @Req() req: any,
    @Query('studentId') studentId: string,
    @Query('weekOf') weekOf?: string,
  ) {
    return this.parent.attendanceWeek(req.user, studentId, weekOf);
  }

  @Get('overview')
  overview(@Req() req: any, @Query('studentId') studentId: string) {
    return this.parent.overview(req.user, studentId);
  }

  @Get('overview/week')
  overviewWeek(@Req() req: any, @Query('studentId') studentId: string) {
    return this.parent.overviewWeek(req.user, studentId);
  }

  @Get('dashboard')
  dashboard(@Req() req: any) {
    return this.parent.dashboard(req.user);
  }
}
