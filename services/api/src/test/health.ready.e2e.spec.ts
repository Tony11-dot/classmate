import { createTestApp } from './test.util';

describe('health/ready endpoints (e2e)', () => {
  it('GET /api/health returns ok', async () => {
    const { http, close } = await createTestApp();
    await http.get('/api/health').expect(200);
    await close();
  });

  it('GET /api/ready returns ok (db reachable)', async () => {
    const { http, close } = await createTestApp();
    await http.get('/api/ready').expect(200);
    await close();
  });
});
