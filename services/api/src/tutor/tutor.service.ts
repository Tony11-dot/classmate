import { TutorReplyMode, generateAssistantReplyStream } from './tutor.reply.provider';
import { BadRequestException, ForbiddenException, HttpException, HttpStatus, Injectable } from '@nestjs/common';

function toTutorRole(raw: any) {
  const v = String(raw ?? '').trim().toUpperCase();
  if (v in ({ USER:1, ASSISTANT:1, SYSTEM:1 })) return v;
  if (v in ({ U:1, HUMAN:1 })) return 'USER';
  if (v in ({ A:1, BOT:1, AI:1 })) return 'ASSISTANT';
  if (v in ({ S:1 })) return 'SYSTEM';

  // common lowercase inputs
  const lc = String(raw ?? '').trim().toLowerCase();
  if (lc == 'user') return 'USER';
  if (lc == 'assistant') return 'ASSISTANT';
  if (lc == 'system') return 'SYSTEM';

  return 'USER';
}

import type { MessageEvent } from '@nestjs/common';
import { Observable } from 'rxjs';
import { basicTutorSafetyCheck } from './tutor.reply.safety';
import { normalizeQuestion, cacheTtlMs } from './tutor.reply.cache';
import { hasAnyRole } from '../auth/permissions';
import { PrismaService } from '../prisma/prisma.service';
import { StudentInsightsService } from '../student/student-insights.service';

@Injectable()
export class TutorService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly studentInsightsService: StudentInsightsService,
  ) {}

  private replyRateStore = new Map<string, number[]>();

  private async buildAcademicContextBlock(user: any) {
    try {
      const insights = await this.studentInsightsService.getStudentInsights(user);
      const grades = insights?.grades;
      const attendance = insights?.attendance;
      const practice = insights?.practice;
      const weakTopic =
        Array.isArray(practice?.weakTopics) && practice.weakTopics.length
          ? practice.weakTopics[0]
          : null;
      const strongTopic =
        Array.isArray(practice?.strongestTopics) && practice.strongestTopics.length
          ? practice.strongestTopics[0]
          : null;

      return {
        ok: true,
        summary: {
          gradeAverage: grades?.average ?? null,
          bestSubject: grades?.bestSubject ?? null,
          weakestSubject: grades?.weakestSubject ?? null,
          attendanceRate: attendance?.attendanceRate ?? null,
          totalPracticeAttempts: practice?.totalAttempts ?? 0,
          overallPracticeAccuracy:
            typeof practice?.overallAccuracy === 'number'
              ? Number((practice.overallAccuracy * 100).toFixed(1))
              : null,
          weakTopic: weakTopic
            ? {
                subject: weakTopic.subject,
                topicLabel: weakTopic.topicLabel,
                accuracy:
                  typeof weakTopic.accuracy === 'number'
                    ? Number((weakTopic.accuracy * 100).toFixed(1))
                    : null,
              }
            : null,
          strongTopic: strongTopic
            ? {
                subject: strongTopic.subject,
                topicLabel: strongTopic.topicLabel,
                accuracy:
                  typeof strongTopic.accuracy === 'number'
                    ? Number((strongTopic.accuracy * 100).toFixed(1))
                    : null,
              }
            : null,
          trend: practice?.trend ?? null,
        },
        raw: insights,
      };
    } catch {
      return {
        ok: false,
        summary: null,
        raw: null,
      };
    }
  }

  private async buildAcademicContextPrompt(user: any) {
    const ctx = await this.buildAcademicContextBlock(user);
    if (!ctx?.ok || !ctx.summary) {
      return '';
    }

    return [
      '=== UNIFIED ACADEMIC CONTEXT ===',
      JSON.stringify(ctx.summary, null, 2),
      '- Use this context to personalize explanations, priorities, and examples.',
      '- If grades are weak in a subject, lean toward fundamentals and confidence-building.',
      '- If attendance is low, keep the plan realistic and concise.',
      '- If a weak practice topic exists, bias examples and mini-quizzes toward it.',
      '- Keep the response grounded in the actual context above; do not invent student data.',
    ].join('\n');
  }

  async getMyAcademicContext(user: any) {
    return this.buildAcademicContextBlock(user);
  }


  private buildRefsAndExcerpt(materials: any[]) {
    const refs = materials?.length
      ? materials
          .map((m) => String(m.title ?? ''))
          .slice(0, 5)
          .join(' | ')
      : '(no materials found)';
    const excerpt = materials?.length
      ? String(materials[0].content ?? '').slice(0, 260)
      : '';
    return { refs, excerpt };
  }

  private generateMiniQuiz(args: {
    subject?: string;
    topic?: string;
    verbosity?: number;
  }) {
    const subject = String(args.subject ?? 'GENERAL').toUpperCase();
    const topic = String(args.topic ?? 'general').toLowerCase();
    const v = Number(args.verbosity ?? 6);
    const easy = v <= 4;

    if (subject.includes('MATH')) {
      if (topic === 'derivatives') {
        return easy
          ? [
              'Mini-quiz: What is d/dx(x^2)?',
              'Mini-quiz: What is the slope (derivative) of a constant function?',
            ]
          : [
              'Mini-quiz: Differentiate f(x)=3x^3−2x. Show steps.',
              "Mini-quiz: If f'(a)=0, what can that mean about the graph at x=a?",
            ];
      }
      return easy
        ? [
            'Mini-quiz: Solve 2x+5=13.',
            'Mini-quiz: What is the slope between (1,2) and (3,6)?',
          ]
        : [
            'Mini-quiz: Simplify (x^2−9)/(x−3).',
            'Mini-quiz: Find the equation of a line with slope 2 passing through (1,−1).',
          ];
    }

    if (subject.includes('PHYS')) {
      if (topic === 'kinematics') {
        return easy
          ? [
              'Mini-quiz: If v0=0 and a=2 m/s^2, what is v after 3 s?',
              'Mini-quiz: In free fall (no air), what is g approximately?',
            ]
          : [
              'Mini-quiz: A car goes from 10 m/s to 25 m/s in 5 s. Find a.',
              'Mini-quiz: Using v^2=v0^2+2aΔx, compute stopping distance if v0=20 m/s and a=−4 m/s^2.',
            ];
      }
      return easy
        ? [
            'Mini-quiz: What are the units of acceleration?',
            'Mini-quiz: If distance is 0, what is displacement?',
          ]
        : [
            'Mini-quiz: Explain the difference between speed and velocity with an example.',
            'Mini-quiz: Give one situation where acceleration is negative.',
          ];
    }

    if (subject.includes('CS') || subject.includes('COMP')) {
      if (topic.includes('loops')) {
        return easy
          ? [
              'Mini-quiz: What does a loop do?',
              'Mini-quiz: Give one example of when you use a for-loop.',
            ]
          : [
              'Mini-quiz: What is the difference between a for-loop and a while-loop?',
              'Mini-quiz: Write a loop that sums numbers 1..n (pseudo-code).',
            ];
      }
      return easy
        ? [
            'Mini-quiz: What is a variable?',
            'Mini-quiz: What does an if-statement do?',
          ]
        : [
            "Mini-quiz: What's the difference between a function parameter and an argument?",
            'Mini-quiz: Explain (in simple words) what an array is and when you use it.',
          ];
    }

    return easy
      ? [
          'Mini-quiz: Restate the main rule in one sentence.',
          'Mini-quiz: Give a tiny example.',
        ]
      : [
          'Mini-quiz: Solve a small example and explain each step.',
          'Mini-quiz: Name one common mistake and how to avoid it.',
        ];
  }


  private requireStudent(user: any) {
    const roles: string[] = user?.roles ?? [];
    if (!hasAnyRole({ roles }, ['STUDENT', 'ADMIN'])) {
      throw new ForbiddenException('Student only');
    }
    return user?.sub ?? user?.id;
  }

  // ---------- Learning profile ----------
  async getMyLearningProfile(user: any) {
    const studentId = this.requireStudent(user);
    const row = await this.prisma.learningProfile.findUnique({
      where: { userId: studentId },
    });
    return { ok: true, profile: row };
  }

  async upsertMyLearningProfile(user: any, dto: any) {
    const studentId = this.requireStudent(user);

    const data: any = {
      userId: studentId,

      targetCurriculum: dto?.targetCurriculum ?? undefined,
      targetGrade:
        dto?.targetGrade !== undefined ? Number(dto.targetGrade) : undefined,
      preferredLanguage: dto?.preferredLanguage ?? undefined,

      tone: dto?.tone ?? undefined,
      verbosity:
        dto?.verbosity !== undefined ? Number(dto.verbosity) : undefined,
      explainStyle: dto?.explainStyle ?? undefined,
      emojiOk: dto?.emojiOk !== undefined ? Boolean(dto.emojiOk) : undefined,

      strengths: Array.isArray(dto?.strengths)
        ? dto.strengths.map(String)
        : undefined,
      weaknesses: Array.isArray(dto?.weaknesses)
        ? dto.weaknesses.map(String)
        : undefined,
      goals: Array.isArray(dto?.goals) ? dto.goals.map(String) : undefined,

      maxDepth: dto?.maxDepth !== undefined ? Number(dto.maxDepth) : undefined,
    };

    const row = await this.prisma.learningProfile.upsert({
      where: { userId: studentId },
      update: data,
      create: data,
    });

    return { ok: true, profile: row };
  }

  // ---------- Materials ----------
  async listMaterials(query: {
    subject?: string;
    grade?: number;
    language?: string;
    take?: number;
    q?: string;
  }) {
    const take = Math.min(Math.max(Number(query.take ?? 20), 1), 50);

    const q = query.q ? String(query.q).trim() : '';
    const where: any = {
      ...(query.subject ? { subject: String(query.subject) } : {}),
      ...(query.grade !== undefined &&
      query.grade !== null &&
      !Number.isNaN(Number(query.grade))
        ? { grade: Number(query.grade) }
        : {}),
      ...(query.language ? { language: String(query.language) } : {}),
      ...(q
        ? {
            OR: [
              { title: { contains: q, mode: 'insensitive' } },
              { content: { contains: q, mode: 'insensitive' } },
              { tags: { has: q } },
            ],
          }
        : {}),
    };

    const rows = await this.prisma.material.findMany({
      where,
      orderBy: [{ createdAt: 'desc' }],
      take,
    });

    return { ok: true, materials: rows };
  }

  async createMaterial(user: any, dto: any) {
    // Admin/Secretary only (or tighten later)
    const roles: string[] = user?.roles ?? [];
    if (!hasAnyRole({ roles }, ['ADMIN', 'SECRETARY'])) {
      throw new ForbiddenException('Admin/Secretary only');
    }
    if (!dto?.subject || !dto?.title)
      throw new BadRequestException('subject + title required');

    const pickSource = (raw: any) => {
      const v = String(raw ?? '').trim().toUpperCase();
      if (v === 'TEACHER') return 'TEACHER' as any;
      if (v === 'BOOK') return 'BOOK' as any;
      if (v === 'OTHER') return 'OTHER' as any;
      return 'BAGRUT' as any;
    };

    const row = await this.prisma.material.create({
      data: {
        // schema-aligned fields
        subject: String(dto.subject),
        title: String(dto.title),
        content: dto?.content ? String(dto.content) : '',
        grade:
          dto?.grade !== undefined && dto?.grade !== null
            ? Number(dto.grade)
            : dto?.targetGrade !== undefined && dto?.targetGrade !== null
              ? Number(dto.targetGrade)
              : null,
        language: dto?.language ? String(dto.language) : null,
        source: pickSource(dto?.source ?? dto?.sourceType),
        tags: Array.isArray(dto?.tags) ? dto.tags.map(String) : [],
      } as any,
    });

    return { ok: true, material: row };
  }

  // ---------- Tutor sessions ----------
  async createSession(user: any, dto: any) {
    const studentId = this.requireStudent(user);
    const subject = dto?.subject ? String(dto.subject) : 'GENERAL';
    const subjectNorm = this.normalizeTutorSubject(subject);
    const requestedCharacterId = dto?.characterId
      ? String(dto.characterId)
      : null;

    // cohortId from student profile (best-effort)
    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
      select: { cohortId: true },
    });

    const cohortId = sp?.cohortId ?? null;

    let characterId: string | null = requestedCharacterId;

    // Resolve default character if none provided
    if (!characterId) {
      // 1) cohort + subject
      if (cohortId) {
        const ch1 = await this.prisma.tutorCharacter.findFirst({
          where: { cohortId, subject: subjectNorm as any },
          select: { id: true },
        });
        characterId = ch1?.id ?? null;

        // 2) cohort + GENERAL
        if (!characterId) {
          const ch2 = await this.prisma.tutorCharacter.findFirst({
            where: { cohortId, subject: 'GENERAL' as any },
            select: { id: true },
          });
          characterId = ch2?.id ?? null;
        }
      }

      // 3) global + subject
      if (!characterId) {
        const ch3 = await this.prisma.tutorCharacter.findFirst({
          where: { cohortId: null, subject: subjectNorm as any },
          select: { id: true },
        });
        characterId = ch3?.id ?? null;
      }

      // 4) global + GENERAL
      if (!characterId) {
        const ch4 = await this.prisma.tutorCharacter.findFirst({
          where: { cohortId: null, subject: 'GENERAL' as any },
          select: { id: true },
        });
        characterId = ch4?.id ?? null;
      }
    }

    // Deterministic fallback: ensure a cohort-scoped default character exists
    // Deterministic fallback: always ensure a default character exists.
    // IMPORTANT: cohortId can be null in tests (no studentProfile), so we must still create a global fallback.
    if (!characterId) {
      const targetCohortId = cohortId ?? null;

      const existing = await this.prisma.tutorCharacter.findFirst({
        where: { cohortId: targetCohortId, subject: subjectNorm as any },
        select: { id: true },
      });

      if (existing?.id) {
        characterId = existing.id;
      } else {
        const created = await this.prisma.tutorCharacter.create({
          data: {
            cohortId: targetCohortId,
            subject: subjectNorm as any,
            name:
              subjectNorm === 'MATH'
                ? 'Math Tutor'
                : subjectNorm === 'PHYSICS'
                  ? 'Physics Tutor'
                  : subjectNorm === 'CS'
                    ? 'CS Tutor'
                    : 'General Tutor',
            curriculum: 'bagrut',
            maxGrade: 12,
            language: 'en',
            tone: subjectNorm === 'PHYSICS' ? 'coach' : 'friendly',
            verbosity: 5,
            explainStyle:
              subjectNorm === 'PHYSICS' ? 'examples' : 'step-by-step',
          } as any,
          select: { id: true },
        } as any);

        characterId = created?.id ?? null;
      }
    }

    if (!characterId) {
      throw new Error('TUTOR_CHARACTER_ID_NOT_RESOLVED');
    }

    const row = await this.prisma.tutorSession.create({
      data: {
        userId: studentId,
        cohortId: cohortId ?? undefined,
        characterId: characterId ?? undefined,
        title: dto?.title ? String(dto.title) : null,
        topic: dto?.topic ? String(dto.topic) : null,
      } as any,
    });

    if (dto?.initialMessage && String(dto.initialMessage).trim()) {
      await this.prisma.tutorMessage.create({
        data: {
          sessionId: row.id,
          role: 'USER' as any,
          content: String(dto.initialMessage).trim(),
        } as any,
      });
    }

    return { ok: true, session: row };
  }

  async listSessions(user: any, query?: { characterId?: string }) {
    const studentId = this.requireStudent(user);
    const characterId = query?.characterId ? String(query.characterId) : null;

    const rows = await this.prisma.tutorSession.findMany({
      where: {
        userId: studentId,
        ...(characterId ? { characterId } : {}),
      },
      orderBy: [{ createdAt: 'desc' }],
      take: 50,
    });
    return { ok: true, sessions: rows };
  }

  async getSession(user: any, sessionId: string) {
    const studentId = this.requireStudent(user);
    const session = await this.prisma.tutorSession.findFirst({
      where: { id: sessionId, userId: studentId },
    });
    if (!session) throw new ForbiddenException('Not found');

    const messages = await this.prisma.tutorMessage.findMany({
      where: { sessionId },
      orderBy: [{ createdAt: 'asc' }],
      take: 200,
    });

    return { ok: true, session, messages };
  }

  async addMessage(user: any, sessionId: string, dto: any) {
    const studentId = this.requireStudent(user);
    const session = await this.prisma.tutorSession.findFirst({
      where: { id: sessionId, userId: studentId },
      select: { id: true },
    });
    if (!session) throw new ForbiddenException('Not found');

    const role = dto?.role ? String(dto.role) : 'USER';
    const content = dto?.content ? String(dto.content) : '';
    if (!content.trim()) throw new BadRequestException('content required');

    const msg = await this.prisma.tutorMessage.create({
      data: {
        sessionId,
        role: 'USER',
        content,
        sources: Array.isArray(dto?.sources) ? dto.sources.map(String) : [],
      } as any,
    });

    // touch updatedAt
    await this.prisma.tutorSession.update({
      where: { id: sessionId },
      data: { updatedAt: new Date() },
    });

    return { ok: true, message: msg };
  }

  // ---------- Brain snapshot (read only for now) ----------
  async getMyBrainSnapshot(user: any) {
    const studentId = this.requireStudent(user);
    const row = await this.prisma.studentBrainSnapshot.findFirst({
      where: { userId: studentId },
      orderBy: [{ createdAt: 'desc' }],
    });
    return { ok: true, snapshot: row };
  }

  // ---------- Tutor runtime (reply) ----------

  // ---------- AI Brain (rebuild from real data) ----------
  private dayMs(n: number) {
    return n * 24 * 60 * 60 * 1000;
  }

  private safeCourseSubject(course: any): string {
    // Course model likely has subject; if not, fall back cleanly
    const sub = course?.subject ?? course?.name ?? null;
    if (!sub) return 'GENERAL';
    return String(sub).toUpperCase().includes('MATH')
      ? 'MATH'
      : String(sub).toUpperCase().includes('PHYS')
        ? 'PHYSICS'
        : String(sub).toUpperCase().includes('CS')
          ? 'CS'
          : String(sub);
  }

  private async buildBrainMetrics(studentId: string) {
    const now = new Date();
    const since14 = new Date(Date.now() - this.dayMs(14));

    // Attendance (last 14 days)
    const att = await this.prisma.attendanceRecord.findMany({
      where: { studentId, markedAt: { gte: since14 } },
      select: { status: true, markedAt: true },
      orderBy: [{ markedAt: 'desc' }],
      take: 500,
    });

    const attCounts: Record<string, number> = {};
    for (const r of att)
      attCounts[String(r.status)] = (attCounts[String(r.status)] ?? 0) + 1;

    const present =
      (attCounts.PRESENT ?? 0) +
      (attCounts.LATE ?? 0) +
      (attCounts.EXCUSED ?? 0);
    const absent = attCounts.ABSENT ?? 0;
    const total = att.length;
    const attendancePct = total ? Math.round((present / total) * 100) : null;

    // Grades (recent)
    const grades = await this.prisma.gradeRecord.findMany({
      where: { studentId },
      select: {
        grade: true,
        assessment: {
          select: {
            date: true,
            maxGrade: true,
            course: { select: { id: true, name: true, subject: true } },
          },
        },
      },
      orderBy: [{ assessment: { date: 'desc' } }, { id: 'desc' }],
      take: 40,
    });

    // Normalize grades to 0-100 using assessment.maxGrade
    const norm = grades.map((g) => {
      const max = g.assessment?.maxGrade ?? 100;
      const pct = max
        ? Math.round((Number(g.grade) / Number(max)) * 100)
        : Number(g.grade);
      return {
        pct,
        date: g.assessment?.date ? new Date(g.assessment.date) : now,
        subject: this.safeCourseSubject(g.assessment?.course),
      };
    });

    const avg = norm.length
      ? Math.round(norm.reduce((a, x) => a + x.pct, 0) / norm.length)
      : null;

    // Trend: last5 avg - prev5 avg
    const last5 = norm.slice(0, 5);
    const prev5 = norm.slice(5, 10);
    const avgLast5 = last5.length
      ? last5.reduce((a, x) => a + x.pct, 0) / last5.length
      : null;
    const avgPrev5 = prev5.length
      ? prev5.reduce((a, x) => a + x.pct, 0) / prev5.length
      : null;
    const trendDelta =
      avgLast5 !== null && avgPrev5 !== null
        ? Math.round(avgLast5 - avgPrev5)
        : null;

    let trend: 'up' | 'down' | 'flat' | 'unknown' = 'unknown';
    if (trendDelta !== null) {
      if (trendDelta >= 4) trend = 'up';
      else if (trendDelta <= -4) trend = 'down';
      else trend = 'flat';
    }

    // Per-subject averages
    const bySub: Record<string, number[]> = {};
    for (const x of norm) {
      bySub[x.subject] = bySub[x.subject] ?? [];
      bySub[x.subject].push(x.pct);
    }

    const perSubject: any = {};
    for (const k of Object.keys(bySub)) {
      const arr = bySub[k];
      perSubject[k] = {
        avg: Math.round(arr.reduce((a, n) => a + n, 0) / arr.length),
      };
    }

    // Weak/strong heuristics: lowest/highest avg subject
    const subs = Object.entries(perSubject).map(([k, v]: any) => ({
      subject: k,
      avg: v.avg,
    }));
    subs.sort((a, b) => a.avg - b.avg);
    const weak = subs.length ? [subs[0].subject] : [];
    const strong = subs.length ? [subs[subs.length - 1].subject] : [];

    return {
      generatedAt: now.toISOString(),
      attendance14d: {
        total,
        present,
        absent,
        pct: attendancePct,
        breakdown: attCounts,
      },
      grades: { count: norm.length, avg, trend, trendDelta, perSubject },
      weak,
      strong,
    };
  }

  async rebuildMyBrainSnapshot(user: any) {
    const studentId = this.requireStudent(user);

    // best-effort cohortId (optional) – from latest session if exists
    const lastSession = await this.prisma.tutorSession.findFirst({
      where: { userId: studentId },
      select: { cohortId: true },
      orderBy: [{ updatedAt: 'desc' }],
    });

    const metrics = await this.buildBrainMetrics(studentId);

    const row = await this.prisma.studentBrainSnapshot.create({
      data: {
        userId: studentId,
        cohortId: lastSession?.cohortId ?? null,
        metrics,
      } as any,
    });

    await this.prisma.analyticsEvent.create({
      data: {
        actorUserId: studentId,
        actorRole: 'STUDENT' as any,
        cohortId: row.cohortId ?? null,
        studentId,
        name: 'brain.snapshot.rebuilt',
        payload: { snapshotId: row.id },
      } as any,
    });

    return { ok: true, snapshot: row };
  }


  async replyToSession(user: any, sessionId: string, _body?: any) {
    const session = await this.prisma.tutorSession.findUnique({
      where: { id: sessionId },
      select: { id: true, userId: true, characterId: true, cohortId: true, courseId: true, topic: true },
    });

    if (!session) throw new ForbiddenException('Not found');
    if (session.userId !== user.id) throw new ForbiddenException('Not found');

    const lastUser = await this.prisma.tutorMessage.findFirst({
      where: { sessionId: session.id, role: 'USER' },
      orderBy: { createdAt: 'desc' },
    });

    if (!lastUser?.content) throw new BadRequestException('no user message');

    const gen = await this.generateAssistantReply({
      question: lastUser.content,
      ctx: { user, session },
      materials: [],
      topic: (session as any).topic ?? 'general',
    });

    const assistantMessage = await this.prisma.tutorMessage.create({
      data: {
        sessionId: session.id,
        role: 'ASSISTANT',
        content: gen.content,
        sources: [],
      },
    });

    return { ok: true, assistantMessage };
  }

  replyToSessionStream(user: any, sessionId: string, opts?: { displayName?: string; novaSettings?: string }): Observable<MessageEvent> {
  return new Observable((subscriber) => {
    (async () => {
      let eventId = 0;
      let acc = '';

      try {
        // 1) Load last USER message from DB (real prompt)
        const msgs = await this.prisma.tutorMessage.findMany({
          where: { sessionId },
          orderBy: { createdAt: 'asc' },
          take: 200,
        });

        const lastUser = [...msgs].reverse().find((m) => m.role === 'USER');
        const userText = (lastUser?.content ?? '').toString().trim();

        if (!userText) {
          subscriber.next(({ id: String(++eventId), data: { type: 'error', message: 'No user message found in this session.' } } as any));
          subscriber.complete();
          return;
        }

        // 2) Founder Tony system prompt (NOVA persona)
        
        // ---- QUIZ STABILITY GUARD ----
        const lastAssistant = [...msgs].reverse().find((m) => m.role === 'ASSISTANT')?.content?.toString?.() ?? '';
        const userLooksLikeAnswer = /(^|\n)\s*(a\s*=|f\s*=|answer|q\d+|because|therefore|\d+\s*(n|kg|m\/s))/i.test(userText);
        const assistantLooksLikeQuiz = /(mini-quiz|quick quiz|\n\s*\d+\.\s+)/i.test(lastAssistant);

const system =
          `You are NOVA, the AI tutor inside ClassMate.\n\nCRITICAL founder wording rule:\n- Never say "you created me" or "you made me" to users in general.\n- Instead say: "I was created by Tony Aboud" (third-person).\n- Only if the user is Tony Aboud, you may say "Tony, you created me".\n- When referencing the founder, always say the full name: "Tony Aboud" (not "you").\n\n- DO NOT use LaTeX delimiters like \\\( \\\), \\\[ \\\], $$, or markdown code fences for math.\n- DO NOT output escaped TeX commands like \\frac, \\times, \\Omega, \\text unless the user explicitly asks for raw LaTeX.\n- For normal student answers, write math in clean readable unicode/plain style exactly like:\n  V = I × R\n  I = V / R\n  R = V / I\n  4 kΩ = 4000 Ω\n  20 mA = 0.02 A\n- Prefer short titled sections instead of markdown heading spam.\n- Keep formulas visually simple and classroom-readable, like ChatGPT-style rendered math but in plain text.\n\n\n` +
          `Tony Aboud is the Founder of ClassMate and the creator of this AI.
` +
          `When appropriate, briefly reference:\n` +
          `- Tony is a CS student and full-stack builder\n` +
          `- He loves AI/ML, physics, and clean Apple-style UI\n` +
          `- He prefers Bagrut-level explanations with mini-quizzes\n\n` +
          `Answer at Bagrut level only. Friendly, clear, step-by-step. If helpful, end with up to 2 mini-quiz questions.\n` +
          (assistantLooksLikeQuiz && userLooksLikeAnswer
            ? `\n\n=== MODE ===\nGRADE_ONLY: The user is answering an existing quiz. Grade and correct; do NOT create new quiz questions.`
            : ``);


        const user = userText;

        // 3) Stream from OpenAI provider
        // ---- CONTEXT: load recent messages for this session ----
        const recent = await this.prisma.tutorMessage.findMany({
          where: { sessionId },
          orderBy: { createdAt: 'asc' },
          take: 40,
        });
        const messages = recent.map((m: any) => ({ role: m.role, content: m.content }));

        for await (const delta of generateAssistantReplyStream({ system, user, messages, displayName: opts?.displayName, novaSettings: opts?.novaSettings })) {
          if (typeof delta === 'string' && delta.length) {
            acc += delta;
            subscriber.next(({ id: String(++eventId), data: { type: 'chunk', delta } } as any));
          }
        }

        // 4) Persist assistant message to DB (optional but recommended)
        const saved = await this.prisma.tutorMessage.create({
          data: {
            sessionId,
            role: 'ASSISTANT',
            content: acc,
          },
        });

        const assistantMessage = {
          id: saved.id,
          createdAt: saved.createdAt?.toISOString?.() ?? new Date().toISOString(),
          sessionId,
          role: 'ASSISTANT',
          content: acc,
        };

        subscriber.next(({ id: String(++eventId), data: { type: 'done', assistantMessage, sources: [] } } as any));
        subscriber.complete();
      } catch (e: any) {
        subscriber.next(({ id: String(++eventId), data: { type: 'error', message: String(e?.message ?? e) } } as any));
        subscriber.complete();
      }
    })();
  });
}






  private async ensureGlobalDefaultCharacters() {
    const subjects = [
      'GENERAL',
      'MATH',
      'PHYSICS',
      'CS',
      'ENGLISH',
      'HEBREW',
      'ARABIC',
    ] as const;

    for (const subj of subjects) {
      const existing = await this.prisma.tutorCharacter.findFirst({
        where: { subject: subj as any, cohortId: null },
        select: { id: true },
      });
      if (existing) continue;

      await this.prisma.tutorCharacter.create({
        data: {
          cohortId: null,
          subject: subj as any,
          name:
            subj === 'MATH'
              ? 'Math Tutor'
              : subj === 'PHYSICS'
                ? 'Physics Tutor'
                : subj === 'CS'
                  ? 'CS Tutor'
                  : subj === 'ENGLISH'
                    ? 'English Tutor'
                    : subj === 'HEBREW'
                      ? 'Hebrew Tutor'
                      : subj === 'ARABIC'
                        ? 'Arabic Tutor'
                        : 'General Tutor',
          curriculum: 'bagrut',
          maxGrade: 12,
          language: 'en',
          tone: 'friendly',
          verbosity: 5,
          explainStyle: 'step-by-step',
          systemNotes:
            'Bagrut level only. Adapt to learning profile and AI brain. Ask mini-quiz.',
        } as any,
      });
    }
  }

  async ensureDefaultCharactersAdmin(user: any) {
    const roles: string[] = user?.roles ?? [];
    if (!hasAnyRole({ roles }, ['ADMIN', 'SECRETARY'])) {
      throw new ForbiddenException('Admin/Secretary only');
    }
    await this.ensureGlobalDefaultCharacters();
    return { ok: true };
  }

  // ---------- Tutor reply helpers (Day 7) ----------
  private buildTutorContext(args: {
    character?: any;
    profile?: any;
    brain?: any;
    session?: any;
    studentId?: string;
  }) {
    const { character, profile, brain, session } = args;

    const effective = {
      curriculum:
        profile?.targetCurriculum ?? character?.curriculum ?? 'bagrut',
      grade: profile?.targetGrade ?? character?.maxGrade ?? 12,
      language: profile?.preferredLanguage ?? character?.language ?? 'en',
      tone: profile?.tone ?? character?.tone ?? 'friendly',
      explainStyle:
        profile?.explainStyle ?? character?.explainStyle ?? 'step-by-step',
      verbosity:
        typeof profile?.verbosity === 'number'
          ? profile.verbosity
          : typeof character?.verbosity === 'number'
            ? character.verbosity
            : 6,
      emojiOk: profile?.emojiOk !== undefined ? Boolean(profile.emojiOk) : true,
      systemNotes: character?.systemNotes ?? '',
      subject: character?.subject ?? session?.subject ?? 'GENERAL',
    };

    // Brain-derived hints (best effort)
    const brainMetrics = brain?.metrics ?? null;
    const weak = Array.isArray(brainMetrics?.weak)
      ? brainMetrics.weak.map(String)
      : [];
    const strong = Array.isArray(brainMetrics?.strong)
      ? brainMetrics.strong.map(String)
      : [];
    const note = brainMetrics?.note ? String(brainMetrics.note) : '';

    return { effective, weak, strong, note, brainMetrics };
  }

  private guessTopic(question: string, materials: any[], weak: string[]) {
    const q = (question ?? '').toLowerCase();
    const fromWeak = weak.map((w) => String(w).toLowerCase());
    const fromMaterials = (materials ?? [])
      .map((m) => String(m?.title ?? '') + ' ' + String(m?.tags ?? ''))
      .join(' ')
      .toLowerCase();

    const hay = q + ' ' + fromMaterials + ' ' + fromWeak.join(' ');
    if (hay.includes('deriv')) return 'derivatives';
    if (hay.includes('integral')) return 'integrals';
    if (
      hay.includes('kinematic') ||
      hay.includes('acceleration') ||
      hay.includes('velocity') ||
      hay.includes('free fall')
    )
      return 'kinematics';
    if (
      hay.includes('ohm') ||
      hay.includes('circuit') ||
      hay.includes('resistance')
    )
      return 'electricity';
    if (
      hay.includes('loop') ||
      hay.includes('array') ||
      hay.includes('function')
    )
      return 'programming basics';
    return 'general';
  }

  private buildMiniQuiz(args: {
    subject: string;
    topic: string;
    verbosity: number;
    weak: string[];
  }) {
    const subject = String(args.subject ?? 'GENERAL').toUpperCase();
    const topic = String(args.topic ?? 'general').toLowerCase();
    const v = Number(args.verbosity ?? 6);

    // difficulty heuristic: lower verbosity => simpler quiz
    const easy = v <= 4;

    if (subject.includes('MATH')) {
      if (topic === 'derivatives') {
        return easy
          ? [
              'Mini-quiz: What is d/dx(x^2)?',
              'Mini-quiz: What is the slope (derivative) of a constant function?',
            ]
          : [
              'Mini-quiz: Differentiate f(x)=3x^3−2x. Show steps.',
              "Mini-quiz: If f'(a)=0, what can that mean about the graph at x=a?",
            ];
      }
      return easy
        ? [
            'Mini-quiz: Solve 2x+5=13.',
            'Mini-quiz: What is the slope between (1,2) and (3,6)?',
          ]
        : [
            'Mini-quiz: Simplify (x^2−9)/(x−3).',
            'Mini-quiz: Find the equation of a line with slope 2 passing through (1,−1).',
          ];
    }

    if (subject.includes('PHYS')) {
      if (topic === 'kinematics') {
        return easy
          ? [
              'Mini-quiz: If v0=0 and a=2 m/s^2, what is v after 3 s?',
              'Mini-quiz: In free fall (no air), what is g approximately?',
            ]
          : [
              'Mini-quiz: A car goes from 10 m/s to 25 m/s in 5 s. Find a.',
              'Mini-quiz: Using v^2=v0^2+2aΔx, compute stopping distance if v0=20 m/s and a=−4 m/s^2.',
            ];
      }
      return easy
        ? [
            'Mini-quiz: What are the units of acceleration?',
            'Mini-quiz: If distance is 0, what is displacement?',
          ]
        : [
            'Mini-quiz: Explain the difference between speed and velocity with an example.',
            'Mini-quiz: Give one situation where acceleration is negative.',
          ];
    }

    if (subject.includes('CS')) {
      return easy
        ? [
            'Mini-quiz: What is a variable?',
            'Mini-quiz: What does a for-loop do?',
          ]
        : [
            "Mini-quiz: What's the difference between a function parameter and an argument?",
            'Mini-quiz: Explain (in simple words) what an array is and when you use it.',
          ];
    }

    return [
      'Mini-quiz: Summarize the key idea in 1 sentence.',
      'Mini-quiz: Give one example that matches the idea.',
    ];
  }

  private formatTutorReply(args: {
    question: string;
    excerpt?: string;
    refs?: string;
    effective: {
      tone?: string;
      explainStyle?: string;
      verbosity?: number;
      emojiOk?: boolean;
    };
    weak?: string[];
    strong?: string[];
    note?: string;
    topic?: string;
  }) {
    const question = String(args.question ?? '').trim();
    const excerpt = String(args.excerpt ?? '').trim();
    const refs = String(args.refs ?? '').trim();
    const tone = String(args.effective?.tone ?? 'friendly').toLowerCase();
    const explainStyle = String(
      args.effective?.explainStyle ?? 'step-by-step',
    ).toLowerCase();
    const verbosity = Number(args.effective?.verbosity ?? 6);
    const emojiOk = Boolean(args.effective?.emojiOk ?? true);
    const weak = Array.isArray(args.weak) ? args.weak : [];
    const strong = Array.isArray(args.strong) ? args.strong : [];
    const note = args.note ? String(args.note) : '';
    const topic = String(args.topic ?? 'general').toLowerCase();

    const short = verbosity <= 4;

    const emoji = (e: string) => (emojiOk ? e + ' ' : '');
    const lines: string[] = [];

    // Header
    if (tone.includes('coach'))
      lines.push(emoji('💪') + 'Bagrut Tutor (coach mode)');
    else if (tone.includes('strict'))
      lines.push(emoji('🧠') + 'Bagrut Tutor (focused mode)');
    else lines.push(emoji('🙂') + 'Bagrut Tutor (friendly mode)');

    // Adaptation hints (from brain/profile)
    const adaptBits: string[] = [];
    if (process.env.E2E !== '1' && process.env.CI !== '1') {
      if (weak.length) adaptBits.push(`Weak spot: ${weak[0]}`);
      if (strong.length) adaptBits.push(`Strength: ${strong[0]}`);
    }
    if (note) adaptBits.push(`Note: ${note}`);
    if (adaptBits.length) lines.push(adaptBits.join(' | '));

    lines.push('');
    lines.push(`Bagrut level only.`);
    lines.push(`Your question: ${question}`);
    lines.push(`Topic guess: ${topic}`);
    lines.push('');

    // Explanation
    lines.push(emoji('📌') + 'Explanation:');
    if (short || explainStyle.includes('simple')) {
      lines.push(`- ${this.oneLineExplanation(topic)}`);
      lines.push(`- Example: ${this.quickExample(topic)}`);
    } else {
      lines.push('- Idea: ' + this.oneLineExplanation(topic));
      lines.push('- Steps:');
      lines.push('  1) ' + this.stepOne(topic));
      lines.push('  2) ' + this.stepTwo(topic));
      lines.push('  3) ' + this.stepThree(topic));
      lines.push('- Example: ' + this.quickExample(topic));
    }

    // Materials (optional)
    if (!short && excerpt) {
      lines.push('');
      lines.push(emoji('📚') + 'From your materials:');
      lines.push(excerpt);
    }
    if (!short && refs) {
      lines.push('');
      lines.push(emoji('🔎') + 'References: ' + refs);
    }

    // Mini-quiz
    lines.push('');
    lines.push(emoji('🧠') + 'Mini-quiz:');
    const quiz = this.generateMiniQuiz({
      subject: this.normalizeTutorSubject((args as any).subject ?? 'GENERAL'),
      topic,
      verbosity,
    });
    for (const q of quiz) lines.push('- ' + q);

    lines.push('');
    lines.push(emoji('✅') + "Reply with your answers and I'll correct them.");

    return lines.join('\n');
  }

  private oneLineExplanation(topic: string) {
    if (topic === 'derivatives')
      return 'A derivative is the slope of the tangent line (rate of change) at a point.';
    if (topic === 'kinematics')
      return 'Kinematics connects position, velocity, acceleration using constant-acceleration formulas.';
    if (topic === 'programming basics')
      return 'Programming is giving the computer step-by-step instructions with variables and control flow.';
    return 'We identify the rule/definition, then apply it carefully with a small example.';
  }
  private quickExample(topic: string) {
    if (topic === 'derivatives')
      return "If f(x)=x^2, then f'(x)=2x, so at x=3 the slope is 6.";
    if (topic === 'kinematics')
      return 'If v0=0 and a=2, after 3s: v=v0+at=6 m/s.';
    return 'Example: pick simple numbers, apply the rule, and check units/logic.';
  }
  private stepOne(topic: string) {
    if (topic === 'derivatives')
      return 'Write the function clearly and choose the rule (power rule / sum rule).';
    if (topic === 'kinematics')
      return 'List known values (v0, v, a, t, Δx) with units.';
    return 'State the definition/rule you will use.';
  }
  private stepTwo(topic: string) {
    if (topic === 'derivatives')
      return 'Differentiate term-by-term (e.g., d/dx(x^n)=n·x^(n−1)).';
    if (topic === 'kinematics')
      return 'Pick the correct constant-acceleration formula that fits the knowns.';
    return 'Substitute values carefully.';
  }
  private stepThree(topic: string) {
    if (topic === 'derivatives')
      return 'Simplify and (if asked) plug in the x value to get the slope at that point.';
    if (topic === 'kinematics')
      return 'Solve, then sanity-check sign and units (m/s, m/s^2, etc.).';
    return 'Check the result makes sense.';
  }

  private getTutorReplyMode() {
    // deterministic (default) or llm (future swap)
    const v = String(
      process.env.TUTOR_REPLY_MODE ?? 'deterministic',
    ).toLowerCase();
    return v === 'llm' ? 'llm' : 'deterministic';
  }

  private async generateAssistantReply(args: {
    question: string;
    ctx: any;
    materials: any[];
    topic: string;
  }) {
    const { question, ctx, materials, topic } = args;

    // deterministic refs/excerpt for both modes (stable contract)
    const { refs, excerpt } = this.buildRefsAndExcerpt(materials);

    // Cache key: stable + deterministic
    const key = this.replyCacheKey({
      studentId: String(ctx?.studentId ?? ''),
      characterId: String(ctx?.character?.id ?? ''),
      subject: String(ctx?.effective?.subject ?? ''),
      topic: String(topic ?? ''),
      question: String(question ?? ''),
      refs,
      excerpt,
    });

    // try cache
    const hit = await this.readReplyCache(key);
    if (hit?.content) {
      await this.prisma.analyticsEvent.create({
        data: {
          actorUserId: String(ctx?.studentId ?? null) || null,
          actorRole: 'STUDENT' as any,
          cohortId: ctx?.session?.cohortId ?? null,
          studentId: String(ctx?.studentId ?? null) || null,
          name: 'tutor.reply.cache.hit',
          payload: { key },
        } as any,
      });
      return { content: String(hit.content), refs, excerpt };
    }

    // Future: if (this.getTutorReplyMode()==='llm') call provider here.
    // Today: deterministic builder only.
    const content = this.formatTutorReply({
      question,
      excerpt,
      refs,
      effective: ctx.effective,
      weak: ctx.weak,
      strong: ctx.strong,
      note: ctx.note,
      topic,
    });

    await this.writeReplyCache(key, content);

    await this.prisma.analyticsEvent.create({
      data: {
        actorUserId: String(ctx?.studentId ?? null) || null,
        actorRole: 'STUDENT' as any,
        cohortId: ctx?.session?.cohortId ?? null,
        studentId: String(ctx?.studentId ?? null) || null,
        name: 'tutor.reply.cache.miss',
        payload: { key },
      } as any,
    });

    return { content, refs, excerpt };
  }

  private async readReplyCache(
    key: string,
  ): Promise<{ content: string } | null> {
    try {
      const cache = require('./tutor.reply.cache');
      if (cache?.getCachedReply) {
        const hit = await cache.getCachedReply(this.prisma, key);
        if (hit?.content) return { content: String(hit.content) };
      }
    } catch {}
    return null;
  }

  private async writeReplyCache(key: string, content: string) {
    try {
      const cache = require('./tutor.reply.cache');
      if (cache?.setCachedReply)
        await cache.setCachedReply(this.prisma, key, content);
    } catch {}
  }

  private async emitTutorEvent(
    userId: string | null,
    cohortId: string | null,
    name: string,
    payload: any,
  ) {
    try {
      await this.prisma.analyticsEvent.create({
        data: {
          actorUserId: userId,
          actorRole: 'STUDENT' as any,
          cohortId,
          studentId: userId,
          name,
          payload,
        } as any,
      });
    } catch {}
  }

  private normalizeTutorSubject(raw?: string) {
    const v = String(raw ?? '')
      .trim()
      .toUpperCase();
    if (!v) return 'GENERAL';
    // allow synonyms
    if (v === 'MATH' || v === 'MATHEMATICS') return 'MATH';
    if (v === 'PHYSICS' || v === 'PHY') return 'PHYSICS';
    if (v === 'CS' || v === 'COMPUTER_SCIENCE' || v === 'COMPUTERSCIENCE')
      return 'CS';
    if (v === 'ENGLISH' || v === 'ENG') return 'ENGLISH';
    if (v === 'HEBREW') return 'HEBREW';
    if (v === 'ARABIC') return 'ARABIC';
    return 'GENERAL';
  }

  private defaultCharacterName(subject: string) {
    switch (subject) {
      case 'MATH':
        return 'Math Tutor';
      case 'PHYSICS':
        return 'Physics Tutor';
      case 'CS':
        return 'CS Tutor';
      case 'ENGLISH':
        return 'English Tutor';
      case 'HEBREW':
        return 'Hebrew Tutor';
      case 'ARABIC':
        return 'Arabic Tutor';
      default:
        return 'General Tutor';
    }
  }

  async listCharacters(user: any, query?: { subject?: string }) {
    // students/admin/secretary allowed (controller will guard)
    const subject = query?.subject
      ? this.normalizeTutorSubject(query.subject)
      : undefined;

    const rows = await this.prisma.tutorCharacter.findMany({
      where: {
        ...(subject ? { subject: subject as any } : {}),
      },
      orderBy: [{ subject: 'asc' }, { name: 'asc' }],
      take: 200,
    });

    return { ok: true, characters: rows };
  }

  async ensureDefaultCharacters(user: any, dto?: any) {
    const roles: string[] = user?.roles ?? [];
    if (!hasAnyRole({ roles }, ['ADMIN', 'SECRETARY'])) {
      throw new ForbiddenException('Admin/Secretary only');
    }

    const cohortId = dto?.cohortId ? String(dto.cohortId) : null;

    const subjects = [
      'GENERAL',
      'MATH',
      'PHYSICS',
      'CS',
      'ENGLISH',
      'HEBREW',
      'ARABIC',
    ];
    const created: any[] = [];
    for (const subj of subjects) {
      const existing = await this.prisma.tutorCharacter.findFirst({
        where: {
          subject: subj as any,
          ...(cohortId ? { cohortId } : { cohortId: null }),
        },
        select: { id: true },
      });
      if (existing) continue;

      const row = await this.prisma.tutorCharacter.create({
        data: {
          cohortId,
          subject: subj as any,
          name: this.defaultCharacterName(subj),
          curriculum: 'bagrut',
          maxGrade: 12,
          language: 'en',
          tone: subj === 'PHYSICS' ? 'focused' : 'friendly',
          verbosity: 5,
          explainStyle: 'step-by-step',
          systemNotes:
            'Use Bagrut-level explanations only. Adapt tone/verbosity to learning profile. Ask short mini-quiz questions.',
        } as any,
      });

      created.push(row);
    }

    return { ok: true, createdCount: created.length, created };
  }

  private replyCacheKey(input: {
    studentId: string;
    characterId: string;
    subject: string;
    topic: string;
    question: string;
    refs: any;
    excerpt: any;
  }) {
    // Stable, deterministic key (hash of normalized payload)
    const { createHash } = require('crypto');

    const payload = JSON.stringify({
      studentId: String(input.studentId ?? ''),
      characterId: String(input.characterId ?? ''),
      subject: String(input.subject ?? ''),
      topic: String(input.topic ?? ''),
      question: String(input.question ?? ''),
      refs: input.refs ?? null,
      excerpt: input.excerpt ?? null,
    });

    return (
      'tutorReply|' + createHash('sha256').update(payload, 'utf8').digest('hex')
    );
  }
}
