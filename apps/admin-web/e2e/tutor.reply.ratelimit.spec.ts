import { test, expect, request } from '@playwright/test';

import { expectOk } from './helpers/httpAssert';
import { seededStudentApi, API } from './helpers/tutorApi';

test('tutor reply rate-limit kicks in', async () => {
  test.skip(process.env.CI === '1');
  const { seed, ctx } = await seededStudentApi();

  const sess = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH', title: 'RL' } });
  const id = (await sess.json()).session.id;

  let lastOk = true;
  for (let i=0;i<20;i++) {
    const r = await ctx.post(`${API}/tutor/sessions/${id}/reply`, { data: { content: 'hi' } });
    lastOk = r.ok();
    if (!lastOk) break;
  }
  expect(lastOk).toBeFalsy();
  await ctx.dispose();
});
