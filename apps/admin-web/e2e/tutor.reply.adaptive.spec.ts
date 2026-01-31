import { test, expect, request } from '@playwright/test';



import { expectOk } from './helpers/httpAssert';
import { seededStudentApi, API } from './helpers/tutorApi';
test('tutor reply adapts using brain/profile and includes mini-quiz', async () => {
  const { seed, ctx } = await seededStudentApi();

  // Create a session (auto-picks character if needed)
  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH', title: 'Adaptive test' } });
  await expectOk(s, 's');
  const sj = await s.json();
  const sessionId = sj.session?.id;
  expect(sessionId).toBeTruthy();

  // Ask something that should trigger “derivatives”
  const r = await ctx.post(`${API}/tutor/sessions/${sessionId}/reply`, {
    data: { content: 'Explain derivatives in a simple way. Then give me practice.' },
  });
  await expectOk(r, 'r');
  const json = await r.json();

  const assistant = String(json.assistantMessage?.content ?? '');
  expect(assistant.length).toBeGreaterThan(20);

  // Must mention bagrut-level + have mini-quiz bullets
  expect(assistant.toLowerCase()).toContain('bagrut');
  expect(assistant.toLowerCase()).toContain('mini');
  expect(assistant).toContain('- Mini');

  await ctx.dispose();
});
