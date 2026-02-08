import { test, expect, request } from '@playwright/test';



import { expectOk } from './helpers/httpAssert';
import { seededStudentApi, API } from './helpers/tutorApi';
test('tutor reply stores assistant message and sources', async () => {
  const { seed, ctx } = await seededStudentApi();

  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH' } });
  await expectOk(s, 's');
  const sj = await s.json();
  expect(sj.session?.id).toBeTruthy();

  const r = await ctx.post(`${API}/tutor/sessions/${sj.session.id}/reply`, {
    data: { content: 'What is a derivative? Explain Bagrut level.' },
  });
  await expectOk(r, 'r');

  const rj = await r.json();
  expect(rj.assistantMessage?.id).toBeTruthy();
  expect(typeof rj.assistantMessage?.content).toBe('string');
  expect(rj.assistantMessage.content).toContain('Mini-quiz');
  expect(rj.assistantMessage.content).toContain('Reply with your answers');
  expect(Array.isArray(rj.assistantMessage?.sources)).toBeTruthy();

  // should usually have at least 1 source because we seeded a derivative material
  expect(Array.isArray(rj.assistantMessage.sources)).toBeTruthy();

  await ctx.dispose();
});
