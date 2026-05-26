import { Global, Module } from '@nestjs/common';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { NotificationsHubService } from './notifications-hub.service';
import { PushService } from './push.service';
import { DevicesController } from './devices.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { PrismaService } from '../prisma/prisma.service';
import { RealtimeModule } from '../realtime/realtime.module';
import { ParentNotificationsEventsModule } from '../parent/parent-notifications-events.module';

// @Global() so any service can inject NotificationsHubService without
// every domain module having to add NotificationsModule to its imports.
// Mirrors RealtimeModule's pattern — these cross-cutting infrastructure
// modules don't have a clean "feature" home so global is the cleaner fit.
@Global()
@Module({
  imports: [PrismaModule, RealtimeModule, ParentNotificationsEventsModule],
  controllers: [NotificationsController, DevicesController],
  providers: [
    PrismaService,
    NotificationsService,
    NotificationsHubService,
    PushService,
  ],
  exports: [NotificationsService, NotificationsHubService, PushService],
})
export class NotificationsModule {}
