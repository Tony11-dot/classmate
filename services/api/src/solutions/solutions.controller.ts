import { Body, Controller, Get, Param, Patch, Post, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { SolutionsService } from './solutions.service';

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

  @Roles(Role.STUDENT, Role.ADMIN)
  @Post()
  create(@Req() req: any, @Body() body: any) {
    return this.solutions.create(req.user, body);
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
