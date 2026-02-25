import request from 'supertest';
import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { AppModule } from '../../src/app.module';
import { createTestApp } from '../../src/test/helpers/app';
import { PrismaClient } from '@prisma/client';

describe('Solutions cursor pagination', () => {
  let app: INestApplication;
  let prisma: PrismaClient;
  let token: string;

  beforeAll(async () => {
    prisma = new PrismaClient();

    const modRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = modRef.createNestApplication();
    app.setGlobalPrefix('api');
    await app.init();

    // seed admin-web
    await request(app.getHttpServer()).post('/api/test/seed/admin-web').expect(201);

    // login
    const login = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: 'admin1@classmate.app', password: 'dev' })
      .expect(201);

    token = login.body.token;
    expect(typeof token).toBe('string');
    expect(token.length).toBeGreaterThan(50);
  });

  afterAll(async () => {
    await app?.close();
    await prisma?.$disconnect();
  });

  it('bad cursor returns 400', async () => {
    const res = await request(app.getHttpServer())
      .get('/api/solutions?limit=2&cursor=badcursor')
      .set('Authorization', `Bearer ${token}`)
      .expect(400);

    expect(String(res.body?.message || '')).toContain('Invalid cursor');
  });

  it('same createdAt does not overlap between page1/page2', async () => {
    // create 6 rows
    const ids: string[] = [];
    for (let i = 1; i <= 6; i++) {
      const r = await request(app.getHttpServer())
        .post('/api/solutions')
        .set('Authorization', `Bearer ${token}`)
        .send({
          subject: 'math',
          sourceType: 'bagrut',
          sourceName: 'same-createdAt',
          page: 1,
          questionNumber: String(i),
          body: `seed-${i}`,
        })
        .expect(201);

      ids.push(r.body.id);
    }

    // force same createdAt
    const ts = new Date('2026-02-25T14:00:00.000Z');
    await prisma.solution.updateMany({ where: { id: { in: ids } }, data: { createdAt: ts } });

    const p1 = await request(app.getHttpServer())
      .get('/api/solutions?limit=3&sourceName=same-createdAt')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    const c1 = p1.body.nextCursor as string;
    expect(typeof c1).toBe('string');
    expect(c1.includes('|')).toBeTruthy();

    const p2 = await request(app.getHttpServer())
      .get('/api/solutions')
      .query({ limit: 3, sourceName: 'same-createdAt', cursor: c1 })
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    const p1Ids = new Set((p1.body.items as any[]).map(x => x.id));
    const overlap = (p2.body.items as any[]).map((x: any) => x.id).filter((id: string) => p1Ids.has(id));
    expect(overlap).toEqual([]);

    // cleanup
    await prisma.solution.deleteMany({ where: { id: { in: ids } } });
  });
});
