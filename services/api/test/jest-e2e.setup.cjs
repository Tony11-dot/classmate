// Runs in each e2e worker before its test file.
// DB schema push is handled once in globalSetup (jest-e2e.global-setup.cjs).
//
// Auth guards only honor the dev bypass when DEV_AUTH_BYPASS is explicitly set
// (see src/auth/dev-bypass.ts). globalSetup runs in a separate process, so the
// flag must be set here, inside the worker, to take effect for the tests.
process.env.DEV_AUTH_BYPASS = process.env.DEV_AUTH_BYPASS ?? '1';
