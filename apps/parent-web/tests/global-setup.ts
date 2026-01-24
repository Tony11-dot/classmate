import fs from 'fs';
import path from 'path';
import { request } from '@playwright/test';

const API_BASE = process.env.API_BASE || 'http://127.0.0.1:3000';
const TOKEN_KEY = 'parent_token';

export default async function globalSetup() {
  const runId =
    process.env.PW_RUN_ID ||
    `${Date.now()}-${Math.random().toString(16).slice(2)}`;

  const ctx = await request.newContext({ baseURL: API_BASE });

  // seed isolated parent
  const seedRes = await ctx.post('/api/test/seed/parent-web', { data: { runId } });
  if (!seedRes.ok()) {
    const t = await seedRes.text();
    throw new Error(`seed parent-web failed: ${seedRes.status()} ${t}`);
  }
  const seed = await seedRes.json();

  // login for token
  const loginRes = await ctx.post('/api/auth/login', {
    data: { email: seed.email, password: seed.password },
  });
  if (!loginRes.ok()) {
    const t = await loginRes.text();
    throw new Error(`login failed: ${loginRes.status()} ${t}`);
  }
  const login = await loginRes.json();
  const token = login.token;
  if (!token) throw new Error('login did not return token');

  await ctx.dispose();

  // write storageState with the token in localStorage for http://127.0.0.1:3000
  const authDir = path.join(process.cwd(), '.playwright', '.auth');
  fs.mkdirSync(authDir, { recursive: true });

  const storagePath = path.join(authDir, 'parent.json');
  const origin = API_BASE.replace(/\/$/, '');

  const storageState = {
    cookies: [],
    origins: [
      {
        origin,
        localStorage: [{ name: TOKEN_KEY, value: token }],
      },
    ],
  };

  fs.writeFileSync(storagePath, JSON.stringify(storageState, null, 2));
  console.log(`✅ parent-web storageState written: ${storagePath} (runId=${runId})`);
}
