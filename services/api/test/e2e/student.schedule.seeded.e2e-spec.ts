import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../../src/app.module';
import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

function mustToken(body: any, label: string): string {
  const t = body?.accessToken ?? body?.token;
  if (typeof t !== 'string' || t.length < 10) {
    throw new Error(`${label}: missing token. body=` + JSON.stringify(body));
  }
  const parts = t.split('.');
  if (parts.length !== 3) {
    throw new Error(`${label}: token is not a JWT. token=` + t);
  }
  return t;
}

function ymdJerusalem(date = new Date()): string {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Jerusalem',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(date); // YYYY-MM-DD
}

function dowJerusalem(date = new Date()): number {
  const wk = new Intl.DateTimeFormat('en-US', {
    timeZone: 'Asia/Jerusalem',
    weekday: 'short',
  }).format(date);
  const map: Record<string, number> = {
    Sun: 0,
    Mon: 1,
    Tue: 2,
    Wed: 3,
    Thu: 4,
    Fri: 5,
    Sat: 6,
  };
  return map[wk] ?? 0;
}

describe('Student schedule (seeded)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const mod = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = mod.createNestApplication();
    app.setGlobalPrefix('api');
    await app.init();
  });

  afterAll(async () => {
    await app.close();
    await prisma.$disconnect();
  });

  it('student today schedule returns non-empty when seeded', async () => {
    // ---- Seed data directly (no admin endpoints, no admin JWT) ----
    const cohortName = `cohort_${Date.now()}`;
    const cohort = await prisma.cohort.create({
      data: { name: cohortName, grade: 10 },
      select: { id: true },
    });
    const cohortId = cohort.id;

    const course = await prisma.course.create({
      data: {
        name: 'Math',
        subject: 'Math',
        cohortId,
      },
      select: { id: true },
    });
    const courseId = course.id;

    // Join code (must match StudentService.onboard bcrypt.compare)
    const joinCodePlain = String(Math.floor(100000 + Math.random() * 900000)); // 6 digits
    const codeHash = await bcrypt.hash(joinCodePlain, 10);
    await prisma.cohortJoinCode.create({
      data: {
        cohortId,
        codeHash,
        active: true,
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
      },
    });

    // Schedule slot for TODAY period 1
    const dayOfWeek = dowJerusalem(new Date());
    await prisma.scheduleSlot.upsert({
      where: { cohortId_dayOfWeek_period: { cohortId, dayOfWeek, period: 1 } },
      update: { courseId },
      create: { cohortId, dayOfWeek, period: 1, courseId },
    });

    // ---- Real flow: student register -> login -> onboard -> fetch today ----
    const studentEmail = `student_${Date.now()}@classmate.app`;
    const studentPass = 'dev';

    await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({ email: studentEmail, password: studentPass, name: 'Student 1' })
      .expect(201);

    const studentLogin = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: studentEmail, password: studentPass })
      .expect(201);

    let studentToken = mustToken(studentLogin.body, 'studentLogin');

    // ensure STUDENT role exists for this user (JWT roles come from login payload)
    const studentUser = await prisma.user.findUnique({ where: { email: studentEmail } });
    if (!studentUser) throw new Error('student user not found after register');

    await prisma.userRole.upsert({
      where: { userId_role: { userId: studentUser.id, role: 'STUDENT' } },
      update: {},
      create: { userId: studentUser.id, role: 'STUDENT' },
    });

    // re-login so JWT includes STUDENT role
    const studentRelogin = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: studentEmail, password: studentPass })
      .expect(201);

    studentToken = mustToken(studentRelogin.body, 'studentRelogin');



    
    // sanity: token works on some authed route (pick one that exists in your app)
    // try /api/student/schedule/today (should be 400 "not onboarded" BEFORE onboard)
    const pre = await request(app.getHttpServer())
      .get('/api/student/schedule/today')
      .set('Authorization', `Bearer ${studentToken}`);

    const onboardRes = await request(app.getHttpServer())
      .post('/api/student/onboard')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        cohortId,
        joinCode: joinCodePlain,
        englishLevel: 3,
        mathLevel: 3,
      });

    expect(onboardRes.status).toBe(201);
const today = await request(app.getHttpServer())
      .get('/api/student/schedule/today')
      .set('Authorization', `Bearer ${studentToken}`)
      .expect(200);

    expect(Array.isArray(today.body)).toBe(true);
    expect(today.body.length).toBeGreaterThan(0);

    // Optional: if response includes "date", check it
    const todayYmd = ymdJerusalem(new Date());
    if (today.body?.[0]?.date) {
      expect(today.body[0].date).toBe(todayYmd);
    }
  });
});
