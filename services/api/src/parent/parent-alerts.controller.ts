import { Body, Controller, Get, Patch, Query, UseGuards } from '@nestjs/common';
import { ParentAlertsService } from './parent-alerts.service';
import { AuthGuard } from '@nestjs/passport';
import { UpdateAlertSettingsDto } from './dto/update-alert-settings.dto';
import { CurrentUser } from '../auth/current-user.decorator';

@UseGuards(AuthGuard('jwt'))
@Controller('parent/alerts')
export class ParentAlertsController {
  constructor(private svc: ParentAlertsService) {}

  @Get('settings')
  get(@CurrentUser() u: any, @Query('studentId') studentId: string) {
    const parentId = (u?.sub ?? u?.userId ?? u?.id);
    if (!parentId) throw new Error('CurrentUser missing id (sub/userId/id)');
    return this.svc.get(parentId, studentId);
  }

  @Patch('settings')
  patch(@CurrentUser() u: any, @Body() dto: UpdateAlertSettingsDto) {
    const parentId = (u?.sub ?? u?.userId ?? u?.id);
    if (!parentId) throw new Error('CurrentUser missing id (sub/userId/id)');
    return this.svc.update(parentId, dto);
  }
}
