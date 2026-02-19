import { NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function POST() {
  // deterministic test users used by jest e2e specs
  const passwordHash = 'dev'; // tests just need consistent seed; auth impl may hash/compare differently
  const school = await prisma.school.upsert({
    where: { id: 'test-school' },
    update: {},
    create: { id: 'test-school', name: 'Test School' } as any,
  });

  const teacherEmail = 'teacher1@classmate.app';
  const parentEmail = 'parent1@classmate.app';
  const studentEmail = 'student1@classmate.app';

  // create/update users with roles
  const teacherUser = await prisma.user.upsert({
    where: { email: teacherEmail },
    update: { role: 'TEACHER' as any, schoolId: school.id, passwordHash } as any,
    create: { email: teacherEmail, fullName: 'Teacher 1', role: 'TEACHER' as any, schoolId: school.id, passwordHash } as any,
  });

  const parentUser = await prisma.user.upsert({
    where: { email: parentEmail },
    update: { role: 'PARENT' as any, schoolId: school.id, passwordHash } as any,
    create: { email: parentEmail, fullName: 'Parent 1', role: 'PARENT' as any, schoolId: school.id, passwordHash } as any,
  });

  const studentUser = await prisma.user.upsert({
    where: { email: studentEmail },
    update: { role: 'STUDENT' as any, schoolId: school.id, passwordHash } as any,
    create: { email: studentEmail, fullName: 'Student 1', role: 'STUDENT' as any, schoolId: school.id, passwordHash } as any,
  });

  // ensure Teacher/Student rows exist (best-effort, schema varies)
  const teacher = await prisma.teacher.upsert({
    where: { userId: teacherUser.id } as any,
    update: {},
    create: { userId: teacherUser.id } as any,
  });

  const student = await prisma.student.upsert({
    where: { userId: studentUser.id } as any,
    update: {},
    create: { userId: studentUser.id } as any,
  });

  return NextResponse.json(
    {
      ok: true,
      teacherEmail,
      parentEmail,
      studentEmail,
      password: 'dev',
      teacherId: (teacher as any)?.id,
      studentId: (student as any)?.id,
    },
    { status: 201 }
  );
}
