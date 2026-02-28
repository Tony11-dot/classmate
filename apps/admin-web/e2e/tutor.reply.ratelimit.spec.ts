import { test, expect } from '@playwright/test';
import { seededStudentApi, API } from './helpers/tutorApi';

test('tutor reply rate-limit kicks in', async () => {
  test.skip(process.env.CI === '1');

  const { ctx } = await seededStudentApi();

  const sess = await ctx.post(`${API}/tutor/sessions`, {
    data: { subject: 'MATH', title: 'RL' },
  });

  if (!sess.ok()) {
    const text = await sess.text().catch(() => '');
    throw new Error(`create session failed ${sess.status()}: ${text}`);
  }

  const id = (await sess.json()).session.id;

  let lastStatus = 0;
  let lastBody = '';

  for (let i = 0; i < 30; i++) {
    const r = await ctx.post(`${API}/tutor/sessions/${id}/reply`, {
      data: { content: 'hi' },
    });

    lastStatus = r.status();
    lastBody = await r.text().catch(() => '');

    if (lastStatus === 429) break;
  }

  if (lastStatus !== 429) {
    throw new Error(`expected 429 but got ${lastStatus}: ${lastBody}`);
  }

  await ctx.dispose();
});
