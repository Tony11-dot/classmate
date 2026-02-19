import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, requireRole } from "@/lib/authz";

export async function GET(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;
  const forb = requireRole(a, ["PARENT", "ADMIN"]);
  if (forb) return forb;

  // admin: return empty for now (or wire later)
  if (a.role === "ADMIN") return NextResponse.json({ children: [] });

  const parentRow = await (prisma as any).parent.findFirst({
    where: { userId: a.uid } as any,
    select: { id: true } as any,
  });
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
        } as any,
      } as any,
    } as any,
    take: 200,
  });

  const children = links.map((x: any) => ({
    studentId: x.student.id,
    userId: x.student.user.id,
    fullName: x.student.user.fullName,
    email: x.student.user.email,
    grade: x.student.grade ?? null,
  }));

  return NextResponse.json({ children });
}
