import { test, expect, request } from '@playwright/test';



import { expectOk } from './helpers/httpAssert';
import { seededStudentApi, API } from './helpers/tutorApi';
async function makeReply(ctx: any, subject: string, prompt: string) {
  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject, title: `Snap ${subject}` } });
  await expectOk(s, 's');
  const sj = await s.json();
  const sessionId = String(sj.session?.id ?? '');
  expect(sessionId).toBeTruthy();

  const r = await ctx.post(`${API}/tutor/sessions/${sessionId}/reply`, { data: { content: prompt } });
  await expectOk(r, 'r');
  const json = await r.json();
  return String(json.assistantMessage?.content ?? '');
}

test('snapshot: math derivatives reply', async () => {
  const { seed, ctx } = await seededStudentApi();

  const text = await makeReply(ctx, 'MATH', 'Explain derivatives simply. Then give a mini-quiz.');
  expect(text).toMatchSnapshot('tutor.reply.math.derivatives.txt');
});

test('snapshot: physics kinematics reply', async () => {
  const { seed, ctx } = await seededStudentApi();

  const text = await makeReply(ctx, 'PHYSICS', 'Explain constant acceleration and give a mini-quiz.');
  expect(text).toMatchSnapshot('tutor.reply.physics.kinematics.txt');
});
