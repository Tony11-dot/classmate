import { HealthModule } from './health/health.module';
import { Module } from '@nestjs/common';
import { E2ESeedController } from './e2e/seed.controller';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { TutorModule } from './tutor/tutor.module';
import { ScheduleModule } from './schedule/schedule.module';
import { StudentModule } from './student/student.module';
import { AdminModule } from './admin/admin.module';
import { TeacherModule } from './teacher/teacher.module';
import { ParentModule } from './parent/parent.module';
import { AnnouncementsModule } from './announcements/announcements.module';
import { loadEnv } from './env';

const env = loadEnv();

@Module({
  controllers: [...(env.ENABLE_E2E_SEED ? [E2ESeedController] : [])],
  imports: [
    HealthModule,
    PrismaModule,
    AuthModule,
    TutorModule,
    ScheduleModule,
    StudentModule,
    AdminModule,
    TeacherModule,
    ParentModule,
    AnnouncementsModule,
  ],
})
export class AppModule {}
