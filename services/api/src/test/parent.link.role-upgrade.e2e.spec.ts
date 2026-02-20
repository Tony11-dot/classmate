import request from 'supertest';
import { createTestApp } from './helpers/app';

describe('parent link upgrades role (e2e)', () => {
  it('parent gets PARENT role after linking', async () => {
    const t = await createTestApp();
    const http = request(t.app.getHttpServer());

        const seed = await http.post('/api/test/seed/admin-web').send({});
    expect([200,201]).toContain(seed.status);

    const cohortId = seed.body.cohortId;
    expect(cohortId).toBeTruthy();

    const teacherEmail =
      seed.body?.teacherEmail ??
      seed.body?.teacher?.email ??
      seed.body?.teacherUser?.email ??
      seed.body?.teacher_account?.email ??
      seed.body?.emailTeacher ??
      '';

    const teacherPassword =
      seed.body?.teacherPassword ??
      seed.body?.teacher?.password ??
      seed.body?.teacherUser?.password ??
      seed.body?.teacher_account?.password ??
      seed.body?.passwordTeacher ??
      seed.body?.password ??
      'Password123!';

    expect(teacherEmail).toBeTruthy();
    expect(teacherPassword).toBeTruthy();

    const tlogin = await http.post('/api/auth/login').send({
      email: teacherEmail,
      password: teacherPassword,
    });

    expect([200, 201]).toContain(tlogin.status);

        const tkn = tlogin.body?.accessToken ?? tlogin.body?.token;
    expect(tkn).toBeTruthy();

    const adminEmail =
      seed.body?.adminEmail ??
      seed.body?.admin?.email ??
      seed.body?.adminUser?.email ??
      seed.body?.admin_account?.email ??
      seed.body?.emailAdmin ??
      seed.body?.email ??
      teacherEmail;

    const adminPassword =
      seed.body?.adminPassword ??
      seed.body?.admin?.password ??
      seed.body?.adminUser?.password ??
      seed.body?.admin_account?.password ??
      seed.body?.passwordAdmin ??
      seed.body?.password ??
      teacherPassword;

    let adminToken = tkn;
    if (adminEmail && adminPassword) {
      const alogin = await http.post('/api/auth/login').send({ email: adminEmail, password: adminPassword });
      expect([200, 201]).toContain(alogin.status);
      adminToken = alogin.body?.accessToken ?? alogin.body?.token ?? adminToken;
    }
    expect(adminToken).toBeTruthy();
  



    // Generate join-code
    const jc = await http
          .post('/api/teacher/cohorts/join-code')
          .set('Authorization', `Bearer ${tkn}`)
          .send({ cohortId, expiresInHours: 24, length: 6 });
    
        expect([200, 201]).toContain(jc.status);
const joinCode = String(jc.body?.code ?? '').trim();
        expect(joinCode2).toBeTruthy();
const jc2 = await http.post('/api/admin/cohorts/join-code')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ cohortId, expiresInHours: 24, length: 6 });

    const joinCode2 = String(jc2.body.code).trim();

    // Register student
    const studentEmail = `student+${Date.now()}@classmate.app`;

    const studentEmail2 = `student+${Date.now()}@classmate.app`;

    await http.post('/api/auth/register').send({
      name: 'Student',
      email: studentEmail,
      password: 'Password123!',
    });

    const slogin = await http.post('/api/auth/login').send({
      email: studentEmail2,
      password: 'Password123!',
    });

    const studentToken = slogin.body?.accessToken ?? slogin.body?.token;

    // Onboard
    const onboard = await http.post('/api/student/onboard')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ cohortId, joinCode, englishLevel: 3, mathLevel: 3 });
    expect(onboard.status).toBe(201);

    // Generate parent link code
    const plc = await http.post('/api/student/parent-link-code')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({});

    const parentCode = plc.body.code;

    // Register parent
    const parentEmail = `parent+${Date.now()}@classmate.app`;

    await http.post('/api/auth/register').send({
      name: 'Parent',
      email: parentEmail,
      password: 'Password123!',
    });

    const plogin = await http.post('/api/auth/login').send({
      email: parentEmail,
      password: 'Password123!',
    });

    const parentToken = plogin.body?.accessToken ?? plogin.body?.token;

    // Link parent
    const link = await http.post('/api/parent/link')
      .set('Authorization', `Bearer ${parentToken}`)
      .send({ code: parentCode });

    expect([200,201]).toContain(link.status);

    const relog = await http.post('/api/auth/login').send({
      email: parentEmail,
      password: 'Password123!',
    });

    const roles = (relog.body?.user?.roles ?? relog.body?.roles ?? []) as any[];
    const role =
      (relog.body?.user?.role ?? relog.body?.role ?? relog.body?.user?.type ?? relog.body?.type ?? null) as any;

    const norm = (x: any) => String(x ?? '').toUpperCase().trim();
    const roleSet = new Set<string>([...roles.map(norm), norm(role)].filter(Boolean));

    expect(Array.from(roleSet)).toContain('PARENT');

    await t.close();
  });
});
