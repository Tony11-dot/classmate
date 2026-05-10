import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

type DayOfWeek = 0 | 1 | 2 | 3 | 4 | 5 | 6;

const PERIOD_TIME: Record<number, { start: string; end: string }> = {
  1: { start: '08:00', end: '08:45' },
  2: { start: '08:50', end: '09:35' },
  3: { start: '09:45', end: '10:30' },
  4: { start: '10:35', end: '11:20' },
  5: { start: '11:30', end: '12:15' },
  6: { start: '12:20', end: '13:05' },
  7: { start: '13:15', end: '14:00' },
  8: { start: '14:05', end: '14:50' },
  9: { start: '15:00', end: '15:45' },
  10: { start: '15:50', end: '16:35' },
};

function timesForPeriod(period: number): { startTime: string; endTime: string } {
  const t = PERIOD_TIME[Number(period)] ?? { start: '00:00', end: '00:00' };
  return { startTime: t.start, endTime: t.end };
}

@Injectable()
export class ClassroomsService {
  constructor(private readonly prisma: PrismaService) {}

  private async cohortIdForStudentUserId(userId: string): Promise<string> {
    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: String(userId) },
      select: { cohortId: true },
    });
    if (!sp?.cohortId) throw new BadRequestException('Student not onboarded');
    return String(sp.cohortId);
  }

  async listStudentClassrooms(studentUserId: string) {
    // Return cohorts the student belongs to directly (no course layer needed)
    const directLinks = await (this.prisma as any).studentCohort.findMany({
      where: { studentId: studentUserId },
      include: { cohort: true },
    });

    let cohorts: any[] = directLinks.map((l: any) => l.cohort);

    if (!cohorts.length) {
      const profile = await this.prisma.studentProfile.findUnique({
        where: { userId: studentUserId },
        include: { cohort: true },
      });
      if (profile?.cohort) cohorts = [profile.cohort];
    }

    return cohorts.map((c: any) => ({
      id: c.id,
      name: c.name,
      subject: null,
      teacherId: null,
      cohortId: c.id,
      grade: c.grade,
      groupTag: null,
    }));
  }

  async getStudentClassroom(studentUserId: string, cohortId: string) {
    const studentCohortId = await this.cohortIdForStudentUserId(studentUserId);

    const cohort = await (this.prisma as any).cohort.findUnique({
      where: { id: String(cohortId) },
      select: { id: true, name: true, grade: true },
    });
    if (!cohort || cohort.id !== studentCohortId) throw new BadRequestException('Invalid classroom id');

    const slotIds = (await this.prisma.scheduleSlotCohort.findMany({
      where: { cohortId: String(cohortId) },
      select: { slotId: true },
    })).map((r) => r.slotId);
    const tmpl = slotIds.length ? await this.prisma.scheduleSlot.findMany({
      where: { id: { in: slotIds } },
      orderBy: [{ dayOfWeek: 'asc' }, { period: 'asc' }],
      select: { id: true, dayOfWeek: true, period: true },
    }) : [];

    const template = tmpl.map((r) => {
      const { startTime, endTime } = timesForPeriod(Number(r.period));
      return {
        id: r.id,
        dayOfWeek: Number(r.dayOfWeek) as DayOfWeek,
        period: Number(r.period),
        startTime,
        endTime,
      };
    });

    return {
      id: cohort.id,
      name: cohort.name,
      grade: cohort.grade,
      cohortId: cohort.id,
      scheduleTemplate: template,
      announcements: [],
    };
  }
}
