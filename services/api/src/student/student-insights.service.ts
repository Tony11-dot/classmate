import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { PracticeService } from '../practice/practice.service';
import type {
  StudentInsightsAttendanceItem,
  StudentInsightsAttendanceSummary,
  StudentInsightsGradeItem,
  StudentInsightsGradesSummary,
  StudentInsightsPracticeSummary,
  StudentInsightsPracticeTrend,
  StudentInsightsResponse,
} from './student-insights.types';

@Injectable()
export class StudentInsightsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly practiceService: PracticeService,
  ) {}

  private ymd(value: Date | string | null | undefined): string | null {
    if (!value) return null;
    const d = value instanceof Date ? value : new Date(value);
    if (Number.isNaN(d.getTime())) return null;
    return new Intl.DateTimeFormat('en-CA', { timeZone: 'UTC' }).format(d);
  }

  private avg(nums: number[]): number | null {
    if (!nums.length) return null;
    const sum = nums.reduce((a, b) => a + b, 0);
    return Number((sum / nums.length).toFixed(1));
  }

  private summarizeGrades(rows: any[]): StudentInsightsGradesSummary {
    const latest: StudentInsightsGradeItem[] = rows.slice(0, 6).map((r) => ({
      id: String(r.id),
      subject: String(r.assessment?.course?.subject ?? ''),
      courseName: String(r.assessment?.course?.name ?? ''),
      assessmentTitle: String(r.assessment?.title ?? ''),
      grade: Number(r.grade ?? 0),
      date: this.ymd(r.assessment?.date),
    }));

    const allGrades = rows
      .map((r) => Number(r.grade))
      .filter((n) => Number.isFinite(n));

    const bySubject = new Map<string, number[]>();
    for (const row of rows) {
      const subject = String(row.assessment?.course?.subject ?? '').trim();
      const grade = Number(row.grade ?? 0);
      if (!subject || !Number.isFinite(grade)) continue;
      const bucket = bySubject.get(subject) ?? [];
      bucket.push(grade);
      bySubject.set(subject, bucket);
    }

    let bestSubject: string | null = null;
    let weakestSubject: string | null = null;
    let bestAvg = -1;
    let weakAvg = 101;

    for (const [subject, grades] of bySubject.entries()) {
      const subjectAvg = this.avg(grades);
      if (subjectAvg == null) continue;
      if (subjectAvg > bestAvg) {
        bestAvg = subjectAvg;
        bestSubject = subject;
      }
      if (subjectAvg < weakAvg) {
        weakAvg = subjectAvg;
        weakestSubject = subject;
      }
    }

    return {
      count: rows.length,
      average: this.avg(allGrades),
      latest,
      bestSubject,
      weakestSubject,
    };
  }

  private buildTrendWindow(label: '7d' | '30d', rows: any[]): StudentInsightsPracticeTrend['last7d'] {
    const attempts = rows.length;
    const correct = rows.filter((row) => row?.isCorrect === true).length;
    const accuracy =
      attempts > 0
        ? Number(((correct / attempts) * 100).toFixed(1))
        : null;

    return {
      label,
      attempts,
      correct,
      accuracy,
    };
  }

  private summarizePracticeTrend(rows: any[]): StudentInsightsPracticeTrend {
    const now = Date.now();
    const dayMs = 24 * 60 * 60 * 1000;

    const rows7d = rows.filter((row) => {
      const createdAt = new Date(row?.createdAt ?? 0).getTime();
      return Number.isFinite(createdAt) && now - createdAt <= 7 * dayMs;
    });

    const rows30d = rows.filter((row) => {
      const createdAt = new Date(row?.createdAt ?? 0).getTime();
      return Number.isFinite(createdAt) && now - createdAt <= 30 * dayMs;
    });

    const last7d = this.buildTrendWindow('7d', rows7d);
    const last30d = this.buildTrendWindow('30d', rows30d);

    const deltaAccuracy =
      last7d.accuracy == null || last30d.accuracy == null
        ? null
        : Number((last7d.accuracy - last30d.accuracy).toFixed(1));

    return {
      last7d,
      last30d,
      deltaAccuracy,
    };
  }

  private summarizeAttendance(rows: any[]): StudentInsightsAttendanceSummary {
    const latest: StudentInsightsAttendanceItem[] = rows.slice(0, 8).map((r) => ({
      date: this.ymd(r.session?.date) ?? '',
      period: Number(r.session?.period ?? 0),
      status: String(r.status ?? ''),
      subject: r.session?.course?.subject ? String(r.session.course.subject) : null,
      courseName: r.session?.course?.name ? String(r.session.course.name) : null,
    }));

    const total = rows.length;
    let present = 0;
    let absent = 0;
    let late = 0;
    let justified = 0;

    for (const row of rows) {
      const status = String(row.status ?? '').toUpperCase();
      if (status === 'PRESENT') present += 1;
      else if (status === 'ABSENT') absent += 1;
      else if (status === 'LATE') late += 1;
      else if (status === 'JUSTIFIED') justified += 1;
    }

    const attendanceRate =
      total > 0 ? Number((((present + late + justified) / total) * 100).toFixed(1)) : null;

    return {
      total,
      present,
      absent,
      late,
      justified,
      attendanceRate,
      latest,
    };
  }

  async getStudentInsights(user: any): Promise<StudentInsightsResponse> {
    const studentId = String(user?.sub ?? user?.id ?? '');

    const profile = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
      select: { userId: true },
    });

    if (!profile) {
      return {
        ok: true,
        studentId,
        generatedAt: new Date().toISOString(),
        grades: {
          count: 0,
          average: null,
          latest: [],
          bestSubject: null,
          weakestSubject: null,
        },
        attendance: {
          total: 0,
          present: 0,
          absent: 0,
          late: 0,
          justified: 0,
          attendanceRate: null,
          latest: [],
        },
        practice: {
          totalSessions: 0,
          totalAttempts: 0,
          totalCorrect: 0,
          overallAccuracy: 0,
          weakTopics: [],
          strongestTopics: [],
        },
      };
    }

    const [gradeRows, attendanceRows, practiceAttemptRows] = await Promise.all([
      this.prisma.gradeRecord.findMany({
        where: { studentId },
        orderBy: [{ assessment: { date: 'desc' } }, { id: 'desc' }],
        include: {
          assessment: {
            include: {
              course: true,
            },
          },
        },
      }),
      this.prisma.attendanceRecord.findMany({
        where: { studentId },
        orderBy: [{ session: { date: 'desc' } }, { session: { period: 'asc' } }],
        include: {
          session: {
            include: {
              course: true,
            },
          },
        },
      }),
      this.prisma.practiceAttempt.findMany({
        where: { userId: studentId },
        orderBy: [{ createdAt: 'desc' }],
        select: {
          createdAt: true,
          isCorrect: true,
        },
      }),
    ]);

    const practice =
      (await this.practiceService.getProgressSummary(
        studentId,
      )) as StudentInsightsPracticeSummary;

    return {
      ok: true,
      studentId,
      generatedAt: new Date().toISOString(),
      grades: this.summarizeGrades(gradeRows),
      attendance: this.summarizeAttendance(attendanceRows),
      practice: {
        ...practice,
        trend: this.summarizePracticeTrend(practiceAttemptRows),
      },
    };
  }
}
