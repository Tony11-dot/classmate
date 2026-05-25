// One-shot: create Apple App Review demo accounts in whichever DB
// DATABASE_URL points at. Idempotent — safe to re-run.
//
// Creates 4 users (student, parent, teacher, admin) on the first
// existing school (or "Apple Review School" if none exist), all with
// password `AppleReview2026!`.
//
// Run from services/api/:
//   railway run --service api node scripts/create-review-accounts.mjs
// or with prod DATABASE_URL exported:
//   DATABASE_URL=postgresql://... node scripts/create-review-accounts.mjs

import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();
const PASSWORD = 'AppleReview2026!';

const ACCOUNTS = [
  { email: 'apple-review@classmate.app',  name: 'Apple Reviewer (Student)', role: 'STUDENT' },
  { email: 'parent-review@classmate.app', name: 'Apple Reviewer (Parent)',  role: 'PARENT' },
  { email: 'teacher-review@classmate.app',name: 'Apple Reviewer (Teacher)', role: 'TEACHER' },
  { email: 'admin-review@classmate.app',  name: 'Apple Reviewer (Admin)',   role: 'ADMIN' },
];

async function main() {
  let school = await prisma.school.findFirst({ orderBy: { createdAt: 'asc' } });
  if (!school) {
    school = await prisma.school.create({
      data: { name: 'Apple Review School' },
    });
    console.log(`Created school: ${school.id} (${school.name})`);
  } else {
    console.log(`Using existing school: ${school.id} (${school.name})`);
  }

  const hash = await bcrypt.hash(PASSWORD, 10);
  const created = {};

  for (const a of ACCOUNTS) {
    const user = await prisma.user.upsert({
      where: { email: a.email },
      update: {
        name: a.name,
        password: hash,
        schoolId: school.id,
        status: 'ACTIVE',
      },
      create: {
        email: a.email,
        name: a.name,
        password: hash,
        schoolId: school.id,
        status: 'ACTIVE',
      },
    });
    await prisma.userRole.upsert({
      where: { userId_role: { userId: user.id, role: a.role } },
      update: {},
      create: { userId: user.id, role: a.role },
    });
    created[a.role] = user;
    console.log(`  ✓ ${a.role.padEnd(8)} ${a.email}`);
  }

  // Student profile + token balance so NOVA works for the reviewer
  await prisma.studentProfile.upsert({
    where: { userId: created.STUDENT.id },
    update: { grade: 11 },
    create: { userId: created.STUDENT.id, grade: 11 },
  });

  await prisma.tokenBalance.upsert({
    where: { userId: created.STUDENT.id },
    update: {
      planTokensRemaining: 5_000_000,
      topupTokensRemaining: 5_000_000,
    },
    create: {
      userId: created.STUDENT.id,
      planTokensRemaining: 5_000_000,
      topupTokensRemaining: 5_000_000,
    },
  });
  console.log(`  ✓ Student profile + 10M NOVA tokens granted`);

  // Link parent → student so parent app shows the child
  await prisma.parentChild.upsert({
    where: {
      parentId_childId: {
        parentId: created.PARENT.id,
        childId: created.STUDENT.id,
      },
    },
    update: { status: 'APPROVED' },
    create: {
      parentId: created.PARENT.id,
      childId: created.STUDENT.id,
      status: 'APPROVED',
    },
  });
  console.log(`  ✓ Parent ↔ Student linked (APPROVED)`);

  console.log('\nReview credentials (paste into App Review Information):');
  for (const a of ACCOUNTS) {
    console.log(`  ${a.role.padEnd(8)} ${a.email}  /  ${PASSWORD}`);
  }
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(() => prisma.$disconnect());
