import { BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { hasAnyRole } from '../auth/permissions';

export type ScheduleRole =
  | 'STUDENT'
  | 'PARENT'
  | 'ADMIN'
  | 'TEACHER'
  | 'SECRETARY';

export async function resolveCohortIdForSchedule(params: {
  prisma?: any;
  req?: any;
  request?: any;
  user?: any;
  cohortId?: string;
  childId?: string;
}): Promise<string> {
  const { prisma, req, request } = params as any;

  // Try to read user from common Nest request shapes
  const __reqAny: any =
    (typeof req !== 'undefined' ? (req as any) : undefined) ??
    (typeof request !== 'undefined' ? (request as any) : undefined) ??
    (params as any)?.req ??
    (params as any)?.request;

  const __user: any =
    (params as any)?.user ??
    __reqAny?.user ??
    __reqAny?.auth?.user ??
    __reqAny?.context?.user ??
    __reqAny?.payload;

  const __uid =
    __user?.id ??
    __user?.userId ??
    __user?.sub ??
    __user?.user?.id ??
    __user?.user?.userId ??
    __user?.user?.sub ??
    __user?.payload?.sub ??
    __user?.payload?.id;

  const __roles = (((__user?.roles ?? __user?.user?.roles ?? []) as any[]) as any[])
    .map((r: any) => (typeof r === 'string' ? r : r?.role ?? r?.name))
    .filter(Boolean)
    .map((x: any) => String(x).toUpperCase());

  const __isStudent =
    __roles.includes('STUDENT') ||
    __roles.includes('ROLE_STUDENT') ||
    __roles.includes('STUDENTS');

  const __isParent =
    __roles.includes('PARENT') ||
    __roles.includes('ROLE_PARENT') ||
    __roles.includes('PARENTS');

  const __isStaff =
    __roles.includes('ADMIN') ||
    __roles.includes('TEACHER') ||
    __roles.includes('SECRETARY') ||
    __roles.includes('ROLE_ADMIN') ||
    __roles.includes('ROLE_TEACHER') ||
    __roles.includes('ROLE_SECRETARY');

  const __p: any =
    (params as any)?.prisma ??
    (typeof prisma !== 'undefined' ? (prisma as any) : undefined);

  // STUDENT: forbid specifying cohortId via query; derive cohortId from DB by userId
  if (__isStudent) {
    const __requestedCohortId = __reqAny?.query?.cohortId;
    if (__requestedCohortId !== undefined) {
      throw new ForbiddenException('Students cannot specify cohortId');
    }

    const cidFromToken =
      __user?.studentProfile?.cohortId ??
      __user?.profile?.cohortId ??
      __user?.cohortId ??
      __user?.studentProfile?.cohort?.id ??
      null;

    if (cidFromToken) return String(cidFromToken);

    if (__uid && __p?.studentProfile?.findFirst) {
      const __sp =
        (await __p.studentProfile.findFirst({
          where: { userId: __uid },
          select: { cohortId: true },
        })) ??
        (await __p.studentProfile.findFirst({
          where: { userId: String(__uid) },
          select: { cohortId: true },
        })) ??
        (await __p.studentProfile
          .findFirst({
            where: { user: { id: __uid } },
            select: { cohortId: true },
          })
          .catch(() => null));

      if (__sp?.cohortId) return String(__sp.cohortId);
    }

    throw new BadRequestException('Student is missing cohortId');
  }

  // PARENT: resolve via link -> child.studentProfile.cohortId
  if (__isParent) {
    const childId = (params as any).childId;
    if (!childId) throw new BadRequestException('childId is required');

    const link = await __p?.parentStudentLink?.findFirst?.({
      where: { parentId: __uid, childId },
      include: { child: { select: { studentProfile: { select: { cohortId: true } } } } },
    });

    const cid = link?.child?.studentProfile?.cohortId;
    if (!cid) {
      throw new BadRequestException('Child has no cohortId (no StudentProfile?)');
    }
    return String(cid);
  }

  // STAFF: require cohortId
  const cohortId = (params as any).cohortId ?? null;
  if (!cohortId) throw new BadRequestException('cohortId is required');
  return String(cohortId);
}
