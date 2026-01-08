import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { ScheduleModule } from './schedule/schedule.module';
import { StudentModule } from './student/student.module';
import { AdminModule } from './admin/admin.module';
import { TeacherModule } from './teacher/teacher.module';
import { ParentModule } from './parent/parent.module';
import { AnnouncementsModule } from './announcements/announcements.module';

@Module({
  imports: [
    PrismaModule,
    AuthModule,
    ScheduleModule,
    StudentModule,
    AdminModule,
    TeacherModule,
    ParentModule,
    AnnouncementsModule,
  ],
})
export class AppModule {}
