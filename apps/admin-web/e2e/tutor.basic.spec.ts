import { test, expect, request } from '@playwright/test';



import { expectOk } from './helpers/httpAssert';
import { seededStudentApi, API } from './helpers/tutorApi';
test('student can create tutor session and send message', async () => {
  const { seed, ctx } = await seededStudentApi();

  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH' } });
  await expectOk(s, 's');
  const sj = await s.json();
  expect(sj.session?.id).toBeTruthy();

  const m = await ctx.post(`${API}/tutor/sessions/${sj.session.id}/messages`, {
    data: { role: 'USER', content: 'What is a derivative?' },
  });
  await expectOk(m, 'm');

  const get = await ctx.get(`${API}/tutor/sessions/${sj.session.id}`);
  await expectOk(get, 'get');
  const json = await get.json();
  expect(Array.isArray(json.messages)).toBeTruthy();
  expect(json.messages.length).toBe(1);

  await ctx.dispose();
});
