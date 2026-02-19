import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, requireRole } from "@/lib/authz";
import { z } from "zod";

const Body = z.object({ isPublished: z.boolean() });

export async function PATCH(req: Request, ctx: { params: Promise<{ id: string }> }) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;

  const forb = requireRole(a, ["TEACHER"]);
  if (forb) return forb;

  const { id } = await ctx.params;
  const body = Body.parse(await req.json());

  return await prisma.$transaction(async (tx) => {
    const teacher = await tx.teacher.findFirst({ where: { userId: a.uid }, select: { id: true } });
    if (!teacher) return NextResponse.json({ error: "TEACHER_NOT_FOUND" }, { status: 404 });

    const assessment = await tx.assessment.findUnique({
      where: { id },
      select: { id: true, classId: true, courseId: true },
    });
    if (!assessment) return NextResponse.json({ error: "ASSESSMENT_NOT_FOUND" }, { status: 404 });

    const assignment = await tx.teachingAssignment.findFirst({
      where: { teacherId: teacher.id, classId: assessment.classId, courseId: assessment.courseId },
      select: { id: true },
    });
    if (!assignment) return NextResponse.json({ error: "NOT_ASSIGNED" }, { status: 403 });

    const updated = await tx.assessment.update({
      where: { id },
      data: { isPublished: body.isPublished },
      select: { id: true, isPublished: true },
    });

    return NextResponse.json({ assessment: updated });
  });
}
