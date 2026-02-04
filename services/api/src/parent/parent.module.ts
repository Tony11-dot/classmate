import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { ScheduleModule } from '../schedule/schedule.module';

import { ParentController } from './parent.controller';
import { ParentService } from './parent.service';

import { ParentNotificationsController } from './parent-notifications.controller';
import { ParentNotificationsService } from './parent-notifications.service';

@Module({
  imports: [PrismaModule, ScheduleModule],
  controllers: [ParentController, ParentNotificationsController],
  providers: [ParentService, ParentNotificationsService],
  exports: [ParentService, ParentNotificationsService],
})
export class ParentModule {}
