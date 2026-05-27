import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { Body, Controller, Get, Post, Query, Req, UseGuards } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import {
  StudentScheduleTodayResponseSchema,
  StudentScheduleWeekQuerySchema,
  StudentScheduleWeekResponseSchema,
} from '../contracts/student.contract';
import {
  StudentOnboardBodySchema,
  StudentParentLinkCodeBodySchema,
} from '../contracts/student.onboard.contract';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { StudentService } from './student.service';
import { OnboardStudentDto } from './dto/onboard-student.dto';

@UseGuards(JwtAuthGuard)
@Roles(Role.STUDENT, Role.ADMIN)
@Controller('student')
export class StudentController {
  constructor(private readonly student: StudentService) {}

  @Post('onboard')
  async onboard(@Req() req: any, @Body() body: any) {
    const b = StudentOnboardBodySchema.parse(body);
    return this.student.onboard(req.user, b);
  }

  // Lists every cohort the calling student belongs to (via StudentCohort
  // many-to-many). Profile screen renders these as chips so the student
  // can see their full cohort membership, not just the primary cohort
  // that /auth/me returns.
  @Get('cohorts')
  async myCohorts(@Req() req: any) {
    return this.student.myCohorts(req.user);
  }

  @Post('parent-link-code')
  async parentLinkCode(@Req() req: any, @Body() body: any) {
    const b = StudentParentLinkCodeBodySchema.parse(body ?? {});
    return this.student.generateParentLinkCode(req.user, b);
  }

  @SkipThrottle()
  @Get('schedule/today')
  async today(@Req() req: any) {
    const out = await this.student.todaySchedule(req.user);

    const date = new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Jerusalem' }).format(new Date());

    const items = (Array.isArray(out) ? out : []).map((x: any) => ({
      id: String(x?.id ?? ''),
      startsAt: String(x?.startTime ?? ''),
      endsAt: String(x?.endTime ?? ''),
      title: String(x?.title ?? ''),
      period: x?.period ?? null,
      location: x?.location ?? null,
      cohortId: x?.cohortId ?? null,
      subject: x?.subject ?? null,
    }));

    return StudentScheduleTodayResponseSchema.parse({ ok: true, items: { date, items } });
  }

  @SkipThrottle()
  @Get('schedule/week')
  async week(@Req() req: any, @Query('weekOf') weekOfParam?: string) {
    // Pass the client-supplied weekOf through to the service so scrolling
    // to a different week actually fetches that week.  Previously this
    // method ignored the query param entirely, computed "today's week"
    // server-side, and returned the SAME week regardless of what the
    // client asked for — which is why scrolling to May 24 (or any other
    // week) showed days whose dates didn't match anything in the response.
    const out = await this.student.weekSchedule(req.user, weekOfParam);
    const rows = Array.isArray(out) ? out : [];

    // weekOf for the 7-day fill — honor the client's request if it sent
    // a YYYY-MM-DD-shaped value, otherwise fall back to today's week.
    const clientYmd = (weekOfParam ?? '').trim();
    const useClient = /^\d{4}-\d{2}-\d{2}$/.test(clientYmd);
    let weekOf: string;
    if (useClient) {
      weekOf = clientYmd;
    } else {
      const todayYmd = new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Jerusalem' }).format(new Date());
      const todayUtcMidnight = new Date(todayYmd + 'T00:00:00.000Z');
      const wk = new Intl.DateTimeFormat('en-US', { timeZone: 'Asia/Jerusalem', weekday: 'short' }).format(todayUtcMidnight);
      const map: Record<string, number> = { Sun: 0, Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6 };
      const dow = map[wk] ?? 0;
      const weekStart = new Date(todayUtcMidnight.getTime());
      weekStart.setUTCDate(weekStart.getUTCDate() - dow);
      weekOf = new Intl.DateTimeFormat('en-CA', { timeZone: 'UTC', year: 'numeric', month: '2-digit', day: '2-digit' }).format(weekStart);
    }

    // group by date (YYYY-MM-DD)
    const byDate = new Map<string, any[]>();
    for (const r of rows) {
      const d = String((r as any)?.date ?? '');
      const arr = byDate.get(d) ?? [];
      arr.push(r);
      byDate.set(d, arr);
    }

    // Always return 7 days starting from weekOf (UTC date string), even if empty
    const fillStart = new Date(weekOf + 'T00:00:00.000Z');
    const days = Array.from({ length: 7 }).map((_, i) => {
      const d = new Date(fillStart.getTime());
      d.setUTCDate(d.getUTCDate() + i);
      const date = new Intl.DateTimeFormat('en-CA', { timeZone: 'UTC', year: 'numeric', month: '2-digit', day: '2-digit' }).format(d);

      const items = (byDate.get(date) ?? []).map((x: any) => ({
        id: String(x?.id ?? ''),
        startsAt: String(x?.startTime ?? x?.startsAt ?? ''),
        endsAt: String(x?.endTime ?? x?.endsAt ?? ''),
        title: String(x?.title ?? ''),
        period: x?.period ?? null,
        location: x?.location ?? null,
        cohortId: x?.cohortId ?? null,
        subject: x?.subject ?? null,
        // The previous shape stripped these — the schedule tile reads
        // teacherName for the subtitle, caption for the header row,
        // and attachments for the "N materials" pill + detail-sheet
        // pill list. Without them the tile rendered only time + period
        // + subject even though the underlying resolver populated the
        // rest correctly.
        teacherName: x?.teacherName ?? null,
        teacherId: x?.teacherId ?? null,
        caption: x?.caption ?? null,
        classroomId: x?.classroomId ?? null,
        date: x?.date ?? date,
        attachments: Array.isArray(x?.attachments) ? x.attachments : [],
      }));

      return { date, items };
    });

    return StudentScheduleWeekResponseSchema.parse({ ok: true, items: { weekOf, days } });
  }

@SkipThrottle()
  @Get('assessments')
  assessments(@Req() req: any) {
    return this.student.myAssessments(req.user);
  }

@Get('grades')
  grades(@Req() req: any) {
    return this.student.myGrades(req.user);
  }

  @Get('insights')
  insights(@Req() req: any) {
    return this.student.getInsights(req.user);
  }

  @Get('subjects')
  subjects(@Req() req: any) {
    return this.student.mySubjects(req.user);
  }

  @SkipThrottle()
  @Get('exams')
  exams(@Req() req: any) {
    return this.student.myExams(req.user);
  }

  @SkipThrottle()
  @Get('assignments')
  assignments(@Req() req: any) {
    return this.student.myTeacherAssignments(req.user);
  }

  @SkipThrottle()
  @Get('diplomas')
  diplomas(@Req() req: any) {
    return this.student.myDiplomas(req.user);
  }

}
