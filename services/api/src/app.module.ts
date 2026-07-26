import { Module, ValidationPipe } from '@nestjs/common';
import { APP_FILTER, APP_GUARD, APP_PIPE } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { ServeStaticModule } from '@nestjs/serve-static';
import { existsSync, mkdirSync } from 'fs';
import { join } from 'path';

import { loadEnv } from './env';
import { setUploadSafetyHeaders } from './common/upload-safety';
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
import { ManagerModule } from './manager/manager.module';
import { PasswordResetController } from './auth/password-reset/password-reset.controller';
import { PasswordResetService } from './auth/password-reset/password-reset.service';
import { EmailService } from './auth/password-reset/email.service';
import { SmsService } from './auth/password-reset/sms.service';
import { VerifyController } from './auth/verify/verify.controller';
import { VerifyService } from './auth/verify/verify.service';
import { TeacherModule } from './teacher/teacher.module';
import { CertificatesModule } from './certificates/certificates.module';
import { ParentModule } from './parent/parent.module';
import { AnnouncementsModule } from './announcements/announcements.module';
import { SolutionsModule } from './solutions/solutions.module';
import { UploadsModule } from './uploads/uploads.module';
import { BillingModule } from './billing/billing.module';
import { UsersModule } from './users/users.module';
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
import { MessagesModule } from './messages/messages.module';
import { FormsModule } from './forms/forms.module';
import { RealtimeModule } from './realtime/realtime.module';
import { GradeBumpModule } from './grade-bump/grade-bump.module';
import { SlotSharedMaterialsModule } from './slot-shared-materials/slot-shared-materials.module';
import { NotesModule } from './notes/notes.module';
import { ClassnotesModule } from './classnotes/classnotes.module';
import { CMailModule } from './cmail/cmail.module';
import { AccountModule } from './account/account.module';
import { SupportModule } from './support/support.module';
import { MoeSsoModule } from './auth/moe-sso/moe-sso.module';
import { RetentionService } from './common/retention.service';

const env = loadEnv();

const uploadsRoot = join(process.cwd(), 'uploads');

if (!existsSync(uploadsRoot)) {
  mkdirSync(uploadsRoot, { recursive: true });
}

// Project-bundled brand assets (e.g. logo_light.png used by email templates).
// Served unconditionally because email recipients fetch these URLs regardless
// of the SERVE_UPLOADS env gate that controls user-uploaded media.
const assetsRoot = join(process.cwd(), 'assets');

const serveStatic = [
  ...(env.SERVE_UPLOADS === 'true' || env.NODE_ENV !== 'production'
    ? [
        ServeStaticModule.forRoot({
          rootPath: uploadsRoot,
          serveRoot: '/uploads',
          serveStaticOptions: {
            fallthrough: false,
            // User-uploaded media gets a unique timestamped filename, so each
            // URL is immutable — cache it for a year. Cuts repeat bandwidth +
            // compute hugely at scale, and lets a CDN/edge serve it for free.
            maxAge: 60 * 60 * 24 * 365 * 1000,
            immutable: true,
            // Force-download + neuter anything script-capable (SVG/HTML) —
            // uploaded content must never execute on the API origin.
            setHeaders: setUploadSafetyHeaders,
          },
        }),
      ]
    : []),
  ...(existsSync(assetsRoot)
    ? [
        ServeStaticModule.forRoot({
          rootPath: assetsRoot,
          serveRoot: '/static',
          serveStaticOptions: {
            fallthrough: false,
            // Aggressive cache — these assets are immutable per deploy.
            maxAge: 60 * 60 * 24 * 30 * 1000,
          },
        }),
      ]
    : []),
];

const seedControllers = [
  ...(env.NODE_ENV === 'test' ? [E2ESeedController] : []),
  ...(env.NODE_ENV !== 'production' ? [E2ESeedController] : []),
];

@Module({
  imports: [
    MessagesModule,
    FormsModule,
    RealtimeModule,
    ...serveStatic,
    // Two throttle buckets:
    //   • default — generous global cap so a buggy client can't spam us
    //     to death. 1200 req/min/IP — needed once a parent watching two
    //     kids does a tab switch (insights + schedule + week refetch + SSE
    //     reconnect can fan out 30+ requests in a second). 600 was tripping
    //     under that pattern.
    //   • auth    — strict 5 req / 15 min / IP for credential-handling
    //     endpoints (login, register, forgot/reset password). Brute-
    //     force defense; opted into per-route with @Throttle({ auth: … }).
    //
    // ⚠ @nestjs/throttler enforces EVERY named bucket on EVERY route unless
    // that bucket is skipped by name — and a bare @SkipThrottle() only skips
    // 'default'. Without the skipIf below, the strict auth cap silently
    // applied platform-wide and intermittently 429'd hot read endpoints
    // (testers hit it on the messages thread fetch). skipIf makes the auth
    // bucket OPT-IN: it only runs on routes that explicitly declared
    // @Throttle({ auth: … }) metadata.
    ThrottlerModule.forRoot([
      { name: 'default', ttl: 60_000, limit: 1200 },
      {
        name: 'auth',
        ttl: 15 * 60_000,
        limit: 5,
        skipIf: (context) => {
          // THROTTLER_LIMIT constant from @nestjs/throttler internals —
          // metadata key is `${'THROTTLER:LIMIT'}${bucketName}`.
          const key = 'THROTTLER:LIMITauth';
          const handler = context.getHandler();
          const cls = context.getClass();
          return (
            Reflect.getMetadata(key, handler) === undefined &&
            Reflect.getMetadata(key, cls) === undefined
          );
        },
      },
    ]),
    HealthModule,
    PrismaModule,
    AuthModule,
    TutorModule,
    StudentModule,
    AdminModule,
    TeacherModule,
    CertificatesModule,
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
    ManagerModule,
    PracticeAdaptiveModule,
    NovaModule,
    PracticeModule,
    GradeBumpModule,
    SlotSharedMaterialsModule,
    NotesModule,
    ClassnotesModule,
    CMailModule,
    AccountModule,
    BillingModule,
    UsersModule,
    SupportModule,
    MoeSsoModule,
  ],
  controllers: [DmUploadController, PasswordResetController, VerifyController, MetricsController, ...seedControllers],
  providers: [
    JsonLogger,
    RequestMetricsInterceptor,
    PasswordResetService,
    EmailService,
    SmsService,
    VerifyService,
    RetentionService,
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
    // Order matters — guards run top-to-bottom. JwtAuthGuard sets req.user;
    // RolesGuard reads it. Putting Roles first (the old order) only worked
    // when APP_ENV was 'development' because RolesGuard short-circuited.
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
    {
      provide: APP_GUARD,
      useClass: DevOverrideGuard,
    },
    {
      provide: APP_GUARD,
      useClass: RolesGuard,
    },
  ],
})
export class AppModule {}