import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Req,
  Put,
  ServiceUnavailableException,
  UseGuards,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { ALL_APP_ROLES } from '../auth/roles';
import { ClassnotesService } from './classnotes.service';
import { ClassnotesAiService } from './classnotes.ai.service';
import {
  NotebookUpsertDto,
  NotebookPagesUpsertDto,
  ShelfUpsertDto,
  NotesAiDto,
} from './dto/classnotes.dto';

/// Personal ClassNotes library sync. Any signed-in user manages their OWN
/// notebooks/shelves — the native ClassNotes app PUTs metadata here on every
/// edit, and the ClassMate "ClassNotes" tab GETs the library. Scoped entirely
/// to `req.user`; never takes another user's id.
@UseGuards(JwtAuthGuard)
@Roles(...ALL_APP_ROLES)
@Controller('classnotes')
export class ClassnotesController {
  constructor(
    private readonly svc: ClassnotesService,
    private readonly ai: ClassnotesAiService,
  ) {}

  /// NOVA note assistant — explain a highlight, beautify handwriting, or chat.
  /// Keyless on the client (the model key lives server-side). Throttled: this
  /// fans out to a third-party model, so it's help, not a firehose.
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @Post('ai')
  async notesAi(@Body() dto: NotesAiDto) {
    if (!this.ai.isEnabled()) {
      throw new ServiceUnavailableException('NOVA is not available right now.');
    }
    try {
      const task = (dto.task || '').toLowerCase();
      if (task === 'beautify') return await this.ai.beautify(dto.text);
      if (task === 'explain') return await this.ai.explain(dto.text);
      return await this.ai.chat(dto.text, dto.history ?? [], dto.pageContext);
    } catch {
      throw new ServiceUnavailableException(
        'NOVA is temporarily unavailable. Please try again in a moment.',
      );
    }
  }

  @Get('library')
  library(@Req() req: any) {
    return this.svc.getLibrary(req.user);
  }

  @Put('notebooks/:id')
  putNotebook(
    @Req() req: any,
    @Param('id') id: string,
    @Body() dto: NotebookUpsertDto,
  ) {
    return this.svc.upsertNotebook(req.user, id, dto);
  }

  @Delete('notebooks/:id')
  deleteNotebook(@Req() req: any, @Param('id') id: string) {
    return this.svc.deleteNotebook(req.user, id);
  }

  /// Rendered page images for one owned notebook, ordered by pageIndex.
  @Get('notebooks/:id/pages')
  getNotebookPages(@Req() req: any, @Param('id') id: string) {
    return this.svc.getNotebookPages(req.user, id);
  }

  /// Upload the rendered page images for one owned notebook. Upserts each page
  /// and prunes any pages at index >= pageCount (removed pages disappear).
  @Put('notebooks/:id/pages')
  putNotebookPages(
    @Req() req: any,
    @Param('id') id: string,
    @Body() dto: NotebookPagesUpsertDto,
  ) {
    return this.svc.upsertNotebookPages(req.user, id, dto);
  }

  @Put('shelves/:id')
  putShelf(
    @Req() req: any,
    @Param('id') id: string,
    @Body() dto: ShelfUpsertDto,
  ) {
    return this.svc.upsertShelf(req.user, id, dto);
  }

  @Delete('shelves/:id')
  deleteShelf(@Req() req: any, @Param('id') id: string) {
    return this.svc.deleteShelf(req.user, id);
  }
}
