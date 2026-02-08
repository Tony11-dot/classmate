import { test, expect, request } from '@playwright/test';





import { expectOk } from './helpers/httpAssert';
import { seededStudentApi, API } from './helpers/tutorApi';
test('reply cache hits on repeated prompt', async () => {
  const { seed, ctx } = await seededStudentApi();

  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH', title: 'Cache hit' } });
  await expectOk(s, 's');
  const sid = (await s.json()).session.id as string;

  const prompt = 'Explain derivatives simply and give a mini-quiz.';

  const r1 = await ctx.post(`${API}/tutor/sessions/${sid}/reply`, { data: { content: prompt } });
  await expectOk(r1, 'r1');
  const t1 = String((await r1.json()).assistantMessage?.content ?? '');

  const r2 = await ctx.post(`${API}/tutor/sessions/${sid}/reply`, { data: { content: prompt } });
  await expectOk(r2, 'r2');
  const t2 = String((await r2.json()).assistantMessage?.content ?? '');

  // cache hit should produce identical deterministic output
  expect(t2).toBe(t1);

  await ctx.dispose();
});
