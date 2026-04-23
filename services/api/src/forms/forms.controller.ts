import { Controller, Get, Param, Req, UseGuards } from '@nestjs/common';
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
}