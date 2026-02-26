import { test, expect, request } from '@playwright/test';



import { expectOk } from './helpers/httpAssert';
import { seededStudentApi, API } from './helpers/tutorApi';
test('student can open multiple tutor chats across characters', async () => {
  const { seed, ctx } = await seededStudentApi();

  const s1 = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH', characterId: seed.mathTutorId } });
  await expectOk(s1, 's1');
  const j1 = await s1.json();

  const s2 = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'PHYSICS', characterId: seed.physicsTutorId } });
  await expectOk(s2, 's2');
  const j2 = await s2.json();

  const list = await ctx.get(`${API}/tutor/sessions`);
  await expectOk(list, 'list');
  const lj = await list.json();
  expect(lj.sessions.length).toBeGreaterThanOrEqual(2);

  expect(j1.session.characterId).toBeTruthy();
  expect(j2.session.characterId).toBeTruthy();

  await ctx.dispose();
});
