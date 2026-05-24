import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { ScheduleModule } from '../schedule/schedule.module';

import { ParentController } from './parent.controller';
import { ParentService } from './parent.service';

import { ParentNotificationsController } from './parent-notifications.controller';
import { ParentNotificationsService } from './parent-notifications.service';
import { ParentAttendanceController } from './parent.attendance.controller';
import { StudentModule } from '../student/student.module';
import { ParentNotificationsEventsModule } from './parent-notifications-events.module';

@Module({
  imports: [PrismaModule, ScheduleModule, StudentModule, ParentNotificationsEventsModule],
  controllers: [ParentController, ParentNotificationsController,
    ParentAttendanceController,
  ],
  providers: [ParentService, ParentNotificationsService],
  exports: [ParentService, ParentNotificationsService],
})
export class ParentModule {}
