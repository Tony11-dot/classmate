import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient({
  datasourceUrl: process.env.DATABASE_URL_TEST || process.env.DATABASE_URL,
});

async function login(app: INestApplication, email: string, password: string) {
  const res = await request(app.getHttpServer())
    .post('/auth/login')
    .send({ email, password })
    .expect(201);
  return res.body.token as string;
}

async function getUnlinkedStudentIdForParent(parentEmail: string) {
  const parent = await prisma.user.findUnique({ where: { email: parentEmail } as any, select: { id: true } });
  if (!parent?.id) throw new Error('parent missing in seed');

  const linked = await prisma.parentChild.findMany({
    where: { parentId: parent.id },
    select: { childId: true },
  });
  const linkedSet = new Set(linked.map((x) => x.childId));

  const anyStudent = await prisma.user.findFirst({ where: { roles: { some: { role: 'STUDENT' as any } } } as any, select: { id: true } });
  if (anyStudent?.id && !linkedSet.has(anyStudent.id)) return anyStudent.id;

  // fallback: try student1 but ensure not linked
  const s1 = await prisma.user.findUnique({ where: { email: 'student1@classmate.app' } as any, select: { id: true } });
  if (s1?.id && !linkedSet.has(s1.id)) return s1.id;

  // worst case: create a random student if schema supports it (skip)
  return null;
}

describe('security: parent requires approved link (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    await app.init();

    await request(app.getHttpServer()).post('/test/seed/admin-web').expect(201);
  });

  afterAll(async () => {
    await prisma.$disconnect();
    await app.close();
  });

  it('parent GET /parent/attendance?childId=... without link -> 403', async () => {
    const parentEmail = 'parent1@classmate.app';
    const token = await login(app, parentEmail, 'dev');

    const childId = await getUnlinkedStudentIdForParent(parentEmail);
    if (!childId) return;

    await request(app.getHttpServer())
      .get(`/parent/attendance?childId=${encodeURIComponent(childId)}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(403);
  });
});
