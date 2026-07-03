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
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { NotesService } from './notes.service';
import { CreateNoteDto, UpdateNoteDto } from './dto/note.dto';

/// Staff-only student notes. Students/parents/secretaries are rejected at the
/// guard layer; the service re-checks roles AND school-scopes every query.
@UseGuards(JwtAuthGuard)
@Roles(Role.TEACHER, Role.ADMIN)
@Controller('notes')
export class NotesController {
  constructor(private readonly notes: NotesService) {}

  @Get('students')
  listStudents(@Req() req: any, @Query('q') q?: string) {
    return this.notes.listStudents(req.user, q);
  }

  @Get('students/:studentId')
  listNotes(@Req() req: any, @Param('studentId') studentId: string) {
    return this.notes.listNotes(req.user, studentId);
  }

  @Post('students/:studentId')
  createNote(
    @Req() req: any,
    @Param('studentId') studentId: string,
    @Body() dto: CreateNoteDto,
  ) {
    return this.notes.createNote(req.user, studentId, dto);
  }

  @Patch(':noteId')
  updateNote(@Req() req: any, @Param('noteId') noteId: string, @Body() dto: UpdateNoteDto) {
    return this.notes.updateNote(req.user, noteId, dto);
  }

  @Delete(':noteId')
  deleteNote(@Req() req: any, @Param('noteId') noteId: string) {
    return this.notes.deleteNote(req.user, noteId);
  }
}
