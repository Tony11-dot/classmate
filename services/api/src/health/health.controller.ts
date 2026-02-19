import { Controller, Get } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Controller()
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  // Liveness: process is up
  @Get('health')
  health() {
    return { ok: true };
  }

  // Readiness: dependencies are reachable (DB)
  @Get('ready')
  async ready() {
    // lightweight DB ping
    await this.prisma.$queryRaw`SELECT 1`;
    return { ok: true };
  }
}
