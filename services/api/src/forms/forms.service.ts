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
              // Gate the broadcast clause to records with NO narrower targeting, so a
              // grade-only item (stored as EVERYONE + targetGrades) no longer leaks
              // school-wide — it is matched by the targetGrades clause instead.
              { targetType: 'EVERYONE', targetCohortIds: { isEmpty: true }, targetStudentIds: { isEmpty: true }, targetGrades: { isEmpty: true } },
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
      if (dbForm) {
        // Audience check: without this, any authenticated user could read any
        // form (and its questions) by id. Staff/creator may always view; a
        // student may only view a published form that targets them.
        const scope = await this.resolveViewerScope(user);
        if (!this.canViewForm(dbForm, scope)) {
          throw new NotFoundException('Form not found');
        }
        return { ok: true, form: { id: dbForm.id, subject: dbForm.subject ?? '', title: dbForm.title, description: dbForm.description ?? '', teacher: 'Teacher', audienceLabel: dbForm.audienceLabel ?? 'Class', acceptingResponses: dbForm.acceptingResponses, allowMultipleResponses: dbForm.allowMultipleResponses, published: dbForm.published, publishedAt: dbForm.publishedAt?.toISOString() ?? null, questions: Array.isArray(dbForm.questions) ? dbForm.questions : [], summary: { responsesCount: 0, pendingCount: 0, completionRate: 0, averageDurationLabel: null, publishedLabel: null } } };
      }
    } catch (e: any) {
      if (e?.status === 404) throw e; // surface the audience denial
    }
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
        // Audience check: a student must be targeted by the form before they
        // can submit to it (was previously unchecked — any id was submittable).
        const scope = await this.resolveViewerScope(user);
        if (!this.canViewForm(dbForm, scope)) {
          throw new NotFoundException('Form not found');
        }
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
      if (e?.status === 409 || e?.status === 404) throw e; // conflict / audience denial
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

  /** Resolve the viewer's role + (for students) cohort/grade scope. */
  private async resolveViewerScope(user: any): Promise<{
    isStudent: boolean;
    isStaff: boolean;
    schoolId: string | null;
    uid: string;
    cohortIds: string[];
    grade: number | null;
  }> {
    const schoolId = (user as any)?.schoolId ?? null;
    const uid = String((user as any)?.sub ?? (user as any)?.id ?? '');
    const roles: string[] = Array.isArray((user as any)?.roles) ? (user as any).roles : [];
    const isStaff =
      roles.includes('TEACHER') || roles.includes('ADMIN') || roles.includes('SECRETARY');
    const isStudent = roles.includes('STUDENT') && !isStaff;
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
    return { isStudent, isStaff, schoolId, uid, cohortIds, grade };
  }

  /** Mirrors the live() audience filter for a single already-fetched form. */
  private canViewForm(
    form: any,
    scope: { isStaff: boolean; schoolId: string | null; uid: string; cohortIds: string[]; grade: number | null },
  ): boolean {
    // Same-school staff (and the creator) may always view.
    if (scope.isStaff && (!scope.schoolId || !form.schoolId || form.schoolId === scope.schoolId)) {
      return true;
    }
    if (form.createdBy && form.createdBy === scope.uid) return true;
    // Students: school must match, form must be published, and audience must hit.
    if (scope.schoolId && form.schoolId && form.schoolId !== scope.schoolId) return false;
    if (!form.published) return false;
    const noNarrowTargeting =
      (form.targetCohortIds?.length ?? 0) === 0 &&
      (form.targetStudentIds?.length ?? 0) === 0 &&
      (form.targetGrades?.length ?? 0) === 0;
    if (form.targetType === 'EVERYONE' && noNarrowTargeting) return true;
    if (Array.isArray(form.targetStudentIds) && form.targetStudentIds.includes(scope.uid)) return true;
    if (scope.cohortIds.some((c) => form.targetCohortIds?.includes(c))) return true;
    if (scope.grade != null && Array.isArray(form.targetGrades) && form.targetGrades.includes(scope.grade)) {
      return true;
    }
    return false;
  }

  private visibleForms(_user: any): PublishedForm[] {
    // Demo/static sample forms removed. Students and teachers now only ever
    // see real teacher-created forms (from SchoolForm). An empty school shows
    // an empty state instead of three hard-coded placeholder forms.
    return [];
  }
}