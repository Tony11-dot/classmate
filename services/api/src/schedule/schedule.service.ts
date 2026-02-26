import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
type DayOfWeek = 'SUN'|'MON'|'TUE'|'WED'|'THU'|'FRI'|'SAT';

export type ScheduleItem = {
  id: string;
  title: string;
  location: string | null;
  dayOfWeek: DayOfWeek;
  startTime: string;
  endTime: string;
  classroomId: string | null;
};

@Injectable()
export class ScheduleService {
  constructor(private readonly prisma: PrismaService) {}

  private todayDow(): DayOfWeek {
    // JS: 0=Sun..6=Sat
    const map: DayOfWeek[] = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return map[new Date().getDay()];
  }

  private async listByStudentId(studentId: string): Promise<ScheduleItem[]> {
    const prisma: any = this.prisma as any;

    if (prisma.studentScheduleItem?.findMany) {
      const rows = await prisma.studentScheduleItem.findMany({
        where: { studentId },
        select: {
          id: true,
          title: true,
          location: true,
          dayOfWeek: true,
          startTime: true,
          endTime: true,
          classroomId: true,
        },
        orderBy: [{ dayOfWeek: 'asc' }, { startTime: 'asc' }],
      });

      return rows.map((r: any) => ({
        id: String(r.id),
        title: String(r.title),
        location: r.location ?? null,
        dayOfWeek: r.dayOfWeek,
        startTime: String(r.startTime),
        endTime: String(r.endTime),
        classroomId: r.classroomId ? String(r.classroomId) : null,
      }));
    }

    if (prisma.scheduleItem?.findMany) {
      const rows = await prisma.scheduleItem.findMany({
        where: { studentId },
        select: {
          id: true,
          title: true,
          location: true,
          dayOfWeek: true,
          startTime: true,
          endTime: true,
          classroomId: true,
        },
        orderBy: [{ dayOfWeek: 'asc' }, { startTime: 'asc' }],
      });

      return rows.map((r: any) => ({
        id: String(r.id),
        title: String(r.title),
        location: r.location ?? null,
        dayOfWeek: r.dayOfWeek,
        startTime: String(r.startTime),
        endTime: String(r.endTime),
        classroomId: r.classroomId ? String(r.classroomId) : null,
      }));
    }

    return [];
  }

  private async listByCohortId(cohortId: string): Promise<ScheduleItem[]> {
    const prisma: any = this.prisma as any;

    // Most likely: scheduleItem has cohortId
    if (prisma.scheduleItem?.findMany) {
      const rows = await prisma.scheduleItem.findMany({
        where: { cohortId },
        select: {
          id: true,
          title: true,
          location: true,
          dayOfWeek: true,
          startTime: true,
          endTime: true,
          classroomId: true,
        },
        orderBy: [{ dayOfWeek: 'asc' }, { startTime: 'asc' }],
      });

      return rows.map((r: any) => ({
        id: String(r.id),
        title: String(r.title),
        location: r.location ?? null,
        dayOfWeek: r.dayOfWeek,
        startTime: String(r.startTime),
        endTime: String(r.endTime),
        classroomId: r.classroomId ? String(r.classroomId) : null,
      }));
    }

    // Fallback: cohortScheduleItem
    if (prisma.cohortScheduleItem?.findMany) {
      const rows = await prisma.cohortScheduleItem.findMany({
        where: { cohortId },
        select: {
          id: true,
          title: true,
          location: true,
          dayOfWeek: true,
          startTime: true,
          endTime: true,
          classroomId: true,
        },
        orderBy: [{ dayOfWeek: 'asc' }, { startTime: 'asc' }],
      });

      return rows.map((r: any) => ({
        id: String(r.id),
        title: String(r.title),
        location: r.location ?? null,
        dayOfWeek: r.dayOfWeek,
        startTime: String(r.startTime),
        endTime: String(r.endTime),
        classroomId: r.classroomId ? String(r.classroomId) : null,
      }));
    }

    return [];
  }

  // Existing API used by classrooms/session work
  async listForStudent(studentId: string): Promise<ScheduleItem[]> {
    return this.listByStudentId(studentId);
  }

  // REQUIRED by existing student/parent modules
  async getTodayForCohort(cohortId: string): Promise<ScheduleItem[]> {
    const all = await this.listByCohortId(String(cohortId));
    const dow = this.todayDow();
    return all.filter((x) => x.dayOfWeek === dow);
  }

  // REQUIRED by existing student/parent modules
  async getWeekForCohort(cohortId: string, _weekOf?: string): Promise<ScheduleItem[]> {
    // Keep it simple: return cohort weekly schedule ordered by day/time.
    // (_weekOf can be used later if you add dated schedules.)
    return this.listByCohortId(String(cohortId));
  }
}
