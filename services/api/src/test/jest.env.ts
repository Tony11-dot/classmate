import path from 'node:path';
import fs from 'node:fs';
import dotenv from 'dotenv';

const envPath = path.resolve(__dirname, '../../.env.test');
if (fs.existsSync(envPath)) {
  dotenv.config({ path: envPath, quiet: true });
}

// CI exports DATABASE_URL already; keep it.
// But if CI's DATABASE_URL is masked/empty, ensure it's set to something.
process.env.NODE_ENV = process.env.NODE_ENV ?? 'test';
process.env.PORT = process.env.PORT ?? '3001';
// Auth guards only honor the dev bypass when this flag is explicitly set
// (see auth/dev-bypass.ts). Tests use real JWTs, but keep the historical
// "test env = role checks relaxed" behavior so existing specs stay green.
process.env.DEV_AUTH_BYPASS = process.env.DEV_AUTH_BYPASS ?? '1';
