import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminService } from './admin.service';

@UseGuards(JwtAuthGuard)
@Controller('admin')
export class AdminController {
  constructor(private readonly admin: AdminService) {}

  @Post('cohorts')
  createCohort(@Req() req: any, @Body() body: { name: string; grade: number }) {
    return this.admin.createCohort(req.user, body);
  }

  @Post('cohorts/join-code')
  joinCode(
    @Req() req: any,
    @Body()
    body: { cohortId: string; expiresInHours?: number; length?: number },
  ) {
    return this.admin.generateJoinCode(req.user, body);
  }

  @Get('schedule/cohort/:cohortId')
  cohortSchedule(@Req() req: any, @Param('cohortId') cohortId: string) {
    return this.admin.getCohortSchedule(req.user, cohortId);
  }

  @Post('schedule/slot')
  setSlot(
    @Req() req: any,
    @Body()
    body: {
      cohortId: string;
      dayOfWeek: number;
      period: number;
      courseId?: string | null;
    },
  ) {
    return this.admin.setScheduleSlot(req.user, body);
  }

  @Post('schedule/bulk')
  setBulk(
    @Req() req: any,
    @Body()
    body: {
      cohortId: string;
      slots: { dayOfWeek: number; period: number; courseId?: string | null }[];
    },
  ) {
    return this.admin.setScheduleBulk(req.user, body);
  }

  @Post('schedule/override')
  setOverride(
    @Req() req: any,
    @Body()
    body: {
      cohortId: string;
      date: string;
      period: number;
      courseId?: string | null;
    },
  ) {
    return this.admin.setScheduleOverride(req.user, body);
  }
}
