import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class BrainService {
  constructor(private readonly prisma: PrismaService) {}

  private async ensureStudentProfile(studentId: string) {
    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
      select: { userId: true, cohortId: true },
    });
    return sp; // may be null
  }

  async getBrainMe(studentId: string) {
    if (!studentId) return { ok: true, studentId: '', profile: null, summary: null, topSkills: [] };

    await this.ensureStudentProfile(studentId);

    const [profile, summary, skills] = await Promise.all([
      this.prisma.studentBrainProfile.findUnique({ where: { studentId } }),
      this.prisma.studentBrainSummary.findUnique({ where: { studentId } }),
      this.prisma.studentBrainSkill.findMany({
        where: { studentId },
        orderBy: [{ updatedAt: 'desc' }],
        take: 12,
      }),
    ]);

    return { ok: true, studentId, profile, summary, topSkills: skills };
  }

  async recordEvent(args: {
    studentId: string;
    type: any;
    subject?: string | null;
    topic?: string | null;
    payload?: string | null;
    tutorSessionId?: string | null;
    tutorMessageId?: string | null;
  }) {
    const studentId = String(args.studentId ?? '').trim();
    if (!studentId) return { ok: true };

    const sp = await this.ensureStudentProfile(studentId);

    const created = await this.prisma.studentBrainEvent.create({
      data: {
        id: undefined as any,
        studentId,
        type: args.type,
        subject: args.subject ?? null,
        topic: args.topic ?? null,
        payload: args.payload ?? null,
        tutorSessionId: args.tutorSessionId ?? null,
        tutorMessageId: args.tutorMessageId ?? null,
      },
      select: { id: true, createdAt: true },
    });

    // keep lastEventAt fresh (summary may or may not exist yet)
    await this.prisma.studentBrainSummary.upsert({
      where: { studentId },
      create: {
        studentId,
        summary: 'No brain data yet.',
        lastEventAt: created.createdAt,
      },
      update: { lastEventAt: created.createdAt },
    });

    return { ok: true, eventId: created.id, cohortId: sp?.cohortId ?? null };
  }

  async rebuildSummary(studentId: string) {
    const sid = String(studentId ?? '').trim();
    if (!sid) return { ok: true, studentId: '', summary: 'No brain data yet.' };

    await this.ensureStudentProfile(sid);

    const events = await this.prisma.studentBrainEvent.findMany({
      where: { studentId: sid },
      orderBy: [{ createdAt: 'desc' }],
      take: 80,
      select: { type: true, subject: true, topic: true, payload: true, createdAt: true },
    });

    const topTopics: Record<string, number> = {};
    const recentMistakes: string[] = [];

    for (const e of events) {
      const key = [e.subject ?? 'General', e.topic ?? ''].filter(Boolean).join(':');
      if (key) topTopics[key] = (topTopics[key] ?? 0) + 1;

      const t = String(e.type ?? '').toUpperCase();
      if (t === 'MISTAKE' || t === 'CONFUSION') {
        const p = (e.payload ?? '').trim();
        if (p) recentMistakes.push(p);
      }
    }

    const top = Object.entries(topTopics).sort((a, b) => b[1] - a[1]).slice(0, 8);

    const lines: string[] = [];
    lines.push(`Student focus (recent): ${top.map(([k]) => k).join(', ') || 'n/a'}`);
    if (recentMistakes.length) lines.push(`Recent confusions/mistakes: ${recentMistakes.slice(0, 5).join(' | ')}`);

    const profile = await this.prisma.studentBrainProfile.findUnique({ where: { studentId: sid } });
    if (profile?.baselineSummary?.trim()) lines.push(`Baseline: ${profile.baselineSummary.trim()}`);

    const summaryText = lines.join('\n').trim() || 'No brain data yet.';

    const saved = await this.prisma.studentBrainSummary.upsert({
      where: { studentId: sid },
      create: { studentId: sid, summary: summaryText, lastEventAt: events[0]?.createdAt ?? null },
      update: { summary: summaryText, lastEventAt: events[0]?.createdAt ?? null },
    });

    return { ok: true, studentId: sid, summary: saved.summary };
  }

  async getSummaryForPrompt(studentId: string) {
    const sid = String(studentId ?? '').trim();
    if (!sid) return { ok: true, studentId: '', summary: '' };
    const row = await this.prisma.studentBrainSummary.findUnique({ where: { studentId: sid } });
    return { ok: true, studentId: sid, summary: row?.summary ?? '' };
  }
}
