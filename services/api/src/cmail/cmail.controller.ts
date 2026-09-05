import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { CMailService } from './cmail.service';
import { SendCMailDto } from './dto/send-cmail.dto';

/// CMail routes. Composing (send/sent/ddl) is staff-only; inbox/detail/delete
/// are open to every role — anyone can RECEIVE mail. Static paths are
/// declared before ':id' so Nest never swallows them as a mail id.
@UseGuards(JwtAuthGuard)
@Controller('cmail')
export class CMailController {
  constructor(private readonly cmail: CMailService) {}

  @Get('ddl')
  @Roles(Role.ADMIN, Role.TEACHER, Role.SECRETARY)
  ddl(@Req() req: any) {
    return this.cmail.ddl(req.user);
  }

  @Post('send')
  @Roles(Role.ADMIN, Role.TEACHER, Role.SECRETARY)
  send(@Req() req: any, @Body() dto: SendCMailDto) {
    return this.cmail.send(req.user, dto);
  }

  @Get('sent')
  @Roles(Role.ADMIN, Role.TEACHER, Role.SECRETARY)
  sent(@Req() req: any) {
    return this.cmail.sent(req.user);
  }

  @Get('inbox')
  @Roles(Role.STUDENT, Role.TEACHER, Role.ADMIN, Role.PARENT, Role.SECRETARY)
  inbox(@Req() req: any) {
    return this.cmail.inbox(req.user);
  }

  @Get('unread-count')
  @Roles(Role.STUDENT, Role.TEACHER, Role.ADMIN, Role.PARENT, Role.SECRETARY)
  unreadCount(@Req() req: any) {
    return this.cmail.unreadCount(req.user);
  }

  @Get(':id')
  @Roles(Role.STUDENT, Role.TEACHER, Role.ADMIN, Role.PARENT, Role.SECRETARY)
  detail(@Req() req: any, @Param('id') id: string) {
    return this.cmail.detail(req.user, id);
  }

  // Sender-only recipient roster for the "N recipients" chip (QA #44).
  @Get(':id/recipients')
  @Roles(Role.TEACHER, Role.ADMIN, Role.SECRETARY)
  recipients(@Req() req: any, @Param('id') id: string) {
    return this.cmail.recipients(req.user, id);
  }

  @Delete(':id')
  @Roles(Role.STUDENT, Role.TEACHER, Role.ADMIN, Role.PARENT, Role.SECRETARY)
  delete(@Req() req: any, @Param('id') id: string) {
    return this.cmail.delete(req.user, id);
  }

  // Gmail-style long-press actions: toggle a mail's read state without
  // opening it (detail() already marks read on open).
  @Post(':id/read')
  @Roles(Role.STUDENT, Role.TEACHER, Role.ADMIN, Role.PARENT, Role.SECRETARY)
  markRead(@Req() req: any, @Param('id') id: string) {
    return this.cmail.setRead(req.user, id, true);
  }

  @Post(':id/unread')
  @Roles(Role.STUDENT, Role.TEACHER, Role.ADMIN, Role.PARENT, Role.SECRETARY)
  markUnread(@Req() req: any, @Param('id') id: string) {
    return this.cmail.setRead(req.user, id, false);
  }
}
