import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { BadRequestException, Body, Controller, DefaultValuePipe, Get, GoneException, Header, ParseIntPipe, Post, Query, Req, UseGuards } from '@nestjs/common';
import { CurrentActor } from '../common/request/current-actor.decorator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ParentService } from './parent.service';

@UseGuards(JwtAuthGuard)
@Roles(Role.PARENT, Role.ADMIN)
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
  grades(
    @Req() req: any,
    @Query('take', new DefaultValuePipe(20), ParseIntPipe) take: number,
    @Query('studentId') studentId?: string,
  ) {
    if (studentId?.trim()) {
      return this.parent.childGrades(req.user, studentId.trim());
    }
    return this.parent.grades(req.user, take);
  }

  @Get('schedule/today')
  scheduleToday(@Req() req: any, @Query('studentId') studentId: string) {
    if (!studentId?.trim())
      throw new BadRequestException('studentId is required');
    return this.parent.scheduleToday(req.user, studentId.trim());
  }

  @Get('schedule/week')
  scheduleWeek(
    @Req() req: any,
    @Query('studentId') studentId: string,
    @Query('weekOf') weekOf?: string,
  ) {
    if (!studentId?.trim())
      throw new BadRequestException('studentId is required');
    return this.parent.scheduleWeek(req.user, studentId.trim(), weekOf);
  }

  @Get('attendance/today')
  attendanceToday(@Req() req: any, @Query('studentId') studentId: string) {
    if (!studentId?.trim())
      throw new BadRequestException('studentId is required');
    return this.parent.attendanceToday(req.user, studentId.trim());
  }

  @Get('attendance/week')
  attendanceWeek(
    @Req() req: any,
    @Query('studentId') studentId: string,
    @Query('weekOf') weekOf?: string,
  ) {
    if (!studentId?.trim())
      throw new BadRequestException('studentId is required');
    return this.parent.attendanceWeek(req.user, studentId.trim(), weekOf);
  }

  @Get('overview')
  overview(@Req() req: any, @Query('studentId') studentId: string) {
    if (!studentId?.trim())
      throw new BadRequestException('studentId is required');
    return this.parent.overview(req.user, studentId.trim());
  }

  @Get('overview/week')
  overviewWeek(@Req() req: any, @Query('studentId') studentId: string) {
    if (!studentId?.trim())
      throw new BadRequestException('studentId is required');
    return this.parent.overviewWeek(req.user, studentId.trim());
  }

  @Get('dashboard')
  dashboard(@Req() req: any) {
    return this.parent.dashboard(req.user);
  }
  @Header("Deprecation","true")
  @Header("Sunset","2026-03-01")
  @Get('notifications-legacy')
  notifications(
    @Req() req: any,
    @Query('studentId') studentId: string | undefined,
    @Query('take', new DefaultValuePipe(20), ParseIntPipe) take: number,
  ) {
    throw new GoneException('This endpoint is removed. Use /api/parent/notifications');
  }
  @Header("Deprecation","true")
  @Header("Sunset","2026-03-01")
  @Get('notifications-legacy/unread-count')
  unreadCount(
    @Req() req: any,
    @Query('studentId') studentId: string | undefined,
    @Query('since') since: string | undefined,
  ) {
    throw new GoneException('This endpoint is removed. Use /api/parent/notifications/unread-count');
  }
  @Header("Deprecation","true")
  @Header("Sunset","2026-03-01")
  @Post('notifications-legacy/mark-seen')
  markSeen(@Req() req: any, @Body() body: any) {
    throw new GoneException('This endpoint is removed. Use /api/parent/notifications/mark-seen');
  }

  @Get('lookup')
  lookup(@Req() req: any) {
    return this.parent.lookup(req.user);
  }

  // ── Child-scoped feeds ────────────────────────────────────────────
  // Mirror the student endpoints (/student/exams, /student/diplomas,
  // /student/assignments, /student/classrooms/all-materials, etc.) but
  // pivot to the parent's selected child. All gated by requireParentChild
  // in the service.

  @Get('exams')
  exams(@Req() req: any, @Query('studentId') studentId: string) {
    if (!studentId?.trim()) throw new BadRequestException('studentId is required');
    return this.parent.examsForChild(req.user, studentId.trim());
  }

  @Get('assignments')
  assignments(@Req() req: any, @Query('studentId') studentId: string) {
    if (!studentId?.trim()) throw new BadRequestException('studentId is required');
    return this.parent.assignmentsForChild(req.user, studentId.trim());
  }

  @Get('diplomas')
  diplomas(@Req() req: any, @Query('studentId') studentId: string) {
    if (!studentId?.trim()) throw new BadRequestException('studentId is required');
    return this.parent.diplomasForChild(req.user, studentId.trim());
  }

  @Get('meetings')
  meetings(@Req() req: any, @Query('studentId') studentId: string) {
    if (!studentId?.trim()) throw new BadRequestException('studentId is required');
    return this.parent.meetingsForChild(req.user, studentId.trim());
  }

  @Get('materials')
  materials(@Req() req: any, @Query('studentId') studentId: string) {
    if (!studentId?.trim()) throw new BadRequestException('studentId is required');
    return this.parent.materialsForChild(req.user, studentId.trim());
  }

  @Get('insights')
  insights(@Req() req: any, @Query('studentId') studentId: string) {
    if (!studentId?.trim()) throw new BadRequestException('studentId is required');
    return this.parent.insightsForChild(req.user, studentId.trim());
  }
}
