import { Controller, Get, Query } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { Public } from '../auth/decorators/public.decorator';
import { PrismaService } from '../prisma/prisma.service';

@Controller()
@SkipThrottle({ global: true, auth: true })
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  // Liveness: process is up
  @Public()
  @Get('health')
  health() {
    return { ok: true };
  }

  // TEMP diagnostic — meetings-empty bug. Remove after fix.
  @Public()
  @Get('diag-meetings')
  async diagMeetings(@Query('uid') uid?: string) {
    const total = await this.prisma.teacherMeeting.count();
    const everyone = await this.prisma.teacherMeeting.count({
      where: { targetType: 'EVERYONE' as any },
    });
    const recent = await this.prisma.teacherMeeting.findMany({
      orderBy: { createdAt: 'desc' },
      take: 5,
      select: { id: true, title: true, targetType: true, targetStudentIds: true, createdAt: true },
    });
    let matchedForUid: number | null = null;
    if (uid) {
      const rows = await this.prisma.teacherMeeting.findMany({
        where: {
          OR: [{ targetType: 'EVERYONE' as any }, { targetStudentIds: { has: uid } }],
        },
        select: { id: true },
      });
      matchedForUid = rows.length;
    }
    return { marker: 'diag-v1', total, everyone, matchedForUid, recent };
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
