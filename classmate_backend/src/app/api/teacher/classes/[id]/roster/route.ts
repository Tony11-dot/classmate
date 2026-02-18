import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, requireRole } from "@/lib/authz";

export async function GET(req: Request, ctx: { params: Promise<{ id: string }> }) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;
  const forb = requireRole(a, ["TEACHER", "ADMIN"]);
  if (forb) return forb;

  const { id: classId } = await ctx.params;

  const teacherRow = await (prisma as any).teacher.findFirst({
    where: { userId: a.uid },
    select: { id: true } as any,
  });

  if (a.role !== "ADMIN") {
    if (!teacherRow) return NextResponse.json({ error: "FORBIDDEN" }, { status: 403 });
    const has = await (prisma as any).teachingAssignment.findFirst({
      where: { teacherId: teacherRow.id, classId, class: { schoolId: a.sid } } as any,
      select: { classId: true } as any,
    });
    if (!has) return NextResponse.json({ error: "FORBIDDEN" }, { status: 403 });
  }

  const rows = await (prisma as any).enrollment.findMany({
    where: { classId, class: { schoolId: a.sid } } as any,
    select: {
      student: {
        select: {
          id: true,
          user: { select: { id: true, fullName: true, email: true } } as any,
        },
      } as any,
    } as any,
    take: 500,
  });

  const students = rows.map((r: any) => ({
    studentId: r.student.id,
    userId: r.student.user.id,
    fullName: r.student.user.fullName,
    email: r.student.user.email,
  }));

  return NextResponse.json({ students });
}
