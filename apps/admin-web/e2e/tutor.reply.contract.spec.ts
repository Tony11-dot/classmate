import { test, expect, request } from '@playwright/test';



import { expectOk } from './helpers/httpAssert';
import { seededStudentApi, API } from './helpers/tutorApi';
test('POST /tutor/sessions/:id/reply returns stable contract', async () => {
  const { seed, ctx } = await seededStudentApi();

  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH', title: 'Contract test' } });
  await expectOk(s, 's');
  const sj = await s.json();
  const sessionId = String(sj.session?.id ?? '');
  expect(sessionId).toBeTruthy();

  const r = await ctx.post(`${API}/tutor/sessions/${sessionId}/reply`, {
    data: { content: 'Explain derivatives simply and give a mini quiz.' },
  });
  await expectOk(r, 'r');
  const json = await r.json();

  // top-level
  expect(json.ok).toBeTruthy();

  // message objects exist
  expect(json.userMessage?.id).toBeTruthy();
  expect(json.userMessage?.role).toBe('USER');
  expect(String(json.userMessage?.content ?? '').length).toBeGreaterThan(0);

  expect(json.assistantMessage?.id).toBeTruthy();
  expect(json.assistantMessage?.role).toBe('ASSISTANT');
  expect(String(json.assistantMessage?.content ?? '').length).toBeGreaterThan(20);

  // stable conventions in content
  const content = String(json.assistantMessage?.content ?? '').toLowerCase();
  expect(content).toContain('bagrut');
  expect(content).toContain('mini-quiz');

  await ctx.dispose();
});
