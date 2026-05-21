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

@UseGuards(JwtAuthGuard, RolesGuard)
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
  @Get('attendance/sessions')
  listAttendanceSessions(@Req() req: any, @Query('from') from?: string, @Query('to') to?: string) {
    return this.teacher.listAttendanceSessions(req.user, { from, to });
  }

  @Get('school-students')
  schoolStudents(@Req() req: any) {
    return this.teacher.schoolStudents(req.user);
  }

  @Get('cohorts')
  teacherCohorts(@Req() req: any) {
    return this.teacher.teacherCohorts(req.user);
  }

  @Get('school-cohorts')
  schoolCohorts(@Req() req: any) {
    return this.teacher.schoolCohorts(req.user);
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
  listAssessments(@Req() req: any, @Query('cohortId') cohortId?: string) {
    return this.teacher.listAssessments(req.user, { cohortId } as any);
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

  // ── Classroom management ────────────────────────────────────────────────────

  @Post('classrooms')
  createClassroom(@Req() req: any, @Body() body: any) {
    return this.teacher.createClassroom(req.user, body);
  }

  @Get('classrooms')
  listClassrooms(@Req() req: any) {
    return this.teacher.listClassrooms(req.user);
  }

  @Get('classrooms/:id')
  getClassroom(@Req() req: any, @Param('id') id: string) {
    return this.teacher.getClassroom(req.user, id);
  }

  @Patch('classrooms/:id')
  updateClassroom(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.teacher.updateClassroom(req.user, id, body);
  }

  @Delete('classrooms/:id')
  deleteClassroom(@Req() req: any, @Param('id') id: string) {
    return this.teacher.deleteClassroom(req.user, id);
  }

  @Get('classrooms/:id/members')
  listClassroomMembers(@Req() req: any, @Param('id') id: string) {
    return this.teacher.listClassroomMembers(req.user, id);
  }

  @Post('classrooms/:id/members')
  addClassroomMembers(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.teacher.addClassroomMembers(req.user, id, body);
  }

  @Delete('classrooms/:id/members/:studentId')
  removeClassroomMember(@Req() req: any, @Param('id') id: string, @Param('studentId') studentId: string) {
    return this.teacher.removeClassroomMember(req.user, id, studentId);
  }

  @Get('classrooms/:id/chat')
  getClassroomChat(
    @Req() req: any,
    @Param('id') id: string,
    @Query('limit') limit?: string,
    @Query('cursor') cursor?: string,
  ) {
    return this.teacher.getClassroomChat(req.user, id, { limit: limit ? Number(limit) : 30, cursor });
  }

  @Post('classrooms/:id/chat')
  sendClassroomChat(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.teacher.sendClassroomChat(req.user, id, body);
  }

  @Get('classrooms/:id/assignments')
  listClassroomAssignments(@Req() req: any, @Param('id') id: string) {
    return this.teacher.listClassroomAssignments(req.user, id);
  }

  @Post('classrooms/:id/assignments')
  createClassroomAssignment(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.teacher.createClassroomAssignment(req.user, id, body);
  }

  @Patch('classrooms/:id/assignments/:aId')
  updateClassroomAssignment(@Req() req: any, @Param('id') id: string, @Param('aId') aId: string, @Body() body: any) {
    return this.teacher.updateClassroomAssignment(req.user, id, aId, body);
  }

  @Delete('classrooms/:id/assignments/:aId')
  deleteClassroomAssignment(@Req() req: any, @Param('id') id: string, @Param('aId') aId: string) {
    return this.teacher.deleteClassroomAssignment(req.user, id, aId);
  }

  @Get('classrooms/:id/assignments/:aId/submissions')
  listSubmissions(@Req() req: any, @Param('id') id: string, @Param('aId') aId: string) {
    return this.teacher.listAssignmentSubmissions(req.user, id, aId);
  }

  @Delete('assignments/:assignmentId/submissions/:studentId')
  resetSubmission(
    @Req() req: any,
    @Param('assignmentId') assignmentId: string,
    @Param('studentId') studentId: string,
  ) {
    return this.teacher.resetAssignmentSubmission(req.user, assignmentId, studentId);
  }

  @Get('classrooms/:id/materials')
  listClassroomMaterials(@Req() req: any, @Param('id') id: string) {
    return this.teacher.listClassroomMaterials(req.user, id);
  }

  @Post('classrooms/:id/materials')
  createClassroomMaterial(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.teacher.createClassroomMaterial(req.user, id, body);
  }

  @Delete('classrooms/:id/materials/:mId')
  deleteClassroomMaterial(@Req() req: any, @Param('id') id: string, @Param('mId') mId: string) {
    return this.teacher.deleteClassroomMaterial(req.user, id, mId);
  }

  @Get('classrooms/:id/meetings')
  listClassroomMeetings(@Req() req: any, @Param('id') id: string) {
    return this.teacher.listClassroomMeetings(req.user, id);
  }

  @Post('classrooms/:id/meetings')
  createClassroomMeeting(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.teacher.createClassroomMeeting(req.user, id, body);
  }

  @Delete('classrooms/:id/meetings/:mId')
  deleteClassroomMeeting(@Req() req: any, @Param('id') id: string, @Param('mId') mId: string) {
    return this.teacher.deleteClassroomMeeting(req.user, id, mId);
  }

  @Get('classrooms/:id/analytics')
  classroomAnalytics(@Req() req: any, @Param('id') id: string) {
    return this.teacher.classroomAnalytics(req.user, id);
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

  @Post('classrooms/:cohortId/students')
  addStudentToClassroom(
    @Req() req: any,
    @Param('cohortId') cohortId: string,
    @Body() body: any,
  ) {
    return this.teacher.addStudentToClassroom(req.user, cohortId, body);
  }

  @Delete('classrooms/:cohortId/students/:studentId')
  removeStudentFromClassroom(
    @Req() req: any,
    @Param('cohortId') cohortId: string,
    @Param('studentId') studentId: string,
  ) {
    return this.teacher.removeStudentFromClassroom(req.user, cohortId, studentId);
  }

  @Get('attendance/history')
  attendanceHistory(
    @Req() req: any,
    @Query('cohortId') cohortId: string,
    @Query('date') date: string,
    @Query('period', ParseIntPipe) period: number,
    @Query('slotId') slotId?: string,
  ) {
    return this.teacher.getAttendanceSession(req.user, { cohortId, date, period, slotId });
  }

  // ---- Forms ----
  @Get('forms')
  listForms(@Req() req: any) {
    return this.teacher.listForms(req.user);
  }

  @Post('forms')
  createForm(@Req() req: any, @Body() body: any) {
    return this.teacher.createForm(req.user, body);
  }

  @Patch('forms/:id')
  updateForm(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.teacher.updateForm(req.user, id, body);
  }

  @Delete('forms/:id')
  deleteForm(@Req() req: any, @Param('id') id: string) {
    return this.teacher.deleteForm(req.user, id);
  }

  @Get('forms/:id/responses')
  formResponses(@Req() req: any, @Param('id') id: string) {
    return this.teacher.formResponses(req.user, id);
  }

  // ---- Diplomas ----
  @Get('diplomas')
  listDiplomas(@Req() req: any) {
    return this.teacher.listDiplomas(req.user);
  }

  @Post('diplomas')
  createDiploma(@Req() req: any, @Body() body: any) {
    return this.teacher.createDiploma(req.user, body);
  }

  @Delete('diplomas/:id')
  deleteDiploma(@Req() req: any, @Param('id') id: string) {
    return this.teacher.deleteDiploma(req.user, id);
  }

  // ── Subjects ──────────────────────────────────────────────────────────────

  @Get('subjects')
  listSubjects(@Req() req: any) { return this.teacher.listSubjects(req.user); }

  // ── Teacher Assignments ───────────────────────────────────────────────────

  @Get('assignments')
  listTeacherAssignments(@Req() req: any) { return this.teacher.listTeacherAssignments(req.user); }

  @Post('assignments')
  createTeacherAssignment(@Req() req: any, @Body() body: any) { return this.teacher.createTeacherAssignment(req.user, body); }

  @Patch('assignments/:id')
  updateTeacherAssignment(@Req() req: any, @Param('id') id: string, @Body() body: any) { return this.teacher.updateTeacherAssignment(req.user, id, body); }

  @Delete('assignments/:id')
  deleteTeacherAssignment(@Req() req: any, @Param('id') id: string) { return this.teacher.deleteTeacherAssignment(req.user, id); }

  @Get('assignments/:id/submissions')
  getAssignmentSubmissions(@Req() req: any, @Param('id') id: string) { return this.teacher.getAssignmentSubmissions(req.user, id); }

  @Patch('assignments/:id/submissions/:studentId/grade')
  gradeAssignmentSubmission(@Req() req: any, @Param('id') id: string, @Param('studentId') studentId: string, @Body() body: any) { return this.teacher.gradeAssignmentSubmission(req.user, id, studentId, body); }

  // ── Teacher Materials ─────────────────────────────────────────────────────

  @Get('materials')
  listTeacherMaterials(@Req() req: any) { return this.teacher.listTeacherMaterials(req.user); }

  @Post('materials')
  createTeacherMaterial(@Req() req: any, @Body() body: any) { return this.teacher.createTeacherMaterial(req.user, body); }

  @Patch('materials/:id')
  updateTeacherMaterial(@Req() req: any, @Param('id') id: string, @Body() body: any) { return this.teacher.updateTeacherMaterial(req.user, id, body); }

  @Delete('materials/:id')
  deleteTeacherMaterial(@Req() req: any, @Param('id') id: string) { return this.teacher.deleteTeacherMaterial(req.user, id); }

  // ── Slot Attachments (attach teacher materials to a schedule slot) ────────

  @Get('schedule-slots/:slotId/materials')
  listSlotMaterials(@Req() req: any, @Param('slotId') slotId: string) {
    return this.teacher.listSlotMaterials(req.user, slotId);
  }

  @Post('schedule-slots/:slotId/materials')
  attachSlotMaterial(@Req() req: any, @Param('slotId') slotId: string, @Body() body: any) {
    return this.teacher.attachSlotMaterial(req.user, slotId, String(body?.teacherMaterialId ?? ''));
  }

  @Delete('schedule-slots/:slotId/materials/:materialId')
  detachSlotMaterial(@Req() req: any, @Param('slotId') slotId: string, @Param('materialId') materialId: string) {
    return this.teacher.detachSlotMaterial(req.user, slotId, materialId);
  }

  // ── Attach existing library items to a classroom ─────────────────────────
  // Picker FABs in classroom detail tabs call these to mirror an item
  // from the teacher's library into the classroom.

  @Post('classrooms/:id/attach-material')
  attachMaterialToClassroom(@Req() req: any, @Param('id') classroomId: string, @Body() body: any) {
    return this.teacher.attachTeacherMaterialToClassroom(req.user, classroomId, String(body?.teacherMaterialId ?? ''));
  }

  @Post('classrooms/:id/attach-assignment')
  attachAssignmentToClassroom(@Req() req: any, @Param('id') classroomId: string, @Body() body: any) {
    return this.teacher.attachTeacherAssignmentToClassroom(req.user, classroomId, String(body?.teacherAssignmentId ?? ''));
  }

  @Post('classrooms/:id/attach-meeting')
  attachMeetingToClassroom(@Req() req: any, @Param('id') classroomId: string, @Body() body: any) {
    return this.teacher.attachTeacherMeetingToClassroom(req.user, classroomId, String(body?.teacherMeetingId ?? ''));
  }

  // ── Teacher Meetings ──────────────────────────────────────────────────────

  @Get('meetings')
  listTeacherMeetings(@Req() req: any) { return this.teacher.listTeacherMeetings(req.user); }

  @Post('meetings')
  createTeacherMeeting(@Req() req: any, @Body() body: any) { return this.teacher.createTeacherMeeting(req.user, body); }

  @Patch('meetings/:id')
  updateTeacherMeeting(@Req() req: any, @Param('id') id: string, @Body() body: any) { return this.teacher.updateTeacherMeeting(req.user, id, body); }

  @Delete('meetings/:id')
  deleteTeacherMeeting(@Req() req: any, @Param('id') id: string) { return this.teacher.deleteTeacherMeeting(req.user, id); }

  // ── Teacher Exams ─────────────────────────────────────────────────────────

  @Get('exams')
  listTeacherExams(@Req() req: any) { return this.teacher.listTeacherExams(req.user); }

  @Post('exams')
  createTeacherExam(@Req() req: any, @Body() body: any) { return this.teacher.createTeacherExam(req.user, body); }

  @Delete('exams/:id')
  deleteTeacherExam(@Req() req: any, @Param('id') id: string) { return this.teacher.deleteTeacherExam(req.user, id); }

  @Get('exams/:id/grades')
  getExamGrades(@Req() req: any, @Param('id') id: string) { return this.teacher.getExamGrades(req.user, id); }

  @Post('exams/:id/grades')
  saveExamGrades(@Req() req: any, @Param('id') id: string, @Body() body: any) { return this.teacher.saveExamGrades(req.user, id, body); }
}
