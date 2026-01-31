import { ForbiddenException } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

export async function requireParentChild(
  prisma: PrismaClient,
  parentUserId: string,
  childUserId: string,
) {
  const link = await prisma.parentChild.findUnique({
    where: {
      parentId_childId: { parentId: parentUserId, childId: childUserId },
    },
    select: { status: true },
  });
  if (!link || link.status !== 'APPROVED')
    throw new ForbiddenException('Child not linked');
}

export async function parentAllowedChildIds(
  prisma: PrismaClient,
  parentUserId: string,
) {
  const rows = await prisma.parentChild.findMany({
    where: { parentId: parentUserId, status: 'APPROVED' },
    select: { childId: true },
  });
  return rows.map((r) => r.childId);
}

export async function teacherAllowedCourseIds(
  prisma: PrismaClient,
  teacherUserId: string,
) {
  const courses = await prisma.course.findMany({
    where: { teacherId: teacherUserId },
    select: { id: true },
  });
  return courses.map((c) => c.id);
}

export async function teacherAllowedCohortIds(
  prisma: PrismaClient,
  teacherUserId: string,
) {
  const cohorts = await prisma.course.findMany({
    where: { teacherId: teacherUserId },
    select: { cohortId: true },
  });
  return Array.from(
    new Set(cohorts.map((c) => c.cohortId).filter(Boolean)),
  ) as string[];
}
