import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, requireRole } from "@/lib/authz";

export async function GET(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;
  const forb = requireRole(a, ["TEACHER", "ADMIN"]);
  if (forb) return forb;

  const teacherRow = await (prisma as any).teacher.findFirst({
    where: { userId: a.uid },
    select: { id: true } as any,
  });
  if (!teacherRow) return NextResponse.json({ classes: [] });

  const links = await (prisma as any).teachingAssignment.findMany({
    where: { teacherId: teacherRow.id, class: { schoolId: a.sid } } as any,
    select: {
      class: { select: { id: true, name: true, grade: true } } as any,
    } as any,
    orderBy: [{ class: { grade: "asc" } }, { class: { name: "asc" } }] as any,
  });

  const classes = links.map((x: any) => x.class);
  return NextResponse.json({ classes });
}
