"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
async function main() {
    const roles = ['STUDENT', 'TEACHER', 'PARENT', 'ADMIN'];
    const email = process.env.SEED_ADMIN_EMAIL?.trim();
    const password = process.env.SEED_ADMIN_PASSWORD?.trim();
    const name = process.env.SEED_ADMIN_NAME?.trim() || 'Admin';
    if (email && password) {
        const existing = await prisma.user.findUnique({ where: { email }, include: { roles: true } });
        if (!existing) {
            const user = await prisma.user.create({
                data: {
                    email,
                    name,
                    password,
                    roles: { create: [{ role: 'ADMIN' }] },
                },
            });
            console.log('Seeded admin:', user.email);
        }
        else {
            console.log('Admin already exists:', existing.email);
        }
    }
    else {
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
//# sourceMappingURL=seed.js.map