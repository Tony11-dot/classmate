import { Module } from '@nestjs/common';
import { AuthModule } from '../auth.module';
import { PrismaModule } from '../../prisma/prisma.module';
import { MoeSsoController } from './moe-sso.controller';
import { MoeSsoService } from './moe-sso.service';

/**
 * Ministry of Education SSO. Imports AuthModule for AuthService.signSessionToken
 * (mint a ClassMate session for the authenticated user) and JwtModule (sign /
 * verify the CSRF state token). Inert until MOE_SSO_ENABLED=1 + config is set.
 */
@Module({
  imports: [AuthModule, PrismaModule],
  controllers: [MoeSsoController],
  providers: [MoeSsoService],
})
export class MoeSsoModule {}
