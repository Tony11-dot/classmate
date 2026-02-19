import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaClient } from '@prisma/client';
import 'dotenv/config';
const prisma = new PrismaClient({ datasourceUrl: process.env.DATABASE_URL_TEST || process.env.DATABASE_URL });
function decodeJwtPayload(token: string): any {
  const part = token.split('.')[1] || '';
  const json = Buffer.from(part, 'base64url').toString('utf8');
  return JSON.parse(json);
}

async function seedApprovedParentChild(token: string, childId: string) {
  const payload = decodeJwtPayload(token);
  const parentId = payload?.sub || payload?.id;
  if (!parentId) throw new Error('Could not derive parentId from token payload');
  if (!childId) throw new Error('childId is required');

  // Ensure the row exists with APPROVED status
  // If schema has different unique constraints, findFirst+create is safest.
  const existing = await prisma.parentChild.findFirst({
    where: { parentId, childId },
    select: { id: true },
  });

  if (existing?.id) {
    await prisma.parentChild.update({
      where: { id: existing.id },
      data: { status: 'APPROVED' as any },
    });
  } else {
    await prisma.parentChild.create({
      data: { parentId, childId, status: 'APPROVED' as any },
    });
  }
}


async function login(app: INestApplication, email: string, password: string) {
  const res = await request(app.getHttpServer())
    .post('/auth/login')
    .send({ email, password })
    .expect(201);

  expect(res.body).toHaveProperty('token');
  return res.body.token as string;
}

describe('Parent attendance (e2e)', () => {
  console.log('DB URL:', process.env.DATABASE_URL_TEST || process.env.DATABASE_URL);
  afterAll(async () => { await prisma.$disconnect(); });

  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleRef.createNestApplication();
    await app.init();

    await request(app.getHttpServer())
      .post('/test/seed/admin-web')
      .expect(201);

  });

  afterAll(async () => {
    await app.close();
  });

  it('parent can fetch child attendance (approved link)', async () => {
    const token = await login(app, 'parent1@classmate.app', 'dev');

    const childId = '6c56edbc-d612-4c91-9073-bfe9986df4d0';

    
    await seedApprovedParentChild(token, childId);
const res = await request(app.getHttpServer())
      .get(`/parent/attendance?childId=${encodeURIComponent(childId)}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(res.body).toHaveProperty('ok', true);
    expect(Array.isArray(res.body.items)).toBe(true);
  });

  it('parent can fetch child attendance with from/to filters', async () => {
    const token = await login(app, 'parent1@classmate.app', 'dev');

    const childId = '6c56edbc-d612-4c91-9073-bfe9986df4d0';

    
    await seedApprovedParentChild(token, childId);
const res = await request(app.getHttpServer())
      .get(
        `/parent/attendance?childId=${encodeURIComponent(
          childId,
        )}&from=2026-01-01&to=2026-01-09`,
      )
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(res.body).toHaveProperty('ok', true);
    expect(res.body.from).toBe('2026-01-01');
    expect(res.body.to).toBe('2026-01-09');
    expect(Array.isArray(res.body.items)).toBe(true);
  });
});