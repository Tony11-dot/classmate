import { PrismaModule } from '../prisma/prisma.module';
import { JwtStrategy } from './jwt.strategy';
import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

@Module({
  providers: [JwtStrategy, AuthService],
  imports: [
    PassportModule,
    PrismaModule,
    // JwtService injected into AuthService.login (signs) and JwtStrategy
    // (verifies). Default 90-day expiry matches the long-lived "stay signed
    // in" UX the mobile clients want.
    // env.ts (loadEnv) already refuses to boot without a >=16-char JWT_SECRET,
    // so there is no insecure literal fallback here — a missing secret is a
    // hard startup failure, never a silently-signed weak token.
    JwtModule.register({
      secret: process.env.JWT_SECRET,
      signOptions: { expiresIn: '90d' },
    }),
  ],
  controllers: [AuthController],
  exports: [AuthService, JwtModule],
})
export class AuthModule {}
