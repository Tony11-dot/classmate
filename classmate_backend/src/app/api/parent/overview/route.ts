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

  const student = await prisma.student.findUnique({
    where: { id: studentId },
    select: {
      id: true,
      grade: true,
      user: { select: { fullName: true, email: true } },
      enrollments: {
        select: {
          class: { select: { id: true, name: true, grade: true } },
        },
        take: 1,
        orderBy: { createdAt: "desc" },
      },
    },
  });

  if (!student) {
    return NextResponse.json({ error: "STUDENT_NOT_FOUND" }, { status: 404 });
  }

  return NextResponse.json({
    student: {
      id: student.id,
      name: student.user.fullName,
      email: student.user.email,
      grade: student.grade,
      cohort: student.enrollments[0]?.class
        ? {
            id: student.enrollments[0].class.id,
            name: student.enrollments[0].class.name,
            grade: student.enrollments[0].class.grade,
          }
        : null,
    },
    capabilities: {
      schedule: false,
      attendance: false,
    },
    todaySchedule: { slots: [] },
    todayAttendance: { sessions: [] },
  });
}