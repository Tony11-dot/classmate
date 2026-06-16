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
  UseInterceptors,
  UploadedFile,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { RolesGuard } from '../auth/guards/roles.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminService } from './admin.service';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('admin')
export class AdminController {
  constructor(private readonly admin: AdminService) {}

  @Roles(Role.ADMIN)
  @Post('cohorts')
  createCohort(@Req() req: any, @Body() body: { name: string; grade?: number; grades?: number[] }) {
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

  // DDLs power read-only screens (export, schedule view, people) — secretary
  // needs them to populate filters and student pickers even though they
  // can't mutate the underlying data.
  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('ddl/students')
  ddlStudents(@Req() req: any, @Query('q') q?: string, @Query('cohortId') cohortId?: string) {
    return this.admin.listStudentsForDDL(req.user, { q, cohortId });
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('ddl/teachers')
  ddlTeachers(@Req() req: any) {
    return this.admin.listTeachersForDDL(req.user);
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('ddl/cohorts')
  ddlCohorts(@Req() req: any) {
    return this.admin.listCohortsForDDL(req.user);
  }

  // Per-role user list for the export filter sheet's role drill-down.
  // role=STUDENT|TEACHER|PARENT|SECRETARY|ADMIN.
  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('ddl/users-by-role')
  ddlUsersByRole(@Req() req: any, @Query('role') role: string) {
    return this.admin.listUsersByRoleForDDL(req.user, role);
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('ddl/classrooms')
  ddlClassrooms(@Req() req: any, @Query('teacherId') teacherId: string) {
    return this.admin.listClassroomsForTeacher(req.user, teacherId);
  }

  // ── Schedule overrides (legacy cohort-based) ─────────────────────────────────

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('schedule/cohort/:cohortId')
  cohortSchedule(@Req() req: any, @Param('cohortId') cohortId: string) {
    return this.admin.getCohortSchedule(req.user, cohortId);
  }

  @Roles(Role.ADMIN)
  @Post('schedule/override')
  setOverride(@Req() req: any, @Body() body: { cohortId: string; date: string; period: number }) {
    return this.admin.setScheduleOverride(req.user, body);
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
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

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('subjects/all')
  listAllSchoolSubjects(@Req() req: any) {
    return this.admin.listAllSchoolSubjects(req.user);
  }

  @Roles(Role.ADMIN)
  @Post('subjects/add-to-grades')
  addSubjectToGrades(@Req() req: any, @Body() body: any) {
    return this.admin.addSubjectToGrades(req.user, body);
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

  @Roles(Role.ADMIN, Role.SECRETARY)
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

  /// Multi-filter user export. All filters are UNIONed: the result is
  /// every user that matches ANY of the supplied filters. Cohort/grade
  /// filters only contribute STUDENT rows; specific userIds include
  /// regardless of role. roles[] (comma-separated) acts as a wildcard
  /// for "every user with one of these roles" (no other filter needed).
  /// Query: roles, cohortIds, gradeIds, userIds, generatePasswords.
  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('export/users')
  exportUsers(
    @Req() req: any,
    @Query('roles') roles?: string,
    @Query('cohortIds') cohortIds?: string,
    @Query('gradeIds') gradeIds?: string,
    @Query('userIds') userIds?: string,
    @Query('generatePasswords') generatePasswords?: string,
  ) {
    return this.admin.exportUsers(req.user, {
      roles,
      cohortIds,
      gradeIds,
      userIds,
      generatePasswords,
    });
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('export/cohorts')
  exportCohorts(@Req() req: any) {
    return this.admin.exportCohorts(req.user);
  }

  @Roles(Role.ADMIN)
  @Post('users')
  createUser(@Req() req: any, @Body() body: any) {
    return this.admin.createUser(req.user, body);
  }

  // Live username-availability check for the add-user / bulk-add forms.
  @Roles(Role.ADMIN)
  @Get('users/check-username')
  checkUsername(@Req() req: any, @Query('username') username?: string) {
    return this.admin.checkUsername(req.user, username ?? '');
  }

  // Bulk create from the in-app spreadsheet grid.
  @Roles(Role.ADMIN)
  @Post('users/bulk')
  bulkCreateUsers(@Req() req: any, @Body() body: any) {
    return this.admin.bulkCreateUsers(req.user, body);
  }

  // Upload a CSV (headers in any language). ?dryRun=true returns a preview
  // (detected fields + first rows) without creating anything.
  @Roles(Role.ADMIN)
  @Post('users/import-csv')
  @UseInterceptors(FileInterceptor('file'))
  importCsv(@Req() req: any, @UploadedFile() file: any, @Query('dryRun') dryRun?: string) {
    const text = file?.buffer ? Buffer.from(file.buffer).toString('utf8') : '';
    return this.admin.importCsv(req.user, text, dryRun === 'true' || dryRun === '1');
  }

  // Danger-zone resets + manual grade promotion (admin only).
  @Roles(Role.ADMIN)
  @Post('schedule/reset')
  resetSchedule(@Req() req: any) {
    return this.admin.resetSchedule(req.user);
  }

  @Roles(Role.ADMIN)
  @Post('cohorts/reset')
  resetCohorts(@Req() req: any) {
    return this.admin.resetCohorts(req.user);
  }

  @Roles(Role.ADMIN)
  @Post('grades/promote-all')
  promoteAllGrades(@Req() req: any) {
    return this.admin.promoteAllGrades(req.user);
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

  // Cohort mutations are admin-only — secretary sees a read-only view of
  // cohorts (per role spec). Roster reads are still shared so secretary
  // can browse membership without holding the keys.
  @Roles(Role.ADMIN)
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

  @Roles(Role.ADMIN)
  @Post('cohorts/:id/students')
  addStudentsToCohort(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.admin.addStudentsToCohort(req.user, id, body);
  }

  @Roles(Role.ADMIN)
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

  // ── Message reports (Play policy: report-content flow) ───────────────

  // Reports moderation — secretary handles inbox + day-to-day moderation;
  // admin keeps the same access. Both roles can resolve/dismiss.
  @Roles(Role.ADMIN, Role.SECRETARY)
  @Get('reports')
  listReports(
    @Req() req: any,
    @Query('status') status?: string,
  ) {
    return this.admin.listMessageReports(req.user, status);
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Post('reports/:id/resolve')
  resolveReport(@Req() req: any, @Param('id') id: string) {
    return this.admin.resolveMessageReport(req.user, id, 'RESOLVED');
  }

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Post('reports/:id/dismiss')
  dismissReport(@Req() req: any, @Param('id') id: string) {
    return this.admin.resolveMessageReport(req.user, id, 'DISMISSED');
  }

}
