import { test, expect, request } from '@playwright/test';



import { expectOk } from './helpers/httpAssert';
import { seededStudentApi, API } from './helpers/tutorApi';
test('student can rebuild brain snapshot and tutor reply reflects it', async () => {
  const { seed, ctx } = await seededStudentApi();

  const rebuild = await ctx.post(`${API}/tutor/me/brain/rebuild`, { data: {} });
  await expectOk(rebuild, 'rebuild');
  const bj = await rebuild.json();
  expect(bj.snapshot?.id).toBeTruthy();
  expect(bj.snapshot?.metrics).toBeTruthy();

  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH' } });
  await expectOk(s, 's');
  const sj = await s.json();
  expect(sj.session?.id).toBeTruthy();

  const r = await ctx.post(`${API}/tutor/sessions/${sj.session.id}/reply`, {
    data: { content: 'Explain derivative at Bagrut level.' },
  });
  await expectOk(r, 'r');
  const rj = await r.json();
  expect(rj.assistantMessage?.content).toContain('Mini-quiz');

  await ctx.dispose();
});
