import { BadRequestException, ForbiddenException, Injectable } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class TutorService {
  private prisma = new PrismaClient();

  private requireStudent(user: any) {
    const roles: string[] = user?.roles ?? [];
    if (!roles.includes('STUDENT') && !roles.includes('ADMIN')) {
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
      targetGrade: dto?.targetGrade !== undefined ? Number(dto.targetGrade) : undefined,
      preferredLanguage: dto?.preferredLanguage ?? undefined,

      tone: dto?.tone ?? undefined,
      verbosity: dto?.verbosity !== undefined ? Number(dto.verbosity) : undefined,
      explainStyle: dto?.explainStyle ?? undefined,
      emojiOk: dto?.emojiOk !== undefined ? Boolean(dto.emojiOk) : undefined,

      strengths: Array.isArray(dto?.strengths) ? dto.strengths.map(String) : undefined,
      weaknesses: Array.isArray(dto?.weaknesses) ? dto.weaknesses.map(String) : undefined,
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
      ...(query.grade !== undefined && query.grade !== null && !Number.isNaN(Number(query.grade))
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
    if (!roles.includes('ADMIN') && !roles.includes('SECRETARY')) {
      throw new ForbiddenException('Admin/Secretary only');
    }
    if (!dto?.subject || !dto?.title) throw new BadRequestException('subject + title required');

    const row = await this.prisma.material.create({
      data: {
        subject: String(dto.subject),
        topic: dto?.topic ? String(dto.topic) : null,
        level: dto?.level ? String(dto.level) : 'BAGRUT',
        title: String(dto.title),
        content: dto?.content ? String(dto.content) : '',
        sourceType: dto?.sourceType ? String(dto.sourceType) : null,
        sourceRef: dto?.sourceRef ? String(dto.sourceRef) : null,
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
    const requestedCharacterId = dto?.characterId ? String(dto.characterId) : null;

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

    const row = await this.prisma.tutorSession.create({
      data: {
        userId: studentId,
        cohortId: cohortId ?? undefined,
        characterId: characterId ?? undefined,
        title: dto?.title ? String(dto.title) : null,
        topic: dto?.topic ? String(dto.topic) : null,
      } as any,
    });

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
        role: role as any,
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
  private dayMs(n: number) { return n * 24 * 60 * 60 * 1000; }

  private safeCourseSubject(course: any): string {
    // Course model likely has subject; if not, fall back cleanly
    const sub = course?.subject ?? course?.name ?? null;
    if (!sub) return 'GENERAL';
    return String(sub).toUpperCase().includes('MATH') ? 'MATH'
      : String(sub).toUpperCase().includes('PHYS') ? 'PHYSICS'
      : String(sub).toUpperCase().includes('CS') ? 'CS'
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
    for (const r of att) attCounts[String(r.status)] = (attCounts[String(r.status)] ?? 0) + 1;

    const present = (attCounts.PRESENT ?? 0) + (attCounts.LATE ?? 0) + (attCounts.EXCUSED ?? 0);
    const absent = (attCounts.ABSENT ?? 0);
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
      const pct = max ? Math.round((Number(g.grade) / Number(max)) * 100) : Number(g.grade);
      return {
        pct,
        date: g.assessment?.date ? new Date(g.assessment.date) : now,
        subject: this.safeCourseSubject(g.assessment?.course),
      };
    });

    const avg = norm.length ? Math.round(norm.reduce((a, x) => a + x.pct, 0) / norm.length) : null;

    // Trend: last5 avg - prev5 avg
    const last5 = norm.slice(0, 5);
    const prev5 = norm.slice(5, 10);
    const avgLast5 = last5.length ? last5.reduce((a, x) => a + x.pct, 0) / last5.length : null;
    const avgPrev5 = prev5.length ? prev5.reduce((a, x) => a + x.pct, 0) / prev5.length : null;
    const trendDelta = (avgLast5 !== null && avgPrev5 !== null) ? Math.round(avgLast5 - avgPrev5) : null;

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
      perSubject[k] = { avg: Math.round(arr.reduce((a, n) => a + n, 0) / arr.length) };
    }

    // Weak/strong heuristics: lowest/highest avg subject
    const subs = Object.entries(perSubject).map(([k, v]: any) => ({ subject: k, avg: v.avg }));
    subs.sort((a, b) => a.avg - b.avg);
    const weak = subs.length ? [subs[0].subject] : [];
    const strong = subs.length ? [subs[subs.length - 1].subject] : [];

    return {
      generatedAt: now.toISOString(),
      attendance14d: { total, present, absent, pct: attendancePct, breakdown: attCounts },
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
  async replyToSession(user: any, sessionId: string, dto: any) {
    const studentId = this.requireStudent(user);

    const session = await this.prisma.tutorSession.findFirst({
      where: { id: sessionId, userId: studentId },
      include: { character: true },
    });
    if (!session) throw new ForbiddenException('Not found');

    const question = dto?.content ? String(dto.content) : '';
    if (!question.trim()) throw new BadRequestException('content required');

    const profile = await this.prisma.learningProfile.findUnique({
      where: { userId: studentId },
    });

    const brain = await this.prisma.studentBrainSnapshot.findFirst({
      where: { userId: studentId },
      orderBy: [{ createdAt: 'desc' }],
    });

    const subj = session.character?.subject && String(session.character.subject) !== 'GENERAL'
      ? String(session.character.subject)
      : undefined;

    const grade = profile?.targetGrade ?? session.character?.maxGrade ?? undefined;
    const language = profile?.preferredLanguage ?? session.character?.language ?? undefined;

    // Retrieve some materials (simple contains search)
    const q = question.trim();
    const materials = await this.prisma.material.findMany({
      where: {
        ...(subj ? { subject: subj } : {}),
        ...(grade !== undefined ? { grade: Number(grade) } : {}),
        ...(language ? { language: String(language) } : {}),
        OR: [
          { title: { contains: q, mode: 'insensitive' } },
          { content: { contains: q, mode: 'insensitive' } },
          { tags: { has: q } },
        ],
      } as any,
      orderBy: [{ createdAt: 'desc' }],
      take: 8,
    });

    // Store USER message
    const userMsg = await this.prisma.tutorMessage.create({
      data: {
        sessionId,
        role: 'USER' as any,
        content: question,
        sources: [],
      } as any,
    });

    // Build deterministic assistant reply (LLM comes later; today we make it feel like a real tutor)
    const tone = profile?.tone ?? session.character?.tone ?? 'friendly';
    const explainStyle = profile?.explainStyle ?? session.character?.explainStyle ?? 'step-by-step';
    const verbosity = typeof profile?.verbosity === 'number' ? profile.verbosity : (typeof session.character?.verbosity === 'number' ? session.character.verbosity : 6);
    const emojiOk = profile?.emojiOk !== undefined ? Boolean(profile.emojiOk) : true;

    const brainHint = brain?.metrics ? JSON.stringify(brain.metrics).slice(0, 240) : '(none yet)';
    const refs = materials.length ? materials.map((m) => m.title).slice(0, 5).join(' | ') : '(no materials found)';
    const excerpt = materials.length ? String(materials[0].content ?? '').slice(0, 260) : '';

    const short = verbosity <= 3;
    const strict = String(tone).toLowerCase().includes('strict');
    const stepEmoji = emojiOk ? (strict ? '➡️ ' : '👉 ') : '';
    const warnEmoji = emojiOk ? '⚠️ ' : '';
    const quizEmoji = emojiOk ? '🧠 ' : '';
    const headingEmoji = emojiOk ? '📌 ' : '';

    const formatSteps = (arr: string[]) => arr.map((x, i) => `${stepEmoji}${i + 1}) ${x}`).join('\n');

    const intro =
      strict
        ? 'Bagrut Tutor (focused mode)\n'
        : 'Bagrut Tutor (friendly mode)\n';

    const brainLine = `AI Brain: ${brainHint}\n`;
    const sourcesLine = `Sources: ${refs}\n`;

    const steps = [
      'Derivative means the slope of the tangent line to the graph.',
      'It tells how fast the function changes at a specific x.',
      'For polynomials, use the power rule: d/dx(x^n) = n·x^(n-1).',
    ];

    const exampleLines = [
      'Example: f(x)=x² → f\'(x)=2x (power rule).',
      'At x=3: f\'(3)=6, so the slope of the tangent there is 6.',
    ];

    const mistakeLines = [
      'Common mistake: mixing f(x) with f\'(x). f\'(x) is a new function.',
      'Common mistake: forgetting the power rule (x² → 2x, not x).',
    ];

    const quiz = [
      'Quick check 1: If f(x)=x³, what is f\'(x)?',
      'Quick check 2: If f\'(2)=0, what does that suggest about the tangent at x=2?',
    ];
    if (!short) quiz.push('Bonus: If f\'(x) is positive on an interval, what is f(x) doing there?');

    let reply = '';
    reply += intro;
    reply += brainLine;
    if (!short) reply += sourcesLine;
    reply += `\nQ: ${question}\n\n`;

    reply += `${headingEmoji}Explanation:\n`;
    reply += explainStyle.includes('hints') ? formatSteps(steps) : steps.map(x => `${stepEmoji}${x}`).join('\n');

    reply += `\n\n${headingEmoji}Worked example:\n`;
    reply += explainStyle.includes('hints') ? formatSteps(exampleLines) : exampleLines.map(x => `${stepEmoji}${x}`).join('\n');

    reply += `\n\n${headingEmoji}Common mistake:\n`;
    reply += mistakeLines.map(x => `${warnEmoji}${x}`).join('\n');

    reply += `\n\n${quizEmoji}Mini-quiz:\n`;
    reply += quiz.map((x, i) => `${i + 1}) ${x}`).join('\n');

    if (excerpt && !short) {
      reply += `\n\n${headingEmoji}From your material:\n`;
      reply += excerpt;
    }

    reply += `\n\nReply with your quiz answers and I’ll check them.`;

    // Store ASSISTANT message
    const assistantMsg = await this.prisma.tutorMessage.create({
      data: {
        sessionId,
        role: 'ASSISTANT' as any,
        content: reply,
        sources: materials.map((m) => m.id),
      } as any,
    });

    await this.prisma.analyticsEvent.create({
      data: {
        actorUserId: studentId,
        actorRole: 'STUDENT' as any,
        cohortId: session.cohortId ?? null,
        courseId: session.courseId ?? null,
        studentId,
        name: 'tutor.reply.generated',
        payload: {
          sessionId,
          characterId: session.characterId,
          materialsUsed: materials.map((m) => m.id),
        },
      } as any,
    });

    return { ok: true, userMessage: userMsg, assistantMessage: assistantMsg };
  }

  private async ensureGlobalDefaultCharacters() {
    const subjects = ['GENERAL','MATH','PHYSICS','CS','ENGLISH','HEBREW','ARABIC'] as const;

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
            subj === 'MATH' ? 'Math Tutor'
            : subj === 'PHYSICS' ? 'Physics Tutor'
            : subj === 'CS' ? 'CS Tutor'
            : subj === 'ENGLISH' ? 'English Tutor'
            : subj === 'HEBREW' ? 'Hebrew Tutor'
            : subj === 'ARABIC' ? 'Arabic Tutor'
            : 'General Tutor',
          curriculum: 'bagrut',
          maxGrade: 12,
          language: 'en',
          tone: 'friendly',
          verbosity: 5,
          explainStyle: 'step-by-step',
          systemNotes: 'Bagrut level only. Adapt to learning profile and AI brain. Ask mini-quiz.',
        } as any,
      });
    }
  }

  async ensureDefaultCharactersAdmin(user: any) {
    const roles: string[] = user?.roles ?? [];
    if (!roles.includes('ADMIN') && !roles.includes('SECRETARY')) {
      throw new ForbiddenException('Admin/Secretary only');
    }
    await this.ensureGlobalDefaultCharacters();
    return { ok: true };
  }



  private normalizeTutorSubject(raw?: string) {
    const v = String(raw ?? '').trim().toUpperCase();
    if (!v) return 'GENERAL';
    // allow synonyms
    if (v === 'MATH' || v === 'MATHEMATICS') return 'MATH';
    if (v === 'PHYSICS' || v === 'PHY') return 'PHYSICS';
    if (v === 'CS' || v === 'COMPUTER_SCIENCE' || v === 'COMPUTERSCIENCE') return 'CS';
    if (v === 'ENGLISH' || v === 'ENG') return 'ENGLISH';
    if (v === 'HEBREW') return 'HEBREW';
    if (v === 'ARABIC') return 'ARABIC';
    return 'GENERAL';
  }

  private defaultCharacterName(subject: string) {
    switch (subject) {
      case 'MATH': return 'Math Tutor';
      case 'PHYSICS': return 'Physics Tutor';
      case 'CS': return 'CS Tutor';
      case 'ENGLISH': return 'English Tutor';
      case 'HEBREW': return 'Hebrew Tutor';
      case 'ARABIC': return 'Arabic Tutor';
      default: return 'General Tutor';
    }
  }



  async listCharacters(user: any, query?: { subject?: string }) {
    // students/admin/secretary allowed (controller will guard)
    const subject = query?.subject ? this.normalizeTutorSubject(query.subject) : undefined;

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
    if (!roles.includes('ADMIN') && !roles.includes('SECRETARY')) {
      throw new ForbiddenException('Admin/Secretary only');
    }

    const cohortId = dto?.cohortId ? String(dto.cohortId) : null;

    const subjects = ['GENERAL','MATH','PHYSICS','CS','ENGLISH','HEBREW','ARABIC'];
    const created: any[] = [];
    for (const subj of subjects) {
      const existing = await this.prisma.tutorCharacter.findFirst({
        where: { subject: subj as any, ...(cohortId ? { cohortId } : { cohortId: null }) },
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


}
