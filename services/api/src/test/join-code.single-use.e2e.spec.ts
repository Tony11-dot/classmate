import request from 'supertest';
import { createTestApp } from './helpers/app';

describe('cohort join-code is single-use (e2e)', () => {
  it('e2e', async () => {
    const t = await createTestApp();
    const http = request(t.app.getHttpServer());

    const seed = await http.post('/api/test/seed/admin-web').send({});

    if (first.status !== 201) {
      // eslint-disable-next-line no-console
      console.log('JOIN1', first.status, first.body, first.text);
    }
    expect(first.status).toBe(201);

    const secondEmail = `student2+${Date.now()}@classmate.app`;
    const reg2 = await http.post('/api/auth/register').send({ cohortId: seed.body.cohortId, code: joinCode, joinCode: joinCode, englishLevel: 3, mathLevel: 3 });

    expect([400, 401, 403]).toContain(second.status);

    await t.close();
  });
});
