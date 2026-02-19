import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Roles baseline (adjust if your schema differs)
  const roles = ['STUDENT', 'TEACHER', 'PARENT', 'ADMIN'] as const;

  // If you have a Role model/table:
  // await Promise.all(roles.map((role) => prisma.role.upsert({
  //   where: { role },
  //   update: {},
  //   create: { role },
  // })));

  // If roles are created via User.roles relation only, keep this file for future expansions.

  // Example admin user (optional, only if env provides it)
  const email = process.env.SEED_ADMIN_EMAIL?.trim();
  const password = process.env.SEED_ADMIN_PASSWORD?.trim();
  const name = process.env.SEED_ADMIN_NAME?.trim() || 'Admin';

  // If you already have register flow + hashing utilities, prefer calling AuthService;
  // otherwise keep seed minimal to avoid duplicating auth logic.

  if (email && password) {
    const existing = await prisma.user.findUnique({ where: { email }, include: { roles: true } });
    if (!existing) {
      // NOTE: this assumes prisma.user has fields: email, name, password and roles relation create.
      // If your schema differs, adjust.
      const user = await prisma.user.create({
        data: {
          email,
          name,
          password, // dev-only seed; in prod use a hashed password or remove this block
          roles: { create: [{ role: 'ADMIN' }] },
        },
      });
      console.log('Seeded admin:', user.email);
    } else {
      console.log('Admin already exists:', existing.email);
    }
  } else {
    console.log('Skipping admin seed (missing SEED_ADMIN_EMAIL/SEED_ADMIN_PASSWORD)');
  }
}

main()
  .then(async () => prisma.$disconnect())
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
