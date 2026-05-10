import { PrismaClient, TutorCharacterSubject } from '@prisma/client'
import * as bcrypt from 'bcrypt'

const prisma = new PrismaClient()

// dayOfWeek: 0=Sun 1=Mon 2=Tue 3=Wed 4=Thu 5=Fri 6=Sat
const WEEKDAYS = [1, 2, 3, 4, 5]

async function main() {
  // ── Tutor characters ───────────────────────────────────────────────────────
  await prisma.tutorCharacter.createMany({
    data: [
      { name: 'NOVA', subject: TutorCharacterSubject.GENERAL },
      { name: 'Dr. Maxwell', subject: TutorCharacterSubject.PHYSICS },
      { name: 'Euler', subject: TutorCharacterSubject.MATH },
    ],
    skipDuplicates: true,
  })

  // ── School ─────────────────────────────────────────────────────────────────
  const school = await (prisma as any).school.upsert({
    where: { id: 'dev-school' },
    update: { name: 'ClassMate Academy' },
    create: { id: 'dev-school', name: 'ClassMate Academy' },
  })
  console.log('School:', school.name)

  // ── Teachers ───────────────────────────────────────────────────────────────
  const teachers = [
    { email: 'rokny@classmate.app', name: 'Rokny Kawar', password: 'Rokny123' },
    { email: 'eman@classmate.app',  name: 'Eman Lahham', password: 'Eman123'  },
  ]

  const [rokny, eman] = await Promise.all(teachers.map(async (t) => {
    const hash = await bcrypt.hash(t.password, 10)
    const user = await prisma.user.upsert({
      where: { email: t.email },
      update: { name: t.name, password: hash, schoolId: school.id },
      create: { email: t.email, name: t.name, password: hash, schoolId: school.id },
    })
    await (prisma as any).userRole.upsert({
      where: { userId_role: { userId: user.id, role: 'TEACHER' } },
      update: {},
      create: { userId: user.id, role: 'TEACHER' },
    })
    console.log('Teacher:', t.email, '/', t.password)
    return user
  }))

  // ── Cohort ─────────────────────────────────────────────────────────────────
  const cohort = await (prisma as any).cohort.upsert({
    where: { name: 'Grade 10' },
    update: { grade: 10 },
    create: { name: 'Grade 10', grade: 10 },
  })

  // ── Courses (no students enrolled yet — testing the add-student flow) ──────
  const mathCourse = await prisma.course.upsert({
    where: { id: 'math-course' },
    update: { teacherId: rokny.id, cohortId: cohort.id, name: 'Math', subject: 'Math' },
    create: { id: 'math-course', name: 'Math', subject: 'Math', teacherId: rokny.id, cohortId: cohort.id },
  })
  const engCourse = await prisma.course.upsert({
    where: { id: 'eng-course' },
    update: { teacherId: eman.id, cohortId: cohort.id, name: 'English', subject: 'English' },
    create: { id: 'eng-course', name: 'English', subject: 'English', teacherId: eman.id, cohortId: cohort.id },
  })
  console.log('Courses: Math (Rokny), English (Eman)')

  // ── Schedule: 3 slots/day Mon–Fri ─────────────────────────────────────────
  // Period 1 = Math, Period 2 = English, Period 3 = Math
  for (const dow of WEEKDAYS) {
    await (prisma as any).scheduleSlot.upsert({
      where: { cohortId_dayOfWeek_period: { cohortId: cohort.id, dayOfWeek: dow, period: 1 } },
      update: { courseId: mathCourse.id },
      create: { cohortId: cohort.id, dayOfWeek: dow, period: 1, courseId: mathCourse.id },
    })
    await (prisma as any).scheduleSlot.upsert({
      where: { cohortId_dayOfWeek_period: { cohortId: cohort.id, dayOfWeek: dow, period: 2 } },
      update: { courseId: engCourse.id },
      create: { cohortId: cohort.id, dayOfWeek: dow, period: 2, courseId: engCourse.id },
    })
    await (prisma as any).scheduleSlot.upsert({
      where: { cohortId_dayOfWeek_period: { cohortId: cohort.id, dayOfWeek: dow, period: 3 } },
      update: { courseId: mathCourse.id },
      create: { cohortId: cohort.id, dayOfWeek: dow, period: 3, courseId: mathCourse.id },
    })
  }
  console.log('Schedule: 3 slots/day (Math P1, English P2, Math P3) Mon–Fri')

  // ── Students ───────────────────────────────────────────────────────────────
  const studentData = [
    { email: 'tony@classmate.app',   name: 'Tony Aboud',    password: 'Tony123'   },
    { email: 'sally@classmate.app',  name: 'Sally Ashkar',  password: 'Sally123'  },
    { email: 'mayar@classmate.app',  name: 'Mayar Awoayed', password: 'Mayar123'  },
    { email: 'joseph@classmate.app', name: 'Joseph Jabaly', password: 'Joseph123' },
  ]

  for (const sd of studentData) {
    const hash = await bcrypt.hash(sd.password, 10)
    const student = await prisma.user.upsert({
      where: { email: sd.email },
      update: { name: sd.name, password: hash, schoolId: school.id },
      create: { email: sd.email, name: sd.name, password: hash, schoolId: school.id },
    })
    await (prisma as any).userRole.upsert({
      where: { userId_role: { userId: student.id, role: 'STUDENT' } },
      update: {},
      create: { userId: student.id, role: 'STUDENT' },
    })
    await (prisma as any).studentProfile.upsert({
      where: { userId: student.id },
      update: { cohortId: cohort.id },
      create: { userId: student.id, cohortId: cohort.id, englishLevel: 3, mathLevel: 3 },
    })
    // NOT enrolling students in courses — test the add-student flow
    console.log('Student:', sd.email, '/', sd.password)
  }

  console.log('\n✅ Seed complete — ClassMate Academy')
  console.log('   Cohort: Grade 10 · 4 students (not enrolled yet)')
  console.log('   Math course: math-course (Rokny)')
  console.log('   English course: eng-course (Eman)')
}

main()
  .catch(e => { console.error(e); process.exit(1) })
  .finally(() => prisma.$disconnect())
