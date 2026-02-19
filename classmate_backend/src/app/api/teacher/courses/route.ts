import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, requireRole } from "@/lib/authz";

export async function GET(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;
  const forb = requireRole(a, ["TEACHER", "ADMIN"]);
  if (forb) return forb;

  const courses = await prisma.course.findMany({
    where: { teacherId: a.uid, cohort: { schoolId: a.sid } } as any,
    select: {
      id: true,
      name: true,
      subject: true,
      cohort: { select: { id: true, name: true, grade: true } } as any,
    } as any,
    orderBy: { name: "asc" } as any,
  });

  return NextResponse.json({ courses });
}
