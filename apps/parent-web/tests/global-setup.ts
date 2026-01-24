import fs from 'fs';
import path from 'path';
import { request } from '@playwright/test';

const API_BASE = process.env.API_BASE || 'http://127.0.0.1:3000';
const TOKEN_KEY = 'parent_token';

async function sleep(ms: number) {
  await new Promise((r) => setTimeout(r, ms));
}

async function waitForApi(ctx: any) {
  const healthPaths = ['/api/health', '/health', '/api/healthz', '/healthz'];
  for (let i = 0; i < 200; i++) {
    for (const p of healthPaths) {
      try {
        const r = await ctx.get(p);
        if (r.ok()) {
          const t = await r.text().catch(() => '');
          if (!t || t.includes('"ok":true') || t.includes('ok')) return;
          // if it returns something else but 200, still treat as up
          return;
        }
      } catch {}
    }
    await sleep(200);
  }
  throw new Error('API never became healthy');
}

async function seedParent(ctx: any, runId: string) {
  // try both: with /api prefix and without (controller is /test/seed)
  const seedPaths = ['/api/test/seed/parent-web', '/test/seed/parent-web'];

  let lastErr = '';
  for (const p of seedPaths) {
    try {
      const r = await ctx.post(p, { data: { runId } });
      if (r.ok()) return await r.json();
      lastErr = `${p} -> ${r.status()} ${await r.text().catch(() => '')}`;
    } catch (e: any) {
      lastErr = `${p} -> ${e?.message || String(e)}`;
    }
  }
  throw new Error('seed parent-web failed: ' + lastErr);
}

export default async function globalSetup() {
  const runId =
    process.env.PW_RUN_ID ||
    `${Date.now()}-${Math.random().toString(16).slice(2)}`;

  const ctx = await request.newContext({ baseURL: API_BASE });

  await waitForApi(ctx);

  // 1) seed isolated parent
  const seed = await seedParent(ctx, runId);

  // 2) login for token (auth is under /api/auth/login in your API)
  const loginRes = await ctx.post('/api/auth/login', {
    data: { email: seed.email, password: seed.password },
  });
  if (!loginRes.ok()) {
    const t = await loginRes.text().catch(() => '');
    throw new Error(`login failed: ${loginRes.status()} ${t}`);
  }
  const login = await loginRes.json();
  const token = login.token;
  if (!token) throw new Error('login did not return token');

  await ctx.dispose();

  // 3) Write storageState with parent_token in localStorage for your app origin
  const outDir = path.join(process.cwd(), '.playwright', '.auth');
  fs.mkdirSync(outDir, { recursive: true });
  const outFile = path.join(outDir, 'parent.json');

  const storageState = {
    cookies: [],
    origins: [
      {
        // MUST match parent-web baseURL origin so Playwright applies localStorage
        origin: 'http://localhost:3004',
        localStorage: [{ name: TOKEN_KEY, value: token }],
      },
    ],
  };

  fs.writeFileSync(outFile, JSON.stringify(storageState, null, 2));
  console.log(`✅ Wrote storageState: ${outFile} (runId=${runId}, email=${seed.email})`);
}
