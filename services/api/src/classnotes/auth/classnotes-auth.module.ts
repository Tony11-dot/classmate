import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PrismaModule } from '../../prisma/prisma.module';
import { EmailService } from '../../auth/password-reset/email.service';
import { ClassNotesAuthController } from './classnotes-auth.controller';
import { ClassNotesAccountService } from './classnotes-account.service';

/// ClassNotes' own accounts.
///
/// This module does NOT import `AuthModule`, even though it needs the same
/// `JwtService`: `AuthModule` imports this one (its `JwtStrategy` has to resolve
/// ClassNotes tokens), and importing back would be a cycle. It registers
/// `JwtModule` with the same secret and the same 90-day window instead, so a
/// token from either side verifies against the same key — which is exactly why
/// the payload has to carry `kind` to say which table owns it.
///
/// `EmailService` is dependency-free and is provided directly here, the way
/// `app.module` and `admin.module` already provide it.
@Module({
  imports: [
    PrismaModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET,
      signOptions: { expiresIn: '90d' },
    }),
  ],
  controllers: [ClassNotesAuthController],
  providers: [ClassNotesAccountService, EmailService],
  exports: [ClassNotesAccountService],
})
export class ClassNotesAuthModule {}
