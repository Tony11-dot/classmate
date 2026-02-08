import { test, expect, request } from '@playwright/test';

import { expectOk } from './helpers/httpAssert';
import { seededStudentApi, API } from './helpers/tutorApi';

test('createSession auto-creates default tutor characters when none exist (@serial)', async () => {
  const { seed, ctx } = await seededStudentApi();

  const wipeCtx = await request.newContext();
  const wipe = await wipeCtx.post(`${API}/test/seed/clear-tutor-characters`, {
    data: { cohortId: seed.cohortId },
  });
  await expectOk(wipe, 'wipe');
  await wipeCtx.dispose();

  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH' } });
  await expectOk(s, 's');

  const sj = await s.json();
  expect(sj.session?.id).toBeTruthy();
  expect(sj.session?.characterId).toBeTruthy();

  await ctx.dispose();
});