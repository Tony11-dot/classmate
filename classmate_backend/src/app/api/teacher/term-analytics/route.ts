import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, requireRole } from "@/lib/authz";

export async function GET(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;

  const forb = requireRole(a, ["TEACHER"]);
  if (forb) return forb;

  const teacher = await prisma.teacher.findFirst({
    where: { userId: a.uid },
    select: { id: true },
  });

  if (!teacher)
    return NextResponse.json({ error: "TEACHER_NOT_FOUND" }, { status: 404 });

  const grades = await prisma.grade.findMany({
    where: {
      isFinal: true,
      graderId: teacher.id,
    },
    select: {
      rawScore: true,
      adjustedScore: true,
      submission: {
        select: {
          assessment: {
            select: {
              termId: true,
              weight: true,
            },
          },
        },
      },
    },
  });

  const termMap = new Map<string, { total: number; weight: number }>();

  for (const g of grades) {
    const score = g.adjustedScore ?? g.rawScore;
    const weight = g.submission.assessment.weight;
    const termId = g.submission.assessment.termId;

    if (!termMap.has(termId)) {
      termMap.set(termId, { total: 0, weight: 0 });
    }

    const t = termMap.get(termId)!;
    t.total += score * weight;
    t.weight += weight;
  }

  const result = Array.from(termMap.entries()).map(([termId, v]) => ({
    termId,
    average: v.weight === 0 ? null : Number((v.total / v.weight).toFixed(2)),
  }));

  return NextResponse.json({ terms: result });
}
