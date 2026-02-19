import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, requireRole } from "@/lib/authz";
import { z } from "zod";

const Body = z.object({
  content: z.string().min(1).optional(),
});

export async function POST(req: Request, ctx: { params: Promise<{ id: string }> }) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;

  const forb = requireRole(a, ["STUDENT"]);
  if (forb) return forb;

  const { id: assessmentId } = await ctx.params;
  const body = Body.parse(await req.json().catch(() => ({})));

  return await prisma.$transaction(async (tx) => {
    const student = await tx.student.findFirst({
      where: { userId: a.uid },
      select: { id: true },
    });
    if (!student) return NextResponse.json({ error: "STUDENT_NOT_FOUND" }, { status: 404 });

    const assessment = await tx.assessment.findUnique({
      where: { id: assessmentId },
      select: { id: true, classId: true, isPublished: true },
    });
    if (!assessment) return NextResponse.json({ error: "ASSESSMENT_NOT_FOUND" }, { status: 404 });
    if (!assessment.isPublished) return NextResponse.json({ error: "NOT_PUBLISHED" }, { status: 403 });

    const enrolled = await tx.enrollment.findFirst({
      where: { studentId: student.id, classId: assessment.classId },
      select: { id: true },
    });
    if (!enrolled) return NextResponse.json({ error: "NOT_ENROLLED" }, { status: 403 });

    const data: any = {
      assessmentId,
      studentId: student.id,
      status: "SUBMITTED",
      submittedAt: new Date(),
    };

    if (body.content != null) data.content = body.content;

    const submission = await tx.submission.upsert({
      where: { assessmentId_studentId: { assessmentId, studentId: student.id } },
      update: data,
      create: data,
      select: { id: true, status: true, submittedAt: true },
    });

    return NextResponse.json({ submission });
  });
}
