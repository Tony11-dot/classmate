import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, requireRole } from "@/lib/authz";

export async function GET(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;

  const forb = requireRole(a, ["ADMIN"]);
  if (forb) return forb;

  const grades = await prisma.grade.findMany({
    where: { isFinal: true },
    select: {
      rawScore: true,
      adjustedScore: true,
      submission: {
        select: {
          assessment: {
            select: {
              classId: true,
              weight: true,
            },
          },
        },
      },
    },
  });

  const classMap = new Map<string, { total: number; weight: number }>();

  for (const g of grades) {
    const score = g.adjustedScore ?? g.rawScore;
    const weight = g.submission.assessment.weight;
    const classId = g.submission.assessment.classId;

    if (!classMap.has(classId)) {
      classMap.set(classId, { total: 0, weight: 0 });
    }

    const c = classMap.get(classId)!;
    c.total += score * weight;
    c.weight += weight;
  }

  const result = Array.from(classMap.entries()).map(([classId, v]) => ({
    classId,
    average: v.weight === 0 ? null : Number((v.total / v.weight).toFixed(2)),
  }));

  return NextResponse.json({ classes: result });
}
