import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('seed: start');

  // TODO: create admin/teacher/student/parent, cohort, courses, schedule template, etc.

  console.log('seed: done');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
