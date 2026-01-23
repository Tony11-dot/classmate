import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  globalSetup: './tests/global-setup.ts',
  use: {
    baseURL: 'http://localhost:3004',
    storageState: './tests/.auth/parent.json',
  },
  webServer: {
    command: 'pnpm dev',
    url: 'http://localhost:3004',
    reuseExistingServer: true,
    timeout: 120_000,
  },
});
