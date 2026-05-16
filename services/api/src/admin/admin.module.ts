import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { ScheduleTemplatesController } from './schedule-templates/schedule-templates.controller';
import { AdminService } from './admin.service';
import { PrismaService } from '../prisma/prisma.service';
import { PasswordResetService } from '../auth/password-reset/password-reset.service';
import { EmailService } from '../auth/password-reset/email.service';
import { SmsService } from '../auth/password-reset/sms.service';

@Module({
  controllers: [AdminController,
    ScheduleTemplatesController,
  ],
  providers: [
    AdminService,
    PrismaService,
    // Used by admin.service.setUserPassword to notify the target user that
    // an admin changed their password (with a one-click reset link).
    PasswordResetService,
    EmailService,
    SmsService,
  ],
})
export class AdminModule {}
