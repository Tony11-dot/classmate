import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Put,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { ALL_APP_ROLES } from '../auth/roles';
import { ClassnotesService } from './classnotes.service';
import { NotebookUpsertDto, ShelfUpsertDto } from './dto/classnotes.dto';

/// Personal ClassNotes library sync. Any signed-in user manages their OWN
/// notebooks/shelves — the native ClassNotes app PUTs metadata here on every
/// edit, and the ClassMate "ClassNotes" tab GETs the library. Scoped entirely
/// to `req.user`; never takes another user's id.
@UseGuards(JwtAuthGuard)
@Roles(...ALL_APP_ROLES)
@Controller('classnotes')
export class ClassnotesController {
  constructor(private readonly svc: ClassnotesService) {}

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
