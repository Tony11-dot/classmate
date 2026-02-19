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
  UseGuards,
} from '@nestjs/common';
import { RolesGuard } from '../auth/roles.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminService } from './admin.service';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('ADMIN')
@Controller('admin')
export class AdminController {
  constructor(private readonly admin: AdminService) {}

  @Post('cohorts')
  createCohort(@Req() req: any, @Body() body: { name: string; grade: number }) {
    return this.admin.createCohort(req.user, body);
  }

  @Roles('ADMIN', 'TEACHER')
  @Post('cohorts/join-code')
  joinCode(
    @Req() req: any,
    @Body()
    body: { cohortId: string; expiresInHours?: number; length?: number },
  ) {
    return this.admin.generateJoinCode(req.user, body);
  }

  @Get('schedule/cohort/:cohortId')
  cohortSchedule(@Req() req: any, @Param('cohortId') cohortId: string) {
    return this.admin.getCohortSchedule(req.user, cohortId);
  }

  @Post('schedule/slot')
  setSlot(
    @Req() req: any,
    @Body()
    body: {
      cohortId: string;
      dayOfWeek: number;
      period: number;
      courseId?: string | null;
    },
  ) {
    return this.admin.setScheduleSlot(req.user, body);
  }

  @Post('schedule/bulk')
  setBulk(
    @Req() req: any,
    @Body()
    body: {
      cohortId: string;
      slots: { dayOfWeek: number; period: number; courseId?: string | null }[];
    },
  ) {
    return this.admin.setScheduleBulk(req.user, body);
  }

  @Post('schedule/override')
  setOverride(
    @Req() req: any,
    @Body()
    body: {
      cohortId: string;
      date: string;
      period: number;
      courseId?: string | null;
    },
  ) {
    return this.admin.setScheduleOverride(req.user, body);
  }

  // ---- Courses ----

  @Get('courses')
  listCourses(@Req() req: any, @Query('cohortId') cohortId?: string) {
    return this.admin.listCourses(req.user, { cohortId });
  }

  @Post('courses')
  createCourse(
    @Req() req: any,
    @Body()
    body: {
      name: string;
      subject: string;
      teacherId?: string | null;
      cohortId?: string | null;
      groupTag?: string | null;
    },
  ) {
    return this.admin.createCourse(req.user, body);
  }

  @Patch('courses/:id')
  updateCourse(
    @Req() req: any,
    @Param('id') id: string,
    @Body()
    body: {
      name?: string;
      subject?: string;
      teacherId?: string | null;
      cohortId?: string | null;
      groupTag?: string | null;
    },
  ) {
    return this.admin.updateCourse(req.user, id, body);
  }

  @Delete('courses/:id')
  deleteCourse(@Req() req: any, @Param('id') id: string) {
    return this.admin.deleteCourse(req.user, id);
  }

  // ---- Schedule template helpers ----

  @Delete('schedule/template')
  clearTemplate(@Req() req: any, @Query('cohortId') cohortId: string) {
    return this.admin.clearScheduleTemplate(req.user, cohortId);
  }

  @Post('schedule/template/clear-period')
  clearPeriod(
    @Req() req: any,
    @Body() body: { cohortId: string; period: number },
  ) {
    return this.admin.clearSchedulePeriodAcrossWeek(req.user, body);
  }

  // ---- Schedule overrides helpers ----

  @Get('schedule/overrides')
  listOverrides(
    @Req() req: any,
    @Query('cohortId') cohortId: string,
    @Query('from') from: string,
    @Query('to') to: string,
  ) {
    return this.admin.listScheduleOverrides(req.user, { cohortId, from, to });
  }

  @Post('schedule/override/delete')
  deleteOverride(
    @Req() req: any,
    @Body() body: { cohortId: string; date: string; period: number },
  ) {
    return this.admin.deleteScheduleOverride(req.user, body);
  }
}
