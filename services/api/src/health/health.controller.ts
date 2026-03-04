import { Controller, Get } from '@nestjs/common';
import { Public } from '../auth/decorators/public.decorator';
import { PrismaService } from '../prisma/prisma.service';

@Controller()
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
