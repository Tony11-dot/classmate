import { defineConfig, devices } from '@playwright/test';

const WEB = process.env.WEB_BASE || 'http://127.0.0.1:3001';

export default defineConfig({
  testDir: './e2e',
  reporter: [['html', { open: 'never' }], ['list']],
  retries: 0,
  timeout: 60_000,

  use: {
    baseURL: WEB,
    trace: 'on',
    screenshot: 'only-on-failure',
    video: 'on',
  },

  // ❌ NO webServer block at all
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
});
