import { Body, Controller, Delete, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { BagrutService } from './bagrut.service';
import { BagrutLibraryService } from './bagrut-library.service';

// Class default is STUDENT-only (the AI generation routes). Library routes
// override per-method with their own @Roles.
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.STUDENT)
@Controller('bagrut')
export class BagrutController {
  constructor(
    private service: BagrutService,
    private library: BagrutLibraryService,
  ) {}

  // ── AI question/exam generation (metered Anthropic spend) — students only ──
  @Post('question')
  async question(@Body() body: any) {
    return this.service.getQuestion(body.subject, body.topicLabel);
  }

  @Post('exam')
  async exam(@Body() body: any) {
    return this.service.getExam(body.subject);
  }

  // ── Past-exam library ──────────────────────────────────────────────────────
  // Browse (students, teachers, managers, admins).
  @Roles(Role.STUDENT, Role.TEACHER, Role.MANAGER, Role.ADMIN)
  @Get('exams')
  listExams(@Query('subject') subject?: string) {
    return this.library.listExams(subject);
  }

  @Roles(Role.STUDENT, Role.TEACHER, Role.MANAGER, Role.ADMIN)
  @Get('exams/:id')
  getExamById(@Param('id') id: string) {
    return this.library.getExam(id);
  }

  // Manage (managers only).
  @Roles(Role.MANAGER)
  @Post('exams')
  createExam(@Body() body: any) {
    return this.library.createExam(body);
  }

  @Roles(Role.MANAGER)
  @Patch('exams/:id')
  updateExam(@Param('id') id: string, @Body() body: any) {
    return this.library.updateExam(id, body);
  }

  @Roles(Role.MANAGER)
  @Delete('exams/:id')
  deleteExam(@Param('id') id: string) {
    return this.library.deleteExam(id);
  }
}
