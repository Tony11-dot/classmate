import { test, expect, request } from '@playwright/test';



import { expectOk } from './helpers/httpAssert';
import { seededStudentApi, API } from './helpers/tutorApi';
test('tutor reply cache: second identical reply returns same content', async () => {
  const { seed, ctx } = await seededStudentApi();

  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH', title: 'Cache test' } });
  await expectOk(s, 's');
  const sj = await s.json();
  const sessionId = String(sj.session?.id ?? '');
  expect(sessionId).toBeTruthy();

  const prompt = 'Explain derivatives simply and give a mini-quiz.';
  const r1 = await ctx.post(`${API}/tutor/sessions/${sessionId}/reply`, { data: { content: prompt } });
  await expectOk(r1, 'r1');
  const j1 = await r1.json();
  const a1 = String(j1.assistantMessage?.content ?? '');
  expect(a1.length).toBeGreaterThan(20);

  const r2 = await ctx.post(`${API}/tutor/sessions/${sessionId}/reply`, { data: { content: prompt } });
  await expectOk(r2, 'r2');
  const j2 = await r2.json();
  const a2 = String(j2.assistantMessage?.content ?? '');
  expect(a2.length).toBeGreaterThan(20);

  expect(a2).toBe(a1);

  await ctx.dispose();
});
