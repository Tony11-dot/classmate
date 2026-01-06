import { Module } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ScheduleModule } from '../schedule/schedule.module';
import { ParentController } from './parent.controller';
import { ParentService } from './parent.service';

@Module({
  imports: [ScheduleModule],
  controllers: [ParentController],
  providers: [ParentService, PrismaService],
})
export class ParentModule {}
