import { Module } from '@nestjs/common';
import { TeacherController } from './teacher.controller';
import { TeacherService } from './teacher.service';
import { PrismaModule } from '../prisma/prisma.module';
import { RealtimeModule } from '../realtime/realtime.module';
import { ParentNotificationsEventsModule } from '../parent/parent-notifications-events.module';

// NotificationsHubService is provided by @Global() NotificationsModule.
// ParentNotificationsEventsModule is imported explicitly because the
// teacher service pokes the parent SSE bus directly when an attendance
// or grade write needs to ping parents WITHOUT going through the hub
// (the existing inline path has its own dedup that we want to keep).
@Module({
  imports: [PrismaModule, RealtimeModule, ParentNotificationsEventsModule],
  controllers: [TeacherController],
  providers: [TeacherService],
})
export class TeacherModule {}
