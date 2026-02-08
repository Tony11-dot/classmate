import { test, expect, request } from '@playwright/test';



import { expectOk } from './helpers/httpAssert';
import { seededStudentApi, API } from './helpers/tutorApi';
test('GET /tutor/sessions can filter by characterId', async () => {
  const { seed, ctx } = await seededStudentApi();

  expect(seed.mathTutorId).toBeTruthy();
  expect(seed.physicsTutorId).toBeTruthy();

  // Create two sessions with explicit characters (deterministic)
  const s1 = await ctx.post(`${API}/tutor/sessions`, {
    data: { characterId: seed.mathTutorId, title: 'Math session' },
  });
  await expectOk(s1, 's1');
  const s1j = await s1.json();
  expect(s1j.session?.id).toBeTruthy();
  expect(s1j.session?.characterId).toBe(seed.mathTutorId);

  const s2 = await ctx.post(`${API}/tutor/sessions`, {
    data: { characterId: seed.physicsTutorId, title: 'Physics session' },
  });
  await expectOk(s2, 's2');
  const s2j = await s2.json();
  expect(s2j.session?.id).toBeTruthy();
  expect(s2j.session?.characterId).toBe(seed.physicsTutorId);

  // Filter by math tutor id
  const res = await ctx.get(`${API}/tutor/sessions?characterId=${encodeURIComponent(seed.mathTutorId)}`);
  await expectOk(res, 'res');
  const json = await res.json();

  expect(Array.isArray(json.sessions)).toBeTruthy();
  expect(json.sessions.length).toBeGreaterThan(0);

  // All returned sessions must match the filter
  for (const row of json.sessions) {
    expect(row.characterId).toBe(seed.mathTutorId);
  }

  await ctx.dispose();
});
