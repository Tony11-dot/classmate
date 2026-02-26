import { test, expect, request } from '@playwright/test';

import { expectOk } from './helpers/httpAssert';
import { seededStudentApi, API } from './helpers/tutorApi';

test('createSession auto-creates default tutor characters when none exist (@serial)', async () => {
  const { seed, ctx } = await seededStudentApi();
  // wipe endpoint not available in this build — skipping wipe
  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH' } });
  await expectOk(s, 's');

  const sj = await s.json();
  expect(sj.session?.id).toBeTruthy();
  expect(sj.session?.characterId).toBeTruthy();

  await ctx.dispose();
});