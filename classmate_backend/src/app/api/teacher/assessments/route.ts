import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, requireRole } from "@/lib/authz";
import { z } from "zod";

const CreateBody = z.object({
  classId: z.string(),
  courseId: z.string(),
  termId: z.string(),
  type: z.enum(["HOMEWORK", "QUIZ", "EXAM", "PROJECT", "PARTICIPATION"]),
  title: z.string().min(1),
  description: z.string().optional(),
  dueDate: z.string(),
  maxScore: z.number().positive(),
  weight: z.number().positive().optional(),
  allowLate: z.boolean().optional(),
  latePenalty: z.number().min(0).optional(),
  isPublished: z.boolean().optional(),
});

export async function GET(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;

  const forb = requireRole(a, ["TEACHER"]);
  if (forb) return forb;

  const url = new URL(req.url);
  const classId = url.searchParams.get("classId") || undefined;
  const courseId = url.searchParams.get("courseId") || undefined;
  const termId = url.searchParams.get("termId") || undefined;
  const published = url.searchParams.get("published");
  const isPublished =
    published === "true" ? true : published === "false" ? false : undefined;

  const teacher = await prisma.teacher.findFirst({
    where: { userId: a.uid },
    select: { id: true },
  });
  if (!teacher)
    return NextResponse.json({ error: "TEACHER_NOT_FOUND" }, { status: 404 });

  const assignments = await prisma.teachingAssignment.findMany({
    where: { teacherId: teacher.id },
    select: { classId: true, courseId: true },
  });

  const classIds = [...new Set(assignments.map((x) => x.classId))];
  const courseIds = [...new Set(assignments.map((x) => x.courseId))];

  if (classIds.length === 0 || courseIds.length === 0)
    return NextResponse.json({ assessments: [] });

  const assessments = await prisma.assessment.findMany({
    where: {
      classId: { in: classIds },
      courseId: { in: courseIds },
      ...(classId ? { classId } : {}),
      ...(courseId ? { courseId } : {}),
      ...(termId ? { termId } : {}),
      ...(typeof isPublished === "boolean" ? { isPublished } : {}),
    },
    orderBy: [{ dueDate: "asc" }, { createdAt: "desc" }],
    take: 500,
    select: {
      id: true,
      title: true,
      type: true,
      description: true,
      dueDate: true,
      maxScore: true,
      weight: true,
      allowLate: true,
      latePenalty: true,
      isPublished: true,
      createdAt: true,
      updatedAt: true,
      class: { select: { id: true, name: true, grade: true } },
      course: { select: { id: true, name: true } },
      term: { select: { id: true, name: true } },
      _count: { select: { submissions: true } },
    },
  });

  return NextResponse.json({ assessments });
}

export async function POST(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;

  const forb = requireRole(a, ["TEACHER"]);
  if (forb) return forb;

  const body = CreateBody.parse(await req.json());

  return await prisma.$transaction(async (tx) => {
    const teacher = await tx.teacher.findFirst({
      where: { userId: a.uid },
      select: { id: true },
    });

    if (!teacher)
      return NextResponse.json({ error: "TEACHER_NOT_FOUND" }, { status: 404 });

    const classRow = await tx.classRoom.findFirst({
      where: { id: body.classId, schoolId: a.sid },
      select: { id: true },
    });

    if (!classRow)
      return NextResponse.json({ error: "CLASS_NOT_FOUND" }, { status: 404 });

    const courseRow = await tx.course.findFirst({
      where: { id: body.courseId, schoolId: a.sid },
      select: { id: true },
    });

    if (!courseRow)
      return NextResponse.json({ error: "COURSE_NOT_FOUND" }, { status: 404 });

    const termRow = await tx.term.findFirst({
      where: { id: body.termId },
      select: { id: true },
    });

    if (!termRow)
      return NextResponse.json({ error: "TERM_NOT_FOUND" }, { status: 404 });

    const assignment = await tx.teachingAssignment.findFirst({
      where: {
        teacherId: teacher.id,
        classId: body.classId,
        courseId: body.courseId,
      },
      select: { id: true },
    });

    if (!assignment)
      return NextResponse.json({ error: "NOT_ASSIGNED" }, { status: 403 });

    const assessment = await tx.assessment.create({
      data: {
        classId: body.classId,
        courseId: body.courseId,
        termId: body.termId,
        type: body.type,
        title: body.title,
        description: body.description,
        dueDate: new Date(body.dueDate),
        maxScore: body.maxScore,
        weight: body.weight ?? 1,
        allowLate: body.allowLate ?? false,
        latePenalty: body.latePenalty ?? 0,
        isPublished: body.isPublished ?? false,
      },
      select: {
        id: true,
        title: true,
        type: true,
        dueDate: true,
        maxScore: true,
        weight: true,
        isPublished: true,
      },
    });

    return NextResponse.json({ assessment });
  });
}
