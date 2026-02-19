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
              classId: true,
              title: true,
            },
          },
        },
      },
    },
  });

  const map = new Map<string, { total: number; count: number }>();

  for (const g of grades) {
    const score = g.adjustedScore ?? g.rawScore;
    const key = g.submission.assessment.classId;

    if (!map.has(key)) {
      map.set(key, { total: 0, count: 0 });
    }

    const v = map.get(key)!;
    v.total += score;
    v.count += 1;
  }

  const result = Array.from(map.entries()).map(([classId, v]) => ({
    classId,
    average: v.count === 0 ? null : Number((v.total / v.count).toFixed(2)),
  }));

  return NextResponse.json({ classes: result });
}
