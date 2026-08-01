import { Controller, Post, Req, UseGuards, BadRequestException } from '@nestjs/common';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { GradeBumpService } from './grade-bump.service';

/// Manual trigger for the Sept-1 grade bump.  The cron in [GradeBumpService]
/// fires automatically; this controller exists so admins (or ops) can force
/// a run during testing or after a missed window.
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('admin/grade-bump')
export class GradeBumpController {
  constructor(private readonly svc: GradeBumpService) {}

  /// Sweeps EVERY school and bumps where due — incl. deleting graduating
  /// students past maxGrade. That is a platform-wide, irreversible action, so
  /// it is MANAGER-only (platform owner). A per-school ADMIN uses run-mine.
  @Roles(Role.MANAGER)
  @Post('run-all')
  runAll() {
    return this.svc.checkAll();
  }

  /// Force-runs the bump for the caller's school, ignoring the "already
  /// bumped this year" guard would still apply — but useful for catch-ups.
  @Roles(Role.ADMIN)
  @Post('run-mine')
  runMine(@Req() req: any) {
    const schoolId = (req.user as any)?.schoolId;
    if (!schoolId) throw new BadRequestException('No school associated with this account');
    return this.svc.runForSchool(schoolId);
  }
}
