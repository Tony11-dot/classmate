import { NextResponse } from "next/server";

import { requireAuth, requireRole } from "@/lib/authz";
import { prisma } from "@/lib/prisma";
import { assertParentStudentAccess } from "@/lib/parent-access";

export async function GET(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;

  const forb = requireRole(a, ["PARENT", "ADMIN"]);
  if (forb) return forb;

  const url = new URL(req.url);
  const studentId = url.searchParams.get("studentId")?.trim() ?? "";
  if (!studentId) {
    return NextResponse.json({ error: "STUDENT_ID_REQUIRED" }, { status: 400 });
  }

  if (a.role === "PARENT") {
    const access = await assertParentStudentAccess(a.uid, studentId);
    if (!access.ok) {
      return NextResponse.json({ error: access.reason }, { status: 403 });
    }
  }

  const grades = await prisma.grade.findMany({
    where: {
      isFinal: true,
      submission: {
        studentId,
      },
    },
    orderBy: { gradedAt: "desc" },
    select: {
      id: true,
      rawScore: true,
      adjustedScore: true,
      gradedAt: true,
      createdAt: true,
      feedback: true,
      submission: {
        select: {
          assessment: {
            select: {
              id: true,
              title: true,
              maxScore: true,
              dueDate: true,
              course: { select: { id: true, name: true } },
            },
          },
        },
      },
    },
  });

  return NextResponse.json({
    grades: grades.map((grade) => ({
      id: grade.id,
      assessmentId: grade.submission.assessment.id,
      assessmentName: grade.submission.assessment.title,
      title: grade.submission.assessment.title,
      courseId: grade.submission.assessment.course.id,
      courseName: grade.submission.assessment.course.name,
      score: grade.adjustedScore ?? grade.rawScore,
      maxScore: grade.submission.assessment.maxScore,
      feedback: grade.feedback,
      gradedAt: grade.gradedAt,
      createdAt: grade.createdAt,
      dueDate: grade.submission.assessment.dueDate,
    })),
  });
}