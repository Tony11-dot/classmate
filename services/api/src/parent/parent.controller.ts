import { Roles } from '../auth/roles.decorator';
import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  Req,
  UseGuards,
  DefaultValuePipe,
  ParseIntPipe,
  BadRequestException,
  Header,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ParentService } from './parent.service';

@UseGuards(JwtAuthGuard)
@Roles('PARENT', 'ADMIN')
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
  ) {
    // ParentService clamps 1..100 anyway, but ParseIntPipe guarantees it's a number.
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
    // If studentId is provided but only whitespace -> reject (prevents accidental "all children").
    if (
      typeof studentId === 'string' &&
      studentId.length > 0 &&
      !studentId.trim()
    ) {
      throw new BadRequestException('studentId is invalid');
    }

    return this.parent.notifications(req.user, {
      studentId: studentId?.trim() || undefined,
      take,
    });
  }
  @Header("Deprecation","true")
  @Header("Sunset","2026-03-01")
  @Get('notifications-legacy/unread-count')
  unreadCount(
    @Req() req: any,
    @Query('studentId') studentId: string | undefined,
    @Query('since') since: string | undefined,
  ) {
    if (
      typeof studentId === 'string' &&
      studentId.length > 0 &&
      !studentId.trim()
    ) {
      throw new BadRequestException('studentId is invalid');
    }

    return this.parent.unreadCount(req.user, {
      studentId: studentId?.trim() || undefined,
      since,
    });
  }
  @Header("Deprecation","true")
  @Header("Sunset","2026-03-01")
  @Post('notifications-legacy/mark-seen')
  markSeen(@Req() req: any, @Body() body: any) {
    return this.parent.markSeen(req.user, body?.ids);
  }

  @Get('lookup')
  lookup(@Req() req: any) {
    return this.parent.lookup(req.user);
  }
}
