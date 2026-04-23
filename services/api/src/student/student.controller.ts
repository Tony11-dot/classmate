import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
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
      courseId: x?.courseId ?? null,
      subject: x?.subject ?? null,
    }));

    return StudentScheduleTodayResponseSchema.parse({ ok: true, items: { date, items } });
  }

  @SkipThrottle()
  @Get('schedule/week')
  async week(@Req() req: any) {
    const out = await this.student.weekSchedule(req.user);
    const rows = Array.isArray(out) ? out : [];

    // weekOf: start-of-week (Sunday) in Asia/Jerusalem
    const todayYmd = new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Jerusalem' }).format(new Date());
    const todayUtcMidnight = new Date(todayYmd + 'T00:00:00.000Z');

    const wk = new Intl.DateTimeFormat('en-US', { timeZone: 'Asia/Jerusalem', weekday: 'short' }).format(todayUtcMidnight);
    const map: Record<string, number> = { Sun: 0, Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6 };
    const dow = map[wk] ?? 0;

    const weekStart = new Date(todayUtcMidnight.getTime());
    weekStart.setUTCDate(weekStart.getUTCDate() - dow);

    const weekOf = new Intl.DateTimeFormat('en-CA', { timeZone: 'UTC', year: 'numeric', month: '2-digit', day: '2-digit' }).format(weekStart);

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
        startsAt: String(x?.startTime ?? ''),
        endsAt: String(x?.endTime ?? ''),
        title: String(x?.title ?? ''),
        period: x?.period ?? null,
        location: x?.location ?? null,
        courseId: x?.courseId ?? null,
        subject: x?.subject ?? null,
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

}
