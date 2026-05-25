import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { MessagesService } from './messages.service';
import { CreateDirectRequestDto } from './dto/create-direct-request.dto';
import { ApproveMessageRequestDto } from './dto/approve-message-request.dto';
import { BlockMessageRequestDto } from './dto/block-message-request.dto';
import { CreateGroupThreadDto } from './dto/create-group-thread.dto';
import { SendMessageDto } from './dto/send-message.dto';
import { MarkThreadReadDto } from './dto/mark-thread-read.dto';
import { EditMessageDto } from './dto/edit-message.dto';
import { TogglePinMessageDto } from './dto/toggle-pin-message.dto';
import { DeleteMessageDto } from './dto/delete-message.dto';
import { ForwardMessageDto } from './dto/forward-message.dto';
import { ReactMessageDto } from './dto/react-message.dto';
import { ReportMessageDto } from './dto/report-message.dto';

@UseGuards(JwtAuthGuard)
@Roles(Role.STUDENT, Role.ADMIN, Role.TEACHER, Role.PARENT, Role.SECRETARY)
@Controller('messages')
export class MessagesController {
  constructor(private readonly service: MessagesService) {}

  @Get('inbox')
  fetchInbox(@Req() req: any) {
    return this.service.fetchInbox(req.user);
  }

  @Get('people/same-school')
  fetchSameSchoolPeople(@Req() req: any) {
    return this.service.fetchSameSchoolPeople(req.user);
  }

  @Get('blocked')
  fetchBlocked(@Req() req: any) {
    return this.service.fetchBlocked(req.user);
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

  @Post('groups/leave')
  leaveGroup(@Req() req: any, @Body() body: BlockMessageRequestDto) {
    return this.service.leaveGroup(req.user, body);
  }

  @Post('threads/block')
  blockDirectThread(@Req() req: any, @Body() body: BlockMessageRequestDto) {
    return this.service.blockDirectThread(req.user, body);
  }

  @Post('threads/unblock')
  unblockDirectThread(@Req() req: any, @Body() body: BlockMessageRequestDto) {
    return this.service.unblockDirectThread(req.user, body);
  }

  @Post('send')
  send(@Req() req: any, @Body() body: SendMessageDto) {
    return this.service.sendMessage(req.user, body);
  }

  @Post('read')
  markRead(@Req() req: any, @Body() body: MarkThreadReadDto) {
    return this.service.markThreadRead(req.user, body);
  }

  @Post('edit')
  edit(@Req() req: any, @Body() body: EditMessageDto) {
    return this.service.editMessage(req.user, body);
  }

  @Post('pin/toggle')
  pin(@Req() req: any, @Body() body: TogglePinMessageDto) {
    return this.service.togglePin(req.user, body);
  }

  @Post('delete')
  deleteMessage(@Req() req: any, @Body() body: DeleteMessageDto) {
    return this.service.deleteMessage(req.user, body);
  }

  @Post('forward')
  forward(@Req() req: any, @Body() body: ForwardMessageDto) {
    return this.service.forwardMessage(req.user, body);
  }

  @Post('react')
  react(@Req() req: any, @Body() body: ReactMessageDto) {
    return this.service.reactMessage(req.user, body);
  }

  @Post('report')
  report(@Req() req: any, @Body() body: ReportMessageDto) {
    return this.service.reportMessage(req.user, body);
  }

  // ── Group management ──────────────────────────────────────────────────────

  @Get('threads/:threadId/info')
  threadInfo(@Req() req: any, @Param('threadId') threadId: string) {
    return this.service.getThreadInfo(req.user, threadId);
  }

  @Post('threads/:threadId/members')
  addMember(@Req() req: any, @Param('threadId') threadId: string, @Body() body: any) {
    return this.service.addGroupMember(req.user, threadId, body);
  }

  @Delete('threads/:threadId/members/:userId')
  removeMember(@Req() req: any, @Param('threadId') threadId: string, @Param('userId') userId: string) {
    return this.service.removeGroupMember(req.user, threadId, userId);
  }

  @Patch('threads/:threadId/members/:userId/role')
  updateMemberRole(@Req() req: any, @Param('threadId') threadId: string, @Param('userId') userId: string, @Body() body: any) {
    return this.service.updateGroupMemberRole(req.user, threadId, userId, body);
  }

  @Post('threads/:threadId/mute')
  muteThread(@Req() req: any, @Param('threadId') threadId: string) {
    return this.service.toggleMuteThread(req.user, threadId);
  }

  @Patch('threads/:threadId/title')
  updateTitle(@Req() req: any, @Param('threadId') threadId: string, @Body() body: any) {
    return this.service.updateGroupTitle(req.user, threadId, body);
  }

  @Post('threads/:threadId/members/:userId/block')
  blockMember(@Req() req: any, @Param('threadId') threadId: string, @Param('userId') userId: string) {
    return this.service.blockGroupMember(req.user, threadId, userId);
  }

  @Post('threads/:threadId/invite-code')
  generateInviteCode(@Req() req: any, @Param('threadId') threadId: string) {
    return this.service.generateGroupInviteCode(req.user, threadId);
  }

  @Post('groups/join')
  joinByInviteCode(@Req() req: any, @Body() body: any) {
    return this.service.joinGroupByCode(req.user, body);
  }
}
