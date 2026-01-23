import { Module } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ScheduleModule } from '../schedule/schedule.module';
import { ParentController } from './parent.controller';
import { ParentAlertsController } from './parent-alerts.controller';
import { ParentAlertsService } from './parent-alerts.service';
import { ParentAttendanceController } from './parent.attendance.controller';
import { ParentService } from './parent.service';

@Module({
  imports: [ScheduleModule],
  controllers: [
    ParentAlertsController,
    ParentController,
    ParentAttendanceController,
  ],
  providers: [ParentAlertsService, ParentService, PrismaService],
})
export class ParentModule {}
