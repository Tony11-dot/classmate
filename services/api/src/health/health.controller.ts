import { Controller, Get } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { Public } from '../auth/decorators/public.decorator';
import { PrismaService } from '../prisma/prisma.service';

@Controller()
// Bucket names must match ThrottlerModule.forRoot — the old '{ global: true }'
// referenced a bucket that doesn't exist, leaving 'default' still enforced.
@SkipThrottle({ default: true, auth: true })
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  // Liveness: process is up
  @Public()
  @Get('health')
  health() {
    return { ok: true };
  }

  // Readiness: dependencies are reachable (DB)
  @Public()
  @Get('ready')
  async ready() {
    // lightweight DB ping
    await this.prisma.$queryRaw`SELECT 1`;
    return { ok: true };
  }
}
