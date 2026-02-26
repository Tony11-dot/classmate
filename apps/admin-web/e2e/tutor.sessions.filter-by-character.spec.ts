import { test, expect, request } from '@playwright/test';



import { expectOk } from './helpers/httpAssert';
import { seededStudentApi, API } from './helpers/tutorApi';
async function getDefaultTutorIds(ctx: any) {
  const r = await ctx.get(`${API}/tutor/characters`);
  const j = await r.json();

  let list: any[] = [];
  if (Array.isArray(j)) list = j;
  else if (Array.isArray(j?.characters)) list = j.characters;
  else if (j?.characters && typeof j.characters === 'object') list = Object.values(j.characters);
  else if (j && typeof j === 'object') list = Object.values(j);

  const norm = (c: any) => String(c?.key ?? c?.slug ?? c?.name ?? '').toLowerCase();
  const math = list.find((c: any) => norm(c).includes('math')) ?? list[0];
  const physics = list.find((c: any) => norm(c).includes('physics')) ?? list[1] ?? list[0];

  return { mathId: math?.id, physicsId: physics?.id };
}

test('GET /tutor/sessions can filter by characterId', async () => {
  const { ctx } = await seededStudentApi();

  // create first session (no strict character assumption)
  const s1 = await ctx.post(`${API}/tutor/sessions`, {
    data: { title: 'Session A' },
  });
  await expectOk(s1, 's1');
  const j1 = await s1.json();
  const charId = j1.session?.characterId;
  expect(charId).toBeTruthy();

  // create second session same character (system default)
  const s2 = await ctx.post(`${API}/tutor/sessions`, {
    data: { title: 'Session B' },
  });
  await expectOk(s2, 's2');

  // filter by the discovered characterId
  const res = await ctx.get(`${API}/tutor/sessions?characterId=${encodeURIComponent(charId)}`);
  await expectOk(res, 'res');
  const json = await res.json();

  expect(Array.isArray(json.sessions)).toBeTruthy();
  for (const row of json.sessions) {
    expect(row.characterId).toBe(charId);
  }

  await ctx.dispose();
});
