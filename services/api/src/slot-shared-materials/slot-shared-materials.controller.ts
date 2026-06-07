import { Body, Controller, Delete, Get, Param, Post, Query, Req, UseGuards } from '@nestjs/common';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { SlotSharedMaterialsService } from './slot-shared-materials.service';

/// Period-scoped materials that students (and teachers) add straight from the
/// period detail sheet. Backed by the normal TeacherMaterial store, so what's
/// added here also appears in the Materials tab.
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.STUDENT, Role.TEACHER, Role.ADMIN)
@Controller('shared-materials')
export class SlotSharedMaterialsController {
  constructor(private readonly svc: SlotSharedMaterialsService) {}

  @Get('slot/:slotId')
  listForSlot(@Req() req: any, @Param('slotId') slotId: string, @Query('date') date?: string) {
    return this.svc.listForSlot(req.user, slotId, date);
  }

  // Body: { title, attachments:[{url,name,mime}], date? } — files are first
  // uploaded via POST /uploads/attachment, then attached here.
  @Post('slot/:slotId')
  add(@Req() req: any, @Param('slotId') slotId: string, @Body() body: any) {
    return this.svc.addToSlot(req.user, slotId, body);
  }

  @Delete(':id')
  remove(@Req() req: any, @Param('id') id: string) {
    return this.svc.remove(req.user, id);
  }
}
