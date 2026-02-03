import { Module } from '@nestjs/common';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';
import { SolutionsModule } from './solutions/solutions.module';

import { loadEnv } from './env';

import { HealthModule } from './health/health.module';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { TutorModule } from './tutor/tutor.module';
import { ScheduleModule } from './schedule/schedule.module';
import { StudentModule } from './student/student.module';
import { AdminModule } from './admin/admin.module';
import { TeacherModule } from './teacher/teacher.module';
import { ParentModule } from './parent/parent.module';
import { AnnouncementsModule } from './announcements/announcements.module';

import { E2ESeedController } from './e2e/seed.controller';

const env = loadEnv();

// Extra safety: never even register the controller in production
const controllers = [
  ...(env.NODE_ENV !== 'production' && env.ENABLE_E2E_SEED ? [E2ESeedController] : []),
];

@Module({
  controllers,
  imports: [
    ServeStaticModule.forRoot({
      rootPath: join(process.cwd(), 'uploads'),
      serveRoot: '/uploads',
    }),
    HealthModule,
    PrismaModule,
    AuthModule,
    TutorModule,
    SolutionsModule,
    ScheduleModule,
    StudentModule,
    AdminModule,
    TeacherModule,
    ParentModule,
    AnnouncementsModule,
  ],
})
export class AppModule {}
