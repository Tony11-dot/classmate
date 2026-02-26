import { RolesGuard } from './auth/guards/roles.guard';
import { DevAuthGuard } from './auth/guards/dev-auth.guard';
import { Module, ValidationPipe } from '@nestjs/common';
import { HttpExceptionFilter } from './common/http-exception.filter';
import { APP_PIPE, APP_FILTER, APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
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
import { NotificationsModule } from './notifications/notifications.module';
import { ClassroomsModule } from './classrooms/classrooms.module';

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
// Always register seed controller in tests; optionally in non-prod when ENABLE_E2E_SEED=true
const controllers = [
  ...(env.NODE_ENV === 'test' ? [E2ESeedController] : []),
  ...(env.NODE_ENV !== 'production' && env.ENABLE_E2E_SEED ? [E2ESeedController] : []),
];

@Module({
  providers: [
    {
      provide: APP_PIPE,
      useValue: new ValidationPipe({ whitelist: true, transform: true, forbidNonWhitelisted: true }),
    },
    {
      provide: APP_FILTER,
      useClass: HttpExceptionFilter,
    },
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
  controllers,
  imports: [
    ClassroomsModule,
    ...serveStatic,
    ThrottlerModule.forRoot([
      {
        name: 'global',
        ttl: 60_000,
        limit: 120,
      },
      {
        name: 'auth',
        ttl: 60_000,
        limit: 30,
      },
    ]),
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
    NotificationsModule,
  ],
})
export class AppModule {}
