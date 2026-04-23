import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { verifyToken } from "@/lib/auth";

function getAuth(req: Request) {
  const h = req.headers.get("authorization") || "";
  const m = h.match(/^Bearer\s+(.+)$/i);
  if (!m) return null;
  return verifyToken(m[1]);
}

export async function GET(req: Request) {
  const a = getAuth(req);
  if (!a) return NextResponse.json({ error: "unauthorized" }, { status: 401 });
  if (a.role !== "STUDENT")
    return NextResponse.json({ error: "forbidden" }, { status: 403 });

  const student = await prisma.student.findUnique({
    where: { userId: a.uid },
    select: { id: true },
  });

  if (!student)
    return NextResponse.json({ error: "student_not_found" }, { status: 404 });

  const assessments = await prisma.assessment.findMany({
    where: {
      isPublished: true,
      class: {
        enrollments: {
          some: { studentId: student.id },
        },
      },
    },
    orderBy: { dueDate: "asc" },
    select: {
      id: true,
      title: true,
      type: true,
      dueDate: true,
      maxScore: true,
      weight: true,
      class: { select: { id: true, name: true, grade: true } },
      course: { select: { id: true, name: true } },
      submissions: {
        where: { studentId: student.id },
        select: {
          id: true,
          status: true,
          submittedAt: true,
          grades: {
            where: { isFinal: true },
            select: { rawScore: true, adjustedScore: true, gradedAt: true },
            orderBy: { gradedAt: "desc" },
            take: 1,
          },
        },
        take: 1,
      },
    },
  });

  const formatted = assessments.map((a) => {
    const submission = a.submissions[0];
    const grade = submission?.grades[0];

    return {
      id: a.id,
      title: a.title,
      type: a.type,
      dueDate: a.dueDate,
      maxScore: a.maxScore,
      weight: a.weight,
      class: a.class,
      course: a.course,
      submission: submission
        ? { id: submission.id, status: submission.status, submittedAt: submission.submittedAt }
        : null,
      grade: grade
        ? { score: grade.adjustedScore ?? grade.rawScore, gradedAt: grade.gradedAt }
        : null,
    };
  });

  return NextResponse.json({ assessments: formatted });
}
