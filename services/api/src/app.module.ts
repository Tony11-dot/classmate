import { Module } from '@nestjs/common';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';

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
import { SolutionsModule } from './solutions/solutions.module';

import { E2ESeedController } from './e2e/seed.controller';
import { VersionModule } from './version/version.module';

const env = loadEnv();

// Static uploads OFF by default; enable explicitly with SERVE_UPLOADS=true
const serveStatic =
  env.SERVE_UPLOADS === 'true'
    ? [
        ServeStaticModule.forRoot({
          rootPath: join(process.cwd(), 'uploads'),
          serveRoot: '/uploads',
        }),
      ]
    : [];

// Always register seed controller in tests; optionally in non-prod when ENABLE_E2E_SEED=true
const controllers = [
  ...(env.NODE_ENV === 'test' ? [E2ESeedController] : []),
  ...(env.NODE_ENV !== 'production' && env.ENABLE_E2E_SEED ? [E2ESeedController] : []),
];

@Module({
  controllers: [E2ESeedController],
  imports: [
    ...serveStatic,
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
    VersionModule,
  ],
})
export class AppModule {}