import { Body, Controller, Get, Param, Patch, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { DmService } from './dm.service';
import { CreateDmThreadDto } from './dto/create-thread.dto';
import { RespondDmRequestDto } from './dto/respond-request.dto';
import { SendDmMessageDto } from './dto/send-message.dto';
import { ReactDmMessageDto } from './dto/react-message.dto';

@Controller('dm')
@UseGuards(JwtAuthGuard)
export class DmController {
  constructor(private readonly dm: DmService) {}

  @Get('threads')
  listThreads(@Req() req: any) {
    return this.dm.listThreads(req.user);
  }

  @Post('threads')
  createThread(@Req() req: any, @Body() dto: CreateDmThreadDto) {
    return this.dm.createThread(req.user, dto);
  }

  @Patch('threads/:id/request')
  respondToRequest(@Req() req: any, @Param('id') id: string, @Body() dto: RespondDmRequestDto) {
    return this.dm.respondToRequest(req.user, id, dto);
  }

  @Patch('threads/:id/unblock')
  unblock(@Req() req: any, @Param('id') id: string) {
    return this.dm.unblock(req.user, id);
  }

  @Get('threads/:id/messages')
  listMessages(@Req() req: any, @Param('id') id: string) {
    return this.dm.listMessages(req.user, id);
  }

  @Post('threads/:id/messages')
  sendMessage(@Req() req: any, @Param('id') id: string, @Body() dto: SendDmMessageDto) {
    return this.dm.sendMessage(req.user, id, dto);
  }

  @Post('messages/:id/view')
  recordView(@Req() req: any, @Param('id') id: string) {
    return this.dm.recordView(req.user, id);
  }

  @Post('messages/:id/react')
  react(@Req() req: any, @Param('id') id: string, @Body() dto: ReactDmMessageDto) {
    return this.dm.react(req.user, id, dto);
  }
}
