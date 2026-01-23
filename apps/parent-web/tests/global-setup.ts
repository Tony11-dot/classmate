import fs from 'node:fs';
import path from 'node:path';
import { request, type FullConfig } from '@playwright/test';

const API_BASE = process.env.API_BASE || 'http://127.0.0.1:3000';
const WEB_BASE = process.env.WEB_BASE || 'http://localhost:3004';
const TOKEN_KEY = 'parent_token';

export default async function globalSetup(_config: FullConfig) {
  const outDir = path.join(__dirname, '.auth');
  const outFile = path.join(outDir, 'parent.json');
  fs.mkdirSync(outDir, { recursive: true });

  const ctx = await request.newContext({ baseURL: API_BASE });

  // 1) Seed data
  const seed = await ctx.post('/api/test/seed/admin-web');
  if (!seed.ok()) {
    throw new Error(`Seed failed: ${seed.status()} ${await seed.text()}`);
  }

  // 2) Login as parent
  const login = await ctx.post('/api/auth/login', {
    data: { email: 'parent1@classmate.app', password: 'dev' },
  });

  if (!login.ok()) {
    throw new Error(`Login failed: ${login.status()} ${await login.text()}`);
  }

  const json = await login.json();
  const token = json?.token;

  if (!token || typeof token !== 'string' || token.length < 20) {
    throw new Error(`No token returned from login. Got: ${JSON.stringify(json)}`);
  }

  // 3) Write storageState with parent_token in localStorage for your app origin
  const storageState = {
    cookies: [],
    origins: [
      {
        origin: WEB_BASE,
        localStorage: [{ name: TOKEN_KEY, value: token }],
      },
    ],
  };

  fs.writeFileSync(outFile, JSON.stringify(storageState, null, 2));
  console.log(`✅ Wrote storageState: ${outFile}`);
}
