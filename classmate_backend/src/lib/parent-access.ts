import { prisma } from "@/lib/prisma";

export async function findParentByUserId(userId: string) {
  return (prisma as any).parent.findFirst({
    where: { userId } as any,
    select: { id: true } as any,
  });
}

export async function getLinkedStudentIds(parentId: string) {
  const links = await (prisma as any).parentStudent.findMany({
    where: { parentId } as any,
    select: { studentId: true } as any,
    take: 500,
  });

  return links.map((link: any) => String(link.studentId));
}

export async function assertParentStudentAccess(userId: string, studentId: string) {
  const parent = await findParentByUserId(userId);
  if (!parent) return { ok: false as const, reason: "PARENT_NOT_FOUND" };

  const linkedStudentIds = await getLinkedStudentIds(parent.id);
  if (!linkedStudentIds.includes(studentId)) {
    return { ok: false as const, reason: "STUDENT_NOT_LINKED" };
  }

  return { ok: true as const, parentId: parent.id, linkedStudentIds };
}