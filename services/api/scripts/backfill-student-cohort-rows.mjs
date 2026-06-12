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

// Pick the first connection string that actually has a host. Inside Railway
// the internal DATABASE_URL works; from a dev machine you must pass a reachable
// URL via BACKFILL_DATABASE_URL (e.g. an enabled TCP-proxy public URL), because
// `postgres.railway.internal` only resolves inside Railway's network and
// DATABASE_PUBLIC_URL is empty unless the Postgres TCP proxy is enabled.
function hasHost(u) {
  try {
    return !!new URL(u).hostname;
  } catch {
    return false;
  }
}
const url =
  [
    process.env.BACKFILL_DATABASE_URL,
    process.env.DATABASE_PUBLIC_URL,
    process.env.DATABASE_URL,
  ].find((u) => u && hasHost(u)) || process.env.DATABASE_URL;

const prisma = new PrismaClient(
  url ? { datasources: { db: { url } } } : undefined,
);

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
