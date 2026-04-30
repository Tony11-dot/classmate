import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import {
  Header,
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
import { RolesGuard } from '../auth/guards/roles.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminService } from './admin.service';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('admin')
export class AdminController {
  constructor(private readonly admin: AdminService) {}

  @Roles(Role.ADMIN)
  @Post('cohorts')
  createCohort(@Req() req: any, @Body() body: { name: string; grade: number }) {
    return this.admin.createCohort(req.user, body);
  }

  @Roles(Role.ADMIN, Role.TEACHER)
  @Header('Deprecation', 'true')
  @Header('Sunset', '2026-03-31')
  @Header('Link', '</api/teacher/cohorts/join-code>; rel="successor-version"')
  @Post('cohorts/join-code')
  joinCode(
    @Req() req: any,
    @Body()
    body: { cohortId: string; expiresInHours?: number; length?: number },
  ) {
    return this.admin.generateJoinCode(req.user, body);
  }

  @Roles(Role.ADMIN)
  @Get('schedule/cohort/:cohortId')
  cohortSchedule(@Req() req: any, @Param('cohortId') cohortId: string) {
    return this.admin.getCohortSchedule(req.user, cohortId);
  }

  @Roles(Role.ADMIN)
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

  @Roles(Role.ADMIN)
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

  @Roles(Role.ADMIN)
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

  @Roles(Role.ADMIN)
  @Get('courses')
  listCourses(@Req() req: any, @Query('cohortId') cohortId?: string) {
    return this.admin.listCourses(req.user, { cohortId });
  }

  @Roles(Role.ADMIN)
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

  @Roles(Role.ADMIN)
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

  @Roles(Role.ADMIN)
  @Delete('courses/:id')
  deleteCourse(@Req() req: any, @Param('id') id: string) {
    return this.admin.deleteCourse(req.user, id);
  }

  // ---- Schedule template helpers ----

  @Roles(Role.ADMIN)
  @Delete('schedule/template')
  clearTemplate(@Req() req: any, @Query('cohortId') cohortId: string) {
    return this.admin.clearScheduleTemplate(req.user, cohortId);
  }

  @Roles(Role.ADMIN)
  @Post('schedule/template/clear-period')
  clearPeriod(
    @Req() req: any,
    @Body() body: { cohortId: string; period: number },
  ) {
    return this.admin.clearSchedulePeriodAcrossWeek(req.user, body);
  }

  // ---- Schedule overrides helpers ----

  @Roles(Role.ADMIN)
  @Get('schedule/overrides')
  listOverrides(
    @Req() req: any,
    @Query('cohortId') cohortId: string,
    @Query('from') from: string,
    @Query('to') to: string,
  ) {
    return this.admin.listScheduleOverrides(req.user, { cohortId, from, to });
  }

  @Roles(Role.ADMIN)
  @Post('schedule/override/delete')
  deleteOverride(
    @Req() req: any,
    @Body() body: { cohortId: string; date: string; period: number },
  ) {
    return this.admin.deleteScheduleOverride(req.user, body);
  }

  // ---- Session 10: Subject defaults + per-student overrides ----

  @Roles(Role.ADMIN)
  @Post('subjects/defaults')
  setSubjectDefaults(@Req() req: any, @Body() body: any) {
    return this.admin.setSubjectDefaults(req.user, body);
  }

  @Roles(Role.ADMIN)
  @Get('subjects/defaults')
  getSubjectDefaults(
    @Req() req: any,
    @Query('schoolId') schoolId: string,
    @Query('grade') grade: string,
  ) {
    return this.admin.getSubjectDefaults(req.user, {
      schoolId,
      grade: Number(grade),
    });
  }

  @Roles(Role.ADMIN)
  @Post('subjects/overrides/:identifier')
  upsertSubjectOverride(
    @Req() req: any,
    @Param('identifier') identifier: string,
    @Body() body: any,
  ) {
    return this.admin.upsertSubjectOverride(req.user, identifier, body);
  }

  @Roles(Role.ADMIN)
  @Get('subjects/overrides/:identifier')
  getSubjectOverride(
    @Req() req: any,
    @Param('identifier') identifier: string,
  ) {
    return this.admin.getSubjectOverride(req.user, identifier);
  }

  // ---- Schools ----

  @Roles(Role.ADMIN)
  @Post('schools')
  createSchool(@Req() req: any, @Body() body: any) {
    return this.admin.createSchool(req.user, body);
  }

  @Roles(Role.ADMIN)
  @Get('schools')
  listSchools(@Req() req: any) {
    return this.admin.listSchools(req.user);
  }

  @Roles(Role.ADMIN)
  @Get('schools/:id')
  getSchool(@Req() req: any, @Param('id') id: string) {
    return this.admin.getSchool(req.user, id);
  }

  @Roles(Role.ADMIN)
  @Patch('schools/:id')
  updateSchool(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.admin.updateSchool(req.user, id, body);
  }

  @Roles(Role.ADMIN)
  @Delete('schools/:id')
  deleteSchool(@Req() req: any, @Param('id') id: string) {
    return this.admin.deleteSchool(req.user, id);
  }

  @Roles(Role.ADMIN)
  @Post('schools/:id/assign-user')
  assignUserToSchool(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.admin.assignUserToSchool(req.user, id, body);
  }

}
