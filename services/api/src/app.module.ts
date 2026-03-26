import { Module, ValidationPipe } from '@nestjs/common';
import { APP_FILTER, APP_GUARD, APP_PIPE } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';

import { loadEnv } from './env';
import { HttpExceptionFilter } from './common/http-exception.filter';
import { JsonLogger } from './common/logging/json.logger';
import { RequestMetricsInterceptor } from './common/interceptors/request-metrics.interceptor';
import { MetricsController } from './common/controllers/metrics.controller';

import { RolesGuard } from './auth/guards/roles.guard';
import { DevOverrideGuard } from './auth/dev-override.guard';
import { JwtAuthGuard } from './auth/jwt-auth.guard';

import { HealthModule } from './health/health.module';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { TutorModule } from './tutor/tutor.module';
import { StudentModule } from './student/student.module';
import { AdminModule } from './admin/admin.module';
import { DmUploadController } from './uploads/dm-upload.controller';
import { TeacherModule } from './teacher/teacher.module';
import { ParentModule } from './parent/parent.module';
import { AnnouncementsModule } from './announcements/announcements.module';
import { SolutionsModule } from './solutions/solutions.module';
import { UploadsModule } from './uploads/uploads.module';
import { VersionModule } from './version/version.module';
import { NotificationsModule } from './notifications/notifications.module';
import { ClassroomsModule } from './classrooms/classrooms.module';
import { OutboxModule } from './modules/outbox/outbox.module';
import { ProjectionsModule } from './modules/projections/projections.module';
import { BrainModule } from './brain/brain.module';
import { ScheduleModule } from './schedule/schedule.module';
import { BagrutModule } from './bagrut/bagrut.module';
import { PracticeAdaptiveModule } from './practice_adaptive/practice_adaptive.module';
import { NovaModule } from './nova/nova.module';
import { PracticeModule } from './practice/practice.module';
import { E2ESeedController } from './e2e/seed.controller';

const env = loadEnv();

const serveStatic =
  env.SERVE_UPLOADS === 'true' || env.NODE_ENV !== 'production'
    ? [
        ServeStaticModule.forRoot({
          rootPath: join(process.cwd(), 'uploads'),
          serveRoot: '/uploads',
        }),
      ]
    : [];

const seedControllers = [
  ...(env.NODE_ENV === 'test' ? [E2ESeedController] : []),
  ...(env.NODE_ENV !== 'production' && env.ENABLE_E2E_SEED ? [E2ESeedController] : []),
];

@Module({
  imports: [
    ...serveStatic,
    ThrottlerModule.forRoot([{ ttl: 60000, limit: 120 }]),
    HealthModule,
    PrismaModule,
    AuthModule,
    TutorModule,
    StudentModule,
    AdminModule,
    TeacherModule,
    ParentModule,
    AnnouncementsModule,
    SolutionsModule,
    UploadsModule,
    VersionModule,
    NotificationsModule,
    ClassroomsModule,
    OutboxModule,
    ProjectionsModule,
    BrainModule,
    ScheduleModule,
    BagrutModule,
    PracticeAdaptiveModule,
    NovaModule,
    PracticeModule,
  ],
  controllers: [
    DmUploadController,
MetricsController, ...seedControllers],
  providers: [
    JsonLogger,
    RequestMetricsInterceptor,
    {
      provide: APP_PIPE,
      useValue: new ValidationPipe({
        whitelist: true,
        transform: true,
        forbidNonWhitelisted: true,
      }),
    },
    {
      provide: APP_FILTER,
      useClass: HttpExceptionFilter,
    },
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
    {
      provide: APP_GUARD,
      useClass: RolesGuard,
    },
    {
      provide: APP_GUARD,
      useClass: DevOverrideGuard,
    },
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
  ],
})
export class AppModule {}
import { NovaController } from './modules/nova/nova.controller';
