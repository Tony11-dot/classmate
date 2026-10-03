import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Put,
  Req,
  UseGuards,
} from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { PermissionsService } from './permissions.service';

/**
 * Admin-only console for the admin-managed permissions feature. The GET returns
 * the full catalog with current effective values per role (drives the Flutter
 * searchable checklist); the PUT saves the admin's toggles.
 *
 * Only ADMIN (and the platform MANAGER) can read or change permissions — a
 * secretary granted other powers can never grant themselves more.
 */
@SkipThrottle()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN, Role.MANAGER)
@Controller('admin/permissions')
export class PermissionsController {
  constructor(private readonly permissions: PermissionsService) {}

  @Get()
  async get(@Req() req: any) {
    const schoolId = (req.user as any)?.schoolId ?? null;
    return this.permissions.getSchoolConfig(schoolId);
  }

  @Put()
  async update(@Req() req: any, @Body() body: any) {
    const schoolId = (req.user as any)?.schoolId;
    if (!schoolId) {
      throw new BadRequestException('No school is associated with this account.');
    }
    // Accept either { overrides: {...} } or the bare map for convenience.
    const incoming = body?.overrides ?? body ?? {};
    const saved = await this.permissions.setOverrides(schoolId, incoming);
    // Return the refreshed config so the client can re-render from truth.
    const config = await this.permissions.getSchoolConfig(schoolId);
    return { ok: true, overrides: saved, ...config };
  }
}
