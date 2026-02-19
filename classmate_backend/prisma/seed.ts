import { PrismaClient, Role } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function upsertSchool() {
  return prisma.school.upsert({
    where: { id: "demo" },
    update: { name: "Demo School" },
    create: { id: "demo", name: "Demo School" },
    select: { id: true },
  });
}

async function upsertUser(params: {
  schoolId: string;
  email: string;
  password: string;
  role: Role;
  fullName: string;
}) {
  const email = params.email.toLowerCase();
  const passwordHash = await bcrypt.hash(params.password, 10);

  return prisma.user.upsert({
    where: { schoolId_email: { schoolId: params.schoolId, email } },
    update: {
      role: params.role,
      fullName: params.fullName,
      // keep existing passwordHash unless you want to rotate:
      // passwordHash,
    },
    create: {
      schoolId: params.schoolId,
      email,
      passwordHash,
      role: params.role,
      fullName: params.fullName,
    },
    select: { id: true, schoolId: true, email: true, role: true },
  });
}

async function ensureRoleRows(userId: string, role: Role) {
  if (role === "TEACHER") {
    await prisma.teacher.upsert({
      where: { userId },
      update: {},
      create: { userId },
      select: { id: true },
    });
  }
  if (role === "STUDENT") {
    await prisma.student.upsert({
      where: { userId },
      update: { grade: 9 },
      create: { userId, grade: 9 },
      select: { id: true },
    });
  }
  if (role === "PARENT") {
    await prisma.parent.upsert({
      where: { userId },
      update: {},
      create: { userId },
      select: { id: true },
    });
  }
}

async function main() {
  const school = await upsertSchool();

  const admin = await upsertUser({
    schoolId: school.id,
    email: "admin@demo.com",
    password: "admin123",
    role: "ADMIN",
    fullName: "Admin Demo",
  });
  await ensureRoleRows(admin.id, "ADMIN");

  const teacherUser = await upsertUser({
    schoolId: school.id,
    email: "teacher@demo.com",
    password: "teacher123",
    role: "TEACHER",
    fullName: "Teacher Demo",
  });
  const teacher = await prisma.teacher.upsert({
    where: { userId: teacherUser.id },
    update: {},
    create: { userId: teacherUser.id },
    select: { id: true },
  });

  const parentUser = await upsertUser({
    schoolId: school.id,
    email: "parent@demo.com",
    password: "parent123",
    role: "PARENT",
    fullName: "Parent Demo",
  });
  const parent = await prisma.parent.upsert({
    where: { userId: parentUser.id },
    update: {},
    create: { userId: parentUser.id },
    select: { id: true },
  });

  const studentUser = await upsertUser({
    schoolId: school.id,
    email: "student@demo.com",
    password: "student123",
    role: "STUDENT",
    fullName: "Student Demo",
  });
  const student = await prisma.student.upsert({
    where: { userId: studentUser.id },
    update: { grade: 9 },
    create: { userId: studentUser.id, grade: 9 },
    select: { id: true, userId: true },
  });

  // class
  const classRoom = await prisma.classRoom.upsert({
    where: { id: "demo-9a" },
    update: { name: "9A", grade: 9, schoolId: school.id },
    create: { id: "demo-9a", name: "9A", grade: 9, schoolId: school.id },
    select: { id: true },
  });

  // course
  const course = await prisma.course.upsert({
    where: { id: "demo-math" },
    update: { name: "Math", schoolId: school.id },
    create: { id: "demo-math", name: "Math", schoolId: school.id },
    select: { id: true },
  });

  // academic year + term (unique by id)
  const year = await prisma.academicYear.upsert({
    where: { id: "demo-2025-2026" },
    update: {
      schoolId: school.id,
      name: "2025–2026",
      startDate: new Date("2025-09-01T00:00:00.000Z"),
      endDate: new Date("2026-06-30T00:00:00.000Z"),
      isActive: true,
    },
    create: {
      id: "demo-2025-2026",
      schoolId: school.id,
      name: "2025–2026",
      startDate: new Date("2025-09-01T00:00:00.000Z"),
      endDate: new Date("2026-06-30T00:00:00.000Z"),
      isActive: true,
    },
    select: { id: true },
  });

  const term = await prisma.term.upsert({
    where: { id: "demo-term-1" },
    update: { academicYearId: year.id, name: "Term 1", weight: 1 },
    create: { id: "demo-term-1", academicYearId: year.id, name: "Term 1", weight: 1 },
    select: { id: true },
  });

  // enrollment (unique: [classId, studentId])
  await prisma.enrollment.upsert({
    where: { classId_studentId: { classId: classRoom.id, studentId: student.id } },
    update: {},
    create: { classId: classRoom.id, studentId: student.id },
    select: { id: true },
  });

  // parent link (unique: [parentId, studentId])
  await prisma.parentStudent.upsert({
    where: { parentId_studentId: { parentId: parent.id, studentId: student.id } },
    update: {},
    create: { parentId: parent.id, studentId: student.id },
    select: { id: true },
  });

  // teaching assignment (unique: [teacherId, classId, courseId])
  await prisma.teachingAssignment.upsert({
    where: {
      teacherId_classId_courseId: {
        teacherId: teacher.id,
        classId: classRoom.id,
        courseId: course.id,
      },
    },
    update: {},
    create: { teacherId: teacher.id, classId: classRoom.id, courseId: course.id },
    select: { id: true },
  });

  console.log("ADMIN_TOKEN=211 TEACHER_TOKEN=213 PARENT_TOKEN=212");
  console.log("seed_ok", { schoolId: school.id, classId: classRoom.id, courseId: course.id, termId: term.id });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
