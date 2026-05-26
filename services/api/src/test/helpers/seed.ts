import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function seedTeacherWithCohort(email: string) {
  const teacher = await prisma.user.findUnique({ where: { email } });
  if (!teacher) throw new Error(`Teacher not found: ${email}`);

  const cohort = await prisma.cohort.create({
    data: { name: `E2E Cohort ${Date.now()}`, grade: 10, grades: [10] },
    select: { id: true },
  });

  const slot = await prisma.scheduleSlot.create({
    data: { teacherId: teacher.id, dayOfWeek: 1, period: 1 },
  });
  await prisma.scheduleSlotCohort.create({ data: { slotId: slot.id, cohortId: cohort.id } });

  const stamp = Date.now();
  const student = await prisma.user.create({
    data: {
      email: `student1+e2e-${stamp}@classmate.app`,
      username: `student1e2e${stamp}`,
      password: teacher.password,
      name: 'Student One',
      roles: { create: [{ role: 'STUDENT' }] },
      studentProfile: {
        create: { cohort: { connect: { id: cohort.id } }, englishLevel: 3, mathLevel: 3 },
      },
    },
    select: { id: true },
  });

  return { cohortId: cohort.id, studentId: student.id };
}
