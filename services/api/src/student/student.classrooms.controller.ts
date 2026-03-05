import { Controller, Get, Param, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';

@UseGuards(JwtAuthGuard)
@Roles(Role.STUDENT, Role.ADMIN)
@Controller('student/classrooms')
export class StudentClassroomsController {
  constructor(private readonly prisma: PrismaService) {}

  private async cohortIdFromUser(req: any): Promise<string> {
    const uid = String(req?.user?.sub ?? req?.user?.id ?? '');
    if (!uid) throw new Error('Missing user id');
    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: uid },
      select: { cohortId: true },
    });
    if (!sp?.cohortId) throw new Error('Student not onboarded');
    return String(sp.cohortId);
  }

  @Get()
  async list(@Req() req: any) {
    const cohortId = await this.cohortIdFromUser(req);

    const items = await this.prisma.course.findMany({
      where: { cohortId },
      orderBy: [{ subject: 'asc' }, { name: 'asc' }],
      select: {
        id: true,
        name: true,
        subject: true,
        teacherId: true,
        cohortId: true,
        groupTag: true,
      },
    });

    return items;
  }

  @Get(':id')
  async getOne(@Req() req: any, @Param('id') id: string) {
    const cohortId = await this.cohortIdFromUser(req);

    const course = await this.prisma.course.findFirst({
      where: { id, cohortId },
      select: {
        id: true,
        name: true,
        subject: true,
        teacherId: true,
        cohortId: true,
        groupTag: true,
      },
    });

    if (!course) return { ok: false, error: 'NOT_FOUND' };
    return { ok: true, item: course };
  }

  // TODO: real classroom feed
  @Get(':id/announcements')
  async announcements(@Req() req: any, @Param('id') id: string) {
    const cohortId = await this.cohortIdFromUser(req);

    // validate course belongs to cohort
    const course = await this.prisma.course.findFirst({
      where: { id, cohortId },
      select: { id: true },
    });
    if (!course) return { ok: false, error: 'NOT_FOUND' };

    // your Announcement model isn't course-scoped yet; return empty for now
    return { ok: true, items: [] as any[] };
  }

  @Get(':id/materials')
  async materials(@Req() req: any, @Param('id') id: string) {
    const cohortId = await this.cohortIdFromUser(req);

    const course = await this.prisma.course.findFirst({
      where: { id, cohortId },
      select: { id: true },
    });
    if (!course) return { ok: false, error: 'NOT_FOUND' };

    // your Material model likely isn't course-scoped yet; return empty for now
    return { ok: true, items: [] as any[] };
  }
}
