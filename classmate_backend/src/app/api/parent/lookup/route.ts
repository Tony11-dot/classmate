import { NextResponse } from "next/server";

import { requireAuth, requireRole } from "@/lib/authz";
import { prisma } from "@/lib/prisma";
import { findParentByUserId, getLinkedStudentIds } from "@/lib/parent-access";

export async function GET(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;

  const forb = requireRole(a, ["PARENT", "ADMIN"]);
  if (forb) return forb;

  if (a.role === "ADMIN") {
    return NextResponse.json({ ok: true, students: [], courses: [] });
  }

  const parent = await findParentByUserId(a.uid);
  if (!parent) return NextResponse.json({ ok: true, students: [], courses: [] });

  const studentIds = await getLinkedStudentIds(parent.id);
  if (studentIds.length === 0) {
    return NextResponse.json({ ok: true, students: [], courses: [] });
  }

  const students = await prisma.student.findMany({
    where: { id: { in: studentIds } },
    select: {
      id: true,
      user: { select: { fullName: true } },
      enrollments: {
        select: {
          class: {
            select: {
              id: true,
              teachingAssignments: {
                select: {
                  course: { select: { id: true, name: true } },
                },
              },
            },
          },
        },
      },
    },
  });

  const studentItems = students.map((student) => ({
    id: student.id,
    name: student.user.fullName,
  }));

  const coursesMap = new Map<string, { id: string; name: string; subject: string; cohortId: string }>();
  for (const student of students) {
    for (const enrollment of student.enrollments) {
      for (const assignment of enrollment.class.teachingAssignments) {
        const course = assignment.course;
        if (!coursesMap.has(course.id)) {
          coursesMap.set(course.id, {
            id: course.id,
            name: course.name,
            subject: course.name,
            cohortId: enrollment.class.id,
          });
        }
      }
    }
  }

  return NextResponse.json({
    ok: true,
    students: studentItems,
    courses: Array.from(coursesMap.values()),
  });
}