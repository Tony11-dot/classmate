import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { MessagesService } from './messages.service';
import { CreateDirectRequestDto } from './dto/create-direct-request.dto';
import { ApproveMessageRequestDto } from './dto/approve-message-request.dto';
import { BlockMessageRequestDto } from './dto/block-message-request.dto';
import { CreateGroupThreadDto } from './dto/create-group-thread.dto';

@UseGuards(JwtAuthGuard)
@Roles(Role.STUDENT, Role.ADMIN, Role.TEACHER, Role.PARENT, Role.SECRETARY)
@Controller('messages')
export class MessagesController {
  constructor(private readonly service: MessagesService) {}

  @Get('inbox')
  fetchInbox(@Req() req: any) {
    return this.service.fetchInbox(req.user);
  }

  @Get('threads/:threadId')
  fetchThread(@Req() req: any, @Param('threadId') threadId: string) {
    return this.service.fetchThread(req.user, String(threadId || '').trim());
  }

  @Get('requests/:threadId')
  fetchRequest(@Req() req: any, @Param('threadId') threadId: string) {
    return this.service.fetchRequest(req.user, String(threadId || '').trim());
  }

  @Post('requests/direct')
  createDirectRequest(@Req() req: any, @Body() body: CreateDirectRequestDto) {
    return this.service.createDirectRequest(req.user, body);
  }

  @Post('requests/approve')
  approveRequest(@Req() req: any, @Body() body: ApproveMessageRequestDto) {
    return this.service.approveRequest(req.user, body);
  }

  @Post('requests/block')
  blockRequest(@Req() req: any, @Body() body: BlockMessageRequestDto) {
    return this.service.blockRequest(req.user, body);
  }

  @Post('threads/group')
  createGroup(@Req() req: any, @Body() body: CreateGroupThreadDto) {
    return this.service.createGroup(req.user, body);
  }
}
