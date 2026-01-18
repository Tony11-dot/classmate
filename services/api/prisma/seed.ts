import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  // remove existing admin + roles (safe rerun)
  await prisma.userRole.deleteMany({
    where: { user: { email: 'admin@classmate.app' } },
  });
  await prisma.user.deleteMany({ where: { email: 'admin@classmate.app' } });

  const hashed = await bcrypt.hash('admin123', 10);

  const admin = await prisma.user.create({
    data: {
      email: 'admin@classmate.app',
      password: hashed,
      name: 'Admin',
      roles: {
        create: [{ role: 'ADMIN' }], // <- matches your UserRole.role enum Role
      },
    },
    select: { id: true, email: true },
  });

  console.log('Seeded admin:', admin.email);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
