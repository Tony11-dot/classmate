import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  use: {
    baseURL: process.env.WEB_BASE || 'http://localhost:3001',
  },
  webServer: {
    command: 'pnpm dev',
    url: process.env.WEB_BASE || 'http://localhost:3001',
    reuseExistingServer: true,
    timeout: 120_000,
  },
});
