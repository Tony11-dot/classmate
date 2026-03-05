import { PrismaClient } from "@prisma/client"

const prisma = new PrismaClient()

async function main() {

  const cohort = await prisma.cohort.upsert({
    where: { id: "dev-cohort" },
    update: {},
    create: {
      id: "dev-cohort",
      name: "Grade 10A",
      grade: 10
    }
  })

  const user = await prisma.user.upsert({
    where: { email: "dev@student.com" },
    update: {},
    create: {
      id: "dev-student",
      name: "Dev Student",
      email: "dev@student.com",
      password: "dev-password",
      roles: {
        create: {
          role: "STUDENT"
        }
      }
    }
  })

  const student = await prisma.studentProfile.upsert({
    where: { userId: user.id },
    update: {},
    create: {
      englishLevel: 5,
      mathLevel: 5,
      user: {
        connect: { id: user.id }
      },
      cohort: {
        connect: { id: cohort.id }
      }
    }
  })

  const course = await prisma.course.upsert({
    where: { id: "math-course" },
    update: {},
    create: {
      id: "math-course",
      name: "Math",
      subject: "MATH"
    }
  })

  await prisma.enrollment.upsert({
    where: {
      courseId_studentId: {
        courseId: course.id,
        studentId: student.userId
      }
    },
    update: {},
    create: {
      courseId: course.id,
      studentId: student.userId
    }
  })

  await prisma.scheduleSlot.createMany({
    data: [
      {
        courseId: course.id,
        cohortId: cohort.id,
        dayOfWeek: 1,
        period: 1,      },
      {
        courseId: course.id,
        cohortId: cohort.id,
        dayOfWeek: 1,
        period: 2,      }
    ],
    skipDuplicates: true
  })

  console.log("DEV DATA SEEDED")
}

main().finally(() => prisma.$disconnect())
