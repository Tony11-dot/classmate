const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');

(async () => {
  const prisma = new PrismaClient();
  const hash = await bcrypt.hash('admin123', 10);

  await prisma.user.update({
    where: { email: 'admin@classmate.app' },
    data: { password: hash },
  });

  console.log('✅ Admin password reset to admin123');
  await prisma.$disconnect();
})();
