import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import {
  Body,
  Controller,
  ForbiddenException,
  Post,
  Put,
  Req,
  UseGuards,
} from '@nestjs/common';
import { RolesGuard } from '../auth/guards/roles.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminService } from './admin.service';
import { hasAnyRole } from '../auth/permissions';

@UseGuards(JwtAuthGuard)
@Roles(Role.ADMIN)
@Controller('admin/schedule')
export class AdminScheduleController {
  constructor(private readonly admin: AdminService) {}

  private assertAdmin(req: any) {
    const roles: string[] = req.user?.roles ?? [];
    if (!hasAnyRole({ roles }, [Role.ADMIN])) throw new ForbiddenException('Admin only');
  }

  @Put('template')
  upsertTemplate(@Req() req: any, @Body() body: any) {
    this.assertAdmin(req);
    return this.admin.createPeriod(req.user, body);
  }

  @Post('override')
  setOverride(
    @Req() req: any,
    @Body()
    body: {
      cohortId: string;
      date: string; // YYYY-MM-DD
      period: number;
    },
  ) {
    this.assertAdmin(req);
    // use the method that already exists in your AdminService
    return this.admin.setScheduleOverride(req.user, body);
  }
}
