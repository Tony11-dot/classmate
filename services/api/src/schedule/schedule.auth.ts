import { BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { hasAnyRole } from '../auth/permissions';

export type ScheduleRole =
  | 'STUDENT'
  | 'PARENT'
  | 'ADMIN'
  | 'TEACHER'
  | 'SECRETARY';

export async function resolveCohortIdForSchedule(params: {
  prisma: PrismaService;
  req: any;
  cohortId?: string;
  childId?: string;
}): Promise<string> {
  const { prisma, req, cohortId, childId } = params;
  const roles: string[] = req.user?.roles ?? [];

  // STUDENT: from own StudentProfile -> cohortId
  if (hasAnyRole({ roles }, ['STUDENT'])) {
    const u = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: { studentProfile: { select: { cohortId: true } } },
    });
    const cid = u?.studentProfile?.cohortId;
    if (!cid) throw new BadRequestException('Student is missing cohortId');
    return cid;
  }

  // PARENT: require childId and verify APPROVED link
  if (hasAnyRole({ roles }, ['PARENT'])) {
    if (!childId)
      throw new BadRequestException('childId is required for parents');

    const link = await prisma.parentChild.findFirst({
      where: { parentId: req.user.id, childId, status: 'APPROVED' },
      select: {
        child: { select: { studentProfile: { select: { cohortId: true } } } },
      },
    });

    const cid = link?.child?.studentProfile?.cohortId;
    if (!cid) {
      throw new BadRequestException(
        'Child has no cohortId (no StudentProfile?)',
      );
    }
    return cid;
  }

  // TEACHER/ADMIN/SECRETARY: require cohortId (fast MVP)
  if (!cohortId) throw new BadRequestException('cohortId is required');
  return cohortId;
}
