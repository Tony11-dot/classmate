import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { ManagerService } from './manager.service';

// Platform-owner console — moved in-app from the old secret-gated /cms page.
// Every route is MANAGER-only (bootstrapped owner + any manager they add).
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.MANAGER)
@Controller('manager')
export class ManagerController {
  constructor(private readonly service: ManagerService) {}

  // ── Schools ────────────────────────────────────────────────────────────────
  @Get('schools')
  listSchools() {
    return this.service.listSchools();
  }

  @Get('schools/:id')
  getSchool(@Param('id') id: string) {
    return this.service.getSchool(id);
  }

  @Post('schools')
  createSchool(@Body() body: any) {
    return this.service.createSchool(body);
  }

  @Patch('schools/:id')
  updateSchool(@Param('id') id: string, @Body() body: any) {
    return this.service.updateSchool(id, body);
  }

  @Delete('schools/:id')
  deleteSchool(@Param('id') id: string) {
    return this.service.deleteSchool(id);
  }

  // ── Managers ───────────────────────────────────────────────────────────────
  @Get('managers')
  listManagers() {
    return this.service.listManagers();
  }

  @Post('managers')
  addManager(@Body() body: any) {
    return this.service.addManager(body);
  }

  @Delete('managers/:userId')
  revokeManager(@Param('userId') userId: string) {
    return this.service.revokeManager(userId);
  }
}
