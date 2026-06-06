import { Body, Controller, Delete, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { SlotSharedMaterialsService } from './slot-shared-materials.service';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.STUDENT, Role.TEACHER, Role.ADMIN)
@Controller('shared-materials')
export class SlotSharedMaterialsController {
  constructor(private readonly svc: SlotSharedMaterialsService) {}

  // All shared materials for the periods I take part in (drawer tab).
  @Get('mine')
  mine(@Req() req: any) {
    return this.svc.mine(req.user);
  }

  @Get('slot/:slotId')
  listForSlot(@Req() req: any, @Param('slotId') slotId: string) {
    return this.svc.listForSlot(req.user, slotId);
  }

  // Body: { fileUrl, fileName?, mimeType?, caption?, date? } — file is first
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
