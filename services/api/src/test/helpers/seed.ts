import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function seedTeacherWithCourse(email: string) {
  const teacher = await prisma.user.findUnique({
    where: { email },
  });

  if (!teacher) {
    throw new Error(`Teacher not found: ${email}`);
  }

  // 1) Create cohort (grade is REQUIRED)
  const cohort = await prisma.cohort.create({
    data: {
      name: `E2E Cohort ${Date.now()}`,
      grade: 10,
    },
    select: { id: true },
  });

  // 2) Create course linked to teacher + cohort
  const course = await prisma.course.create({
    data: {
      name: `Math 101 ${Date.now()}`,
      subject: 'MATH',
      teacher: { connect: { id: teacher.id } },
      cohort: { connect: { id: cohort.id } },
    },
    select: { id: true, cohortId: true },
  });

  // 3) Create student + student profile
  const student = await prisma.user.create({
    data: {
      email: `student1+e2e-${Date.now()}@classmate.app`,
      password: teacher.password,
      name: 'Student One',
      roles: { create: [{ role: 'STUDENT' }] },
      studentProfile: {
        create: {
          cohort: { connect: { id: cohort.id } },
          englishLevel: 3,
          mathLevel: 3,
        },
      },
    },
    select: { id: true },
  });

  // 4) Enroll student in course
  await prisma.enrollment.create({
    data: {
      course: { connect: { id: course.id } },
      student: { connect: { userId: student.id } },
    },
  });

  return {
    courseId: course.id,
    cohortId: cohort.id,
    studentId: student.id,
  };
}
