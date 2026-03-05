const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const now = new Date();

  const cohortId = 'dev-cohort-7a';
  const courseId = 'dev-math';
  const teacherId = 'dev-teacher';
  const studentId = 'dev-student';

  // cohort
  await prisma.cohort.upsert({
    where: { id: cohortId },
    update: { name: '7A', grade: 7 },
    create: { id: cohortId, name: '7A', grade: 7 },
  });

  // course
  await prisma.course.upsert({
    where: { id: courseId },
    update: { name: 'Math', subject: 'MATH', cohortId, teacherId },
    create: { id: courseId, name: 'Math', subject: 'MATH', cohortId, teacherId },
  });

  // student profile (required fields)
  const spFields = Object.keys(prisma.studentProfile.fields ?? {});
  const createSP = { userId: studentId, cohortId, englishLevel: 4 };
  const updateSP = { cohortId, englishLevel: 4 };

  // if schema requires mathLevel too, set it
  // (we detect by trying a create in a transaction; if it fails, we'll retry with mathLevel)
  try {
    await prisma.studentProfile.upsert({
      where: { userId: studentId },
      update: updateSP,
      create: createSP,
    });
  } catch (e) {
    const msg = String(e?.message ?? e);
    if (msg.includes('mathLevel') || msg.includes('Argument `mathLevel` is missing')) {
      await prisma.studentProfile.upsert({
        where: { userId: studentId },
        update: { ...updateSP, mathLevel: 5 },
        create: { ...createSP, mathLevel: 5 },
      });
    } else {
      throw e;
    }
  }

  // enrollment (ignore dup)
  try {
    await prisma.enrollment.create({ data: { userId: studentId, courseId } });
  } catch (_) {}

  // material
  await prisma.classroomMaterial.upsert({
    where: { id: 'dev-mat-1' },
    update: {
      title: 'Chapter 1 Notes',
      description: 'PDF notes for Chapter 1',
      url: 'https://example.com/ch1.pdf',
      mime: 'application/pdf',
      createdBy: teacherId,
    },
    create: {
      id: 'dev-mat-1',
      courseId,
      title: 'Chapter 1 Notes',
      description: 'PDF notes for Chapter 1',
      url: 'https://example.com/ch1.pdf',
      mime: 'application/pdf',
      createdBy: teacherId,
    },
  });

  // meeting
  await prisma.classroomMeeting.upsert({
    where: { id: 'dev-meet-1' },
    update: {
      title: 'Review Session',
      startsAt: new Date(now.getTime() + 2 * 60 * 60 * 1000),
      endsAt: new Date(now.getTime() + 3 * 60 * 60 * 1000),
      link: 'https://zoom.us/j/123456789',
      createdBy: teacherId,
    },
    create: {
      id: 'dev-meet-1',
      courseId,
      title: 'Review Session',
      startsAt: new Date(now.getTime() + 2 * 60 * 60 * 1000),
      endsAt: new Date(now.getTime() + 3 * 60 * 60 * 1000),
      link: 'https://zoom.us/j/123456789',
      createdBy: teacherId,
    },
  });

  // assignment
  await prisma.classroomAssignment.upsert({
    where: { id: 'dev-asg-1' },
    update: {
      title: 'HW 1',
      body: 'Solve questions 1-10',
      dueAt: new Date(now.getTime() + 48 * 60 * 60 * 1000),
      createdBy: teacherId,
    },
    create: {
      id: 'dev-asg-1',
      courseId,
      title: 'HW 1',
      body: 'Solve questions 1-10',
      dueAt: new Date(now.getTime() + 48 * 60 * 60 * 1000),
      createdBy: teacherId,
    },
  });

  // chat messages
  const existing = await prisma.classroomMessage.findFirst({ where: { courseId } });
  if (!existing) {
    await prisma.classroomMessage.createMany({
      data: [
        {
          courseId,
          senderUserId: teacherId,
          kind: 'TEXT',
          text: 'Welcome to Math class 👋',
        },
        {
          courseId,
          senderUserId: studentId,
          kind: 'TEXT',
          text: 'Thanks! Where are the notes?',
        },
      ],
    });
  }

  console.log('OK: classroom tabs seeded');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
