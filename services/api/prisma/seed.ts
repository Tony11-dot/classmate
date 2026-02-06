import { PrismaClient, Role } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  const email = 'admin@classmate.dev';
  const password = 'Admin123!';
  const name = 'Admin';

  const hashed = await bcrypt.hash(password, 10);

  const admin = await prisma.user.upsert({
    where: { email },
    update: {
      password: hashed,
      name,
    },
    create: {
      email,
      password: hashed,
      name,
    },
    select: { id: true, email: true },
  });

  // Ensure the ADMIN role exists for this user (idempotent)
  await prisma.userRole.upsert({
    where: { userId_role: { userId: admin.id, role: Role.ADMIN } },
    update: {},
    create: { userId: admin.id, role: Role.ADMIN },
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
