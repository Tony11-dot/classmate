import { Module } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ScheduleService } from './schedule.service';

@Module({
  providers: [ScheduleService, PrismaService],
  exports: [ScheduleService],
})
export class ScheduleModule {}
