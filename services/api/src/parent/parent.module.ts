import { Module } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ScheduleModule } from '../schedule/schedule.module';
import { ParentController } from './parent.controller';
import { ParentAttendanceController } from './parent.attendance.controller';
import { ParentService } from './parent.service';

@Module({
  imports: [ScheduleModule],
  controllers: [ParentController, ParentAttendanceController],
  providers: [ParentService, PrismaService],
})
export class ParentModule {}
