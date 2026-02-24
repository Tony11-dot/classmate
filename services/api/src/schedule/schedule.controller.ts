import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ScheduleService } from './schedule.service';

@Controller()
export class ScheduleController {
  constructor(private readonly svc: ScheduleService) {}

  @UseGuards(JwtAuthGuard)
  @Get('student/schedule')
  async listStudent(@Req() req: any) {
    const uid = String((req as any).user?.id ?? '');
    return this.svc.listForStudent(uid);
  }
}
