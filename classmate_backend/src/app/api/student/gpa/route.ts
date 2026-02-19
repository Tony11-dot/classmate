import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, requireRole } from "@/lib/authz";

function scoreToPoints(score: number): number {
  if (score >= 90) return 4.0;
  if (score >= 80) return 3.0;
  if (score >= 70) return 2.0;
  if (score >= 60) return 1.0;
  return 0.0;
}

export async function GET(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;

  const forb = requireRole(a, ["STUDENT"]);
  if (forb) return forb;

  const student = await prisma.student.findFirst({
    where: { userId: a.uid },
    select: { id: true },
  });

  if (!student)
    return NextResponse.json({ error: "STUDENT_NOT_FOUND" }, { status: 404 });

  const grades = await prisma.grade.findMany({
    where: {
      isFinal: true,
      submission: {
        studentId: student.id,
      },
    },
    select: {
      rawScore: true,
      adjustedScore: true,
      submission: {
        select: {
          assessment: {
            select: {
              weight: true,
            },
          },
        },
      },
    },
  });

  let totalPoints = 0;
  let totalWeight = 0;

  for (const g of grades) {
    const score = g.adjustedScore ?? g.rawScore;
    const weight = g.submission.assessment.weight;
    const points = scoreToPoints(score);

    totalPoints += points * weight;
    totalWeight += weight;
  }

  const gpa =
    totalWeight === 0
      ? null
      : Number((totalPoints / totalWeight).toFixed(2));

  return NextResponse.json({ gpa });
}
