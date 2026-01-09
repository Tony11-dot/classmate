import { Controller, Get, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ParentService } from './parent.service';

@UseGuards(JwtAuthGuard)
@Controller('parent')
export class ParentAttendanceController {
  constructor(private readonly parent: ParentService) {}

  @Get('attendance')
  attendance(
    @Req() req: any,
    @Query('childId') childId: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    return this.parent.getChildAttendance(req.user, { childId, from, to });
  }
}
