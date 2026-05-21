import { BadRequestException, ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

type FormQuestionType =
  | 'shortAnswer'
  | 'paragraph'
  | 'multipleChoice'
  | 'checkboxes'
  | 'dropdown'
  | 'linearScale';

type FormQuestion = {
  id: string;
  title: string;
  description?: string;
  type: FormQuestionType;
  required?: boolean;
  options?: string[];
  minScale?: number;
  maxScale?: number;
  stats?: {
    choiceStats?: Array<{ label: string; count: number; fraction: number }>;
    textSamples?: string[];
    averageScale?: number;
  };
};

type PublishedForm = {
  id: string;
  subject: string;
  title: string;
  description: string;
  teacher: string;
  audienceLabel: string;
  acceptingResponses: boolean;
  allowMultipleResponses: boolean;
  published: boolean;
  summary: {
    responsesCount: number;
    pendingCount: number;
    completionRate: number;
    averageDurationLabel: string;
    publishedLabel: string;
  };
  questions: FormQuestion[];
};

@Injectable()
export class FormsService {
  constructor(private readonly prisma: PrismaService) {}

  async live(user: any) {
    // Prefer real DB forms created by teachers; fall back to demo forms for empty schools
    const schoolId = (user as any)?.schoolId ?? null;
    const uid = String((user as any)?.sub ?? (user as any)?.id ?? '');
    // Pull the viewer's cohort + grade so we can filter by audience scope.
    // Teachers/admins get all published forms in the school (no filter);
    // students get filtered to forms that target them.
    const roles: string[] = Array.isArray((user as any)?.roles) ? (user as any).roles : [];
    const isStudent = roles.includes('STUDENT') && !roles.includes('TEACHER') && !roles.includes('ADMIN');
    let cohortIds: string[] = [];
    let grade: number | null = null;
    if (isStudent && uid) {
      const [links, profile] = await Promise.all([
        this.prisma.studentCohort.findMany({
          where: { studentId: uid },
          select: { cohortId: true },
        }),
        this.prisma.studentProfile.findUnique({
          where: { userId: uid },
          select: { grade: true },
        }),
      ]);
      cohortIds = links.map((c) => c.cohortId);
      grade = profile?.grade ?? null;
    }
    try {
      const dbForms = await this.prisma.schoolForm.findMany({
        where: {
          published: true,
          acceptingResponses: true,
          ...(schoolId ? { schoolId } : {}),
          ...(isStudent ? {
            OR: [
              { targetType: 'EVERYONE' },
              { targetStudentIds: { has: uid } },
              ...(cohortIds.length ? [{ targetCohortIds: { hasSome: cohortIds } }] : []),
              ...(grade != null ? [{ targetGrades: { has: grade } }] : []),
            ],
          } : {}),
        },
        orderBy: { publishedAt: 'desc' },
        take: 50,
      });
      if (dbForms.length > 0) {
        return {
          ok: true,
          items: dbForms.map((f) => ({
            id: f.id,
            subject: f.subject ?? '',
            title: f.title,
            description: f.description ?? '',
            teacher: 'Teacher',
            audienceLabel: f.audienceLabel ?? 'Class',
            acceptingResponses: f.acceptingResponses,
            allowMultipleResponses: f.allowMultipleResponses,
            published: f.published,
            publishedAt: f.publishedAt?.toISOString() ?? null,
            questions: Array.isArray(f.questions) ? f.questions : [],
            summary: { responsesCount: 0, pendingCount: 0, completionRate: 0, averageDurationLabel: null, publishedLabel: null },
          })),
        };
      }
    } catch (_) {}
    return { ok: true, items: this.visibleForms(user) };
  }

  async byId(user: any, id: string) {
    // Check real DB first
    try {
      const dbForm = await this.prisma.schoolForm.findUnique({ where: { id } });
      if (dbForm) return { ok: true, form: { id: dbForm.id, subject: dbForm.subject ?? '', title: dbForm.title, description: dbForm.description ?? '', teacher: 'Teacher', audienceLabel: dbForm.audienceLabel ?? 'Class', acceptingResponses: dbForm.acceptingResponses, allowMultipleResponses: dbForm.allowMultipleResponses, published: dbForm.published, publishedAt: dbForm.publishedAt?.toISOString() ?? null, questions: Array.isArray(dbForm.questions) ? dbForm.questions : [], summary: { responsesCount: 0, pendingCount: 0, completionRate: 0, averageDurationLabel: null, publishedLabel: null } } };
    } catch (_) {}
    const form = this.visibleForms(user).find((item) => item.id === id);
    if (!form) throw new NotFoundException('Form not found');
    return { ok: true, form };
  }

  async submit(user: any, id: string, body: any) {
    const answers = body?.answers ?? body ?? {};
    const userId = String((user as any)?.sub ?? (user as any)?.id ?? '').trim();

    // Try DB form first
    try {
      const dbForm = await this.prisma.schoolForm.findUnique({ where: { id } });
      if (dbForm) {
        if (!dbForm.acceptingResponses) return { ok: false, error: 'This form is closed.' };
        // Validate required questions
        const questions = Array.isArray(dbForm.questions) ? dbForm.questions as any[] : [];
        for (const q of questions) {
          if (!q.required) continue;
          const val = answers[q.id];
          if (val === null || val === undefined || (typeof val === 'string' && !val.trim()) || (Array.isArray(val) && !val.length)) {
            return { ok: false, error: `Required: ${q.title}` };
          }
        }
        // Persist response
        const studentProfile = userId ? await this.prisma.studentProfile.findUnique({ where: { userId }, select: { userId: true } }) : null;
        if (studentProfile) {
          const existingResponse = await this.prisma.formResponse.findUnique({ where: { formId_studentId: { formId: id, studentId: userId } } });
          if (existingResponse && !dbForm.allowMultipleResponses) {
            throw new ConflictException('You have already submitted this form');
          }
          await this.prisma.formResponse.create({ data: { formId: id, studentId: userId, answers } });
        }
        return { ok: true, message: 'Response recorded. Thank you!' };
      }
    } catch (e: any) {
      if (e?.status === 409) throw e; // Re-throw conflict
    }

    // Fall back to legacy in-memory forms
    const form = this.visibleForms(user).find((item) => item.id === id);
    if (!form) throw new NotFoundException('Form not found');
    if (!form.acceptingResponses) return { ok: false, error: 'This form is closed.' };
    for (const question of form.questions) {
      if (!question.required) continue;
      const value = answers[question.id];
      const empty = value === null || value === undefined || (typeof value === 'string' && !value.trim()) || (Array.isArray(value) && !value.length);
      if (empty) return { ok: false, error: `Required: ${question.title}` };
    }
    return { ok: true, message: 'Response recorded. Thank you!' };
  }

  private visibleForms(user: any): PublishedForm[] {
    const roles = new Set<string>((user?.roles ?? []).map((role: any) => `${role}`.toUpperCase()));
    const teacherLike = roles.has('TEACHER') || roles.has('ADMIN');
    const audience = teacherLike ? 'School-wide responses' : 'Your classroom';

    return [
      {
        id: 'nova-study-checkin',
        subject: 'Advisory',
        title: 'NOVA Study Habits Check-In',
        description:
          'A short weekly form for understanding what students are revising, where NOVA is helping most, and which topics need teacher follow-up.',
        teacher: 'NOVA Team',
        audienceLabel: audience,
        acceptingResponses: true,
        allowMultipleResponses: false,
        published: true,
        summary: {
          responsesCount: 38,
          pendingCount: 7,
          completionRate: 84.4,
          averageDurationLabel: '2 min',
          publishedLabel: 'Published this week',
        },
        questions: [
          {
            id: 'main-subject',
            title: 'Which subject needs the most help this week?',
            type: 'dropdown',
            required: true,
            options: ['Math', 'English', 'Biology', 'History', 'Physics'],
            stats: {
              choiceStats: [
                { label: 'Math', count: 15, fraction: 0.39 },
                { label: 'English', count: 8, fraction: 0.21 },
                { label: 'Biology', count: 7, fraction: 0.18 },
              ],
            },
          },
          {
            id: 'nova-usage',
            title: 'How useful was NOVA this week?',
            type: 'linearScale',
            required: true,
            minScale: 1,
            maxScale: 5,
            stats: { averageScale: 4.2 },
          },
          {
            id: 'topic-help',
            title: 'What topic should your teacher review next?',
            type: 'paragraph',
            stats: {
              textSamples: [
                'Quadratic functions and graph transformations.',
                'More help with text evidence in English answers.',
              ],
            },
          },
        ],
      },
      {
        id: 'mock-exam-reflection',
        subject: 'Assessment',
        title: 'Mock Exam Reflection',
        description:
          'Capture how the last mock exam felt, where time was lost, and what support students want before the next assessment block.',
        teacher: 'Assessment Office',
        audienceLabel: audience,
        acceptingResponses: true,
        allowMultipleResponses: true,
        published: true,
        summary: {
          responsesCount: 52,
          pendingCount: 11,
          completionRate: 82.5,
          averageDurationLabel: '3 min',
          publishedLabel: 'Published 2 days ago',
        },
        questions: [
          {
            id: 'confidence',
            title: 'How confident did you feel before the exam?',
            type: 'multipleChoice',
            required: true,
            options: ['Very confident', 'Mostly ready', 'Unsure', 'Underprepared'],
            stats: {
              choiceStats: [
                { label: 'Mostly ready', count: 21, fraction: 0.40 },
                { label: 'Unsure', count: 18, fraction: 0.35 },
                { label: 'Underprepared', count: 9, fraction: 0.17 },
              ],
            },
          },
          {
            id: 'time-loss',
            title: 'Where did you lose the most time?',
            type: 'checkboxes',
            options: [
              'Reading the prompt',
              'Planning answers',
              'Checking work',
              'Calculations',
            ],
            stats: {
              choiceStats: [
                { label: 'Planning answers', count: 26, fraction: 0.50 },
                { label: 'Calculations', count: 19, fraction: 0.37 },
              ],
            },
          },
          {
            id: 'support-needed',
            title: 'What would help most before the next exam?',
            type: 'shortAnswer',
            stats: {
              textSamples: [
                'A worked example set with timing guidance.',
                'A revision checklist for formulas and method choice.',
              ],
            },
          },
        ],
      },
      {
        id: 'school-communication-preferences',
        subject: 'Operations',
        title: 'School Communication Preferences',
        description:
          'A quick operations form for how families and students want to receive updates, reminder timing, and urgent notice preferences.',
        teacher: 'School Office',
        audienceLabel: teacherLike ? 'Staff and families' : 'Students and families',
        acceptingResponses: false,
        allowMultipleResponses: false,
        published: true,
        summary: {
          responsesCount: 128,
          pendingCount: 0,
          completionRate: 100,
          averageDurationLabel: '1 min',
          publishedLabel: 'Closed',
        },
        questions: [
          {
            id: 'preferred-channel',
            title: 'Preferred update channel',
            type: 'multipleChoice',
            required: true,
            options: ['In-app notification', 'Email', 'SMS', 'WhatsApp'],
            stats: {
              choiceStats: [
                { label: 'In-app notification', count: 55, fraction: 0.43 },
                { label: 'WhatsApp', count: 39, fraction: 0.30 },
                { label: 'Email', count: 25, fraction: 0.20 },
              ],
            },
          },
          {
            id: 'timing',
            title: 'Best time for reminders',
            type: 'dropdown',
            options: ['Morning', 'After school', 'Evening'],
            stats: {
              choiceStats: [
                { label: 'Evening', count: 49, fraction: 0.38 },
                { label: 'After school', count: 44, fraction: 0.34 },
              ],
            },
          },
        ],
      },
    ];
  }
}