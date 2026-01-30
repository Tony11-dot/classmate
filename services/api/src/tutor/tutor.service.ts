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
    const characterId = dto?.characterId ? String(dto.characterId) : null;

    const row = await this.prisma.tutorSession.create({
      data: {
        userId: studentId,
        subject,
        characterId: characterId ?? undefined,
        title: dto?.title ? String(dto.title) : null,
      } as any,
    });

    return { ok: true, session: row };
  }

  async listSessions(user: any) {
    const studentId = this.requireStudent(user);
    const rows = await this.prisma.tutorSession.findMany({
      where: { userId: studentId },
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

    // Build deterministic assistant reply (LLM comes Day 4)
    const tone = profile?.tone ?? session.character?.tone ?? 'friendly';
    const explainStyle = profile?.explainStyle ?? session.character?.explainStyle ?? 'step-by-step';
    const brainHint = brain?.metrics ? JSON.stringify(brain.metrics).slice(0, 240) : '(none yet)';
    const refs = materials.length ? materials.map((m) => m.title).slice(0, 5).join(' | ') : '(no materials found)';

    const reply =
      'Bagrut-level tutor reply\n'
      + 'Style: ' + tone + ', ' + explainStyle + '\n'
      + 'AI Brain: ' + brainHint + '\n'
      + 'Sources: ' + refs + '\n\n'
      + 'Q: ' + question + '\n\n'
      + 'Answer (Bagrut scope):\n'
      + '1) Key idea\n'
      + '2) Small example\n'
      + '3) Common mistake\n'
      + '4) Quick check question';

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

}
