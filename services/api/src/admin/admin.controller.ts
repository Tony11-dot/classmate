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

  // ── School period defaults ───────────────────────────────────────────────────

  @Roles(Role.ADMIN)
  @Get('period-defaults')
  getPeriodDefaults(@Req() req: any) {
    return this.admin.getSchoolPeriodDefaults(req.user);
  }

  @Roles(Role.ADMIN)
  @Post('period-defaults')
  setPeriodDefaults(@Req() req: any, @Body() body: any) {
    return this.admin.setSchoolPeriodDefaults(req.user, body);
  }

  // ── Period CRUD ──────────────────────────────────────────────────────────────

  @Roles(Role.ADMIN)
  @Get('periods')
  listPeriods(@Req() req: any) {
    return this.admin.listPeriods(req.user);
  }

  @Roles(Role.ADMIN)
  @Post('periods')
  createPeriod(@Req() req: any, @Body() body: any) {
    return this.admin.createPeriod(req.user, body);
  }

  @Roles(Role.ADMIN)
  @Patch('periods/:id')
  updatePeriod(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.admin.updatePeriod(req.user, id, body);
  }

  @Roles(Role.ADMIN)
  @Delete('periods/:id')
  deletePeriod(@Req() req: any, @Param('id') id: string) {
    return this.admin.deletePeriod(req.user, id);
  }

  // ── DDL helpers ──────────────────────────────────────────────────────────────

  @Roles(Role.ADMIN)
  @Get('ddl/students')
  ddlStudents(@Req() req: any, @Query('q') q?: string, @Query('cohortId') cohortId?: string) {
    return this.admin.listStudentsForDDL(req.user, { q, cohortId });
  }

  @Roles(Role.ADMIN)
  @Get('ddl/teachers')
  ddlTeachers(@Req() req: any) {
    return this.admin.listTeachersForDDL(req.user);
  }

  @Roles(Role.ADMIN)
  @Get('ddl/cohorts')
  ddlCohorts(@Req() req: any) {
    return this.admin.listCohortsForDDL(req.user);
  }

  @Roles(Role.ADMIN)
  @Get('ddl/classrooms')
  ddlClassrooms(@Req() req: any, @Query('teacherId') teacherId: string) {
    return this.admin.listClassroomsForTeacher(req.user, teacherId);
  }

  // ── Schedule overrides (legacy cohort-based) ─────────────────────────────────

  @Roles(Role.ADMIN)
  @Get('schedule/cohort/:cohortId')
  cohortSchedule(@Req() req: any, @Param('cohortId') cohortId: string) {
    return this.admin.getCohortSchedule(req.user, cohortId);
  }

  @Roles(Role.ADMIN)
  @Post('schedule/override')
  setOverride(@Req() req: any, @Body() body: { cohortId: string; date: string; period: number }) {
    return this.admin.setScheduleOverride(req.user, body);
  }

  @Roles(Role.ADMIN)
  @Get('schedule/overrides')
  listOverrides(@Req() req: any, @Query('cohortId') cohortId: string, @Query('from') from: string, @Query('to') to: string) {
    return this.admin.listScheduleOverrides(req.user, { cohortId, from, to });
  }

  @Roles(Role.ADMIN)
  @Post('schedule/override/delete')
  deleteOverride(@Req() req: any, @Body() body: { cohortId: string; date: string; period: number }) {
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

  // ── User Management ───────────────────────────────────────────────────────────

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('users')
  listUsers(@Req() req: any, @Query('q') q?: string, @Query('role') role?: string, @Query('page') page?: string) {
    return this.admin.listUsers(req.user, { q, role, page: page ? Number(page) : 0 });
  }

  @Get('export/students')
  exportStudents(
    @Req() req: any,
    @Query('cohortId') cohortId?: string,
    @Query('grade') grade?: string,
    @Query('generatePasswords') generatePasswords?: string,
    @Query('studentIds') studentIds?: string,
  ) {
    return this.admin.exportStudents(req.user, { cohortId, grade, generatePasswords, studentIds });
  }

  @Get('export/cohorts')
  exportCohorts(@Req() req: any) {
    return this.admin.exportCohorts(req.user);
  }

  @Roles(Role.ADMIN)
  @Post('users')
  createUser(@Req() req: any, @Body() body: any) {
    return this.admin.createUser(req.user, body);
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('users/:id')
  getUserDetail(@Req() req: any, @Param('id') id: string) {
    return this.admin.getUserDetail(req.user, id);
  }

  @Roles(Role.ADMIN)
  @Patch('users/:id')
  updateUser(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.admin.updateUser(req.user, id, body);
  }

  @Roles(Role.ADMIN)
  @Delete('users/:id')
  deleteUser(@Req() req: any, @Param('id') id: string) {
    return this.admin.deleteUser(req.user, id);
  }

  @Roles(Role.ADMIN)
  @Post('users/:id/set-password')
  setUserPassword(@Req() req: any, @Param('id') id: string, @Body() body: { newPassword?: string }) {
    return this.admin.setUserPassword(req.user, id, body);
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('users/:id/children')
  getUserChildren(@Req() req: any, @Param('id') id: string) {
    return this.admin.getUserChildren(req.user, id);
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Delete('users/:parentId/children/:childId')
  unlinkChild(@Req() req: any, @Param('parentId') parentId: string, @Param('childId') childId: string) {
    return this.admin.unlinkChild(req.user, parentId, childId);
  }

  // ── Parent Links ──────────────────────────────────────────────────────────────

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Post('parent-links')
  linkParent(@Req() req: any, @Body() body: any) {
    return this.admin.linkParent(req.user, body);
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Delete('parent-links/:id')
  unlinkParent(@Req() req: any, @Param('id') id: string) {
    return this.admin.unlinkParent(req.user, id);
  }

  // ── Cohort Management ─────────────────────────────────────────────────────────

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('cohorts')
  listCohorts(@Req() req: any) {
    return this.admin.listCohorts(req.user);
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Patch('cohorts/:id')
  updateCohort(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.admin.updateCohort(req.user, id, body);
  }

  @Roles(Role.ADMIN)
  @Delete('cohorts/:id')
  deleteCohort(@Req() req: any, @Param('id') id: string) {
    return this.admin.deleteCohort(req.user, id);
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('cohorts/:id/roster')
  getCohortRoster(@Req() req: any, @Param('id') id: string) {
    return this.admin.getCohortRoster(req.user, id);
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Post('cohorts/:id/students')
  addStudentsToCohort(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.admin.addStudentsToCohort(req.user, id, body);
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Delete('cohorts/:id/students/:studentId')
  removeStudentFromCohort(@Req() req: any, @Param('id') id: string, @Param('studentId') studentId: string) {
    return this.admin.removeStudentFromCohort(req.user, id, studentId);
  }

  // ── School Settings ───────────────────────────────────────────────────────────

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('school')
  getMySchool(@Req() req: any) {
    return this.admin.getMySchool(req.user);
  }

  @Roles(Role.ADMIN)
  @Patch('school')
  updateMySchool(@Req() req: any, @Body() body: any) {
    return this.admin.updateMySchool(req.user, body);
  }

  // ── Analytics ─────────────────────────────────────────────────────────────────

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('analytics/overview')
  analyticsOverview(@Req() req: any) {
    return this.admin.getAnalyticsOverview(req.user);
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('analytics/attendance')
  analyticsAttendance(@Req() req: any) {
    return this.admin.getAnalyticsAttendance(req.user);
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('analytics/grades')
  analyticsGrades(@Req() req: any) {
    return this.admin.getAnalyticsGrades(req.user);
  }

}
