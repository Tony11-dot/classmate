import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
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
  ChangesAckDto,
  NotebookOrderDto,
  NotebookPatchDto,
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
      // A snip is answered by looking at it. The image decides, not the task
      // name: a follow-up question about the same snip arrives as a plain chat
      // and must still be able to see what it is about.
      if (dto.imageBase64) {
        return await this.ai.see(dto.text, dto.imageBase64, dto.history ?? [], dto.pageContext);
      }
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

  /// What the ClassMate tab changed since this client last acknowledged —
  /// notebooks deleted or renamed there. The native app pulls this on launch,
  /// BEFORE pushing its own library, then acks.
  @Get('changes')
  changes(@Req() req: any) {
    return this.svc.getChanges(req.user);
  }

  @Post('changes/ack')
  ackChanges(@Req() req: any, @Body() dto: ChangesAckDto) {
    return this.svc.ackChanges(req.user, dto.ids ?? []);
  }

  /// Declared BEFORE `notebooks/:id` so the literal path wins over the parameter.
  @Put('notebooks/order')
  reorderNotebooks(@Req() req: any, @Body() dto: NotebookOrderDto) {
    return this.svc.reorderNotebooks(req.user, dto.ids ?? []);
  }

  @Put('notebooks/:id')
  putNotebook(
    @Req() req: any,
    @Param('id') id: string,
    @Body() dto: NotebookUpsertDto,
  ) {
    return this.svc.upsertNotebook(req.user, id, dto);
  }

  /// Rename / re-shelve / recolour from the ClassMate ClassNotes tab.
  @Patch('notebooks/:id')
  patchNotebook(
    @Req() req: any,
    @Param('id') id: string,
    @Body() dto: NotebookPatchDto,
  ) {
    return this.svc.patchNotebook(req.user, id, dto);
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
