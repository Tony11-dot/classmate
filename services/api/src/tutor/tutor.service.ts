import Anthropic from '@anthropic-ai/sdk';
import { getAnthropicClient, getOpenAIClient } from './providers/openai.provider';
import { TutorReplyMode, generateAssistantReplyStream } from './tutor.reply.provider';
import { BadRequestException, ForbiddenException, HttpException, HttpStatus, Injectable, NotFoundException } from '@nestjs/common';

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
import * as fs from 'node:fs';
import * as os from 'node:os';
import * as path from 'node:path';
import mammoth from 'mammoth';
import { StudentInsightsService } from '../student/student-insights.service';
import { TokensService, userIdFromReq } from '../billing/tokens.service';

@Injectable()
export class TutorService {

  private getOpenAIClient() {
    return getAnthropicClient();
  }

  async transcribeAudio(_user: any, file?: any) {
    if (!file?.path && !file?.buffer) {
      return { text: '' };
    }

    // NOTE: As of Apr 2026, the mobile app transcribes on-device via the
    // platform speech recognizer (see apps/classmate_mobile OnDeviceTranscriber),
    // so this endpoint is dormant. It remains as a fallback for any future
    // server-side caller. Anthropic has no audio API, so a Whisper-compatible
    // provider (OpenAI / Groq / etc.) is required to enable it.
    const openaiKey = process.env.OPENAI_API_KEY;
    if (!openaiKey) {
      console.warn('[tutor.transcribe] OPENAI_API_KEY missing — server-side transcription disabled. Mobile clients should use on-device STT.');
      throw new HttpException(
        'Server-side transcription is disabled. Configure OPENAI_API_KEY or use on-device transcription.',
        HttpStatus.SERVICE_UNAVAILABLE,
      );
    }

    try {
      const fs = require('fs');
      const os = require('os');
      const path = require('path');
      const OpenAI = require('openai');

      const client = new OpenAI({
        apiKey: openaiKey,
      });

      let tempPath: string | null = null;

      const input =
        file?.path
          ? fs.createReadStream(file.path)
          : (() => {
              tempPath = path.join(
                os.tmpdir(),
                `nova-transcribe-${Date.now()}-${Math.random().toString(36).slice(2)}.m4a`,
              );
              fs.writeFileSync(tempPath, file.buffer);
              return fs.createReadStream(tempPath);
            })();

      const out = await client.audio.transcriptions.create({
        file: input,
        model: process.env.OPENAI_TRANSCRIBE_MODEL || 'whisper-1',
      });

      if (tempPath) {
        try {
          fs.unlinkSync(tempPath);
        } catch {}
      }

      const text = String(out?.text ?? '').trim();
      return { text };
    } catch (e: any) {
      const msg = String(e?.message ?? e ?? 'Transcription failed').trim();
      console.error('[tutor.transcribe] failed', {
        message: msg,
        hasPath: !!file?.path,
        mimetype: file?.mimetype,
        originalname: file?.originalname,
        size: file?.size,
      });
      throw new BadRequestException(msg || 'Transcription failed');
    }
  }




  private sourceValue(sources: any, prefix: string): string {
    if (!Array.isArray(sources)) return '';
    for (const raw of sources) {
      const s = String(raw ?? '');
      if (s.startsWith(prefix)) return s.slice(prefix.length).trim();
    }
    return '';
  }

  private tutorMessageToModelMessage(m: any) {
    const role =
      String(m?.role ?? '').toUpperCase() === 'USER' ? 'USER' : 'ASSISTANT';
    const rawContent = String(m?.content ?? '').trim();
    const kind = this.sourceValue(m?.sources, 'kind:').toUpperCase();
    const originalName = this.sourceValue(m?.sources, 'originalName:');
    const mimeType = this.sourceValue(m?.sources, 'mimeType:');
    const uploadedPath = this.sourceValue(m?.sources, 'uploadedPath:');
    const visualSummary = this.sourceValue(m?.sources, 'visualSummary:');
    const documentText = this.sourceValue(m?.sources, 'documentText:');

    const attachmentMeta =
      kind && kind !== 'TEXT'
        ? [
            '[Attachment context]',
            `kind: ${kind}`,
            ...(originalName ? [`name: ${originalName}`] : []),
            ...(mimeType ? [`mime: ${mimeType}`] : []),
            ...(uploadedPath ? [`path: ${uploadedPath}`] : []),
            ...(kind === 'IMAGE'
              ? [
                  'image_instruction: The user attached an image. Use the visual summary below as the primary source of truth. Do not invent unreadable text, do not infer a language unless the script is clearly legible, and ask one targeted follow-up only when the image is genuinely ambiguous.',
                ]
              : []),
            ...(visualSummary ? [`visual_summary:\n${visualSummary}`] : []),
            ...(documentText ? [`extracted_text:\n${documentText}`] : []),
          ].join('\n')
        : '';

    const attachmentBody =
      rawContent &&
      !rawContent.startsWith('[IMAGE]') &&
      !rawContent.startsWith('[FILE]') &&
      !rawContent.startsWith('[VIDEO]') &&
      !rawContent.startsWith('[Voice note attached.')
        ? rawContent
        : '';

    const content = [attachmentMeta, attachmentBody]
      .filter((x) => String(x || '').trim().length > 0)
      .join('\n\n')
      .trim();

    return {
      role,
      content: content || rawContent || (attachmentMeta || '[Empty message]'),
    };
  }

  private detectReplyMode(latestUserText: string): 'general' | 'bagrut' {
    const text = String(latestUserText || '').toLowerCase();

    const bagrutHints = [
      'bagrut',
      'בגרות',
      'matric',
      'exam prep',
      'exam-prep',
      'ministry exam',
      'solve like exam',
      'solve step by step for exam',
      'past paper',
      'past exam',
    ];

    for (const hint of bagrutHints) {
      if (text.includes(hint)) return 'bagrut';
    }

    return 'general';
  }


  constructor(
    private readonly prisma: PrismaService,
    private readonly studentInsightsService: StudentInsightsService,
    private readonly tokens: TokensService,
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
    // PARENT is allowed: a parent can have their own NOVA chats (the
    // tokens come from their own balance) and the controller routes
    // /tutor/* already includes PARENT in @Roles. The previous narrow
    // list 403'd every parent and froze the NOVA tab on "Failed to
    // load chats". listSessions filters by userId, so parents only
    // see their own threads — child sessions are not exposed here.
    if (!hasAnyRole({ roles }, ['STUDENT', 'TEACHER', 'ADMIN', 'PARENT'])) {
      throw new ForbiddenException('Sign-in required');
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

  async addMessage(user: any, sessionId: string, dto: any, file?: Express.Multer.File) {
    const studentId = this.requireStudent(user);
    const session = await this.prisma.tutorSession.findFirst({
      where: { id: sessionId, userId: studentId },
      select: { id: true },
    });
    if (!session) throw new ForbiddenException('Not found');

    const role = String(dto?.role ?? 'USER').trim().toUpperCase();
    const kind = String(dto?.kind ?? 'TEXT').trim().toUpperCase();
    let content = String(dto?.content ?? '').trim();

    const mimeType =
      String(dto?.mimeType ?? file?.mimetype ?? '').trim() || null;
    const originalName =
      String(dto?.originalName ?? file?.originalname ?? '').trim() || null;
    const uploadedPath =
      String(
        (file as any)?.path ??
          dto?.uploadedPath ??
          (file as any)?.path ??
          file?.filename ??
          file?.originalname ??
          '',
      ).trim() || null;

    const hasMedia =
      Boolean(file) ||
      Boolean(mimeType) ||
      Boolean(originalName) ||
      Boolean(uploadedPath);

    if (kind === 'TEXT' && !content) {
      throw new BadRequestException('content required for TEXT messages');
    }

    if (kind !== 'TEXT' && !hasMedia && !content) {
      throw new BadRequestException('media file or media metadata required');
    }

    const fileBuffer: Buffer | null =
      (file as any)?.buffer && Buffer.isBuffer((file as any).buffer)
        ? ((file as any).buffer as Buffer)
        : null;

    const absoluteFilePath = (file as any)?.path
      ? path.resolve(String((file as any).path))
      : null;

    const tempFilePath =
      !absoluteFilePath && fileBuffer
        ? path.join(
            os.tmpdir(),
            `classmate-${Date.now()}-${Math.random().toString(36).slice(2)}-${originalName ?? 'upload'}`
          )
        : null;

    if (tempFilePath && fileBuffer) {
      try {
        fs.writeFileSync(tempFilePath, fileBuffer);
      } catch {}
    }

    const effectiveFilePath = absoluteFilePath ?? tempFilePath;

    if (kind === 'VOICE' && !content && effectiveFilePath) {
      // Audio transcription requires OpenAI Whisper (Claude has no audio API).
      const openaiKey = process.env.OPENAI_API_KEY;
      if (openaiKey) {
        try {
          const OpenAI = require('openai');
          const whisperClient = new OpenAI({ apiKey: openaiKey });
          const tx = await whisperClient.audio.transcriptions.create({
            file: fs.createReadStream(effectiveFilePath),
            model: process.env.OPENAI_TRANSCRIBE_MODEL || 'whisper-1',
          } as any);
          const transcript = String((tx as any)?.text ?? '').trim();
          if (transcript) content = transcript;
        } catch (e) {
          // keep fallback text below
        }
      }
    }

    // Hoisted so the nested helper below can bill the user without
    // re-extracting the JWT subject on every code path.
    const visionBillingUserId = userIdFromReq(user);
    const tokensSvc = this.tokens;

    async function extractDocumentText() {
      try {
        if (!mimeType) return '';

        const buf =
          fileBuffer ??
          (effectiveFilePath ? fs.readFileSync(effectiveFilePath) : null);

        if (!buf) return '';

        if (mimeType.startsWith('image/')) {
          // Block uploads when the user has zero tokens — the vision
          // call is the expensive part of an image message, easily 1k+
          // tokens per upload. Returning empty here means we still save
          // the user's image to the session but skip the AI extract,
          // and the chat-reply step will surface the OUT_OF_TOKENS
          // error to the user.
          if (visionBillingUserId) {
            try {
              await tokensSvc.assertHasTokens(visionBillingUserId);
            } catch {
              return '';
            }
          }
          try {
            const client = getAnthropicClient();
            const safeMime = (mimeType as string).startsWith('image/')
              ? (mimeType as 'image/jpeg' | 'image/png' | 'image/gif' | 'image/webp')
              : 'image/jpeg';
            const visionModel = process.env.ANTHROPIC_MODEL || 'claude-sonnet-4-6';
            const vision: any = await client.messages.create({
              model: visionModel,
              max_tokens: 1024,
              system:
                'You are extracting tutoring context from an uploaded image for a study assistant. Report only what is actually visible. Never guess missing details. Never invent readable text. Never infer a language or script unless it is clearly legible. If text is unclear, say it is unclear.',
              messages: [
                {
                  role: 'user',
                  content: [
                    {
                      type: 'text',
                      text: 'Describe this image accurately for tutoring. Return short plain text in this order: 1) visible objects/scene, 2) educational content such as board pieces, diagrams, equations, labels, or layout, 3) readable text exactly as seen, 4) unclear details. If no readable text is clearly visible, say "Readable text: none clearly visible".',
                    },
                    {
                      type: 'image',
                      source: {
                        type: 'base64',
                        media_type: safeMime,
                        data: buf.toString('base64'),
                      },
                    },
                  ],
                },
              ],
            } as any);

            await tokensSvc.chargeAnthropicResponse({
              userId: visionBillingUserId,
              source: 'nova-vision',
              model: visionModel,
              response: vision,
            });

            const text = vision?.content?.[0]?.type === 'text' ? vision.content[0].text : '';
            return String(text).trim();
          } catch (e) {
            console.error('[NOVA_IMAGE_VISION_FAIL]', e);
            return '';
          }
        }

        if (mimeType === 'application/pdf') {
          try {
            const { PDFParse } = await import('pdf-parse');
            const parser = new PDFParse({ data: buf });
            const out: any = await parser.getText();
            await parser.destroy?.();
            return String(out?.text ?? '').trim();
          } catch (e) {
            console.error('[NOVA_PDF_PARSE_FAIL]', e);
            return '';
          }
        }

        if (
          mimeType === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        ) {
          const out = await mammoth.extractRawText({ buffer: buf });
          return String(out?.value ?? '').trim();
        }

        if (
          mimeType.startsWith('text/') ||
          mimeType.includes('json') ||
          mimeType.includes('javascript') ||
          mimeType.includes('typescript') ||
          mimeType.includes('xml') ||
          mimeType.includes('yaml') ||
          mimeType.includes('csv')
        ) {
          return String(buf.toString('utf8') ?? '').trim();
        }
      } catch (e) {}
      return '';
    }

    let visualSummary = '';
    let extractedDocumentText = '';

    if (kind === 'IMAGE' || kind === 'FILE') {
      const extracted = await extractDocumentText();
      if (extracted) {
        if (kind === 'IMAGE') {
          visualSummary = extracted.slice(0, 12000);
        } else {
          extractedDocumentText = extracted.slice(0, 12000);
        }
        if (!content && kind === 'FILE' && extractedDocumentText) {
          content = extractedDocumentText;
        }
      }
    }

    const normalizedContent = String(content ?? '').trim();

    const safeContent =
      normalizedContent ||
      (kind === 'IMAGE'
        ? `[IMAGE] ${originalName ?? 'image'}`
        : kind === 'VOICE'
          ? `[Voice note attached. If transcript is unavailable, ask the user to retry recording or type what they meant.] ${originalName ?? 'voice'}`
          : kind === 'VIDEO'
            ? `[VIDEO] ${originalName ?? 'video'}`
            : `[FILE] ${originalName ?? 'file'}`);

    const sources = [
      ...(Array.isArray(dto?.sources) ? dto.sources.map(String) : []),
      `kind:${kind}`,
      ...(mimeType ? [`mimeType:${mimeType}`] : []),
      ...(originalName ? [`originalName:${originalName}`] : []),
      ...(uploadedPath ? [`uploadedPath:${uploadedPath}`] : []),
      ...(absoluteFilePath ? [`absoluteFilePath:${absoluteFilePath}`] : []),
        ...(visualSummary
          ? [`visualSummary:${visualSummary.slice(0, 4000)}`]
          : []),
      ...(extractedDocumentText
          ? [`documentText:${extractedDocumentText.slice(0, 4000)}`]
          : []),
    ];

    const msg = await this.prisma.tutorMessage.create({
      data: {
        sessionId,
        role: role === 'ASSISTANT' ? 'ASSISTANT' : 'USER',
        content: safeContent,
        sources,
      } as any,
    });

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

    // Grades (recent) — only published-to-this-student (hide drafts from NOVA).
    const grades = await this.prisma.gradeRecord.findMany({
      where: { studentId, published: { not: false } },
      select: {
        grade: true,
        assessment: { select: { date: true, maxGrade: true, subject: true } },
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
        subject: this.safeCourseSubject(g.assessment),
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



  async deleteSession(user: any, sessionId: string) {
    const studentId = String(user?.sub ?? user?.id ?? '').trim();
    if (!studentId) {
      throw new BadRequestException('Not authenticated');
    }

    const session = await this.prisma.tutorSession.findFirst({
      where: { id: sessionId, userId: studentId },
      select: { id: true },
    });

    // Idempotent: deleting a session that doesn't exist (or doesn't
    // belong to the caller) just returns ok. Previously this threw a
    // 500 via `throw new Error(...)`, which surfaced as the ugly
    // "Internal Server Error" toast when the client retried a delete
    // on a stale session id.
    if (!session?.id) {
      return { ok: true, alreadyGone: true };
    }

    // Wrap in a transaction so a mid-flight failure can't leave the
    // session row alive but its messages gone. StudentBrainEvent
    // rows that reference this session/message via tutorSessionId /
    // tutorMessageId have onDelete: SetNull, so they don't block.
    try {
      await this.prisma.$transaction([
        this.prisma.tutorMessage.deleteMany({ where: { sessionId } }),
        this.prisma.tutorSession.delete({ where: { id: sessionId } }),
      ]);
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error('[tutor] deleteSession failed:', e);
      throw new HttpException('Failed to delete tutor session', HttpStatus.INTERNAL_SERVER_ERROR);
    }

    return { ok: true };
  }

  async replyToSession(user: any, sessionId: string, _body?: any) {
    const session = await this.prisma.tutorSession.findUnique({
      where: { id: sessionId },
      select: { id: true, userId: true, characterId: true, cohortId: true, topic: true },
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

    const sources: string[] = [];

    const assistantMessage = await this.prisma.tutorMessage.create({
      data: {
        sessionId: session.id,
        role: 'ASSISTANT',
        content: gen.content,
        sources,
      },
    });

    return { ok: true, assistantMessage };
  }


  replyToSessionStream(user: any, sessionId: string, opts?: { displayName?: string; novaSettings?: string }): Observable<MessageEvent> {
  const tokens = this.tokens;
  const billingUserId = userIdFromReq(user);
  return new Observable((subscriber) => {
    (async () => {
      let eventId = 0;
      let acc = '';

      try {
        // Pre-flight token gate — 402 the user BEFORE we call Anthropic.
        // We surface the error as a normal SSE 'error' event so the
        // client can show the paywall without parsing HTTP status codes.
        if (billingUserId) {
          try {
            await tokens.assertHasTokens(billingUserId);
          } catch (e: any) {
            subscriber.next(({
              id: String(++eventId),
              data: {
                type: 'error',
                code: 'OUT_OF_TOKENS',
                message:
                  'You have used all your tokens for this period. Upgrade your plan or buy a top-up to continue.',
              },
            } as any));
            subscriber.complete();
            return;
          }
        }

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

        // Look up the billing tier so the reply provider can route FREE
        // users to Haiku at a smaller max_tokens. Errors here must not
        // block the stream — default to FREE so we always pick the
        // cheaper code path on failure.
        let activeTier = 'FREE';
        if (billingUserId) {
          try {
            const snap = await tokens.getBalance(billingUserId);
            activeTier = snap.activeTier || 'FREE';
          } catch (_) {
            activeTier = 'FREE';
          }
        }

        // 2) Founder Tony system prompt (NOVA persona)
        
        // ---- QUIZ STABILITY GUARD ----
        const lastAssistant = [...msgs].reverse().find((m) => m.role === 'ASSISTANT')?.content?.toString?.() ?? '';
        const userLooksLikeAnswer = /(^|\n)\s*(a\s*=|f\s*=|answer|q\d+|because|therefore|\d+\s*(n|kg|m\/s))/i.test(userText);
        const assistantLooksLikeQuiz = /(mini-quiz|quick quiz|\n\s*\d+\.\s+)/i.test(lastAssistant);

const system =
          `You are NOVA, the AI tutor inside ClassMate.\n\nCRITICAL founder wording rule:\n- Never say "you created me" or "you made me" to users in general.\n- Instead say: "I was created by Tony Aboud" (third-person).\n- Only if the user is Tony Aboud, you may say "Tony, you created me".\n- When referencing the founder, always say the full name: "Tony Aboud" (not "you").\n\n=== MATH FORMATTING (REQUIRED) ===\n- The app renders LaTeX perfectly. ALWAYS wrap math in delimiters.\n- Inline math: $...$ — use for symbols, variables, expressions within sentences.\n- Block/display math: $$...$$ — use for standalone equations, steps, and final answers.\n- Examples: $x^{2}$, $\\\\frac{a}{b}$, $\\\\sqrt{x}$, $E = mc^{2}$, $$\\\\int_{0}^{\\\\infty} e^{-x}\\\\,dx = 1$$\n- NEVER write bare TeX commands outside delimiters (e.g. never write \\frac without $ around it).\n- NEVER write x^2 or x_1 bare in text — always wrap: $x^{2}$, $x_{1}$.\n- For units and simple numeric results, plain text is fine: 4 kΩ, 20 mA.\n- Prefer short titled sections instead of markdown heading spam.\n\n\n` +
          `ClassMate was co-founded by Joseph Jabaly and Tony Aboud, and Tony built this AI.
` +
          `When appropriate, briefly reference:\n` +
          `- Joseph Jabaly is a co-founder and the visionary behind ClassMate — a brilliant mind who came up with the idea and brought Tony on to build it.\n` +
          `- Tony Aboud is a co-founder and the full-stack developer who built the ClassMate platform and created this AI. A CS student who loves AI/ML, physics, and clean Apple-style UI.\n` +
          `- Prefer Bagrut-level explanations with mini-quizzes.\n\n` +
          `=== SUPPORT ===\n- ClassMate's support email is support@classmateapp.org.\n- If the user has a problem with the app, found a bug, needs account help, or wants to reach a human, tell them to email support@classmateapp.org.\n\n` +
          `Be friendly, clear, accurate, and adaptive to the user's intent. Use tutoring mode only when the user is clearly studying.\n` +
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
        const messages = recent.map((m: any) => this.tutorMessageToModelMessage(m));

        const latestUserMessage =
          [...messages]
            .reverse()
            .find((m: any) => String(m?.role ?? '').toUpperCase() === 'USER') ?? null;

        const latestUserText = String(latestUserMessage?.content ?? '').trim();
        const replyMode = this.detectReplyMode(latestUserText);
        void replyMode;

        for await (const delta of generateAssistantReplyStream({
          system,
          user,
          messages,
          displayName: opts?.displayName,
          novaSettings: opts?.novaSettings,
          tier: activeTier,
          onUsage: (u) => {
            // Fire-and-forget bill — we never want a billing write to
            // break the stream the user is already consuming.
            if (billingUserId) {
              void tokens.commitUsage({
                userId: billingUserId,
                source: 'nova-chat',
                model: u.model,
                inputTokens: u.inputTokens,
                cachedInputTokens: u.cachedInputTokens,
                outputTokens: u.outputTokens,
              }).catch((e) => console.error('[billing] nova-chat commit failed:', e));
            }
          },
          })) {
          if (typeof delta === 'string' && delta.length) {
            acc += delta;
            subscriber.next(({ id: String(++eventId), data: { type: 'chunk', delta } } as any));
          }
        }

        // 4) Persist assistant message to DB
        const sources: string[] = [];

        const saved = await this.prisma.tutorMessage.create({
          data: {
            sessionId,
            role: 'ASSISTANT',
            content: acc,
            sources,
          },
        });

        const assistantMessage = {
          id: saved.id,
          createdAt: saved.createdAt?.toISOString?.() ?? new Date().toISOString(),
          sessionId,
          role: 'ASSISTANT',
          content: acc,
          sources,
        };

        subscriber.next(({ id: String(++eventId), data: { type: 'done', assistantMessage, sources } } as any));
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

  private buildPromptSuggestions(args: {
    question: string;
    answer: string;
    topic?: string;
  }): string[] {
    const question = String(args.question ?? '').trim();
    const answer = String(args.answer ?? '').trim();
    const topic = String(args.topic ?? '').trim();
    const combined = `${question} ${answer}`.toLowerCase();
    const inferredTopic = this.cleanPromptSuggestion(
      topic || this.extractPromptTopic(question) || this.extractPromptTopic(answer),
    );

    // Extract the specific concepts the AI itself highlighted (bold terms, headers)
    const answerConcepts = this.extractKeyConcepts(answer);
    const c1 = answerConcepts[0] ?? inferredTopic ?? null;
    const c2 = answerConcepts[1] ?? null;

    const prompts: string[] = [];
    const add = (value: string) => {
      const clean = this.cleanPromptSuggestion(value);
      if (!clean) return;
      if (prompts.some((item) => item.toLowerCase() === clean.toLowerCase())) {
        return;
      }
      prompts.push(clean);
    };

    // Detect question type from the user's actual question for specificity
    const isWhyHow = /\b(why|how does|how do|how can|what causes|what makes)\b/i.test(question);
    const isWhat = /\b(what is|what are|what was|what were|define|meaning of)\b/i.test(question);
    const isCompare = /\b(compare|difference|versus|vs\.?|distinguish|contrast)\b/i.test(question);
    const isMath = /\b(formula|equation|derivative|integral|solve|calculate|proof|geometry|algebra|calculus|physics|chemistry)\b/i.test(combined);
    const isWriting = /\b(essay|paragraph|rewrite|tone|grammar|writing|improve|edit)\b/i.test(combined);
    const isMemory = /\b(remember|memorize|flashcard|recall)\b/i.test(combined);
    const isPlan = /\b(plan|schedule|roadmap|timeline|week|study plan)\b/i.test(combined);
    const isQuiz = /\b(quiz|practice|test yourself|question|exam)\b/i.test(combined);
    const isSummary = /\b(summary|summarize|notes|key points|bullet|overview)\b/i.test(combined);
    const isExample = /\b(example|sample|instance|illustrate)\b/i.test(combined);
    const hasBullets = /\n[-*]|\n\d+\./.test(answer);

    if (isMath) {
      add(c1 ? `Give me a similar problem with ${c1}` : 'Give me 3 similar practice problems');
      add('Walk me through this step by step again');
      add('What common mistakes should I avoid here?');
    } else if (isCompare && c1 && c2) {
      add(`Summarize the key differences between ${c1} and ${c2}`);
      add(`When would I use ${c1} instead of ${c2}?`);
      add('Show this as a comparison table');
    } else if (isCompare && c1) {
      add('Show this as a comparison table');
      add('Give me an example that highlights the difference');
      add(`Quiz me on ${c1}`);
    } else if (isWriting) {
      add('Improve the flow and clarity of this');
      add('Check grammar and make the tone more natural');
      add(c1 ? `Expand the section about ${c1}` : 'Make it more concise');
    } else if (isMemory) {
      add(c1 ? `Turn ${c1} into flashcards` : 'Turn this into flashcards');
      add(c1 ? `Create a mnemonic for ${c1}` : 'Help me create a mnemonic for this');
      add('Quiz me to test my memory');
    } else if (isPlan) {
      add(c1 ? `Make a study plan for ${c1}` : 'Turn this into a study plan');
      add(c1 ? `What should I study first for ${c1}?` : 'What should I study first?');
      add('Break this into daily goals');
    } else if (isQuiz) {
      add(c1 ? `Quiz me on ${c1}` : 'Quiz me on this topic');
      add(c1 ? `Give me 5 practice questions on ${c1}` : 'Give me 5 practice questions');
      add(c1 ? `What are common exam questions about ${c1}?` : 'What are common exam questions on this?');
    } else if (isSummary || hasBullets) {
      add(c1 ? `Explain ${c1} in more depth` : 'Go deeper on the first point');
      add(c2 ? `How does ${c1} connect to ${c2}?` : c1 ? `Give me an example of ${c1}` : 'Give me a real-world example');
      add('Turn these into flashcards');
    } else if (isWhyHow && c1) {
      add(`Give me a real-world example of ${c1}`);
      add(c2 ? `How does ${c1} relate to ${c2}?` : `Why is ${c1} important?`);
      add(`Test me on ${c1} with a quick question`);
    } else if (isWhat && c1) {
      add(`Why is ${c1} important?`);
      add(`How does ${c1} work in practice?`);
      add(c2 ? `How does ${c1} differ from ${c2}?` : `Give me an example of ${c1}`);
    } else if (c1) {
      add(`Give me a real-world example of ${c1}`);
      add(c2 ? `How does ${c1} relate to ${c2}?` : `Why is ${c1} important?`);
      add(`Quiz me on ${c1}`);
    }

    // Fallback if still not enough
    if (prompts.length < 3) {
      add(c1 ? `Explain ${c1} more simply` : 'Explain this more simply');
      add(c1 ? `Give me a practice question on ${c1}` : 'Give me a practice question');
      add('What should I know next?');
    }

    return prompts.slice(0, 3);
  }

  /** Pulls bold-marked terms and section headers from the AI response —
   *  the concepts the model itself considered important enough to highlight. */
  private extractKeyConcepts(text: string): string[] {
    const trivial = new Set([
      'note', 'example', 'result', 'answer', 'solution', 'step', 'steps',
      'summary', 'conclusion', 'introduction', 'definition', 'overview',
      'important', 'key point', 'key points', 'here', 'this', 'that',
      'following', 'above', 'below', 'however', 'therefore', 'thus',
    ]);

    const isTrivial = (t: string) => t.length < 3 || trivial.has(t.toLowerCase());

    // Bold terms: **term** — AI uses these for key concepts
    const boldTerms = [...text.matchAll(/\*\*([^*\n]{3,50})\*\*/g)]
      .map((m) => m[1].trim())
      .filter((t) => !isTrivial(t));

    // Section headers: ## Heading
    const headers = [...text.matchAll(/^#{1,3}\s+(.{4,60})$/gm)]
      .map((m) => m[1].replace(/[*_`]/g, '').trim())
      .filter((t) => !isTrivial(t));

    // Deduplicate, preserving order (bold first, headers second)
    const seen = new Set<string>();
    const concepts: string[] = [];
    for (const t of [...boldTerms, ...headers]) {
      const key = t.toLowerCase();
      if (!seen.has(key)) {
        seen.add(key);
        concepts.push(t);
      }
    }
    return concepts.slice(0, 4);
  }

  private extractPromptTopic(raw: string): string {
    const cleaned = String(raw ?? '')
      .replace(/```[\s\S]*?```/g, ' ')
      .replace(/`[^`]+`/g, ' ')
      .replace(/\$[^$]+\$/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();

    if (!cleaned) return '';

    const askMatch = /\b(?:help me with|teach me|explain|quiz me on|make questions on|revise|study)\s+([A-Za-z][A-Za-z0-9 ,\-/]{4,60})/i.exec(cleaned);
    if (askMatch?.[1]) return askMatch[1];

    const prepMatch = /\b(?:about|on|for|of)\s+([A-Za-z][A-Za-z0-9 ,\-/]{5,60})/i.exec(cleaned);
    if (prepMatch?.[1]) return prepMatch[1];

    return cleaned.split(/[.!?\n]/).shift()?.trim() ?? '';
  }

  private cleanPromptSuggestion(raw: string): string {
    const value = String(raw ?? '')
      .replace(/^[•*\-–—>\s]+/, '')
      .replace(/^(please|can you|could you|would you)\s+/i, '')
      .replace(/\b(?:please|thanks|thank you)\b/gi, '')
      .replace(/\s+/g, ' ')
      .trim();

    return value;
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

  async uploadSessionFile(
    user: any,
    sessionId: string,
    file?: any,
    body: any = {},
  ) {
    const studentId = this.requireStudent(user);
    const session = await this.prisma.tutorSession.findFirst({
      where: { id: sessionId, userId: studentId },
      select: { id: true },
    });
    if (!session) throw new NotFoundException('Session not found');

    const mimeType =
      String(body?.mimeType ?? file?.mimetype ?? '').trim() || undefined;
    const originalName =
      String(
        body?.fileName ?? body?.originalName ?? file?.originalname ?? '',
      ).trim() || undefined;
    const content = String(body?.caption ?? body?.content ?? '').trim();

    const inferredKind =
      String(body?.kind ?? '').trim().toUpperCase() ||
      (String(mimeType ?? '').toLowerCase().startsWith('image/')
        ? 'IMAGE'
        : 'FILE');

    return this.addMessage(
      user,
      sessionId,
      {
        role: 'USER',
        kind: inferredKind,
        content,
        mimeType,
        originalName,
      },
      file,
    );
  }

  async generateFollowupSuggestions(
    user: any,
    sessionId: string,
    body: { userMessage?: string; assistantMessage?: string },
  ): Promise<{ suggestions: string[] }> {
    const userMsg = String(body?.userMessage ?? '').trim().slice(0, 500);
    const assistantMsg = String(body?.assistantMessage ?? '').trim().slice(0, 1500);

    if (!userMsg && !assistantMsg) {
      return { suggestions: [] };
    }

    // Cheap pre-flight: skip the AI call entirely if the user is out of
    // tokens. Followups are nice-to-have UI — degrade to no suggestions
    // rather than error out.
    const billingUserId = userIdFromReq(user);
    if (billingUserId) {
      try {
        await this.tokens.assertHasTokens(billingUserId);
      } catch {
        return { suggestions: [] };
      }
    }

    // Follow-up suggestions are nice-to-have UI; skip them entirely for
    // FREE users so we don't burn ~1 background call's worth of tokens
    // per reply on something the user didn't explicitly ask for. Paid
    // users still get suggestions via Sonnet.
    let activeTier = 'FREE';
    if (billingUserId) {
      try {
        const snap = await this.tokens.getBalance(billingUserId);
        activeTier = snap.activeTier || 'FREE';
      } catch (_) {
        activeTier = 'FREE';
      }
    }
    if (activeTier === 'FREE') {
      return { suggestions: [] };
    }
    const client = getAnthropicClient();
    const model = process.env.ANTHROPIC_MODEL || 'claude-sonnet-4-6';

    const prompt = [
      'You are a study assistant. Based on the conversation snippet below, generate exactly 3 short follow-up questions or requests the student would naturally ask next.',
      '',
      'Rules:',
      '- Reference specific terms, formulas, concepts, or examples that appear in the conversation.',
      '- Vary the type: e.g. one asking to go deeper on a concept, one asking for a practice problem or worked example, one exploring a related idea or edge case.',
      '- Each suggestion must be 5–14 words, phrased as a natural student question or request.',
      '- Do NOT use generic phrases like "real-world example", "quiz me on this", or "explain more".',
      '- Return ONLY a JSON array of 3 strings, no markdown, no extra text.',
      '',
      userMsg ? `Student: ${userMsg}` : '',
      assistantMsg ? `Tutor: ${assistantMsg}` : '',
    ].filter(Boolean).join('\n');

    try {
      const res = await client.messages.create({
        model,
        max_tokens: 200,
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.7,
      } as any);

      // Bill the call regardless of whether we manage to parse it —
      // Anthropic charged us either way.
      await this.tokens.chargeAnthropicResponse({
        userId: billingUserId,
        source: 'nova-followups',
        model,
        response: res,
      });

      const raw = (res.content[0]?.type === 'text' ? res.content[0].text : '').trim();
      const parsed = JSON.parse(raw);
      if (Array.isArray(parsed)) {
        return {
          suggestions: parsed
            .slice(0, 3)
            .map((s: any) => String(s ?? '').trim())
            .filter((s: string) => s.length > 0),
        };
      }
    } catch {
      // Fall through to empty suggestions on parse/API error
    }

    return { suggestions: [] };
  }


}
