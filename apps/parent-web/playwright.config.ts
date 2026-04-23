import { defineConfig } from '@playwright/test';

const API_BASE =
  process.env.API_BASE ||
  process.env.NEXT_PUBLIC_API_BASE_URL ||
  process.env.NEXT_PUBLIC_API_BASE ||
  'http://127.0.0.1:3001';
const API_ORIGIN = API_BASE.replace(/\/api\/?$/, '');

export default defineConfig({
  testDir: './tests',
  globalSetup: './tests/global-setup.ts',
  use: {
    baseURL: 'http://localhost:3004',
    storageState: './.playwright/.auth/parent.json',
  },
  webServer: [
    {
      command: 'cd /Users/tonyaboud/Dev/classmate/services/api && ENABLE_E2E_SEED=1 pnpm dev',
      url: `${API_ORIGIN}/health`,
      reuseExistingServer: true,
      timeout: 120_000,
    },
    {
      command: 'cd /Users/tonyaboud/Dev/classmate/apps/parent-web && pnpm dev',
      url: 'http://localhost:3004',
      reuseExistingServer: true,
      timeout: 120_000,
    },
  ],
});
