import { Body, Controller, Param, Patch, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { Role } from '@prisma/client';

@Controller('solutions/staff')
@UseGuards(JwtAuthGuard)
export class SolutionsStaffController {
  @Roles(Role.ADMIN, Role.TEACHER, Role.SECRETARY)
  @Patch(':id/moderate')
  moderate(@Param('id') id: string, @Body() body: any) {
    return {
      ok: true,
      id,
      moderationStatus: body.moderationStatus,
      moderationReason: body.moderationReason ?? null,
    };
  }

  @Roles(Role.ADMIN, Role.TEACHER, Role.SECRETARY)
  @Patch(':id/verify')
  verify(@Param('id') id: string, @Body() body: any) {
    return {
      ok: true,
      id,
      verificationStatus: body.verificationStatus,
      verificationNote: body.verificationNote ?? null,
    };
  }
}
