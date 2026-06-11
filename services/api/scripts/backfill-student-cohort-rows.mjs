// Backfill StudentCohort join rows from the scalar studentProfile.cohortId.
//
// Why: every audience read path (exams / assignments / materials / meetings)
// resolves a student's cohorts from the StudentCohort join table. Students who
// onboarded via join code historically only had the scalar `cohortId` set on
// their profile (the join row was never created), so they missed all
// cohort-targeted content. `onboard` now creates the join row going forward;
// this script heals existing students.
//
// Safe + idempotent: only CREATES missing rows that the scalar already implies.
// It never deletes or reassigns. Run: `node scripts/backfill-student-cohort-rows.mjs`
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const profiles = await prisma.studentProfile.findMany({
    where: { cohortId: { not: null } },
    select: { userId: true, cohortId: true },
  });

  let created = 0;
  let alreadyPresent = 0;
  for (const p of profiles) {
    const existing = await prisma.studentCohort.findUnique({
      where: { studentId_cohortId: { studentId: p.userId, cohortId: p.cohortId } },
    });
    if (existing) {
      alreadyPresent += 1;
      continue;
    }
    await prisma.studentCohort.create({
      data: { studentId: p.userId, cohortId: p.cohortId },
    });
    created += 1;
  }

  console.log(
    `Backfill complete: ${created} StudentCohort row(s) created, ${alreadyPresent} already present, ${profiles.length} profiles scanned.`,
  );
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
