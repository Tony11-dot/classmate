import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { FormsService } from './forms.service';

@UseGuards(JwtAuthGuard)
@Controller('forms')
export class FormsController {
  constructor(private readonly forms: FormsService) {}

  @Get('live')
  live(@Req() req: any) {
    return this.forms.live(req.user);
  }

  @Get(':id')
  byId(@Req() req: any, @Param('id') id: string) {
    return this.forms.byId(req.user, id);
  }

  @Post(':id/submit')
  submit(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.forms.submit(req.user, id, body);
  }
}