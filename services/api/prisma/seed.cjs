const { PrismaClient, Role } = require('@prisma/client');
const bcrypt = require('bcrypt');

const prisma = new PrismaClient();

async function main() {
  await prisma.user.deleteMany({ where: { email: 'admin@classmate.app' } });

  const hashed = await bcrypt.hash('admin123', 10);

  const admin = await prisma.user.create({
    data: {
      email: 'admin@classmate.app',
      password: hashed,
      name: 'Admin',
      roles: { create: [{ role: Role.ADMIN }] },
    },
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
