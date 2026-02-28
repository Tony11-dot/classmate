import { PrismaModule } from '../prisma/prisma.module';
import { JwtStrategy } from './jwt.strategy';
import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './auth.controller';

@Module({
  providers: [JwtStrategy],
  imports: [PassportModule, PrismaModule],
  controllers: [AuthController],
})
export class AuthModule {}
