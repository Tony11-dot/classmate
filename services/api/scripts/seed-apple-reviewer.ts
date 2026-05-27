/**
 * One-shot seed script to create the Apple App Review demo accounts.
 *
 * Apple's reviewer rejected v1.0 (Guideline 2.1) because they couldn't
 * log into the app. This creates a dedicated "Apple Review School"
 * isolated from real production data, with one account per role so the
 * reviewer can exercise every surface without touching real data.
 *
 * Run locally pointed at the production DATABASE_URL:
 *   cd services/api
 *   DATABASE_URL='postgres://...prod...' npx ts-node scripts/seed-apple-reviewer.ts
 *
 * Idempotent — if any account already exists, its password is reset
 * to the canonical value and the row is left in place. Safe to re-run
 * before every Apple resubmission.
 */
import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

const SCHOOL_NAME = 'Apple Review School';
const REVIEWER_DOMAIN = 'classmate.app';
// Single canonical password used for every reviewer account so the
// reviewer can copy-paste it into each role without bouncing between
// notes pages. NOT for real users — these accounts are demo-only.
const REVIEWER_PASSWORD = 'AppleReview2026!';

type RoleSeed = {
  role: 'ADMIN' | 'SECRETARY' | 'TEACHER' | 'STUDENT' | 'PARENT';
  email: string;
  username: string;
  fullName: string;
  grade?: number;
};

// The canonical reviewer account uses the exact email Apple already
// has on file from the previous (rejected) submission so resubmitting
// requires no metadata edit on Apple's side. The 4 secondary accounts
// give the reviewer access to every role surface without changing the
// primary credential.
const accounts: RoleSeed[] = [
  {
    role: 'ADMIN',
    email: `apple-review@${REVIEWER_DOMAIN}`,
    username: 'apple-review',
    fullName: 'Apple Review (Admin)',
  },
  {
    role: 'SECRETARY',
    email: `apple-review-secretary@${REVIEWER_DOMAIN}`,
    username: 'apple-review-secretary',
    fullName: 'Apple Review (Secretary)',
  },
  {
    role: 'TEACHER',
    email: `apple-review-teacher@${REVIEWER_DOMAIN}`,
    username: 'apple-review-teacher',
    fullName: 'Apple Review (Teacher)',
  },
  {
    role: 'STUDENT',
    email: `apple-review-student@${REVIEWER_DOMAIN}`,
    username: 'apple-review-student',
    fullName: 'Apple Review (Student)',
    grade: 9,
  },
  {
    role: 'PARENT',
    email: `apple-review-parent@${REVIEWER_DOMAIN}`,
    username: 'apple-review-parent',
    fullName: 'Apple Review (Parent)',
  },
];

async function ensureSchool(): Promise<string> {
  const existing = await prisma.school.findFirst({
    where: { name: SCHOOL_NAME },
    select: { id: true },
  });
  if (existing) return existing.id;
  const created = await prisma.school.create({
    data: {
      name: SCHOOL_NAME,
      minGrade: 5,
      maxGrade: 12,
    },
    select: { id: true },
  });
  return created.id;
}

async function upsertUser(schoolId: string, seed: RoleSeed) {
  const hash = await bcrypt.hash(REVIEWER_PASSWORD, 10);

  // Look up by email so re-runs always converge on the same row even
  // if the username got renamed in a prior pass.
  const existing = await prisma.user.findUnique({
    where: { email: seed.email },
    select: { id: true },
  });

  let userId: string;
  if (existing) {
    await prisma.user.update({
      where: { id: existing.id },
      data: {
        username: seed.username,
        password: hash,
        plainPassword: REVIEWER_PASSWORD,
        name: seed.fullName,
        nameEn: seed.fullName,
        schoolId,
        displayName: seed.fullName,
      },
    });
    userId = existing.id;
  } else {
    const created = await prisma.user.create({
      data: {
        email: seed.email,
        username: seed.username,
        password: hash,
        plainPassword: REVIEWER_PASSWORD,
        name: seed.fullName,
        nameEn: seed.fullName,
        schoolId,
        displayName: seed.fullName,
      },
      select: { id: true },
    });
    userId = created.id;
  }

  // Wipe & rewrite the role rows — the seed always owns this user's
  // role list, so a re-run after manual changes still produces a clean
  // single-role demo account.
  await prisma.userRole.deleteMany({ where: { userId } });
  await prisma.userRole.create({
    data: { userId, role: seed.role as any },
  });

  if (seed.role === 'STUDENT' && seed.grade != null) {
    await prisma.studentProfile.upsert({
      where: { userId },
      create: { userId, grade: seed.grade },
      update: { grade: seed.grade },
    });
  }

  return userId;
}

async function main() {
  const schoolId = await ensureSchool();
  console.log(`[seed] school id: ${schoolId} (${SCHOOL_NAME})`);

  for (const seed of accounts) {
    const id = await upsertUser(schoolId, seed);
    console.log(
      `[seed] ${seed.role.padEnd(9)} ${seed.username.padEnd(20)} ${seed.email}  (${id})`,
    );
  }

  console.log('\nPaste these into App Store Connect > App Review > Notes:');
  console.log('─'.repeat(72));
  console.log(`Password for every account: ${REVIEWER_PASSWORD}`);
  for (const seed of accounts) {
    console.log(
      `  ${seed.role.padEnd(9)} username: ${seed.username.padEnd(20)} (or: ${seed.email})`,
    );
  }
  console.log('─'.repeat(72));
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
