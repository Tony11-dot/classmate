import { Body, Controller, Param, Patch, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { SolutionsService } from './solutions.service';

@Controller('solutions/staff')
@UseGuards(JwtAuthGuard)
export class SolutionsStaffController {
  constructor(private readonly solutions: SolutionsService) {}

  @Roles(Role.ADMIN, Role.TEACHER, Role.SECRETARY)
  @Patch(':id/moderate')
  moderate(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.solutions.moderate(req.user, id, body);
  }

  @Roles(Role.ADMIN, Role.TEACHER, Role.SECRETARY)
  @Patch(':id/verify')
  verify(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.solutions.verify(req.user, id, body);
  }
}
