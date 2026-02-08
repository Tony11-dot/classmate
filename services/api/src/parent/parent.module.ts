import { Module } from '@nestjs/common';
import { ParentNotificationsEvents } from './parent-notifications.events';
import { PrismaModule } from '../prisma/prisma.module';
import { ScheduleModule } from '../schedule/schedule.module';

import { ParentController } from './parent.controller';
import { ParentService } from './parent.service';

import { ParentNotificationsController } from './parent-notifications.controller';
import { ParentNotificationsService } from './parent-notifications.service';
import { ParentAttendanceController } from './parent.attendance.controller';

@Module({
  imports: [PrismaModule, ScheduleModule],
  controllers: [ParentController, ParentNotificationsController,
    ParentAttendanceController,
  ],
  providers: [ParentService, ParentNotificationsService,
    ParentNotificationsEvents
  ],
  exports: [ParentService, ParentNotificationsService],
})
export class ParentModule {}
