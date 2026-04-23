import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, requireRole } from "@/lib/authz";
import { findParentByUserId } from "@/lib/parent-access";

export async function GET(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;
  const forb = requireRole(a, ["PARENT", "ADMIN"]);
  if (forb) return forb;

  // admin: return empty for now (or wire later)
  if (a.role === "ADMIN") return NextResponse.json({ children: [] });

  const parentRow = await findParentByUserId(a.uid);
  if (!parentRow) return NextResponse.json({ children: [] });

  // Join: ParentStudent(parentId) -> Student -> User
  const links = await (prisma as any).parentStudent.findMany({
    where: { parentId: parentRow.id } as any,
    select: {
      student: {
        select: {
          id: true,
          grade: true,
          user: { select: { id: true, fullName: true, email: true } } as any,
          enrollments: {
            select: {
              class: {
                select: { id: true, name: true, grade: true } as any,
              },
            } as any,
            take: 1,
            orderBy: { createdAt: "desc" } as any,
          } as any,
        } as any,
      } as any,
    } as any,
    take: 200,
  });

  const children = links.map((x: any) => ({
    studentId: x.student.id,
    userId: x.student.user.id,
    name: x.student.user.fullName,
    fullName: x.student.user.fullName,
    email: x.student.user.email,
    grade: x.student.grade ?? null,
    status: "Linked",
    cohort: x.student.enrollments?.[0]?.class
      ? {
          id: x.student.enrollments[0].class.id,
          name: x.student.enrollments[0].class.name,
          grade: x.student.enrollments[0].class.grade,
        }
      : null,
  }));

  return NextResponse.json({ children });
}
