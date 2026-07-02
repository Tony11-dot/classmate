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
    // Full history (ordered newest-first): the Grades tab paginates this with
    // its own show-more/less UI, so return the whole list rather than a small
    // preview. The Insights dashboard independently takes only the top few.
    const latest: StudentInsightsGradeItem[] = rows.slice(0, 400).map((r) => {
      const wp = Array.isArray(r.assessment?.weightPercents) ? (r.assessment.weightPercents as number[]) : [];
      const single = r.assessment?.weightPercent;
      return {
        id: String(r.id),
        subject: String(r.assessment?.subject ?? ''),
        assessmentTitle: String(r.assessment?.title ?? ''),
        grade: Number(r.grade ?? 0),
        date: this.ymd(r.assessment?.date),
        maxGrade: r.assessment?.maxGrade != null ? Number(r.assessment.maxGrade) : null,
        label: r.label != null && String(r.label).trim() !== '' ? String(r.label) : null,
        weightPercents: wp.length ? wp : single != null ? [Number(single)] : [],
        semester: r.assessment?.semester != null ? Number(r.assessment.semester) : null,
      };
    });

    const allGrades = rows
      .map((r) => Number(r.grade))
      .filter((n) => Number.isFinite(n));

    const bySubject = new Map<string, number[]>();
    for (const row of rows) {
      const subject = String(row.assessment?.subject ?? '').trim();
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
    // Full history (newest-first): the Attendance tab's range filters
    // (7d/30d/90d/all) and per-day grouping operate on this list, so it must
    // carry the full record set, not just a small preview.
    const latest: StudentInsightsAttendanceItem[] = rows.slice(0, 1000).map((r) => ({
      date: this.ymd(r.session?.date) ?? '',
      period: Number(r.session?.period ?? 0),
      status: String(r.status ?? ''),
      subject: null,
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

  /// `overrideStudentId` lets a verified caller (e.g. a parent who's
  /// already passed requireParentChild()) ask for another student's
  /// insights without impersonating them at the JWT layer.
  async getStudentInsights(user: any, overrideStudentId?: string): Promise<StudentInsightsResponse> {
    const studentId = overrideStudentId?.trim()
      ? overrideStudentId.trim()
      : String(user?.sub ?? user?.id ?? '');

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

    // Each query is independently fault-tolerant: a transient failure in one
    // (e.g. attendance) must NOT blank out the others. Previously a single
    // rejected query rejected the whole endpoint, so the Grades tab would
    // intermittently render empty and only repopulate on a later refresh —
    // the "grades disappear, refresh a few times, they come back" bug.
    const [gradeRows, assignmentGradeRows, attendanceRows, practiceAttemptRows] =
      await Promise.all([
        this.prisma.gradeRecord
          .findMany({
            // Per-student publish: only show grades published to this student
            // (drafts stay hidden). `not: false` keeps legacy rows visible.
            where: { studentId, published: { not: false } },
            orderBy: [{ assessment: { date: 'desc' } }, { id: 'desc' }],
            include: { assessment: true },
          })
          .catch(() => [] as any[]),
        // Graded teacher-assignments belong in the Grades tab too. Mirror the
        // /student/grades merge so both endpoints agree (the inconsistency was
        // a second cause of grades appearing in one place but not the other).
        this.prisma.teacherAssignmentSubmission
          .findMany({
            where: { studentId, grade: { not: null }, status: 'GRADED' },
            orderBy: { gradedAt: 'desc' },
            include: {
              assignment: { select: { id: true, title: true, subject: true } },
            },
          })
          .catch(() => [] as any[]),
        this.prisma.attendanceRecord
          .findMany({
            where: { studentId },
            orderBy: [{ session: { date: 'desc' } }, { session: { period: 'asc' } }],
            include: { session: { include: {} } },
          })
          .catch(() => [] as any[]),
        this.prisma.practiceAttempt
          .findMany({
            where: { userId: studentId },
            orderBy: [{ createdAt: 'desc' }],
            select: { createdAt: true, isCorrect: true },
          })
          .catch(() => [] as any[]),
      ]);

    // Normalize graded assignments into the same shape summarizeGrades reads,
    // then merge with assessment grades, newest-first.
    const assignmentAsGrades = (assignmentGradeRows as any[]).map((s) => ({
      id: `asn-${s.id}`,
      grade: s.grade,
      assessment: {
        id: `assignment-${s.assignment?.id ?? s.assignmentId}`,
        title: s.assignment?.title ?? 'Assignment',
        subject: s.assignment?.subject ?? null,
        date: s.gradedAt ?? s.submittedAt,
      },
    }));
    const mergedGradeRows = [...(gradeRows as any[]), ...assignmentAsGrades].sort(
      (a, b) => {
        const ad = new Date(a.assessment?.date ?? 0).getTime();
        const bd = new Date(b.assessment?.date ?? 0).getTime();
        return bd - ad;
      },
    );

    let practice: StudentInsightsPracticeSummary;
    try {
      practice = (await this.practiceService.getProgressSummary(
        studentId,
      )) as StudentInsightsPracticeSummary;
    } catch {
      practice = {
        totalSessions: 0,
        totalAttempts: 0,
        totalCorrect: 0,
        overallAccuracy: 0,
        weakTopics: [],
        strongestTopics: [],
      } as StudentInsightsPracticeSummary;
    }

    return {
      ok: true,
      studentId,
      generatedAt: new Date().toISOString(),
      grades: this.summarizeGrades(mergedGradeRows),
      attendance: this.summarizeAttendance(attendanceRows),
      practice: {
        ...practice,
        trend: this.summarizePracticeTrend(practiceAttemptRows),
      },
    };
  }
}
