import { Body, Controller, Get, Param, Post, Req } from '@nestjs/common';

import { ApproveMessageRequestDto } from './dto/approve-message-request.dto';
import { BlockMessageRequestDto } from './dto/block-message-request.dto';
import { CreateDirectRequestDto } from './dto/create-direct-request.dto';
import { CreateGroupThreadDto } from './dto/create-group-thread.dto';
import { MessagesService } from './messages.service';

@Controller('messages')
export class MessagesController {
  constructor(private readonly messagesService: MessagesService) {}

  @Get('inbox')
  getInbox(@Req() req: any) {
    return this.messagesService.getInbox(this.userIdFrom(req));
  }

  @Get('threads/:threadId')
  getThread(@Req() req: any, @Param('threadId') threadId: string) {
    return this.messagesService.getThread(this.userIdFrom(req), threadId);
  }

  @Get('requests/:threadId')
  getRequest(@Req() req: any, @Param('threadId') threadId: string) {
    return this.messagesService.getRequest(this.userIdFrom(req), threadId);
  }

  @Post('direct-request')
  createDirectRequest(@Req() req: any, @Body() dto: CreateDirectRequestDto) {
    return this.messagesService.createDirectRequest(this.userIdFrom(req), dto);
  }

  @Post('requests/approve')
  approveRequest(@Req() req: any, @Body() dto: ApproveMessageRequestDto) {
    return this.messagesService.approveRequest(this.userIdFrom(req), dto);
  }

  @Post('requests/block')
  blockRequest(@Req() req: any, @Body() dto: BlockMessageRequestDto) {
    return this.messagesService.blockRequest(this.userIdFrom(req), dto);
  }

  @Post('groups')
  createGroup(@Req() req: any, @Body() dto: CreateGroupThreadDto) {
    return this.messagesService.createGroup(this.userIdFrom(req), dto);
  }

  private userIdFrom(req: any): string {
    return (
      req?.user?.id?.toString()?.trim() ||
      req?.user?.sub?.toString()?.trim() ||
      req?.headers?.['x-dev-user-id']?.toString()?.trim() ||
      'dev-student'
    );
  }
}
