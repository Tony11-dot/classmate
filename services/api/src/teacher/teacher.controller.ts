import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
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
  ParseIntPipe,
  UseGuards,
} from '@nestjs/common';
import { RolesGuard } from '../auth/guards/roles.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { TeacherService } from './teacher.service';

@UseGuards(JwtAuthGuard)
@Roles(Role.TEACHER, Role.ADMIN)
@Controller('teacher')
export class TeacherController {
  
  @Roles(Role.TEACHER, Role.ADMIN)
  @Post('cohorts/join-code')
  joinCode(
    @Req() req: any,
    @Body() body: { cohortId: string; expiresInHours?: number; length?: number },
  ) {
    return this.teacher.generateJoinCode(req.user, body);
  }

  constructor(private readonly teacher: TeacherService) {}

  @Get('schedule/today')
  today(@Req() req: any) {
    return this.teacher.todaySchedule(req.user);
  }

  @Get('attendance/session')
  session(
    @Req() req: any,
    @Query('cohortId') cohortId: string,
    @Query('period', ParseIntPipe) period: number,
    @Query('date') date?: string,
  ) {
    return this.teacher.getAttendanceSession(req.user, {
      cohortId,
      date,
      period,
    });
  }

  @Post('attendance/mark')
  async mark(@Req() req: any, @Body() body: any) {
    // ATTENDANCE_MARK_RETURNS_OK_FALLBACK
    const r = await this.teacher.markAttendance(req.user, body);
    return (r ?? { ok: true }) as any;
  }

  @Post('attendance/bulk')
  bulk(@Req() req: any, @Body() body: any) {
    return this.teacher.bulkAttendance(req.user, body);
  }
  @Get('cohorts/:cohortId/students')
  @Get('cohort/:cohortId/students')
  cohortStudents(@Req() req: any, @Param('cohortId') cohortId: string) {
    return this.teacher.cohortStudents(req.user, cohortId);
  }

  // ---- Grades ----

  @Post('grades/assessment')
  createAssessment(@Req() req: any, @Body() body: any) {
    return this.teacher.createAssessment(req.user, body);
  }

  @Post('grades/bulk')
  bulkGrades(@Req() req: any, @Body() body: any) {
    return this.teacher.bulkGrades(req.user, body);
  }

  @Get('grades/assessments')
  listAssessments(@Req() req: any, @Query('courseId') courseId?: string) {
    return this.teacher.listAssessments(req.user, { courseId });
  }
  @Get('assessments/:id/grades')
  @Get('grades/assessment/:id/grades')
  assessmentGrades(@Req() req: any, @Param('id') id: string) {
    return this.teacher.assessmentGrades(req.user, id);
  }

  @Patch('grades/assessment/:id')
  updateAssessment(
    @Req() req: any,
    @Param('id') id: string,
    @Body() body: any,
  ) {
    return this.teacher.updateAssessment(req.user, id, body);
  }

  @Delete('grades/assessment/:id')
  deleteAssessment(@Req() req: any, @Param('id') id: string) {
    return this.teacher.deleteAssessment(req.user, id);
  }

  // ---- Classroom management ----

  @Get('classrooms')
  listClassrooms(@Req() req: any) {
    return this.teacher.listClassrooms(req.user);
  }

  @Get('classrooms/:courseId')
  getClassroom(@Req() req: any, @Param('courseId') courseId: string) {
    return this.teacher.getClassroom(req.user, courseId);
  }

  @Get('classrooms/:courseId/chat')
  getClassroomChat(
    @Req() req: any,
    @Param('courseId') courseId: string,
    @Query('limit') limit?: string,
    @Query('cursor') cursor?: string,
  ) {
    return this.teacher.getClassroomChat(req.user, courseId, { limit: limit ? Number(limit) : 30, cursor });
  }

  @Post('classrooms/:courseId/chat')
  sendClassroomChat(@Req() req: any, @Param('courseId') courseId: string, @Body() body: any) {
    return this.teacher.sendClassroomChat(req.user, courseId, body);
  }

  @Get('classrooms/:courseId/assignments')
  listClassroomAssignments(@Req() req: any, @Param('courseId') courseId: string) {
    return this.teacher.listClassroomAssignments(req.user, courseId);
  }

  @Post('classrooms/:courseId/assignments')
  createClassroomAssignment(@Req() req: any, @Param('courseId') courseId: string, @Body() body: any) {
    return this.teacher.createClassroomAssignment(req.user, courseId, body);
  }

  @Patch('classrooms/:courseId/assignments/:id')
  updateClassroomAssignment(
    @Req() req: any,
    @Param('courseId') courseId: string,
    @Param('id') id: string,
    @Body() body: any,
  ) {
    return this.teacher.updateClassroomAssignment(req.user, courseId, id, body);
  }

  @Delete('classrooms/:courseId/assignments/:id')
  deleteClassroomAssignment(
    @Req() req: any,
    @Param('courseId') courseId: string,
    @Param('id') id: string,
  ) {
    return this.teacher.deleteClassroomAssignment(req.user, courseId, id);
  }

  @Get('classrooms/:courseId/materials')
  listClassroomMaterials(@Req() req: any, @Param('courseId') courseId: string) {
    return this.teacher.listClassroomMaterials(req.user, courseId);
  }

  @Post('classrooms/:courseId/materials')
  createClassroomMaterial(@Req() req: any, @Param('courseId') courseId: string, @Body() body: any) {
    return this.teacher.createClassroomMaterial(req.user, courseId, body);
  }

  @Delete('classrooms/:courseId/materials/:id')
  deleteClassroomMaterial(
    @Req() req: any,
    @Param('courseId') courseId: string,
    @Param('id') id: string,
  ) {
    return this.teacher.deleteClassroomMaterial(req.user, courseId, id);
  }

  @Get('classrooms/:courseId/meetings')
  listClassroomMeetings(@Req() req: any, @Param('courseId') courseId: string) {
    return this.teacher.listClassroomMeetings(req.user, courseId);
  }

  @Post('classrooms/:courseId/meetings')
  createClassroomMeeting(@Req() req: any, @Param('courseId') courseId: string, @Body() body: any) {
    return this.teacher.createClassroomMeeting(req.user, courseId, body);
  }

  @Delete('classrooms/:courseId/meetings/:id')
  deleteClassroomMeeting(
    @Req() req: any,
    @Param('courseId') courseId: string,
    @Param('id') id: string,
  ) {
    return this.teacher.deleteClassroomMeeting(req.user, courseId, id);
  }

  @Get('classrooms/:courseId/people')
  getClassroomPeople(@Req() req: any, @Param('courseId') courseId: string) {
    return this.teacher.getClassroomPeople(req.user, courseId);
  }

  // ---- Submissions ----

  @Get('classrooms/:courseId/assignments/:assignmentId/submissions')
  listSubmissions(
    @Req() req: any,
    @Param('courseId') courseId: string,
    @Param('assignmentId') assignmentId: string,
  ) {
    return this.teacher.listAssignmentSubmissions(req.user, courseId, assignmentId);
  }

  // ---- Analytics ----

  @Get('classrooms/:courseId/analytics')
  classroomAnalytics(@Req() req: any, @Param('courseId') courseId: string) {
    return this.teacher.classroomAnalytics(req.user, courseId);
  }

  @Get('student/:studentId/profile')
  studentProfile(@Req() req: any, @Param('studentId') studentId: string) {
    return this.teacher.getStudentProfile(req.user, studentId);
  }

  @Get('schedule/week')
  weekSchedule(@Req() req: any, @Query('weekOf') weekOf?: string) {
    return this.teacher.weekSchedule(req.user, weekOf);
  }

  // ---- Student management in classrooms ----

  @Post('classrooms/:courseId/students')
  addStudentToClassroom(
    @Req() req: any,
    @Param('courseId') courseId: string,
    @Body() body: any,
  ) {
    return this.teacher.addStudentToClassroom(req.user, courseId, body);
  }

  @Delete('classrooms/:courseId/students/:studentId')
  removeStudentFromClassroom(
    @Req() req: any,
    @Param('courseId') courseId: string,
    @Param('studentId') studentId: string,
  ) {
    return this.teacher.removeStudentFromClassroom(req.user, courseId, studentId);
  }

  @Get('attendance/history')
  attendanceHistory(
    @Req() req: any,
    @Query('cohortId') cohortId: string,
    @Query('date') date: string,
    @Query('period', ParseIntPipe) period: number,
  ) {
    return this.teacher.getAttendanceSession(req.user, { cohortId, date, period });
  }
}
