import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { ALL_APP_ROLES } from '../auth/roles';
import { FormsService } from './forms.service';

@UseGuards(JwtAuthGuard)
@Roles(...ALL_APP_ROLES)
@Controller('forms')
export class FormsController {
  constructor(private readonly forms: FormsService) {}

  @Get('live')
  async live(@Req() req: any) {
    return this.forms.live(req.user);
  }

  @Get(':id')
  async byId(@Req() req: any, @Param('id') id: string) {
    return this.forms.byId(req.user, id);
  }

  @Post(':id/submit')
  async submit(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.forms.submit(req.user, id, body);
  }
}