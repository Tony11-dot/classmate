import { Body, Controller, Delete, Get, Param, Patch, Post, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { SolutionsService } from './solutions.service';

// NOTE on route ordering: literal paths (subjects, books, reports) are declared
// BEFORE the parametric `:id/...` routes so Nest never matches e.g.
// `/solutions/reports` against a `:id` segment. (Same shadow trap that hit
// the all-meetings route.)
@UseGuards(JwtAuthGuard)
@Controller('solutions')
export class SolutionsController {
  constructor(private readonly solutions: SolutionsService) {}

  @Roles(Role.STUDENT, Role.ADMIN, Role.TEACHER, Role.SECRETARY)
  @Get('subjects')
  subjects() {
    return this.solutions.subjects();
  }

  @Roles(Role.STUDENT, Role.ADMIN, Role.TEACHER, Role.SECRETARY)
  @Get('books')
  books(@Query('subject') subject?: string) {
    return this.solutions.books(subject);
  }

  // ── Book management (teachers + admins only) ──
  @Roles(Role.ADMIN, Role.TEACHER)
  @Post('books')
  createBook(@Req() req: any, @Body() body: any) {
    return this.solutions.createBook(req.user, body);
  }

  @Roles(Role.ADMIN, Role.TEACHER)
  @Patch('books/:id')
  updateBook(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.solutions.updateBook(req.user, id, body);
  }

  @Roles(Role.ADMIN, Role.TEACHER)
  @Delete('books/:id')
  deleteBook(@Req() req: any, @Param('id') id: string) {
    return this.solutions.deleteBook(req.user, id);
  }

  // ── Reports ──
  @Roles(Role.ADMIN)
  @Get('reports')
  listReports(@Req() req: any) {
    return this.solutions.listReports(req.user);
  }

  @Roles(Role.ADMIN)
  @Patch('reports/:id')
  resolveReport(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.solutions.resolveReport(req.user, id, body);
  }

  @Roles(Role.STUDENT, Role.ADMIN, Role.TEACHER, Role.SECRETARY)
  @Get()
  list(
    @Query('subject') subject?: string,
    @Query('bookTitle') bookTitle?: string,
    @Query('pageNumber') pageNumber?: string,
    @Query('questionNumber') questionNumber?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.solutions.list({
      subject,
      bookTitle,
      pageNumber: pageNumber ? Number(pageNumber) : undefined,
      questionNumber,
      page: page ? Number(page) : undefined,
      limit: limit ? Number(limit) : undefined,
    });
  }

  @Roles(Role.STUDENT, Role.ADMIN, Role.TEACHER)
  @Post()
  create(@Req() req: any, @Body() body: any) {
    return this.solutions.create(req.user, body);
  }

  @Roles(Role.STUDENT, Role.ADMIN, Role.TEACHER, Role.SECRETARY)
  @Post(':id/report')
  report(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.solutions.report(req.user, id, body);
  }

  @Roles(Role.ADMIN, Role.TEACHER, Role.SECRETARY)
  @Patch(':id/verify')
  verify(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.solutions.verify(req.user, id, body);
  }

  @Roles(Role.ADMIN, Role.TEACHER, Role.SECRETARY)
  @Patch(':id/moderate')
  moderate(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.solutions.moderate(req.user, id, body);
  }
}
