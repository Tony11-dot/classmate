import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, requireRole } from "@/lib/authz";
import { z } from "zod";

const Body = z.object({
  studentId: z.string().min(1),
  rawScore: z.number().min(0),
  adjustedScore: z.number().min(0).nullable().optional(),
  isFinal: z.boolean().optional(),
  feedback: z.string().optional(),
});

export async function POST(req: Request, ctx: { params: Promise<{ id: string }> }) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;

  const forb = requireRole(a, ["TEACHER"]);
  if (forb) return forb;

  const { id: assessmentId } = await ctx.params;
  const body = Body.parse(await req.json());

  return await prisma.$transaction(async (tx) => {
    const teacher = await tx.teacher.findFirst({
      where: { userId: a.uid },
      select: { id: true },
    });
    if (!teacher) return NextResponse.json({ error: "TEACHER_NOT_FOUND" }, { status: 404 });

    const assessment = await tx.assessment.findUnique({
      where: { id: assessmentId },
      select: { id: true, classId: true, courseId: true, maxScore: true },
    });
    if (!assessment) return NextResponse.json({ error: "ASSESSMENT_NOT_FOUND" }, { status: 404 });

    const assignment = await tx.teachingAssignment.findFirst({
      where: { teacherId: teacher.id, classId: assessment.classId, courseId: assessment.courseId },
      select: { id: true },
    });
    if (!assignment) return NextResponse.json({ error: "NOT_ASSIGNED" }, { status: 403 });

    const submission = await tx.submission.findUnique({
      where: { assessmentId_studentId: { assessmentId, studentId: body.studentId } },
      select: { id: true },
    });
    if (!submission) return NextResponse.json({ error: "SUBMISSION_NOT_FOUND" }, { status: 404 });

    const raw = Math.min(body.rawScore, assessment.maxScore);
    const adj = body.adjustedScore == null ? null : Math.min(body.adjustedScore, assessment.maxScore);

    const grade = await tx.grade.upsert({
      where: { submissionId_isFinal: { submissionId: submission.id, isFinal: true } },
      update: {
        rawScore: raw,
        adjustedScore: adj,
        feedback: body.feedback ?? null,
        gradedAt: new Date(),
      },
      create: {
        submissionId: submission.id,
        graderId: teacher.id,
        rawScore: raw,
        adjustedScore: adj,
        feedback: body.feedback ?? null,
        isFinal: body.isFinal ?? true,
        gradedAt: new Date(),
      },
      select: { id: true, rawScore: true, adjustedScore: true, feedback: true, isFinal: true, gradedAt: true },
    });

    return NextResponse.json({ grade });
  });
}
