// REPLACE ENTIRE FILE WITH THIS (services/api/prisma/seed.ts)
import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  // delete admin if exists
  await prisma.user.deleteMany({
    where: { email: 'admin@classmate.app' },
  });

  const hashed = await bcrypt.hash('admin123', 10);

  const admin = await prisma.user.create({
    data: {
      email: 'admin@classmate.app',
      password: hashed,
      name: 'Admin',
      roles: {
        create: [{ role: 'ADMIN' }],
      },
    },
  });

  console.log('Seeded admin:', admin.email);
}

main()
  .catch(console.error)
  .finally(async () => {
    await prisma.$disconnect();
  });