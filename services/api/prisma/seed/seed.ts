import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// bcrypt('dev') — same hash you used everywhere
const DEV_HASH =
  '$2b$10$H7.AsBWceEadamuN6ixp0OW2nnNDVGCCnBt3xbPNDMbrct43neDhe';

function ymdInJerusalem(date = new Date()): string {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Jerusalem',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(date);
}

function utcMidnightFromYmd(ymd: string): Date {
  return new Date(`${ymd}T00:00:00.000Z`);
}

async function main() {
  console.log('seed: start');

  // ---- Users ----
  const admin = await prisma.user.upsert({
    where: { email: 'admin@classmate.app' },
    update: { name: 'Admin', password: DEV_HASH },
    create: {
      email: 'admin@classmate.app',
      name: 'Admin',
      password: DEV_HASH,
    },
  });

  const teacher = await prisma.user.upsert({
    where: { email: 'teacher1@classmate.app' },
    update: { name: 'Teacher One', password: DEV_HASH },
    create: {
      email: 'teacher1@classmate.app',
      name: 'Teacher One',
      password: DEV_HASH,
    },
  });

  const student = await prisma.user.upsert({
    where: { email: 'student1@classmate.app' },
    update: { name: 'Student One', password: DEV_HASH },
    create: {
      email: 'student1@classmate.app',
      name: 'Student One',
      password: DEV_HASH,
    },
  });

  const parent = await prisma.user.upsert({
    where: { email: 'parent1@classmate.app' },
    update: { name: 'Parent One', password: DEV_HASH },
    create: {
      email: 'parent1@classmate.app',
      name: 'Parent One',
      password: DEV_HASH,
    },
  });

  // ---- Roles ----
  const roleUpserts = [
    { userId: admin.id, role: 'ADMIN' as any },
    { userId: teacher.id, role: 'TEACHER' as any },
    { userId: student.id, role: 'STUDENT' as any },
    { userId: parent.id, role: 'PARENT' as any },
  ];

  for (const r of roleUpserts) {
    await prisma.userRole.upsert({
      where: { userId_role: { userId: r.userId, role: r.role } },
      update: {},
      create: { userId: r.userId, role: r.role },
    });
  }

  // ---- Cohort ----
  const cohort = await prisma.cohort.upsert({
    where: { name: '10th-1' },
    update: { grade: 10 },
    create: { name: '10th-1', grade: 10 },
  });

  // ---- StudentProfile ----
  await prisma.studentProfile.upsert({
    where: { userId: student.id },
    update: { cohortId: cohort.id, englishLevel: 3, mathLevel: 3 },
    create: {
      userId: student.id,
      cohortId: cohort.id,
      englishLevel: 3,
      mathLevel: 3,
    },
  });

  // ---- Parent-child link (approved) ----
  // If your schema uses (parentId, childId) unique, this upsert will work.
  // If it doesn't, createMany + skipDuplicates still works (fallback).
  try {
    await prisma.parentChild.upsert({
      where: {
        parentId_childId: { parentId: parent.id, childId: student.id },
      } as any,
      update: { status: 'APPROVED' as any },
      create: {
        parentId: parent.id,
        childId: student.id,
        status: 'APPROVED' as any,
      } as any,
    });
  } catch {
    await prisma.parentChild.createMany({
      data: [
        {
          parentId: parent.id,
          childId: student.id,
          status: 'APPROVED' as any,
        } as any,
      ],
      skipDuplicates: true,
    });
  }
  // ---- Courses ----
  const upsertCourseByName = async (name: string, subject: string) => {
    const existing = await prisma.course.findFirst({
      where: { name, cohortId: cohort.id },
      select: { id: true },
    });

    if (existing?.id) {
      return prisma.course.update({
        where: { id: existing.id },
        data: { subject, teacherId: teacher.id, cohortId: cohort.id },
      });
    }

    return prisma.course.create({
      data: {
        name,
        subject,
        teacherId: teacher.id,
        cohortId: cohort.id,
      },
    });
  };

  const math = await upsertCourseByName("Math - 10th-1", "Math");
  const arabic = await upsertCourseByName("Arabic - 10th-1", "Arabic");

  // ---- Schedule template: Sun(0)–Thu(4), periods 1–3, period 2 Arabic else Math ----
  const slots: { cohortId: string; dayOfWeek: number; period: number; courseId: string }[] =
    [];
  for (let d = 0; d <= 4; d++) {
    for (let p = 1; p <= 3; p++) {
      slots.push({
        cohortId: cohort.id,
        dayOfWeek: d,
        period: p,
        courseId: p === 2 ? arabic.id : math.id,
      });
    }
  }

  for (const s of slots) {
    await prisma.scheduleSlot.upsert({
      where: {
        cohortId_dayOfWeek_period: {
          cohortId: s.cohortId,
          dayOfWeek: s.dayOfWeek,
          period: s.period,
        },
      },
      update: { courseId: s.courseId },
      create: s,
    });
  }

  // ---- Today override: period 2 => null (free period) ----
  const todayYmd = ymdInJerusalem(new Date());
  const todayUtcMidnight = utcMidnightFromYmd(todayYmd);

  await prisma.scheduleOverride.upsert({
    where: {
      cohortId_date_period: {
        cohortId: cohort.id,
        date: todayUtcMidnight,
        period: 2,
      },
    },
    update: { courseId: null },
    create: { cohortId: cohort.id, date: todayUtcMidnight, period: 2, courseId: null },
  });

  console.log('seed: done');
  console.log(
    JSON.stringify(
      {
        cohortId: cohort.id,
        adminEmail: admin.email,
        teacherEmail: teacher.email,
        studentEmail: student.email,
        parentEmail: parent.email,
        todayYmd,
      },
      null,
      2,
    ),
  );
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
